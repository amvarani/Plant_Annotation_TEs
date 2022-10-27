#!/usr/bin/env python

import sys
import os
import glob
import re

if len(sys.argv) < 3:
    print sys.argv[0], "outdir new-GFF-file"
    sys.exit()

def readFASTA(filename):
    fastalines = []
    f = open(filename)
    lines = f.readlines()
    f.close()
    
    if lines[0][0] != '>':
        sys.exit("Invalid FASTA file: "+filename)
    seq = ""
    header = ""
    for line in lines:
        if len(line) > 0:
            if line[0]=='>':
                if seq != "":
                    fastalines.append([header,seq])
                    seq = ""
                header = line.strip()[1:]
            else:
                line = re.sub(r'\s','',line)
                seq = seq + line
    if seq != "":
        fastalines.append([header,seq])
    return fastalines

outfile = open(sys.argv[2], "w")
#print >>outfile, "##gff-version 3"
print >>outfile, "track name=nonLTR description=\"MGEScan-nonLTR\" color=255,0,0"

# Example ltr.out

# 1----------***
# Drosophila_melanogaster.BDGP5.dna.chromosome.2L.fa_51   16141217        16141492 16146090        16146365        +       276     276     5149    6.02e-129 AAAAT   AAAAT   TGT     ACA     TGT     ACA D
#
for cladeDir in glob.glob( os.path.join(sys.argv[1], '*') ):
    basename = os.path.basename(cladeDir)
    filepath = cladeDir + "/" + basename + ".dna"
    fastalist = readFASTA(filepath)
    for fastaitem in fastalist:
        header = fastaitem[0] # Drosophila_melanogaster.BDGP5.dna.chromosome.2L.fa_51
        seq = fastaitem[1]
        # seqid = header[:header.find("_")]
        seqid = header[:header.rfind("_")]
        try:
            # dm3_gold_chr4_1
            tmp = seqid.split("_")
            if len(tmp) > 2:
                # chr4
                seqid = tmp[2]
        except:
            pass

        # remove the file extension .fa
        seqid = seqid.replace(".fa", "")
        #if seqid[0].isdigit():
        if seqid[:3] != "chr":
            if seqid.isdigit():        
                seqid = "chr" + seqid
        searchObj=re.search(r'([^.]*).([^.]*).([^.]*).([^.]*).([^.]*).fa(.*)',
                header, re.M|re.I)
        try:
            if len(searchObj.groups()) > 5 and searchObj.group(5) != "" :
                seqid = searchObj.group(5)
                if searchObj.group(4) == "chromosome":
                    seqid = "chr" + seqid
        except:
            pass
        start = int(header[header.rfind("_")+1:])
        des = [seqid, "MGEScan_nonLTR", "mobile_genetic_element", str(start), str(start+len(seq)), ".", ".", ".", "ID=" + header] 
        print >>outfile, "\t".join(des)

outfile.close()
