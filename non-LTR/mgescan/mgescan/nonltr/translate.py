"""translate.py: translate DNA

Usage:
    translate -d FILE [-p OUTFILE]
    translate -h|--help
    translate --version

Options:
    -h|--help   Show this screen.
    --version   Show version.

"""

from docopt import docopt
from mgescan.biopython import read_file, translate
from Bio.SeqRecord import SeqRecord
# Description

class Translate(object):

    # This replaces translate c program. Originally it runs with parameters like:
    # translate -d /example/chr2L.fa -h chr2L.fa -p /output/f/chr2L.fa.pep

    def __init__(self, args):

        self.args = args

    def read_seqs(self, seq_file=None):

        file = seq_file or self.args['FILE']
        results = read_file(file)
        self.seqs = results

    def translate(self, seqs=None):

        results = {}
        seqs = seqs or self.seqs
        for seq in seqs:
            results[seq.id] = {
                    "_1" : SeqRecord(translate(seq.seq),
                        id=seq.id + "_1",
                        name=seq.name + "_1",
                        description=seq.description),
                    "_2" : SeqRecord(translate(seq.seq, start=1),
                        id=seq.id + "_2",
                        name=seq.name + "_2",
                        description=seq.description),
                    "_3" : SeqRecord(translate(seq.seq, start=2),
                        id=seq.id + "_3",
                        name=seq.name + "_3",
                        description=seq.description)
                    }
 
        self.p_seqs = results

    def write_p_seqs(self, pep_file=None):

        file = pep_file or self.args['OUTFILE']
        from Bio import SeqIO
        output_handle = open(file, "w")
        tmp = []
        for id, p_seqs in self.p_seqs.iteritems():
            tmp.append(p_seqs['_1'])
            tmp.append(p_seqs['_2'])
            tmp.append(p_seqs['_3'])
            SeqIO.write(tmp,output_handle, "fasta")
            tmp = []
        output_handle.close()

    def run(self):
        self.read_seqs()
        self.translate()
        self.write_p_seqs()

def main():
    arguments = docopt(__doc__, version='translate 0.1')
    tran = Translate(arguments)
    tran.run()

if __name__ == "__main__":
    main()
