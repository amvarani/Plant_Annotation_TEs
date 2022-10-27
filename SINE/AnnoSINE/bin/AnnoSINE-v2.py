import time
import os
import math
import re
from collections import Counter
import argparse
from argparse import RawTextHelpFormatter
import matplotlib.pyplot as plt
import operator


print('Example: python3 AnnoSINE.py 2 ../Input_Files/test.fasta ../Output_Files')
parser = argparse.ArgumentParser(description="SINE Annotation Tool for Plant Genomes",
                                 formatter_class=RawTextHelpFormatter)

# positional arguments
parser.add_argument("mode", type=int,
                    help="[1 | 2 | 3]\n"
                    "Choose the running mode of the program.\n"
                    "\t1--Homology-based method;\n"
                    "\t2--Structure-based method;\n"
                    "\t3--Hybrid of homology-based and structure-based method.")
parser.add_argument("input_filename", type=str, help="input genome assembly path")
parser.add_argument("output_filename", type=str, help="output files path")

# optional arguments
#parser.add_argument("-evalue1", "--hmmer_evalue", type=float, default=1e-10,
                    #help="Expectation value threshold for saving hits of homology search (default: 1e-10)")
#parser.add_argument("-evalue2", "--blast_evalue", type=float, default=1e-10,
                    #help="Expectation value threshold for sequences alignment search (default: 1e-10)")
parser.add_argument("-l", "--length_factor", metavar='', type=float, default=0.3,
                    help="Threshold of the local alignment length relative to the the BLAST query length (default: 0.3)")
parser.add_argument("-c", "--copy_number_factor", metavar='', type=float, default=0.15,
                    help="Threshold of the copy number that determines the SINE boundary (default: 0.15)")
parser.add_argument("-s", "--shift",  metavar='', type=int, default=50,
                    help="Maximum threshold of the boundary shift (default: 50)")
parser.add_argument("-g", "--gap",  metavar='', type=int, default=10,
                    help="Maximum threshold of the truncated gap (default: 10)")
parser.add_argument("-minc", "--copy_number", metavar='', type=int, default=20,
                    help="Minimum threshold of the copy number for each element (default: 20)")
#parser.add_argument("-maxb", "--base_copy_number", type=int, default=1,
                    #help="Maximum threshold of copy number for the first and last base (default: 1)")
#parser.add_argument("-p", "--probability", type=float, default=0.5,
                    #help='Minimum of the length proportion of tandem repeat to element (default: 0.5)')
parser.add_argument("-b", "--boundary", metavar='', type=str, default='msa',
                    help="Output SINE seed boundaries based on TSD or MSA (default: msa)")
parser.add_argument("-f", "--figure", metavar='', type=str, default='y',
                    help="Output the SINE seed MSA figures and copy number profiles (y/n) (default: y)")
parser.add_argument("-r", "--non_redundant", metavar='', type=str, default='y',
                    help="Annotate SINE in the whole genome based on the non-redundant library (y/n) (default: y)")
parser.add_argument("-t", "--threads", metavar='', type=int, default=36,
                    help="Threads for each tools(default: 36)")
args = parser.parse_args()


def hmm_predict(genome_assembly_path,cpus):
    dir_hmm = os.listdir('../Family_Seq/')
    for num_dir_hmm in range(len(dir_hmm)):
        if dir_hmm[num_dir_hmm] != '.DS_Store':
            # Clear the content of exist output
            if os.path.exists('../Family_Seq/' + dir_hmm[num_dir_hmm] + '/' + dir_hmm[num_dir_hmm] + '.out'):
                clear_filename = '../Family_Seq/' + dir_hmm[num_dir_hmm] + '/' + dir_hmm[num_dir_hmm] + '.out'
                with open(clear_filename, "r+") as clear_f:
                    clear_f.seek(0)
                    clear_f.truncate()
            os.system(
                'nhmmer --cpu ' + str(cpus) + ' -o ../Family_Seq/' + dir_hmm[num_dir_hmm] + '/' + dir_hmm[num_dir_hmm] + '.out '
                + '../Family_Seq/' + dir_hmm[num_dir_hmm] + '/' + dir_hmm[num_dir_hmm] + '.hmm '
                + genome_assembly_path)


def read_genome_assembly(genome_assembly_path):
    # ============== Read genome sequences according to sequence ID ===============
    def parse_seq_id(seq_header):
        for b in range(len(seq_header)):
            return seq_header.split()[b][1:]

    with open(genome_assembly_path) as genome_f:
        genome_sequences = {}
        lines = genome_f.readlines()
        # buffer list to store SINE segments to be added to dict
        sequence_buffer = []
        for line in lines:
            if line[0] == '>':
                if len(sequence_buffer) > 0:
                    # has SINE segments in buffer to be added to dict
                    genome_sequences[seq_id] = ''.join(sequence_buffer)  # reset buffer
                    sequence_buffer = []  # reset buffer
                # parse new seq_id
                seq_id = parse_seq_id(line)
            else:
                sequence_buffer.append(line.strip().upper())
    if len(sequence_buffer) > 0:
        # add remaining SINE segments in buffer
        genome_sequences[seq_id] = ''.join(sequence_buffer)
        del sequence_buffer
    return genome_sequences


def process_hmm_output_1(out_file, threshold_hmm_e_value):
    # ============================ HMM prediction start and end annotation =======================
    hmm_predict_record_unsort = []
    hmm_predict_record_sort = []
    hmm_predict_family_number = 0
    with open('../Family_Seq/' + out_file) as predict_f:
        lines = predict_f.readlines()
        for line in lines[15:]:
            if 'inclusion threshold' in line or 'No hits detected' in line or line == '\n':
                break
            else:
                hmm_predict_record_unsort.append(line.split())
    if [] not in hmm_predict_record_unsort:
        out_data = sorted(hmm_predict_record_unsort, key=lambda x: int(x[4]))
        for i in range(len(out_data)):
            if float(out_data[i][0]) < threshold_hmm_e_value:
                if int(out_data[i][4]) < int(out_data[i][5]):
                    hmm_predict_record_sort.append({'start': int(out_data[i][4]) - 1,
                                                    'end': int(out_data[i][5]),
                                                    'e_value': float(out_data[i][0]),

                                                    'family': out_file.split('/', 1)[0],
                                                    'id': out_data[i][3],
                                                    'strand': '+'})
                    if float(out_data[i][0]) <= 1:
                        hmm_predict_family_number += 1
                else:
                    hmm_predict_record_sort.append({'start': int(out_data[i][5]) - 1,
                                                    'end': int(out_data[i][4]),
                                                    'e_value': float(out_data[i][0]),
                                                    'family': out_file.split('/', 1)[0],
                                                    'id': out_data[i][3],
                                                    'strand': 'C'})
                    if float(out_data[i][0]) <= 1:
                        hmm_predict_family_number += 1
    return hmm_predict_record_sort, hmm_predict_family_number


def merge_same_hmm_output(hmm_output_record):
    print('Merging the same hmm prediction ...')
    update_positions = []
    for num_record in hmm_output_record:
        add_pos = True
        for index in range(len(update_positions)):
            update_pos = update_positions[index]
            if num_record['id'] == update_pos['id'] and \
                    (num_record['start'] >= update_pos['start'] and num_record['end'] <= update_pos['end']) or \
                    (num_record['start'] <= update_pos['start'] and num_record['end'] > update_pos['end']) or \
                    (num_record['start'] < update_pos['start'] and num_record['end'] == update_pos['end']) or \
                    (((update_pos['start'] < num_record['start'] < update_pos['end'] < num_record['end'] and
                       abs(num_record['start'] - update_pos['end']) >= 0.5 * abs(
                                num_record['start'] - num_record['end'])) or
                      (num_record['start'] < update_pos['start'] < num_record['end'] < update_pos['end']) and
                      abs(update_pos['start'] - num_record['end']) >= 0.5 * abs(
                                num_record['start'] - num_record['end']))):
                if num_record['strand'] == update_pos['strand']:
                    add_pos = False
                    update_positions[index] = {'start': min(num_record['start'], update_pos['start']),
                                               'end': max(num_record['end'], update_pos['end']),
                                               'id': num_record['id'],
                                               'strand': num_record['strand'],
                                               'family': num_record['family'] + '/' + update_pos['family'],
                                               'e_value': num_record['e_value']}
                    break
        if add_pos:
            update_positions.append(num_record)
    return update_positions


def process_hmm_output_2(threshold_hmm_e_value):
    print('Processing the hmm prediction ...')
    family_count = {}
    family_name = []
    update_hmm_record = []
    dir_file = os.listdir('../Family_Seq/')
    for a in range(len(dir_file)):
        if dir_file[a] != '.DS_Store':
            list_pre = process_hmm_output_1(dir_file[a] + '/' + dir_file[a] + '.out', threshold_hmm_e_value)[0]
            for num_pre in range(len(list_pre)):
                if list_pre[num_pre]['e_value'] <= threshold_hmm_e_value:
                    family_name.append(dir_file[a])
                    if dir_file[a] not in family_count:
                        family_count[dir_file[a]] = 1
                    else:
                        family_count[dir_file[a]] += 1
            for num_return_broken in range(len(list_pre)):
                update_hmm_record.append(list_pre[num_return_broken])
    return update_hmm_record, family_name, family_count


def process_hmm_output_3(threshold_hmm_e_value, in_genome_assembly_path, pattern, out_genome_assembly_path):
    count = 0
    seq_ids = {}
    start = {}
    end = {}
    e_value = {}
    pre_strand = {}
    input_tsd_sequences = {}
    output_genome_sequence = read_genome_assembly(in_genome_assembly_path)
    update_hmm_record = process_hmm_output_2(threshold_hmm_e_value)[0]
    family_name = process_hmm_output_2(threshold_hmm_e_value)[1]
    family_count = process_hmm_output_2(threshold_hmm_e_value)[2]
    update_hmm_output = merge_same_hmm_output(update_hmm_record)

    for num_return_pos in range(len(update_hmm_output)):
        pre_num = count
        start[pre_num] = update_hmm_output[num_return_pos]['start']
        end[pre_num] = update_hmm_output[num_return_pos]['end']
        seq_ids[pre_num] = update_hmm_output[num_return_pos]['id']
        num_id = update_hmm_output[num_return_pos]['id']
        e_value[pre_num] = update_hmm_output[num_return_pos]['e_value']
        input_tsd_sequences[pre_num] = output_genome_sequence[num_id][update_hmm_output[num_return_pos]['start']-30:
                                                                      update_hmm_output[num_return_pos]['end']+50]
        pre_strand[pre_num] = update_hmm_output[num_return_pos]['strand']
        count += 1

    new_start = list(start.values())
    new_end = list(end.values())
    new_sequence_id = list(seq_ids.values())

    if pattern == 1 or pattern == 3:
        if os.path.exists(out_genome_assembly_path+'/Step1_extend_tsd_input_1.fa'):
            modify_text(out_genome_assembly_path+'/Step1_extend_tsd_input_1.fa')
        save_to_fna_1(out_genome_assembly_path+'/Step1_extend_tsd_input_1.fa', input_tsd_sequences, pre_strand,
                      new_sequence_id, 0, 0, new_start, new_end)


def merge_tsd_input(pattern, out_genome_assembly_path):
    if os.path.exists(out_genome_assembly_path+'/Step1_extend_tsd_input.fa'):
        modify_text(out_genome_assembly_path+'/Step1_extend_tsd_input.fa')
    if pattern == 1:
        with open(out_genome_assembly_path+'/Step1_extend_tsd_input_1.fa', 'r') as f1:
            lines1 = f1.readlines()
            lines = lines1
    if pattern == 2:
        with open(out_genome_assembly_path+'/Step1_extend_tsd_input_2.fa', 'r') as f2:
            lines2 = f2.readlines()
            lines = lines2
    elif pattern == 3:
        with open(out_genome_assembly_path+'/Step1_extend_tsd_input_1.fa', 'r') as f1:
            with open(out_genome_assembly_path+'/Step1_extend_tsd_input_2.fa', 'r') as f2:
                lines1 = f1.readlines()
                lines2 = f2.readlines()
                if pattern == 1:
                    lines = lines1
                elif pattern == 2:
                    lines = lines2
                elif pattern == 3:
                    lines = lines1+lines2
    with open(out_genome_assembly_path+'/Step1_extend_tsd_input.fa', 'w') as f3:
        for line in lines:
            if line[0] == '>':
                f3.write(line)
            else:
                f3. write(line)


def search_tsd(out_genome_assembly_path):
    os.system('cat '+ out_genome_assembly_path+'/Step1_extend_tsd_input.fa | sed "s#^N#ATCG#g" > '+out_genome_assembly_path+'/tmp.fa ; cp '+out_genome_assembly_path+'/tmp.fa '+out_genome_assembly_path+'/Step1_extend_tsd_input.fa')
    os.system('node ./TSD_Searcher.js '+out_genome_assembly_path)


def is_at_seq(seq, tolerance):
    """
    Test if a sequence consists with 'A' ('a') and 'T' ('t').
    Occurrence of other bases cannot be more than `tolerance`.

    :param seq: sequence to test
    :param tolerance: Maximum number of occurrence of other bases.

    :return: Whether the tested sequence matches the condition.
    """
    base_dict = Counter(seq.lower())
    if 'a' in base_dict:
        base_dict.pop('a')
    if 't' in base_dict:
        base_dict.pop('t')
    return sum(base_dict.values()) <= tolerance


def process_tsd_output(in_genome_assembly_path, out_genome_assembly_path):
    tsd_output_file = out_genome_assembly_path+'/Step1_extend_tsd_input.fa'
    title = []
    sequences = []
    hmm_start = []
    hmm_end = []
    hmm_id = []
    with open(tsd_output_file) as tsd_file:
        lines = tsd_file.readlines()
        hmm_tsd = []
        finder_tsd = []
        filename = out_genome_assembly_path+'/Step2_tsd.txt'
        for line in lines:
            if line[0] == '>':
                title.append(line)
                hmm_start.append(int(line.split()[2].split(':')[0]))
                hmm_end.append(int(line.split()[2].split(':')[1]))
                hmm_id.append(line.split()[0].replace('>', ''))
            else:
                sequences.append(line)
                hmm_tsd.append(len(line.split()[0]))

    hmm_pos = []
    record_tsd = []
    with open(filename) as f2:
        lines = f2.readlines()
        for line in lines:
            if line[0] != '>':
                hmm_pos.append(line.strip().split())
                if len(line) != 1:
                    left_tsd = line.split()[0]
                    right_tsd = line.split()[2]
                    if is_at_seq(left_tsd.replace('-', ''), 0) or is_at_seq(right_tsd.replace('-', ''), 0):
                        record_tsd.append(0)
                    else:
                        record_tsd.append(1)
                else:
                    record_tsd.append(0)

    starts = []
    ends = []
    tsd_info = []
    input_seq = []

    output_genome_sequence = read_genome_assembly(in_genome_assembly_path)
    for t in range(len(hmm_pos)):
        if record_tsd[t] == 0:
            tsd_info.append('tsd not exist')
            start = hmm_start[t] - 100
            end = hmm_end[t] + 100
            seq_id = hmm_id[t]

            input_seq.append(output_genome_sequence[seq_id][start:end])
            starts.append(hmm_start[t] + 30)
            ends.append(hmm_end[t] - 50)
        else:
            tsd_info.append(len(hmm_pos[t][0]))
            start = hmm_start[t] - 30 + int(hmm_pos[t][1].split('-')[1].replace(')', '')) - 100
            end = hmm_start[t] - 30 + int(hmm_pos[t][3].split('-')[0].replace('(', '')) + 100
            seq_id = hmm_id[t]

            input_seq.append(output_genome_sequence[seq_id][start:end])
            starts.append(
                hmm_start[t] - 30 + int(hmm_pos[t][1].split('-')[1].replace(')', '')))  # tsd boundary
            ends.append(hmm_start[t] - 30 + int(hmm_pos[t][3].split('-')[0].replace('(', '')))
    if os.path.exists(out_genome_assembly_path+'/Step2_tsd_output.fa'):
        modify_text(out_genome_assembly_path+'/Step2_tsd_output.fa')
    save_to_fna_2(out_genome_assembly_path+'/Step2_tsd_output.fa', input_seq, title, tsd_info, starts, ends)

    if os.path.exists(out_genome_assembly_path+'/Step2_extend_blast_input.fa'):
        modify_text(out_genome_assembly_path+'/Step2_extend_blast_input.fa')

    with open(out_genome_assembly_path+'/Step2_tsd_output.fa', 'r')as tsd_output_file:
        with open(out_genome_assembly_path+'/Step2_extend_blast_input.fa', 'w') as blast_input_file:
            flag = False
            for line in tsd_output_file:
                if line[0] == '>':
                    if 'tsd not exist' not in line.split('|')[1]:
                        flag = True
                    else:
                        flag = False
                if flag:
                    blast_input_file.write(line)


def modify_text(modify_name):
    with open(modify_name, "r+") as f:
        f.truncate()


def save_to_fna_1(filename, sequences, strands, ids, left_offset, right_offset, starts, ends):
    header = '>{} {} {}:{}\n'
    index = 0
    payload = []
    for seq in sequences:
        seq_header = header.format(ids[seq], strands[seq], starts[seq] - left_offset, ends[seq] + right_offset)
        payload.append(seq_header)
        payload.append(sequences[seq] + '\n')
        index += 1
    with open(filename, 'a') as file:
        file.writelines(payload)


def save_to_fna_2(filename, sequences, input_title, input_tsd, input_start, input_end):
    HEADER = '{}'.strip() + '|tsd_l:{}|tsd_s:{}|tsd_e:{}'.strip() + '\n'
    payload = []
    for seq in range(len(sequences)):
        seq_header = HEADER.format(input_title[seq].strip(), input_tsd[seq], input_start[seq], input_end[seq])
        payload.append(seq_header.strip() + '\n')
        payload.append(sequences[seq].strip() + '\n')
    with open(filename, 'a') as file:
        file.writelines(payload)


def multiple_sequence_alignment(e_value, in_genome_assembly_path, out_genome_assembly_path,cpus):
    print('BLAST againist the genome assembly ...')
    os.system('makeblastdb -dbtype nucl -in ' + in_genome_assembly_path + ' -out '+out_genome_assembly_path+'/genome ')
    os.system('blastn -query '+out_genome_assembly_path+'/Step2_extend_blast_input.fa '
              #'-subject ' + in_genome_assembly_path + ' '
              '-db '+out_genome_assembly_path+'/genome '
              '-out '+out_genome_assembly_path+'/Step3_blast_output.out '
              '-evalue ' + str(e_value) + ' '
              '-num_alignments 50000 '
              '-word_size 7 '
              '-gapopen 5 '
              '-gapextend 2 '
              '-penalty -3 '
              '-reward 2 '
              '-num_threads ' + str(cpus))


def process_blast_output_1(in_genome_assembly_path, factor_length, factor_copy, max_shift, max_gap, min_copy_number,
                           pos, out_genome_assembly_path, bound, figure):
    print('Processing the BLAST output ...')
    blast_out_filename = out_genome_assembly_path+'/Step2_extend_blast_input.fa'
    with open(blast_out_filename) as blast_input_file:
        lines = blast_input_file.readlines()
        previous_seq = []
        previous_start = []
        previous_end = []
        previous_id = []
        tsd_length = []
        tsd_bound_start = []
        tsd_bound_end = []
        sine_info = []
        for line in lines:
            if line[0] != '>':
                previous_seq.append(line)
            else:
                previous_start.append(int(line.split()[2].split('|')[0].split(':')[0]))
                previous_end.append(int(line.split()[2].split('|')[0].split(':')[1]))
                previous_id.append(line.split()[0].replace('>', ''))
                tsd_length.append(int(line.split('|')[1].split(':')[1]))
                tsd_bound_start.append(int(line.split('|')[2].split(':')[1]))
                tsd_bound_end.append(int(line.split('|')[3].split(':')[1]))
                sine_info.append(line)
    output_genome_sequence = read_genome_assembly(in_genome_assembly_path)
    # ================================ Read BLAST Output ==========================
    blast_inter = []
    length = []
    filename_1 = out_genome_assembly_path+'/Step3_blast_output.out'
    with open(filename_1) as blast_output_file_1:
        lines = blast_output_file_1.readlines()
        flag = False
        for line in lines:
            if 'Query= ' in line:
                flag = True
            if 'Length' in line and flag is True:
                l_length = int(line.replace('Length=', '').strip())
                length.append(l_length)
                flag = False
        start = None
        end = None
        count = -1
        for line in lines:
            if '>' in line:
                if start is not None and end is not None and seq_id is not None:
                    blast_inter[count].append({'start': start - 1,
                                               'end': end,
                                               'id': seq_id})
                start = None
                end = None
                #seq_id = line.split()[1]
                seq_id = line.split()[0]
            if 'Query= ' in line:
                if start is not None and end is not None and seq_id is not None:
                    blast_inter[count].append({'start': start - 1,
                                               'end': end,
                                               'id': seq_id})
                start = None
                end = None
                blast_inter.append([])
                count += 1

            if 'Query ' in line and start is None and end is None:
                start = int(line.split()[1])

            if 'Query ' in line:
                if '--' not in line.split()[-1]:
                    end = int(line.split()[-1])

            if 'Score = ' in line:
                if start is not None and end is not None and seq_id is not None:
                    blast_inter[count].append({'start': start - 1,
                                               'end': end,
                                               'id': seq_id})
                start = None
                end = None
        blast_inter[count].append({'start': start - 1,
                                   'end': end,
                                   'id': seq_id})
    blast_res_0 = []
    blast_res = []
    for num_blast in range(len(blast_inter)):
        threshold = factor_length * (length[num_blast] - 200)
        blast_res_0.append([])
        for seq in range(len(blast_inter[num_blast])):
            if seq == 0:
                blast_res_0[num_blast].append(blast_inter[num_blast][seq])
            start = blast_inter[num_blast][seq]['start']
            end = blast_inter[num_blast][seq]['end']
            seq_id = blast_inter[num_blast][seq]['id']
            if abs(end - start + 1) >= threshold:
                blast_res_0[num_blast].append(blast_inter[num_blast][seq])
    family_count = []
    for num_blast in range(len(blast_res_0)):
        family_count.append(len(blast_res_0[num_blast])-1)
        blast_res.append(blast_res_0[num_blast][1:])

    # ========================= Plot BLSAT Sequences Alignment ==============
    def plot_line(y, x1, x2):
        plt.hlines(y, x1, x2, linewidth=0.2)

    if figure == 'y':
        if not os.path.exists(out_genome_assembly_path+'/Figures'):
            os.makedirs(out_genome_assembly_path+'/Figures')
        for num in range(len(blast_res)):
            plt.yticks(fontsize=8)
            plt.xticks(fontsize=8)
            y_axis = len(blast_res[num])
            plt.ylabel('No. alignment', fontsize=8)
            plt.xlabel('No. base of each SINE', fontsize=8)
            for j in range(len(blast_res[num])):
                y_axis -= 1
                plot_line(y_axis, blast_res[num][j]['start'], blast_res[num][j]['end'])
            # plt.title('MSA_'+str(num))
            # plt.legend()
            # plt.show()
            plt.savefig(out_genome_assembly_path+f'/Figures/MSA_{num}.png')
            plt.close()

    # ================== Statistical Hit Number of Each Position ================
    def get_keys(d):
        sort_key_dic_instance = dict(sorted(d.items(), key=operator.itemgetter(0)))
        return sort_key_dic_instance

    hit_list = []
    x_value = []
    y_value = []
    for i in range(len(blast_res)):
        hit_list.append({})
        for j in range(len(blast_res[i])):
            for pos in range(blast_res[i][j]['start'], blast_res[i][j]['end']):
                if pos in hit_list[i]:
                    hit_list[i][pos] += 1
                else:
                    hit_list[i][pos] = 1
        sort_hit_list = get_keys(hit_list[i])
        x_value.append(list(get_keys(sort_hit_list).keys()))
        y_value.append(list(get_keys(sort_hit_list).values()))
    if figure == 'y':
        for num_value in range(len(x_value)):
            # ================================== Bar Plot==================================
            plt.plot(x_value[num_value], y_value[num_value], linewidth=1.5, marker='o', markersize=2)
            plt.yticks(fontsize=8)
            plt.xticks(fontsize=8)
            # plt.ylim(0, 150)
            plt.xlabel('No. base of each SINE', fontsize=8)
            plt.ylabel('Copy number', fontsize=8)
            # plt.title(f'Copy number profile_{num_value}')
            plt.tight_layout()
            plt.savefig(out_genome_assembly_path+'/Figures/profile_'+str(num_value)+'.png')
            # plt.grid(linestyle='dashed')
            plt.close()

    # ================= Choose Repeat Number and Decide Boundary ===============

    def get_keys(d, value):
        return sorted(k for k, v in d.items() if v >= value)

    def split_by_continuity(positions):
        result = []
        pos_start = None
        pos_end = None
        for index in range(len(positions) - 1):
            inter_pos = positions[index]
            next_pos = positions[index + 1]
            if pos_start is None:
                pos_start = inter_pos
            pos_end = inter_pos
            if next_pos != inter_pos + 1:
                # if is not continuous
                result.append({
                    'start': pos_start,
                    'end': pos_end
                })
                pos_start = None
                pos_end = None
        if pos_start is not None:
            result.append({
                'start': pos_start,
                'end': positions[-1]
            })
        return result

    update_pos = []
    blast_count = []
    prob_copy = []
    num = 0
    max_gap_list = []
    for m in range(len(hit_list)):
        repeat_number = int(math.ceil(family_count[m] * factor_copy))
        prob_copy.append(round(repeat_number, 3))
        blast_count.append(family_count[m])
        if family_count[m] > min_copy_number:
            if family_count[m] > 1:
                res = get_keys(hit_list[m], repeat_number)
                blast_pre = split_by_continuity(res)
                # first and last base copy number
                if hit_list[m][0] <= pos and hit_list[m][length[m] - 1] <= pos:
                    if len(blast_pre) == 1:
                        # shift
                        if max(abs(blast_pre[0]['start'] - 100),
                               abs(blast_pre[0]['end'] - (length[m] - 100))) >= max_shift:
                            update_pos.append({})
                        else:
                            update_pos.append(blast_pre)
                    elif len(blast_pre) > 1:
                        if len(blast_pre) - 2 == 0:
                            # gap
                            if abs(blast_pre[0]['end'] - blast_pre[1]['start']) >= max_gap and \
                                blast_pre[0]['end'] < length[m]-100 and \
                                    blast_pre[1]['start'] > 100:
                                max_gap_list.append(m)
                                del blast_pre[0]
                            if max(abs(blast_pre[0]['start'] - 100),
                                   abs(blast_pre[-1]['end'] - (length[m] - 100))) >= max_shift:
                                update_pos.append({})
                            else:
                                update_pos.append(blast_pre)
                        else:
                            new_blast_pre = []
                            for num_cut in range(0, len(blast_pre) - 2):
                                if abs(blast_pre[num_cut]['end'] - blast_pre[num_cut + 1]['start']) < max_gap and \
                                    blast_pre[0]['end'] < length[m]-100 and \
                                        blast_pre[1]['start'] > 100:
                                    new_blast_pre.append(blast_pre[num_cut])
                            if len(new_blast_pre) == 0 or \
                                    max(abs(new_blast_pre[0]['start'] - 100),
                                        abs(new_blast_pre[-1]['end'] - (length[m] - 100))) >= max_shift:
                                update_pos.append({})
                            else:
                                update_pos.append(new_blast_pre)
                    else:
                        update_pos.append({})
                else:
                    update_pos.append({})
            else:
                update_pos.append({})
        else:
            update_pos.append({})
        num += 1
    # ================================ Correct Boundary Results ========================
    finder_seq = []
    finder_start = []
    finder_end = []
    for t in range(len(update_pos)):
        if len(update_pos[t]) == 0:
            # or abs(update_pos[t][0]['start']-update_pos[t][-1]['end']) <= 90:
            seq_id = previous_id[t]
            finder_seq.append(output_genome_sequence[seq_id][previous_start[t]:previous_end[t]])
            finder_start.append(0)
            finder_end.append(0)
        else:
            if bound == 'msa':
                new_pre_start = tsd_bound_start[t] + update_pos[t][0]['start'] - 100
                new_pre_end = tsd_bound_start[t] + update_pos[t][-1]['end'] - 100
                finder_start.append(new_pre_start)
                finder_end.append(new_pre_end)
                seq_id = previous_id[t]
                finder_seq.append(output_genome_sequence[seq_id][new_pre_start:new_pre_end])
            elif bound == 'tsd':
                old_pre_start = tsd_bound_start[t]
                old_pre_end = tsd_bound_end[t]
                new_pre_start = tsd_bound_start[t] + update_pos[t][0]['start'] - 100
                new_pre_end = tsd_bound_start[t] + update_pos[t][-1]['end'] - 100

                finder_start.append(new_pre_start)
                finder_end.append(new_pre_end)
                seq_id = previous_id[t]
                finder_seq.append(output_genome_sequence[seq_id][old_pre_start:old_pre_end])

    if os.path.exists(out_genome_assembly_path+'/Step3_blast_process_output.fa'):
        modify_text(out_genome_assembly_path+'/Step3_blast_process_output.fa')
    save_to_fna_3(out_genome_assembly_path+'/Step3_blast_process_output.fa', finder_seq, sine_info, finder_start,
                  finder_end, blast_count, length)


def save_to_fna_3(filename, sequences, title, bs, be, num, l):
    header = '{}|blast_s:{}|blast_e:{}|blast_count:{}|blast_l:{}'.strip()
    payload = []
    for seq in range(len(sequences)):
        seq_header = header.format(title[seq].strip(), str(bs[seq]), str(be[seq]), num[seq], l[seq])
        payload.append(seq_header.strip() + '\n')
        payload.append(sequences[seq].strip() + '\n')
    with open(filename, 'a') as file:
        file.writelines(payload)


def process_blast_output_2(out_genome_assembly_path):
    input_f1 = out_genome_assembly_path+'/Step3_blast_process_output.fa'
    input_f2 = out_genome_assembly_path+'/Step4_rna_input.fasta'
    with open(input_f1, 'r')as f1:
        with open(input_f2, 'w') as f2:
            flag = False
            for line in f1:
                if line[0] == '>':
                    if 'blast_s:0' not in line:
                        flag = True
                    else:
                        flag = False
                if flag:
                    f2.write(line)


def blast_rna(out_genome_assembly_path,cpus):
    os.system('blastn -query '+out_genome_assembly_path+'/Step4_rna_input.fasta '
              #'-subject ../Input_Files/rna_database.fa '
              '-db ../Input_Files/rna_database '
              '-out '+out_genome_assembly_path+'/Step4_rna_output.out '
              '-evalue 1 '
              '-num_alignments 50000 '
              '-word_size 7 '
              '-gapopen 5 '
              '-gapextend 2 '
              '-penalty -3 '
              '-reward 2 '
              '-num_threads '+ str(cpus))


def process_rna(out_genome_assembly_path):
    rna_database = []
    with open('../Input_Files/rna_database.fa') as f:
        num = 0
        lines = f.readlines()
        for line in lines:
            if line[0] == '>':
                rna_database.append([])
                if num in range(954):
                    rna_database[0].append(line.replace('>', '').strip())
                elif num in range(954, 1666):
                    rna_database[1].append(line.replace('>', '').strip())
                elif num in range(1666, 1729):
                    rna_database[2].append(line.replace('>', '').strip())
                num += 1

    filter_out = []
    min_e_values = []
    E_VALUE_PATTERN = re.compile(r'Expect = (?P<e_value>\S+)')
    input_f = out_genome_assembly_path+'/Step4_rna_output.out'
    with open(input_f)as f:
        rna_id = []
        title = None
        num = -1
        for line in f:
            if 'Query= ' in line:
                rna_id.append([])
                min_e_values.append(None)
                num += 1
                title = line.split('|')[0]
                filter_out.append(title.strip('\n'))
            if '> ' in line:
                rna_id[num].append(line.split()[1])
            if num > -1 and min_e_values[num] is None:
                # if current e_value is not found, try parsing e_value
                # num > -1 ensures only starting to parse e_value after the query seq is identified
                match = E_VALUE_PATTERN.search(line)
                if match:
                    min_e_values[num] = float(match.group('e_value'))

    # remove titles whose e_value is smaller than 1e-20
    filter_out = [title for index, title in enumerate(filter_out)
                  if min_e_values[index] is None or min_e_values[index] >= 1e-15]

    hit_record = []
    for num in range(len(rna_id)):
        if rna_id[num]:
            if rna_id[num][0] in rna_database[0]:
                hit_record.append('tRNA')
            elif rna_id[num][0] in rna_database[1]:
                hit_record.append('5S rRNA')
            elif rna_id[num][0] in rna_database[2]:
                hit_record.append('7SL RNA')
            else:
                hit_record.append('Unknown')
        else:
            hit_record.append('Unknown')
    if os.path.exists(out_genome_assembly_path+'/Step4_rna_output.fasta'):
        modify_text(out_genome_assembly_path+'/Step4_rna_output.fasta')
    input_f1 = out_genome_assembly_path+'/Step4_rna_input.fasta'
    input_f2 = out_genome_assembly_path+'/Step4_rna_output.fasta'
    with open(input_f1, 'r')as rna_input_file:
        with open(input_f2, 'w')as rna_output_file:
            flag = False
            num = -1
            for line in rna_input_file:
                if line[0] == '>':
                    """if model == 'rule':"""
                    if ('Query= ' + line.split('|')[0].replace('>', '')).split(';')[0].rsplit(' ', 1)[0] in filter_out:
                        flag = True
                    else:
                        flag = False
                    """elif model == 'model':
                        if ('Query= ' + line.split('|')[0].replace('>', '')) in filter_out:
                            flag = True
                        else:
                            flag = False"""
                if flag:
                    if '>' in line:
                        num += 1
                        new_line = line.strip() + '|' + hit_record[num].strip().replace('RNA', '') + '\n'
                        rna_output_file.write(new_line)
                    else:
                        rna_output_file.write(line.strip() + '\n')


def tandem_repeat_finder(out_genome_assembly_path):
    #path = os.path.abspath(os.path.dirname(os.getcwd()))
    os.system('trf '
              + out_genome_assembly_path + '/Step4_rna_output.fasta '
              '2 5 7 80 10 10 2000 -d -h -l 6')


def process_trf(input_trf_prob, out_genome_assembly_path):
    trf_file = '../bin/Step4_rna_output.fasta.2.5.7.80.10.10.2000.dat'
    with open(trf_file, 'r')as trf_f:
        trf_list = []
        num = -1
        trf_lines = trf_f.readlines()
        flag_1 = False
        flag_2 = False
        for line in trf_lines[8:]:
            if 'Parameters: ' in line:
                num += 1
                trf_list.append([])
                flag_1 = True
            if len(line.split()) == 15 and len(line.split()) != 0 and flag_1:
                flag_2 = True
                trf_list[num].append(line.strip())
            if 'Sequence: ' in line and flag_1 and flag_2:
                flag_1 = False
                flag_2 = False
    input_f1 = out_genome_assembly_path+'/Step4_rna_output.fasta'
    input_f2 = out_genome_assembly_path+'/Step5_trf_output.fasta'
    with open(input_f1)as f:
        seq_length = []
        for line in f:
            if line[0] != '>':
                seq_length.append(len(line.strip()))
    with open(input_f1, 'r')as f1:
        with open(input_f2, 'w') as f2:
            counter = -1
            for line in f1:
                if line[0] == '>':
                    flag = True
                    counter += 1
                    trf_length = 0
                    if len(trf_list[counter]) != 0:
                        for num_irf in range(len(trf_list[counter])):
                            trf_length += len((trf_list[counter][num_irf].split()[-1]))
                            if trf_length >= input_trf_prob * seq_length[counter]:
                                flag = False
                                break
                    else:
                        flag = True
                if flag:
                    f2.write(line)


def save_to_fna(filename, input_sequences, input_title):
    header = '{}'.strip()
    index_1 = 0
    payload = []
    for seq in input_sequences:
        seq_header = header.format(input_title[index_1])
        payload.append(seq_header.strip() + '\n')
        payload.append(input_sequences[index_1] + '\n')
        index_1 += 1
    with open(filename, 'a') as file:
        file.writelines(payload)


def extend_seq(in_genome_assembly_path, out_genome_assembly_path):
    output_genome_sequence = read_genome_assembly(in_genome_assembly_path)
    filename_1 = out_genome_assembly_path+'/Step5_trf_output.fasta'

    title = []
    seq = []
    with open(filename_1, 'r')as f1:
        for line in f1:
            if line[0] == '>':
                title.append(line.strip())
                seq_id = line.split()[0].replace('>', '')
                sine_start = int(line.split('|')[2].split(':')[1])
                sine_end = int(line.split('|')[3].split(':')[1])
                if abs(sine_end-sine_start) >= 200:
                    seq.append(output_genome_sequence[seq_id][sine_start:sine_start+100].strip() +
                               output_genome_sequence[seq_id][sine_end-100:sine_end])
                elif 200 > abs(sine_end-sine_start) >= 100:
                    seq.append(output_genome_sequence[seq_id][sine_start:sine_start+50].strip() +
                               output_genome_sequence[seq_id][sine_end-50:sine_end])
                else:
                    seq.append(output_genome_sequence[seq_id][sine_start:sine_end])

    filename_2 = out_genome_assembly_path+'/Step6_irf_input.fasta'
    if os.path.exists(filename_2):
        modify_text(filename_2)
    save_to_fna(filename_2, seq, title)


def inverted_repeat_finder(out_genome_assembly_path):
    path = os.path.abspath(os.path.dirname(os.getcwd()))
    os.system('irf ' + out_genome_assembly_path +'/Step6_irf_input.fasta '
              '2 3 5 80 10 20 500000 10000 -d -h -t4 74 -t5 493 -t7 10000')


def process_irf(out_genome_assembly_path):
    irf_file = out_genome_assembly_path+'/Step6_irf_input.fasta.2.3.5.80.10.20.500000.10000.dat'

    with open(irf_file)as irf_f:
        irf_list = []
        num = -1
        irf_lines = irf_f.readlines()
        flag_1 = False
        flag_2 = False
        for line in irf_lines[8:]:
            if 'Parameters: ' in line:
                num += 1
                irf_list.append([])
                flag_1 = True
            if len(line.split()) == 19 and len(line.split()) != 0 and flag_1:
                flag_2 = True
                irf_list[num].append(line.strip())
            if 'Sequence: ' in line and flag_1 and flag_2:
                flag_1 = False
                flag_2 = False

    input_f1 = out_genome_assembly_path+'/Step5_trf_output.fasta'
    input_f2 = out_genome_assembly_path+'/Step6_irf_output.fasta'

    with open(input_f1)as f:
        seq_length = []
        tsd_length = []
        for line in f:
            if line[0] != '>':
                seq_length.append(len(line.strip()))
            else:
                tsd_length.append(int(line.split('|')[1].split(':')[1]))

    with open(input_f1, 'r')as f1:
        with open(input_f2, 'w') as f2:
            counter = -1
            flag = False
            for line in f1:
                if line[0] == '>':
                    counter += 1
                    if len(irf_list[counter]) != 0:
                        for num_irf in range(len(irf_list[counter])):
                            irf_left_s = int(irf_list[counter][num_irf].split()[0])
                            irf_left_e = int(irf_list[counter][num_irf].split()[1])

                            irf_length = int(irf_list[counter][num_irf].split()[2])

                            irf_right_s = int(irf_list[counter][num_irf].split()[3])
                            irf_right_e = int(irf_list[counter][num_irf].split()[4])
                            if irf_length >= 10:
                                flag = True
                                break
                    else:
                        flag = False
                if not flag:
                    f2.write(line)


def cluster_sequences(out_genome_assembly_path,cpus):
    path = os.path.abspath(os.path.dirname(os.getcwd()))
    os.system('cd-hit-est '
              '-i ' + out_genome_assembly_path + '/Step6_irf_output.fasta '
              '-o ' + out_genome_assembly_path + '/Step7_cluster_output.fasta '
              '-c 0.8 '
              '-T ' + str(cpus))
    with open(out_genome_assembly_path+'/Step7_cluster_output.fasta', 'r')as f_1:
        with open(out_genome_assembly_path+'/Seed_SINE.fa', 'w')as f_2:
            num = 0
            for line in f_1:
                if line[0] == '>':
                    new_line = f'>SINE_{num} ' + line.replace('>', '')
                    f_2.write(new_line)
                    num += 1
                else:
                    f_2.write(line)


def re_process_figure(out_genome_assembly_path):
    comp_1 = []
    comp_2 = []
    with open(out_genome_assembly_path+'/Step2_extend_blast_input.fa') as comp_f1:
        for comp_line1 in comp_f1:
            if comp_line1[0] == '>':
                comp_1.append(comp_line1.replace('>', '').replace('|', ' ').strip('\n'))
    with open(out_genome_assembly_path+'/Seed_SINE.fa') as comp_f2:
        for comp_line2 in comp_f2:
            if comp_line2[0] == '>':
                comp_2.append(comp_line2.replace(comp_line2.split()[0]+' ', '')
                              .split('|blast_s:')[0].replace('|', ' ').strip('\n'))
    for num in range(len(comp_1)):
        if comp_1[num] not in comp_2:
            os.remove(out_genome_assembly_path + '/Figures/' + f'MSA_{num}.png')
            os.remove(out_genome_assembly_path + '/Figures/' + f'profile_{num}.png')


def genome_annotate(in_genome_assembly_path, out_genome_assembly_path, in_nonredundant,cpus):
    #path = os.path.abspath(os.path.dirname(os.getcwd()))
    print(in_genome_assembly_path)
    print(out_genome_assembly_path)
    if in_nonredundant == 'y':
        os.system('RepeatMasker -e ncbi -pa ' + str(cpus) + ' -q -no_is -norna -nolow -div 40 '
                  '-lib  ' + out_genome_assembly_path + '/Seed_SINE.fa '
                  '-cutoff 225 ' + in_genome_assembly_path + ' '
                  '-dir ' + out_genome_assembly_path + '/RepeatMasker/')
    elif in_nonredundant == 'n':
        os.system('RepeatMasker -e ncbi -pa ' + str(cpus) + ' -q -no_is -norna -nolow -div 40 '
                  '-lib  ' + out_genome_assembly_path + '/Step7_cluster_output.fasta '
                  '-cutoff 225 ' + in_genome_assembly_path + ' '
                  '-dir ' + out_genome_assembly_path + '/RepeatMasker/')


def sine_finder(genome_assembly_path):
    #main_func()
    os.system('python3 ./SINEFinder.py ' + genome_assembly_path)


def save_to_fna_4(filename, input_sequences, input_id, input_direct, input_start, input_end):
    header = '{} {} {}:{}'.strip()
    index_1 = 0
    payload = []
    for seq in input_sequences:
        seq_header = header.format(input_id[index_1], input_direct[index_1], input_start[index_1], input_end[index_1])
        payload.append(seq_header.strip() + '\n')
        payload.append(input_sequences[index_1] + '\n')
        index_1 += 1
    with open(filename, 'a') as file:
        file.writelines(payload)


def process_sine_finder(genome_assembly_path, sine_finder_out, out_genome_assembly_path, pattern):
    output_genome_sequence = read_genome_assembly(genome_assembly_path)
    with open(sine_finder_out, 'r')as f1:
        finder_seq = []
        id = []
        direct = []
        start_position = []
        end_position = []
        lines = f1.readlines()
        flag = False
        for line in lines:
            if line[0] == '>':
                # mis_tsd = int(line.split()[3].split(';')[2].split('=')[1])
                id.append(line.split()[0])
                direct.append(line.split()[1])
                flag = True
                seq_id = line.split()[0].replace('>', '')
                s = int(line.split()[2].split(':')[0])
                e = int(line.split()[2].split(':')[1])
                tsd = int(line.split()[3].split(';')[0].split('=')[1])
                if s <= e:
                    start = s + tsd - 30
                    end = e - tsd + 50
                else:
                    start = e + tsd - 30
                    end = s - tsd + 50

            else:
                flag = False
            if flag:
                start_position.append(start+30)
                end_position.append(end-50)
                seq = output_genome_sequence[seq_id][start:end]
                finder_seq.append(seq)
    if pattern == 2 or pattern == 3:
        if os.path.exists(out_genome_assembly_path+'/Step1_extend_tsd_input_2.fa'):
            modify_text(out_genome_assembly_path+'/Step1_extend_tsd_input_2.fa')
        save_to_fna_4(out_genome_assembly_path+'/Step1_extend_tsd_input_2.fa', finder_seq, id, direct, start_position, end_position)



def ensure_path(path):
    if not os.path.exists(path):
        os.mkdir(path)


def main_function():
    print('Please input the path of genomic sequence')
    input_pattern = args.mode
    input_genome_assembly_path = args.input_filename
    output_genome_assembly_path = args.output_filename
    ensure_path(output_genome_assembly_path)
    input_sine_finder = input_genome_assembly_path.replace('.fasta', '')+'-matches.fasta'

    #input_hmm_e_value = args.hmmer_evalue
    #input_blast_e_value = args.blast_evalue
    input_factor_length = args.length_factor
    input_factor_copy_number = args.copy_number_factor
    input_max_shift = args.shift
    input_max_gap = args.gap
    input_min_copy_number = args.copy_number
    #input_pos = args.base_copy_number
    #trf_prob = args.probability
    input_bound = args.boundary
    input_figure = args.figure
    input_non_redundant = args.non_redundant
    
    cpus = args.threads

    start_time = time.time()
    print('************************************************************************')
    print('*************************** AnnoSINE START! ****************************')
    print('************************************************************************')
    if input_pattern == 1:
        print('================ Step 1: HMMER prediction has begun ==================')
        hmm_predict(input_genome_assembly_path,cpus)
        process_hmm_output_3(1e-10, input_genome_assembly_path, input_pattern, output_genome_assembly_path)
    elif input_pattern == 2:
        print('================ Step 1: Structure search has begun ==================')
        sine_finder(input_genome_assembly_path)
        process_sine_finder(input_genome_assembly_path, input_sine_finder, output_genome_assembly_path, input_pattern)
    elif input_pattern == 3:
        print('====== Step 1: HMMER prediction and structure search has begun =======')
        hmm_predict(input_genome_assembly_path,cpus)
        process_hmm_output_3(1e-10, input_genome_assembly_path, input_pattern, output_genome_assembly_path)
        sine_finder(input_genome_assembly_path)
        process_sine_finder(input_genome_assembly_path, input_sine_finder, output_genome_assembly_path, input_pattern)
    merge_tsd_input(input_pattern, output_genome_assembly_path)
    print('\n======================== Step 1 has been done ========================\n\n')

    print('================ Step 2: TSD identification has begun ================')
    search_tsd(output_genome_assembly_path)
    process_tsd_output(input_genome_assembly_path, output_genome_assembly_path)
    print('\n======================== Step 2 has been done ========================\n\n')

    print('================ Step 3: MSA implementation has begun ================')
    multiple_sequence_alignment(1e-10, input_genome_assembly_path, output_genome_assembly_path,cpus)
    process_blast_output_1(input_genome_assembly_path, input_factor_length, input_factor_copy_number,
                           input_max_shift, input_max_gap, input_min_copy_number,
                           1, output_genome_assembly_path, input_bound, input_figure)
    process_blast_output_2(output_genome_assembly_path)

    print('\n======================== Step 3 has been done ========================\n\n')

    print('========= Step 4: RNA derived head identification has begun ==========')
    blast_rna(output_genome_assembly_path,cpus)
    process_rna(output_genome_assembly_path)
    print('\n========================= Step 4 has been done =======================\n\n')

    print('=============== Step 5: Tandem repeat finder has begun ===============')
    tandem_repeat_finder(output_genome_assembly_path)
    process_trf(0.5, output_genome_assembly_path)
    print('\n======================== Step 5 has been done ========================\n\n')

    print('=============== Step 6: Inverted repeat finder has begun =============')
    extend_seq(input_genome_assembly_path, output_genome_assembly_path)
    inverted_repeat_finder(output_genome_assembly_path)
    process_irf(output_genome_assembly_path)
    print('\n========================= Step 6 has been done =======================\n\n')

    print('=============== Step 7: Sequences clustering has begun ===============')
    cluster_sequences(output_genome_assembly_path,cpus)
    print('\n======================== Step 7 has been done ========================\n\n')

    print('================= Step 8: Genome annotation has begun ================')
    if input_figure == 'y':
        dirs = output_genome_assembly_path+'/Figures/'
        if not os.path.exists(dirs):
            os.makedirs(dirs)
        re_process_figure(output_genome_assembly_path)
    genome_annotate(input_genome_assembly_path, output_genome_assembly_path, input_non_redundant,cpus)
    print('\n========================= Step 8 has been done =======================\n\n') 
    os.system('rm -f Step4_rna_output.fasta*.dat')
    end_time = time.time()
    print('Total running time: ', end_time - start_time, 's')
    print('************************************************************************')
    print('************************** AnnoSINE COMPLETE! **************************')
    print('************************************************************************')


if __name__ == '__main__':
    main_function()

