"""MGEScan-nonLTR: identifying non-ltr in genome sequences

Usage:
    nonltr.py all <genome_dir> [--output=<data_dir>]
    nonltr.py forward <genome_dir> [--output=<data_dir>]
    nonltr.py backward <genome_dir> [--output=<data_dir>]
    nonltr.py reverseq <genome_dir> [--output=<data_dir>]
    nonltr.py qvalue <genome_dir> [--output=<data_dir>]
    nonltr.py gff3 <genome_dir> [--output=<data_dir>]
    nonltr.py (-h | --help)
    nonltr.py --version

Options:
    -h --help   Show this screen
    --version   Show version
    --output=<data_dir> Path where results will be saved

"""

from docopt import docopt
from multiprocessing import Process
from subprocess import Popen, PIPE
from mgescan.cmd import MGEScan
from mgescan import utils
from biopython import reverse_complement_fasta, getid
import os
import time
import shutil

class nonLTR(MGEScan):

    main_dir = "nonltr"
    cmd_hmm = main_dir + "/run_hmm.pl"
    cmd_post_process = main_dir + "/post_process.pl"
    cmd_validate_q_value = main_dir + "/post_process2.pl"
    cmd_togff = main_dir + "/toGFF.py"

    processes = set()
    max_processes = 5

    def __init__(self, args):
        self.args = args
        self.all_enabled = self.args['all']
        self.forward_enabled = self.args['forward']
        self.backward_enabled = self.args['backward']
        self.reverseq_enabled = self.args['reverseq']
        self.qvalue_enabled = self.args['qvalue']
        self.gff3_enabled = self.args['gff3']
        self.set_inputs()
        self.set_defaults()

    def set_inputs(self):
        self.data_dir = utils.get_abspath(self.args['--output'])
        self.genome_dir = utils.get_abspath(self.args['<genome_dir>'])

    def set_defaults(self):
        super(nonLTR, self).set_defaults()
        self.plus_dir = self.genome_dir
        if self.reverseq_enabled :
            # minus_dir used to be genome_dir + "_b"
            self.minus_dir = self.data_dir + "/_reversed/" 
        else:
            self.minus_dir = self.genome_dir + "/_reversed/" 

        self.plus_out_dir = self.data_dir + "/f/"
        self.minus_out_dir = self.data_dir + "/b/"

    def run(self):

        # Step 1
        p1 = Process(target=self.forward_strand)
        if (self.all_enabled) or (self.forward_enabled):
            p1.start()

        # Step 2
        if (self.all_enabled) or (self.reverseq_enabled):
            # Reverse complement before backward strand
            self.reverse_complement()

        # Step 3
        p2 = Process(target=self.backward_strand)
        if (self.all_enabled) or (self.backward_enabled):
            p2.start()

        if (self.all_enabled) or (self.forward_enabled):
            p1.join()
        if (self.all_enabled) or (self.backward_enabled):
            p2.join()

        # Step 4
        if (self.all_enabled) or (self.qvalue_enabled):
            # validation for q value
            self.post_processing2()

        # Step 5
        if (self.all_enabled) or (self.gff3_enabled):
            # convert to gff3
            self.toGFF()

    def forward_strand(self):
        
        mypath = self.plus_dir
        out_dir = self.plus_out_dir
        for (dirpath, dirnames, filenames) in os.walk(mypath):
            break
        for name in filenames:
            file_path = utils.get_abspath(dirpath + "/" + name)

            # Rename to sequence id
            sid = getid(file_path)
            new_path = utils.get_abspath(dirpath + "/" + sid)
            os.rename(file_path, new_path)

            command = self.cmd_hmm + (" --dna=%s --out=%s --hmmerv=%s" % 
                    (new_path, out_dir, self.hmmerv))
            command = command.split()
            self.processes.add(Popen(command, stdout=PIPE,
                stderr=PIPE))
            if len(self.processes) >= self.max_processes:
                time.sleep(.1)
                self.processes.difference_update([p for p in self.processes if
                    p.poll() is not None])
        #print dirpath, dirnames, filenames
        for p in self.processes:
            if p.poll() is None:
                p.wait()

        self.post_processing_after_forward_strand()

    def backward_strand(self):
        
        mypath = self.minus_dir
        out_dir = self.minus_out_dir
        for (dirpath, dirnames, filenames) in os.walk(mypath):
            break
        for name in filenames:
            file_path = utils.get_abspath(dirpath + "/" + name)

            # Rename to sequence id
            sid = getid(file_path)
            new_path = utils.get_abspath(dirpath + "/" + sid)
            os.rename(file_path, new_path)

            command = self.cmd_hmm + (" --dna=%s --out=%s --hmmerv=%s" % 
                    (new_path, out_dir, self.hmmerv))
            command = command.split()
            self.processes.add(Popen(command, stdout=PIPE,
                stderr=PIPE))
            if len(self.processes) >= self.max_processes:
                time.sleep(.1)
                self.processes.difference_update([p for p in self.processes if
                    p.poll() is not None])
        #print dirpath, dirnames, filenames
        for p in self.processes:
            if p.poll() is None:
                p.wait()

        self.post_processing_after_reverse_strand()

    def post_processing_after_forward_strand(self):
        self.post_processing(self.plus_out_dir, self.plus_dir, 0)

    def post_processing_after_reverse_strand(self):
        self.post_processing(self.minus_out_dir, self.minus_dir, 1)

    def post_processing(self, out_dir, dir, reverse_yn):
        utils.silentremove(utils.get_abspath(out_dir + "/out1/aaaaa"))
        utils.silentremove(utils.get_abspath(out_dir + "out1/bbbbb"))
        utils.silentremove(utils.get_abspath(out_dir + "out1/ppppp"))
        utils.silentremove(utils.get_abspath(out_dir + "out1/qqqqq"))
        cmd = self.cmd_post_process + (" --dna=%s --out=%s --rev=%s" %
                (dir, out_dir, reverse_yn))
        self.run_cmd(cmd)

    def reverse_complement(self):
        mypath = self.genome_dir
        for (dirpath, dirnames, filenames) in os.walk(mypath):
            break
        directory = self.minus_dir
        if not os.path.exists(directory):
            os.makedirs(directory)
        for name in filenames:
            file_path = utils.get_abspath(dirpath + "/" + name)
            reverse_complement_fasta(file_path, directory)

    def post_processing2(self):

        if self.qvalue_enabled:
            shutil.move(self.genome_dir + "/b", self.data_dir)
            shutil.move(self.genome_dir + "/f", self.data_dir)

        cmd = self.cmd_validate_q_value + \
                " --data_dir=%(data_dir)s --hmmerv=%(hmmerv)s"

        self.run_cmd(cmd)

    def toGFF(self):

        if self.gff3_enabled:
            # Assume info is a only directory in genome_dir
            shutil.move(self.genome_dir + "/info", self.data_dir)

        # gff3
        self.nonltr_out_path = utils.get_abspath(self.data_dir + "/info/full/")
        self.nonltr_gff_path = utils.get_abspath(self.data_dir + "/info/nonltr.gff3")
        cmd = self.cmd_togff + " %(nonltr_out_path)s %(nonltr_gff_path)s"
        res = self.run_cmd(cmd)

def main():
    arguments = docopt(__doc__, version="nonltr 0.2")
    nonltr = nonLTR(arguments)
    nonltr.run()

if __name__ == "__main__":
    main()
