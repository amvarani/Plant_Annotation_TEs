#!/usr/bin/perl
#
# ISFinder Team - http://www-is.biotoul.fr
#
# Citation:
#  ISfinder: the reference center for bacterial insertion sequences
#  P.Siguier, J Perochon, L.Lestrade, J. Mahilon and M. Chandler 
#  Nucleic Acids Research. 2006. Vol. 34. Database Issue
#  doi: 10.1093/nar/gkj014
#
# Alessandro M. Varani  
# Contact: alessandro.varani@ibcg.biotoul.fr
#
# Current Revision/Version: 1
# LAST UPDATE: 17/11/2010
#
# SCRIPT SUBJECT: This program receives a FASTA sequence as standard input with several sequences
# and breaks it in different FASTA files, one per each sequence.
#

use strict;

#
# immediate output flush
#
$| = 1;

#
# test number of parameters
#
if (@ARGV != 1)
  {
    print STDERR "Usage: $0 ";
    print STDERR "<directory to store fastas>\n";
    exit 1;
  }

#
# variables related to parameters and errors
#
my $target_dir          = $ARGV[0];

my $problem_target_dir  = 0;

#
# test parameters and print errors
#
if (!-e "$target_dir")
  {
    $problem_target_dir = 1;
    print STDERR "Directory $target_dir does not exist\n";
  }

#
# exit if problems
#
if ($problem_target_dir)
  {

    exit 1;
    
  }

#
# change input record separator
#
$/ = ">";

#
# read FASTA input
#
while (<STDIN>)
  {

    # remove record separator
    chomp $_;

    # retrieve ID
    my $fasta_id;
    my $record = $_;

    if ($record =~ /^(.*?)\s+/s)
      {
	$fasta_id = $1;
      }
    else
      {
	if ($record =~ /^\s*$/)
	  {
	    # empty record
	    next;
	  }
	else
	  {
	    die "Invalid header format of fasta $record\n";
	  }
      }

    # generate FASTA file
    if (!open (FASTAFILE, "> $target_dir/$fasta_id.fasta"))
      {
	die "Problems when opening file $target_dir/$fasta_id.fasta: $!";
      }
    else
      {
	print FASTAFILE ">$record";
      }

    # close file
    close FASTAFILE;

  }

# exit
exit 0;
