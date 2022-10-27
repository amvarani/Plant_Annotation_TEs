#! /usr/bin/perl
#
#
# Alessandro M. Varani  
# Contact: alessandro.varani@ibcg.biotoul.fr
#
# Current Revision/Version: 1
# LAST UPDATE: 17/11/2010
#
# SCRIPT SUBJECT: extracts a substring from a fasta file
#
# usage: pick <fasta file> [b <beg>] [e <end>]
# if beg is omitted, then begin_pos = 1
# if end is omitted, then end_pos = end_sequence
# if end is omitted and beg is a negative number, the last beg positions are returned
#        
use strict 'vars';
my $condition;
my $fixed;
my $nome;
my $fastaf;
my $begin_pos;
my $end_pos;
my $real_end;
my $first_line;
my @bases;
my $i;
my $j = 1;
my @sequence;
my $sequence;

if ($#ARGV < 2) {
  print "Usage: pick <fasta file> [b <beg>] [e <end>] [n <name>] ; nargv=$#ARGV\n";
  exit(1);
};

# parse command line; not much error checking
$fastaf = $ARGV[0];
$nome = $ARGV[6];
# are all options present?
if ($#ARGV == 6) {
    $begin_pos = $ARGV[2];
    $end_pos = $ARGV[4];
}
else {
#   only b
    if ($ARGV[1] eq "b") { 
	$begin_pos = $ARGV[2];
	$end_pos = -1;
    }
    else {
#   only e
	$begin_pos = 1;
	$end_pos = $ARGV[2];
    }
}
	if ($begin_pos > $end_pos ) {
		$fixed = $begin_pos;
		$begin_pos = $end_pos ;
		$end_pos = $fixed ;
		$condition = 2;
}
	else {
		$condition = 1;
}



#print "opening $fastaf and looking for pos'ns $begin_pos-$end_pos...\n";
open (FASTAF, "<$fastaf")  or die "Could not open input file $fastaf: $!\n";

while (<FASTAF>) { 
    chomp;
    @bases = split //, $_;
    $first_line = $_;
    if ($bases[0] ne ">") {
	print "not in FASTA format.\n";
	exit(1);
    }
    else { last; }
}

$real_end = 0;
while  (<FASTAF>) {
    chomp;
    $sequence .= uc;
    $real_end += length;
    last if $end_pos != -1 && $real_end >= $end_pos;
}

if ($end_pos == -1) {
    $end_pos = $real_end;
}
elsif ($end_pos > $real_end) {
    print "Position $end_pos is beyond end of sequence (= $real_end).\n";
    exit(1);
}
if ($begin_pos < 0) {
    $begin_pos = $end_pos + $begin_pos + 1;
}


if ($condition < 2){
$sequence = substr($sequence,$begin_pos-1,$end_pos-$begin_pos+1);
@sequence = split //, $sequence;
#print "$first_line; from $begin_pos to $end_pos\n";
print "\>$nome , from $begin_pos to $end_pos\n"; 
for ($j = 0, $i = $begin_pos; $i <= $end_pos; $i++, $j++) {
    print $sequence[$i-$begin_pos];
    if (($j+1) % 60 == 0) { print "\n"; }
}
print "\n";
close(FASTAF);
exit(0);
}

else {
$sequence = substr($sequence,$begin_pos-1,$end_pos-$begin_pos+1);
@sequence = split //, $sequence;



#print "$first_line; from $begin_pos to $end_pos\n";
print "\>$nome , from $begin_pos to $end_pos - reverse\n"; 
for ($j = 0, $i = $begin_pos; $i <= $end_pos; $i++, $j++) {
    my $sequence=revseq;
    print $sequence[$i-$begin_pos]; 	
    if (($j+1) % 60 == 0) { print "\n"; }
}
print "\n";
close(FASTAF);
exit(0);
}

sub revseq {
  my ($fastaf)=$sequence;
  my $rev_seq=uc(reverse $fastaf);
  $rev_seq =~ s/G/c/g;
  $rev_seq =~ s/C/g/g;
  $rev_seq =~ s/T/a/g;
  $rev_seq =~ s/A/t/g;
  return uc $rev_seq;
}






