"""MGEScan: identifying ltr and non-ltr in genome sequences

Usage:
    mgescan both <genome_dir> [--output=<data_dir>] [--mpi=<num>] [--debug]
    mgescan ltr <genome_dir> [--output=<data_dir>] [--mpi=<num>] [--debug]
    mgescan nonltr <genome_dir> [--output=<data_dir>] [--mpi=<num>] [--debug]
    mgescan (-h | --help)
    mgescan --version

Options:
    -h --help   Show this screen.
    --version   Show version.
    --output=<data_dir> Directory results will be saved
    --debug     Enable debugging messages

"""
import os, sys
from docopt import docopt
from multiprocessing import Process
from subprocess import check_call, Popen, PIPE
from mgescan import utils
from mgescan.split import Split
import shutil
import time
import math

class MGEScan(object):
    """ MGEScan runs mgescan for identifying ltr and nonltr in genome
    sequence """

    default_output_path = "./output"
    genome_dir = None
    data_dir = None
    ltr_enabled = False
    nonltr_enabled = False
    debug = False

    args = None

    def __init__(self, args):
        self.args = args
        self.set_inputs()
        self.set_defaults()
        self.get_env()
        self.set_debug()
        self.check_tools()

    def check_tools(self):
        utils.check_cmd('trf')
        utils.check_cmd('hmmsearch')
        utils.check_cmd('matcher')
        utils.check_cmd('transeq')

    def set_inputs(self):
        self.data_dir = utils.get_abspath(self.args['--output'])
        self.genome_dir = utils.get_abspath(self.args['<genome_dir>'])
        self.ltr_enabled = self.args['ltr']
        self.nonltr_enabled = self.args['nonltr']
        self.mpi_enabled = self.args['--mpi']
	if(self.mpi_enabled and not self.ltr_enabled and not self.nonltr_enabled):
        	self.mpi_enabled = str(int(math.ceil(1.0*int(self.args['--mpi'])/2)))
        self.debug = self.args['--debug']

    def set_defaults(self):
        """Set default values to run programs

        For LTR,
        min_dist: minimum distance(bp) between LTRs.
        max_dist: maximum distance(bp) between LTRS
        min_len_ltr: minimum length(bp) of LTR.
        max_len_ltr: maximum length(bp) of LTR.
        ltr_sim_condition: minimum similarity(%) for LTRs in an element.
        cluster_sim_condition: minimum similarity(%) for LTRs in a cluster
        len_condition: minimum length(bp) for LTRs aligned in local alignment.
        """

        if self.data_dir:
            self.data_dir = utils.create_directory(self.data_dir, False)
        else:
            self.data_dir = \
            utils.create_directory(utils.get_abspath(self.default_output_path))

        self.hmmerv = 3
        self.min_dist = 2000
        self.max_dist = 20000
        self.min_len_ltr = 130
        self.max_len_ltr = 2000
        self.ltr_sim_condition = 70
        self.cluster_sim_condition = 70
        self.len_condition = 70

        self.sw_rm = "No" # or Yes
        self.scaffold = "" # or directory

    def get_env(self):
        if os.environ.get("MGESCAN_HOME") and not os.environ.get("MGESCAN_SRC"):
            os.environ['MGESCAN_SRC'] = os.environ.get("MGESCAN_HOME") + "/src"
        if not os.environ.get('MGESCAN_SRC'):
            print ("MGEScan environment variable is not defined or .mgescanrc is not sourced.")
            print (os.environ.get("HOME")+"/mgescan3 (default path) is used"+ \
            " to run MGEScan")
            os.environ['MGESCAN_HOME'] = os.environ.get("HOME")+"/mgescan3"
            os.environ['MGESCAN_SRC'] = os.environ.get("MGESCAN_HOME") + "/src"
            if not os.path.exists(os.environ.get("MGESCAN_SRC")):
                print (os.environ.get("MGESCAN_SRC") + " does not exist." + \
                " MGEScan stopped")
                sys.exit(-1)
        self.base_path = os.environ.get('MGESCAN_SRC') + "/mgescan"
        self.hmmerv = os.environ.get("MGESCAN_HMMER_VERSION") or self.hmmerv
        self.min_dist = os.environ.get("MGESCAN_MIN_DISTANCE") or self.min_dist
        self.max_dist = os.environ.get("MGESCAN_MAX_DISTANCE") or self.max_dist
        self.min_len_ltr = os.environ.get("MGESCAN_MIN_LENGTH_LTR") or self.min_len_ltr
        self.max_len_ltr = os.environ.get("MGESCAN_MAX_LENGTH_LTR") or self.max_len_ltr
        self.ltr_sim_condition = os.environ.get("MGESCAN_LTR_SIMILARITY") or self.ltr_sim_condition
        self.cluster_sim_condition = os.environ.get("MGESCAN_LTR_SIMILARITY_CLUSTER") or self.cluster_sim_condition
        self.len_condition = os.environ.get("MGESCAN_MIN_LENGTH") or self.len_condition
        self.sw_rm = os.environ.get("MGESCAN_REPEATMASKER") or self.sw_rm
        self.scaffold = os.environ.get("MGESCAN_SCAFFOLD_DIR") or self.scaffold
         
    def set_debug(self):
        if self.debug:
            os.environ["MGESCAN_DEBUG"] = "True"
           
    def wrapper_split_files(self):
        split = Split()
        split.set_input(self.genome_dir)
        new_genome_dir = split.set_output(self.genome_dir + "/divided-genome")
        split.split_files()
        self.genome_dir =  new_genome_dir

    def run(self):
        # split a large file
        self.wrapper_split_files()

        # ltr
        if not self.nonltr_enabled:
            p1 = Process(target=self.ltr)
            p1.start()
        # nonltr
        if not self.ltr_enabled:
            p2 = Process(target=self.nonltr)
            p2.start()
        if 'p1' in locals():
            p1.join()
        if 'p2' in locals():
            p2.join()

        # remove splitted files
        shutil.rmtree(self.genome_dir)

    def ltr(self):
        print 'ltr: starting'
        start = time.time()

        # scaffold
        # repeatmasker
        cmd0 = self.base_path + "/ltr/pre_process.pl \
                -genome=%(genome_dir)s \
                -data=%(data_dir)s \
                -sw_rm=%(sw_rm)s \
                -scaffold=%(scaffold)s"
        res0 = self.run_cmd(cmd0)

        # find-ltr
        cmd1 = self.base_path + "/ltr/find_ltr.pl \
                -genome=%(genome_dir)s \
                -data=%(data_dir)s \
                -hmmerv=%(hmmerv)s \
                -min_dist=%(min_dist)s \
                -max_dist=%(max_dist)s \
                -min_len_ltr=%(min_len_ltr)s \
                -max_len_ltr=%(max_len_ltr)s \
                -ltr_sim_condition=%(ltr_sim_condition)s \
                -cluster_sim_condition=%(cluster_sim_condition)s \
                -len_condition=%(len_condition)s"
        if self.mpi_enabled:
            cmd1 = (cmd1 + " -mpi=%(mpi_enabled)s")
        res1 = self.run_cmd(cmd1)

        # gff3
        self.ltr_out_path = utils.get_abspath(self.data_dir + "/ltr/ltr.out")
        self.ltr_gff_path = utils.get_abspath(self.data_dir + "/ltr/ltr.gff3")
        cmd2 = self.base_path + "/ltr/toGFF.py %(ltr_out_path)s %(ltr_gff_path)s"
        res2 = self.run_cmd(cmd2)

        end = time.time()
        print ('ltr: finishing (elapsed time: {0} secs)'.format(int(round(end -
            start))))

    def nonltr(self):
        print 'nonltr: starting'
        start = time.time()

        # nonltr
        #cmd0 = self.base_path + "/nonltr/run_MGEScan.pl \
        #        -genome=%(genome_dir)s \
        #        -data=%(data_dir)s \
        #        -hmmerv=%(hmmerv)s"
        cmd0 = "python " + self.base_path + "/nonltr/nonltr.py " + \
                "%(genome_dir)s " + \
                "%(data_dir)s "

        if self.mpi_enabled:
            #cmd0 = (cmd0 + " -mpi=%(mpi_enabled)s")
            cmd0 = (cmd0 + " --mpi=%(mpi_enabled)s")
        res0 = self.run_cmd(cmd0)
        
        # gff3
        self.nonltr_out_path = utils.get_abspath(self.data_dir + "/info/full/")
        self.nonltr_gff_path = utils.get_abspath(self.data_dir + "/info/nonltr.gff3")
        cmd1 = self.base_path + "/nonltr/toGFF.py %(nonltr_out_path)s %(nonltr_gff_path)s"
        res1 = self.run_cmd(cmd1)

        end = time.time()
        print ('nonltr: finishing (elapsed time: {0} secs)'.format(int(round(end -
            start))))

    def run_cmd(self, cmd):
        cmd = cmd % vars(self)
        if self.debug:
            print (cmd)
        #p = Popen(cmd.split(), stdin=PIPE, stdout=PIPE, stderr=PIPE)
        #std_msgs = p.communicate()
        try:
            retcode = check_call(cmd.split())
            if retcode != 0:
                print >>sys.stderr, "%s was terminated by signal" % cmd, -retcode
            #else:
            #    print >>sys.stderr, "Returned", retcode
        except OSError as e:
            print >>sys.stderr, "Failed:", e
	return retcode

def main():
    arguments = docopt(__doc__, version='MGEScan 3.0.0')
    mge = MGEScan(arguments)
    mge.run()

if __name__ == "__main__":
    main()
