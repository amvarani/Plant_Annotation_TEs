import os
import argparse
import multiprocessing
from multiprocessing import Pool


parser = argparse.ArgumentParser()#pylint: disable=invalid-name
parser.add_argument("-g", "--genomeFile", help="Genome file in fasta format", required=True)
parser.add_argument("-name", "--genomeName", help="Genome Name", required=True)
parser.add_argument("-p", "--path", help="Source code path", required=True)
parser.add_argument("-t", "--processer", help="Number of processer", required=True)
parser.add_argument("-d", "--currentD", help="Path of current directory", required=True)
parser.add_argument("-s", "--species", help="One of the following: Maize , Rice or others", required=True)

args = parser.parse_args()#pylint: disable=invalid-name

genome_file = args.genomeFile
genome_Name = args.genomeName
path=args.path
t=args.processer
dir=args.currentD
spliter="-+-"
targetDir=dir+"/"+genome_Name+"/"
os.chdir(targetDir)
species=args.species

if species == "others":
    species="Maize"

#mkDB="makeblastdb -in %s -out %s -dbtype nucl"%(genome_file,genome_file+spliter+"db") #shujun
mkDB="makeblastdb -in %s -out %s -parse_seqids -dbtype nucl 2>/dev/null"%(genome_file,genome_file+spliter+"db") #shujun
os.system(mkDB) #shujun
genomedb=genome_file+spliter+"db" #shujun

def BlastRef(arglist):
    genomefile=arglist[0]
    genomeName=arglist[1]
    refLib=arglist[2]
    path=arglist[3]
  #  blast = "blastn -query %s -db %s -num_threads %s -outfmt=7 -out %s" % (path+"/RefLib/"+refLib , genomedb, int(t), targetDir+genomeName+spliter+"blast"+spliter+refLib) #shujun
    blast = "blastn -max_hsps 5 -perc_identity 80 -qcov_hsp_perc 100 -query %s -db %s -num_threads %s -outfmt '7 qacc sacc length pident gaps mismatch qstart qend sstart send evalue qcovhsp' -out %s 2>/dev/null" % (path+"/RefLib/"+refLib , genomedb, int(t), targetDir+genomeName+spliter+"blast"+spliter+refLib) #shujun
  #  blast = "blastn -query %s -db %s -num_threads %s -outfmt '7 qseqid sseqid length pident gaps mismatch qstart qend sstart send evalue qcovhsp' -out %s" % (path+"/RefLib/"+refLib , genomedb, int(t), targetDir+genomeName+spliter+"blast"+spliter+refLib) #shujun
  #  blast = "blastn -query %s -subject %s -outfmt '7 qseqid sseqid length pident gaps mismatch qstart qend sstart send evalue qcovhsp' -out %s" % (path+"/RefLib/"+refLib , genomefile, targetDir+genomeName+spliter+"blast"+spliter+refLib)
    os.system(blast)




if __name__ == '__main__':
    genome_file = args.genomeFile
    genome_Name = args.genomeName
    path=args.path
    t=args.processer
    dir=args.currentD
    ref_list=[species+"_DTA_RefLib",species+"_DTC_RefLib",species+"_DTH_RefLib",species+"_DTM_RefLib",species+"_DTT_RefLib"]
    arglist=[[genome_file,genome_Name,i,path] for i in ref_list]
    pool = multiprocessing.Pool(int(t))
    pool.map(BlastRef,arglist)
    pool.close()
    pool.join()


def getFile(genomeName):
    for i in ["DTA", "DTC", "DTH", "DTM", "DTT"]:
        oldname=targetDir+genomeName+spliter+"blast"+spliter+"%s_%s_RefLib" % (species, i)
        newname=oldname+spliter+"tem"
        f = open(oldname , "r+")
        o = open(newname , "w")
        lines = f.readlines()
        for line in lines:
            if (line[0] != "#"):
                o.write(line)
        f.close()
        o.close()
#    cat="cat *tem > tem_blastRestul"
    cat="for i in *tem; do cat $i; done > tem_blastRestul" #shujun
    os.system(cat)

getFile(genome_Name)

