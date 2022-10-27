from Bio import SeqIO
from Bio.SeqRecord import SeqRecord
from Bio.Seq import Seq
from Bio.Alphabet import generic_dna
import ntpath
import os

def make_rc_record(record):
    """Returns a new SeqRecord with the reverse complement sequence."""
    """Ref: https://www.biostars.org/p/14614/"""
    return SeqRecord(seq = record.seq.reverse_complement(), \
           id = record.id, \
           # "rc_" + record.id, \
           description = record.description) # "reverse complement")

def reverse_complement_fasta(filepath, dest):
    filename = ntpath.basename(filepath)
    dest_path = os.path.abspath(dest + "/" + filename)
    records = map(make_rc_record, SeqIO.parse(filepath, "fasta"))
    SeqIO.write(records, dest_path , "fasta")
    return dest_path

def read_file(filepath, format="fasta"):
    res = []
    handle = open(filepath, "rU")
    for record in SeqIO.parse(handle, format) :
        res.append(record)
    return res

def translate(seq, start=0):
    coding_dna = Seq(str(seq[start:]), generic_dna)
    res = coding_dna.translate()
    return res

def getid(filepath):
    handle = open(filepath, "rU")
    for record in SeqIO.parse(handle, "fasta") :
        return record.id
