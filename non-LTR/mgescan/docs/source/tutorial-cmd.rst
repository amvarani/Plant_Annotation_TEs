MGEScan Command Line Interface
===============================================================================

MGEScan provides Command Line Interface (CLI) along with Galaxy Web Interface.
You can run MGEScan-LTR and MGEScan-nonLTR programs on your shell terminal.

Installation
-------------------------------------------------------------------------------

If you have installed MGEScan on Galaxy, MGEScan CLI tools are available on your system. 

.. note:: Do you need to install MGEScan? See here for :ref:`Installation <ref-mgescan-installation>`. Follow the instructions except the Galaxy. You can skip the Galaxy installation if you need MGEScan CLI tools only.

Installation in Userspace
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

It is possible to install MGEScan on userspace without root permission. Please
follow the instructions below. ``virtualenv`` is required. Create your 
virtualenv and activate it like::

   virtualenv $HOME/virtualenv/mgescan
   source $HOME/virtualenv/mgescan/bin/activate

Once your virtualenv is activated, you will see ``(mgescan)`` label in your prompt.

.. note:: Don't forget to activate your virtualenv when you open a new session.
   source $HOME/virtualenv/mgescan/bin/activate

::

   git clone https://github.com/MGEScan/mgescan.git
   cd mgescan
   python setup.py install
   
You will see a (Y/n) prompt for your input like::

   $MGESCAN_HOME is not defined where MGESCAN will be installed.
   Would you install MGESCAN at /$HOME/mgescan3 (Y/n)?

``$HOME/mgescan3`` is a default path to install MGEScan. Proceed to install 
MGEScan in the default directory ``$HOME/mgescan3``.
If you like to install MGEScan in other location, define MGESCAN_HOME environment
variable like this::

   export MGESCAN_HOME=<desired location to install mgescan>
   e.g.
   export MGESCAN_HOME=/home/abc/program/mgescan
   



Usage
-------------------------------------------------------------------------------

Try ``mgescan -h`` on your terminal:

::

  (mgescan)$ mgescan -h
  MGEScan: identifying ltr and non-ltr in genome sequences

  Usage:
          mgescan both <genome_dir> [--output=<data_dir>] [--mpi=<num>]
          mgescan ltr <genome_dir> [--output=<data_dir>] [--mpi=<num>]
          mgescan nonltr <genome_dir> [--output=<data_dir>] [--mpi=<num>]
          mgescan (-h | --help)
          mgescan --version

  Options:
          -h --help   Show this screen.
          --version   Show version.
          --output=<data_dir> Directory results will be saved

MGEScan Programs
-------------------------------------------------------------------------------

``mgescan`` CLI tool provides options to run ``ltr``, ``nonltr`` or both
programs.

How to Run
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you need to run MGEScan program to indentify both LTR and non-LTR for
certain genome sequences, simply specify the path where your input genome files
(FASTA format) exist with ``both`` sub-command.

For example, if you have DNA sequences (FASTA) for Fruitfly (Drosophila
melanogaster) under ``$HOME/dmelanogaster`` directory, and want to save
results in the ``$HOME/mgescan_result_dmelanogaster``, your may run ``mgescan``
command like so::


  (mgescan)$ mgescan both $HOME/dmelanogaster --output=$HOME/mgescan_result_dmelanogaster


The expected output message is like so::

        ltr: starting
        nonltr: starting
        nonltr: finishing (elapsed time: 306.881129026)
        ltr: finishing (elapsed time: 1306.881129026)


MPI Option
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

If your system supports a MPI program, you can use ``--mpi`` option with a
number of processes. Use half number of your cores.

Input Files (FASTA)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

The input can be a single file with a single sequence or multiple sequences.
Store your input DNA sequences in a same folder and specify the path when you
run MGEScan program. For example, if you run the program for D. melanogaster,
you may have sequence files like so::

        $ ls -al dmelanogaster
        total 167564
        drwx------  2 mgescan mgescan     4096 Jan 28 23:23 .
        drwx------ 13 mgescan mgescan     4096 Apr  7 18:45 ..
        -rw-------  1 mgescan mgescan 23395126 Dec 18  2014 2L.fa
        -rw-------  1 mgescan mgescan 21499210 Dec 18  2014 2R.fa
        -rw-------  1 mgescan mgescan 24952673 Dec 18  2014 3L.fa
        -rw-------  1 mgescan mgescan 28370194 Dec 18  2014 3R.fa
        -rw-------  1 mgescan mgescan  1374441 Dec 18  2014 4.fa
        -rw-------  1 mgescan mgescan 22796595 Dec 18  2014 X.fa
        -rw-------  1 mgescan mgescan  2796595 Dec 18  2014 Y.fa

Results
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Upon the succeessful completion of MGEScan program, several output files are
stored in the destination directory that you specified with ``--output``
parameter.  It includes plain text and gff3 files.

``ltr.out``
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

MGEScan LTR generates ``ltr.out`` to describe clusters and coordinates of LTR
retrotransposons identified. Each cluster of LTR retrotransposons starts with
the head line of [cluster_number]---------, followed by the information of LTR
retrotransposons in the cluster. The columns for LTR retrotransposons are as
follows.

1. LTR_id: unique id of LTRs identified. It consist of two components, sequence
   file name and id in the file. For example, chr1_2 is the second LTR
   retrotransposon in the chr1 file.
2. start position of 5 LTR.
3. end position of 5 LTR.
4. start position of 3 LTR.
5. end position of 3 LTR.
6. strand: + or -.
7. length of 5 LTR.
8. length of 3 LTR.
9. length of the LTR retrotransposon.
10.TSD on the left side of the LTR retotransposons.
11.TSD on the right side of the LTR retrotransposons.
12.di(tri)nucleotide on the left side of 5LTR
13.di(tri)nucleotide on the right side of 5LTR
14.di(tri)nucleotide on the left side of 3LTR
15.di(tri)nucleotide on the right side of 3LTR


Sample output of ``ltr.out`` for D. melanogaster

:download:`ltr.out <sample_ltr_out.txt>`


