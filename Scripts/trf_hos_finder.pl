#!/usr/bin/perl
# 
# Process a TRF dat file to find potential candidates for higher order structure (HOS)
#
# Author: Keith Bradnam, Genome Center, UC Davis
# This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
#
# Last updated by: $Author: keith $
# Last updated on: $Date: 2012/03/24 05:36:28 $

use strict; use warnings;
use FindBin;
use lib $FindBin::Bin;


my $usage = "
trf_hos_finder.pl
-----------------

Usage: trf_hos_finder.pl <trf dat file>

Processes a TRF *.dat output file to look for candidate higher order structure (HOS)
Looks for following criteria:

1) More than 1 tandem repeat in a sequence
2) multiple tandem repeats occupy approximately same range in sequence
3) One repeat is approximately double the size of a shorter repeat
4) TRF score of longer repeat is at least 10% higher than score of shorter repeat
5) average %identity of repeat units within longer repeat is >2% higher than in shorter repeat

Reports details of shorter and longer repeats that satisfy criteria 1–3. Additionally adds
'hos' to penultimae column of output if either criterion 4 or 5 is met. Adds 'HOS' to output
if conditions 4 AND 5 are met (these are the most likely contenders for HOS). Use sequence
IDs to go back to raw sequence files to investigate further.

Sample output (tab delimited)
-----------------------------

In this example, sequence 2 is a strong case for HOS, and sequence 1 is a weaker case. The
'hos' or 'HOS' information is only included in the line corresponding to the longer of the
two repeats.

ID	LEVEL	START	END	LENGTH	COPIES	SCORE	%IDENT	HOS?	SEQ_ID
1	2		337		844	122		4.2		299		68				gnl|ti|2250106555 GGZG8286.b1
1	2		337		844	244		2.1		330		69		hos		gnl|ti|2250106555 GGZG8286.b1
2	2		51		948	164		5.5		590		70				gnl|ti|2250104470 GGZG7125.g1
2	2		51		951	328		2.8		735		86		HOS		gnl|ti|2250104470 GGZG7125.g1
3	2		54		641	125		4.7		467		83				gnl|ti|2250102961 GGZG6288.g1
3	2		54		641	250		2.3		479		83				gnl|ti|2250102961 GGZG6288.g1

";

die "$usage" unless (@ARGV == 1);

# keep track of how many sequences in TRF dat file
my $seq_counter = 0;

# keep track of how many repeats are found in any one sequence
# will store this data in an array
my $repeat_counter = 0; # count repeats belonging to each read
my @repeat_data;

# want to capture the (slightly processed) FASTA headers in the trf output
my $header;

# how different can start and end coordinates of 2 diff tandem repeats
# be in order to be considered occupying the same span? Default = 10 nt.
my $offset = 10;

# master hash to store all of the data for potential HOS repeats
my %hos;

# how much higher should the score of the longer repeat be in relation to shorter
# repeat. Try 15%
my $score_threshold = 1.15;

# and what about the absolute difference in %identity
# Using criteria of needing +5% in longer repeat
my $identity_threshold = 5;

################################
# MAIN LOOP OVER DAT FILE
################################

REPEAT: while(<>){

	# skip blank likes
	next if (m/^$/);

	# extract info from Sequence headers
	if (m/^Sequence: (.*)/) {
		$header = $1;
		$seq_counter++;
		
		# process previous repeats (if not at first sequence)
		process_repeats($repeat_counter) unless ($seq_counter == 1);

		# reset certain counters and data. Want to track how many repeats are seen within each sequence
		$repeat_counter = 0;
		@repeat_data = ();
	}

	# the main output that we are interested in will all be on one line which starts with various
	# numerical details of the repeat
	next unless (m/^\d+ \d+ \d+ \d+\.\d /);

	# capture repeat data into various variables (most will be unsused)
	my ($start,$end,$period,$copies,$length,$identity,$indels,$score,$a,$c,$g,$t,$entropy,$seq) = split(/\s+/);

	# if we get this far then we will capture some of the repeat data in a hash 
	# this is to potentially compare to other repeats in the same sequence
	# duplicating some info just to be lazy later on
	$repeat_data[$repeat_counter]{start}  = "$start";
	$repeat_data[$repeat_counter]{end}    = "$end";
	$repeat_data[$repeat_counter]{length} = "$length";
	$repeat_data[$repeat_counter]{key}    = "$header,$seq_counter";
	$repeat_data[$repeat_counter]{info}   = "$start,$end,$length,$copies,$score,$identity";
	$repeat_counter++;
}

# process repeats for last repeat
process_repeats($repeat_counter);


print "ID\tLEVEL\tSTART\tEND\tLENGTH\tCOPIES\tSCORE\t%IDENT\tHOS?\tSEQ_ID\n";
my $counter = 1;
HOS: foreach my $key (keys %hos){
	my ($seq_id, $seq_counter) = split(/,/,$key);

	# only want to look at sequences with multiple levels of (potential) HOS
	my $level = @{$hos{$key}};
	next if ($level == 1);

	# now loop over the different levels of HOS present
	LEVELS: for (my $i = 0; $i < @{$hos{$key}}; $i++){
		my ($start, $end, $length, $copies, $score, $identity) = split(/,/, ${$hos{$key}}[$i]);

		if ($level == 2){
			# first grab next tandem repeat in pair 
			my ($n_start, $n_end, $n_length, $n_copies, $n_score, $n_identity) = split(/,/, ${$hos{$key}}[$i+1]);

			# is score of longer repeat 10% greater compared to shorter repeat?
			# is average percentage identity of longer repeat 2% greater compared to shorter repeat?
			# print 'hos' or 'HOS' in final output to signify weak or high confidence that this is a HOS repeat

			# also need to double check whether first repeat in pair of repeats is shorter (sometimes the longer
			# repeat is reported first). If this happens, reverse scores and identities	
			my ($s1, $s2, $i1, $i2) = ($score, $n_score, $identity, $n_identity);		
			my $longer_score;
			my $shorter_score;
			my $longer_ident;
			my $shorter_ident;
			#ID	LEVEL	START	END		LENGTH	COPIES	SCORE	%IDENT	HOS?	SEQ_ID
			#1	2		73		1098	273		3.7		770		79		gnl|ti|1516245357 FAPA551217.y1
			#1	2		82		1098	137		7.4		634		67		gnl|ti|1516245357 FAPA551217.y1

			if($length > $n_length){
				($longer_score, $shorter_score) = ($score, $n_score);
				($longer_ident, $shorter_ident) = ($identity, $n_identity);
			} else{
				($longer_score, $shorter_score) = ($n_score, $score);
				($longer_ident, $shorter_ident) = ($n_identity, $identity);
			}
			
			my $hos_field;
			if ((($longer_score / $shorter_score) > $score_threshold) and 
			    (($longer_ident - $shorter_ident) > $identity_threshold)){
				$hos_field = "HOS";
			}
			elsif ((($longer_score / $shorter_score) > $score_threshold) or 
			       (($longer_ident - $shorter_ident) > $identity_threshold)){
				$hos_field = "hos";
			} else{
				$hos_field = "";
			}
			# now print info for current repeat and next one, and increment value of $i
			print "$counter\t$level\t$start\t$end\t$length\t$copies\t$score\t$identity\t$hos_field\t$seq_id\n";
			print "$counter\t$level\t$n_start\t$n_end\t$n_length\t$n_copies\t$n_score\t$n_identity\t$hos_field\t$seq_id\n";
			$i++;
		} else{
			print "$counter\t$level\t$start\t$end\t$length\t$copies\t$score\t$identity\t???\t$seq_id\n";
		}		
	}
	$counter++;
}

sub process_repeats{
	my ($repeats) = @_;

	# will add index values of potential HOS repeats to hash
	my %potential_hos;
	
	# nested loop through previous repeats. Want to see if any are multiples of another
	for (my $i = 0; $i < $repeats; $i++){
		for (my $j = $i+1; $j < $repeats; $j++){

			# want to see if current start/end coordinates are identical or within $offset nt of previous repeat
			next unless (abs($repeat_data[$i]{start} - $repeat_data[$j]{start}) <= $offset);
	 		next unless (abs($repeat_data[$i]{end}   - $repeat_data[$j]{end})   <= $offset);
	
			# $ratio is the ratio of the longest repeat to the shorter one, need longer repeat to be at least 
			# 1.85x length of shorter repeat. How we calculate this depends on whether current repeat length is 
			# longer than previous one or not
			my $ratio;
			
			if ($repeat_data[$i]{length} < $repeat_data[$j]{length}){
				$ratio = $repeat_data[$j]{length}/ $repeat_data[$i]{length};
			} else{
				$ratio = $repeat_data[$i]{length} / $repeat_data[$j]{length};
			}
			# need to factor in repeats which are not simple doublings in length
			# e.g. compare 100 nt vs 300 nt, simple ratio is 3:1, but want to rule out
			# lengths of 250 which are not multiples. So consider both ratio
			# and processed ratio
			my $processed_ratio = $ratio;
			$processed_ratio =~ s/\d+\.(\d+)/0\.$1/;
			next unless (($processed_ratio < 0.15 or $processed_ratio > 0.85) && ($ratio > 1.8));

			# we should now be looking at two repeats which exhibit HOS
			# store details as there may be other repeats in this sequence which overlap
			$potential_hos{$i} = 1;
			$potential_hos{$j} = 1;
		}
	}
	# can now add details of each repeat to main hash
	foreach my $key (keys %potential_hos){
		my $hos_key  = $repeat_data[$key]{key};
		my $hos_info = $repeat_data[$key]{info};

		push(@{$hos{$hos_key}}, $hos_info);						
	}
}
