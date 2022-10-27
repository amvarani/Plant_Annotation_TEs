#!/usr/bin/env python

# ltr.out looks like
#
# 1------*** (cluster)
# chr2L 1614217 161492 16146090 1614365 + 276 276 5149 3.264e-19 AAAAT AAAAT TGT
# (seqid) (start) .     .       (end)   (strand) 
# ACA AGT
# 2------*** 
# ...
import sys
import re

if len(sys.argv) < 3:
    print sys.argv[0], "LTRout new-GFF-file"
    sys.exit()

infile = open(sys.argv[1], "r")
outfile = open(sys.argv[2], "w")
cluster = ""
#print >>outfile, "##gff-version 3"
print >>outfile, "track name=LTR description=\"MGEScan-LTR\" color=0,0,255,"

for aline in infile:
    aline = aline.strip()
    words = aline.split(None)
    if len(words) == 1:
        cluster = aline[:aline.find("-")]
    else:
        if len(words) == 0:
            continue
        seqid = words[0][:words[0].rfind("_")]

        # remove file extension .fa
        seqid = seqid.replace(".fa", "")
        #if seqid[0].isdigit():
        if seqid[:3] != "chr":
            seqid = "chr" + seqid
        searchObj=re.search(r'([^.]*).([^.]*).([^.]*).([^.]*).([^.]*).fa(.*)',
                words[0], re.M|re.I)
        try:
            if len(searchObj.groups()) > 5 and searchObj.group(5) != "":
                seqid = searchObj.group(5)
                if searchObj.group(4) == "chromosome":
                    seqid = "chr" + seqid
        except:
            pass
        # id is cluster + seqid
        id = cluster + "_" + words[0]
        des = [seqid, "MGEScan_LTR", "mobile_genetic_element", words[1], words[4], ".", words[5], ".", "ID=" + id + ";name=cluster_"+cluster] 
        print >>outfile, "\t".join(des)
outfile.close()
infile.close()


