import os
import sys
import time
import subprocess as sub
from setuptools import setup
from setuptools.command.bdist_egg import bdist_egg 
def cmd_exists(cmd):
    return sub.call(["which", cmd], stdout=sub.PIPE, stderr=sub.PIPE) == 0

class MGEScanInstall(bdist_egg):
    def run(self):
        if cmd_exists("make") and cmd_exists('gcc') and cmd_exists('g++'):
            os.system("cd mgescan/ltr/MER; make clean; make")
            os.system("cd mgescan/nonltr/; make clean; make translate")
            os.system("cd mgescan/nonltr/hmm;make clean; make")
        else:
            print ("[Warning] make|gcc|g++ does not exist. Compile code is skipped")
            time.sleep(3)
        if cmd_exists("mpicc"):
            os.system("cd mgescan;mpicc mpi_mgescan.c -o mpi_mgescan")
        else:
            print ("[Warning] mpicc does not exist. Compile mpi code is"\
                    + " skipped")
            time.sleep(3)
        if not os.environ.get('MGESCAN_HOME'):
             print ("$MGESCAN_HOME is not defined where MGESCAN will be" + \
                     " installed.")
             def_home = raw_input("Would you install MGESCAN at " + \
                     os.environ.get("HOME") + "/mgescan3 (Y/n)?")
             if def_home.lower() == 'n':
                 print ("Run 'export MGESCAN_HOME=<your desired destination" + \
                         " path to install>' if you want to install somewhere"+\
                         " else\n")
                 sys.exit()
             os.environ['MGESCAN_HOME'] = os.environ.get('HOME') + "/mgescan3"
        if os.environ.get('MGESCAN_HOME') and not os.environ.get("MGESCAN_SRC"):
            os.environ['MGESCAN_SRC'] = os.environ.get('MGESCAN_HOME') + "/src"
            if not os.path.exists(os.environ.get("MGESCAN_SRC")):
                os.makedirs(os.environ.get("MGESCAN_SRC"), 0755)
        if os.environ.get("MGESCAN_SRC"):
            os.system("cp -pr * $MGESCAN_SRC")

        bdist_egg.run(self)

class MGEScanInstallOnly(bdist_egg):
    def run(self):
        bdist_egg.run(self)

def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()

reqs = [line.strip() for line in open('requirements.txt')]
setup(
        name = "MGEScan",
        version = "3.0.0",
        author = "Hyungro Lee",
        author_email = "hroe.lee@gmail.com",
        description = ("MGEScan on Galaxy Workflow System for identifying ltr and "
            "non-ltr in genome sequences"),
        license = "GPLv3",
        keywords = "MGEScan, Galaxy workflow",
        url = "https://github.com/MGEScan/mgescan",
        packages = ['mgescan'],
        install_requires = reqs,
        long_description = read('README.md'),
        classifiers=[
            "Development Status :: 3 - Alpha",
            "Topic :: Scientific/Engineering",
            "Intended Audience :: Developers",
            "Intended Audience :: Science/Research",
            "License :: OSI Approved :: GNU GEneral Public License v3 (GPLv3)",
            "Operating System :: POSIX :: Linux",
            "programming Language :: Python",
            ],
        entry_points='''
            [console_scripts]
            mgescan=mgescan.cmd:main
            mg_split=mgescan.split:main
            nonltr=mgescan.nonltr:main
            ''',

        cmdclass={'bdist_egg': MGEScanInstall},  # override bdist_egg
        )

