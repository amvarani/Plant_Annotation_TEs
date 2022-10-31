#!/usr/bin/perl
#
# trf_wrapper.pl
#
# A script to run the tandem repeat finder (trf) program and format the output
# acccording to our needs
#
# Last updated by: $Author: keith $
# Last updated on: $Date: 2011/07/12 20:49:06 $

use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use Keith;
use FAlite;
use Getopt::Long;


###############################
#
#  Command-line options
#
################################

my $file; # specify one input file
my $allfiles; # use current directory for data files
my $match;
my $mismatch;
my $indel;
my $pmatch;
my $pindel;
my $min_score;
my $max_period;
my $min_copies; # minimum number of copies of repeat in read
my $min_length; # minimum length of repeat unit
my $low_repeat_cutoff; # what percentage of the read length should be occupied by repeats?
my $high_repeat_cutoff; # what fraction of read length will we use for our 'high repeat fraction' repeats
my $output_number; # allow the numbering of tandem repeats in output file to start from the last number used
my $slim; # remove duplicates from trf file and create a new 'slim' trf file
my $help; # print help

GetOptions ("file=s"      => \$file,
			"allfiles"    => \$allfiles,
			"match:i"     => \$match,
            "mismatch:i"  => \$mismatch,
            "indel:i"     => \$indel,
            "pmatch:i"    => \$pmatch,
			"pindel:i"    => \$pindel,
            "min_score:i" => \$min_score,
            "period:i"    => \$max_period,
            "copies:f"    => \$min_copies,
            "length:i"    => \$min_length,
		    "low_repeat_cutoff:f" => \$low_repeat_cutoff,
		    "high_repeat_cutoff:f" => \$high_repeat_cutoff,
		    "output_number:i" => \$output_number,
		    "slim"        => \$slim,
		    "help"        => \$help
			);



###############################
#
# Set defaults
#
################################

# set defaults if not specified on command line
# these are all defaults used (and suggested) by the trf program
$match = 1    if (!$match);
$mismatch = 1 if (!$mismatch);
$indel = 2    if (!$indel);
$pmatch = 80  if (!$pmatch);
$pindel = 5   if (!$pindel);
$min_score = 200  if (!$min_score); 
$max_period = 750 if (!$max_period);
$output_number = 0 if (!$output_number); 

# these are extra options that we can only implement through post-processing of raw trf output
$min_copies = 2 if (!$min_copies);
$min_length = 50  if (!$min_length);
$low_repeat_cutoff = 0.5  if (!$low_repeat_cutoff);
$high_repeat_cutoff = 0.8 if (!$high_repeat_cutoff);

print STDERR "\n# $0 started at ", `date`, "\n";


###############################
#
# Check command line options
#
################################

die "Specify -file option for single fasta file, or -allfiles option to process all files in current directory\n" if ($file && $allfiles);
die "low_repeat_cutoff must be lower than high_repeat_cutoff\n" if ($low_repeat_cutoff >= $high_repeat_cutoff);

# usage
my $usage = "
usage: trf_wrapper.pl [options]
options:
  -file <fasta file>
  -allfiles <directory name containing fasta files>
  -match [$match]
  -mismatch [$mismatch]
  -indel [$indel]
  -pmatch (probability of match) [$pmatch]
  -pindel (probability of indel) [$pindel]
  -min_score [$min_score]
  -period (maximum period length) [$max_period]
  -copies (minimum copies) [$min_copies]
  -length (minimum repeat length) [$min_length]
  -low_repeat_cutoff (minimum proportion of trace read that has to be repeat) [$low_repeat_cutoff]
  -high_repeat_cutoff (proportion of trace read that has to be repeat for HRF file) [$high_repeat_cutoff]
  -slim : remove duplicates from final trf output file and make a new 'slim' file
  -help : print this help
";

die $usage if ($help);
die $usage unless ($file or $allfiles);


# if we have one file (-file option) add to @files array and loop through that
# otherwise add all fasta files in current directory to @files array
my @files;
@files = ($file) if ($file);
if($allfiles){
	print STDERR "Looking for *processed_traces.fa files in current directory to process\n";
	@files = glob("*processed_traces*.fa")
}



###############################
#
# Variables
#
###############################

my @param = ($match, $mismatch, $indel, $pmatch, $pindel, $min_score, $max_period);

my %seq_to_length; # need to know lengths of all sequences, key to hash is the fasta header
my %errors; # Keep track of various errors
$errors{'repeat_length'} = $errors{'min_copies'} = $errors{'min_repeat_fraction'} = $errors{'length_multiple'} = 0;

my $file_counter = 0; # keep track of how many files are processed
my $seq_counter = 0; # how many input sequences do we process
my $repeat_counter = 0; # number of tandem repeats predicted by trf
my $output_counter = 0; # number of tandem repeats that pass all filters (this might be the same as $output_number if -output_number is not used)
my ($total_nt, $excluded_trf_nt, $low_trf_nt, $high_trf_nt) = (0,0,0,0); # keep track of the total size of sequence in the input files, and the high/low trf output files



###############################
#
# Loop through input file(s)
#
###############################

foreach my $fasta (@files){
	print STDERR "Processing $fasta\n";
	$file_counter++;
		
	# form name of output file from parameters
	my $data_file  = $fasta . "." . join(".", @param) . ".dat";

	# We may already have run trf on the same sequence file and just want to tweak the parameters for deciding which
	# repeats to keep, so can make the script use an existing data file if one exists
	if(-e $data_file){
		print STDERR "\tNOTE: A data file with the chosen parameters already exists ($data_file), will use this instead of re-running trf\n";
	}
	else{
		system("trf $fasta $match $mismatch $indel $pmatch $pindel $min_score $max_period -d -h > /dev/null") or die "Can't run trf\n";
	}		
	
	# now process trf output file
	process_trf_output($fasta, $data_file);

}



##############################################################
#
# Combine separate trf files
#
###############################################################

print STDERR "Combining separate *high.trf files into one main output file\n";

my ($species) = $files[0] =~ m/(.*)_processed_traces/;
my $trf_file = "$species.high.trf";
if(-e $trf_file){
	print STDERR "\tNOTE: $trf_file already exists, will use existing file\n";
}
else{
	print STDERR "Combining separate TRF files into one output file\n";	
	system("cat *processed_traces*high.trf > $trf_file") && die "Couldn't concatenate trf files into $trf_file\n";
}


###############################
#
# Print summary statistics
#
################################

# if we haven't processed the files because they already existed, then there is no point in printing out error counts
# as they will all be zero

if ($seq_counter == 0){
	print STDERR "\n# $0 finished at ", `date`, "\n";
	exit(0);
}

# Statistics on what was rejected/outside of thresholds
my $total_rejections = $errors{'repeat_length'} + $errors{'min_copies'} + $errors{'min_repeat_fraction'} + $errors{'length_multiple'};
print STDERR "\nProcessed $seq_counter sequences in $file_counter files that contained $repeat_counter repeats";
print STDERR ", $output_counter of which matched all criteria\n";
print STDERR "$total_rejections repeats rejected for failing criteria:\n";
print STDERR "\t$errors{'min_repeat_fraction'} repeats rejected for making up too low a fraction of the total sequence (<$low_repeat_cutoff)\n";
print STDERR "\t$errors{'repeat_length'} repeats rejected for being too short (<$min_length nt)\n";
print STDERR "\t$errors{'min_copies'} repeats rejected for having too few copies (<$min_copies)\n";
print STDERR "\t$errors{'length_multiple'} repeats rejected for being a multiple of a shorter repeat\n\n";

# What fraction of the original input sequences consist of tandem repeats?
my $high_percent      = sprintf("%.2f",($high_trf_nt / $total_nt)*100);
my $low_percent       = sprintf("%.2f",($low_trf_nt / $total_nt)*100);
my $excluded_percent  = sprintf("%.2f",($excluded_trf_nt / $total_nt)*100);
print STDERR "Total amount of input sequence: $total_nt nt\n";
print STDERR "Total amount of tandem repeats in high repeat fraction (>$high_repeat_cutoff): ", int($high_trf_nt), " nt ($high_percent%)\n";
print STDERR "Total amount of tandem repeats in low repeat fraction (>$low_repeat_cutoff): ", int($low_trf_nt), " nt ($low_percent%)\n";
print STDERR "Total amount of tandem repeats in excluded repeat fraction (<$low_repeat_cutoff): ", int($excluded_trf_nt), " nt ($excluded_percent%)\n\n";


###############################################################
#
# Remove duplicate sequences from combined trf file
#
###############################################################

# this step will produce a *.slim.trf which will remove identical duplicates
# and add a count of the duplicates in the FASTA header. This can sometimes half the size
# of the trf output file
remove_duplicates($trf_file) if ($slim);


print STDERR "\n# $0 finished at ", `date`, "\n";
exit(0);



###############################
#
#
#   S U B R O U T I N E S
#
#
################################


sub process_trf_output{

	my ($file,$data) = @_;
	
	# want to capture the (slightly processed) FASTA headers in the trf output
	my $header;

	# can skip this step if files already exist
	if(-e "$file.high.trf" && -e "$file.low.trf"){
		print STDERR "\tNOTE: Both *.trf output files already exists, skipping\n";
		return;
	}
	
	# now need to capture lengths of all sequences in input file (frustratingly, this is not in the TRF output)
	calculate_seq_lengths($file);
	
	# two output streams, one for repeats which make up a high repeat fraction (HRF) of the read
	# and one for repeats which make up a low repeat fraction (LRF). These might contain repeat
	# boundaries
	open(OUT1,">$file.high.trf") or die "Can't open hrf output file\n";
	open(OUT2,">$file.low.trf") or die "Can't open lrf output file\n";
	open(DATA,"<$data") or die "Can't open data file\n";


	my $seq_repeat_counter; # to keep track of when a sequence contains more than one repeat
	my @seq_repeat_data; # keep track of data on all repeats in a sequence to see if they are just multiples of each other

	REPEAT: while(<DATA>){

		# skip blank likes
		next if (m/^$/);

		if (m/^Sequence: (.*)/) {
			$header = $1;
			$seq_counter++;

			# reset certain counters and data
			$seq_repeat_counter = 0;
			@seq_repeat_data = ();

			# and now move to next line in file
			next REPEAT;
		}

		# the main output that we are interested in will all be on one line which starts with various
		# numerical details of the repeat
		if(m/^\d+ \d+ \d+ \d+\.\d /){
			$repeat_counter++;

			# capture repeat data into various variables (most will be unsused)
			my ($start,$end,$period,$copies,$consensus,$matches,$indels,$score,$a,$c,$g,$t,$entropy,$repeat_seq) = split(/\s+/);

			my $repeat_length = length($repeat_seq);
			my $total_repeat_span = $end - $start + 1;
			my $repeat_fraction = $total_repeat_span / $seq_to_length{$header};

			my $tidied = Keith::tidy_seq($repeat_seq);


			###################################################################
			# now apply various criteria to see if we want to keep this repeat
			###################################################################

			# does the repeat occupy enough of the read that it is contained in?
			if ($repeat_fraction < $low_repeat_cutoff){
				$errors{"min_repeat_fraction"}++;
				$excluded_trf_nt += ($copies * $repeat_length);
				next REPEAT;
			}

			# is the repeat unit long enough? We certainly want to dicount tandem monomers, dimers etc.
			if ($repeat_length < $min_length){
				$errors{"repeat_length"}++;
				next REPEAT;
			}

			# are there enough copies of the repeat in the read?
			if ($copies < $min_copies){
				$errors{"min_copies"}++;
				next REPEAT;
			}

			# if we get this far then we will capture some of the repeat data in a hash 
			# this is to potentially compare to other repeats in the same sequence
			$seq_repeat_counter++;
			$seq_repeat_data[$seq_repeat_counter]{'coords'} = "$start $end";
			$seq_repeat_data[$seq_repeat_counter]{'consensus'} = "$consensus";
			$seq_repeat_data[$seq_repeat_counter]{'copies'} = "$copies";

			# Is this repeat just a multiple of a previously seen repeat in the same trace sequence?
			if ($seq_repeat_counter > 1){
				# loop through previous repeats
				for(my $i = 1; $i < @seq_repeat_data;$i++){

					if("$start $end" eq $seq_repeat_data[$i]{'coords'}){
						my $result = $consensus / $seq_repeat_data[$i]{'consensus'};
						my $processed_result = $result;
						$processed_result =~ s/\d+\.(\d+)/0\.$1/;

						# we are not expecting one repeat to be a perfect multiple of another repeat, so we'll allow 
						# some flexibility. 
						if(($processed_result < 0.15 || $processed_result > 0.85) && ($result > 1.5)){
	#						print "$header\tRepeat $seq_repeat_counter: span = $start $end, consensus length = $consensus, copies = $copies\tTHIS IS A MULTIPLE ($result) OF:\n";
	#						print "$header\tRepeat $i: span = $seq_repeat_data[$i]{'coords'}, consensus length = $seq_repeat_data[$i]{'consensus'}, copies = $seq_repeat_data[$i]{'copies'}\n";	
							$errors{"length_multiple"}++;
							next REPEAT;						
						}
					}
				}
			}

			# if we are here then we are keeping the repeat and printing it out
			$output_counter++;
			$output_number++;

			my $formatted = sprintf("%.0f",$repeat_fraction * 100);
			# which output file will the repeats go in?
			if($repeat_fraction > $high_repeat_cutoff){
				$high_trf_nt += ($repeat_length * $copies);
				print OUT1 ">tandem-$output_number N=$copies L=$repeat_length F=$formatted% P=$header\n";
				print OUT1 "$tidied\n";			
			}
			else{
				$low_trf_nt += ($repeat_length * $copies);
				print OUT2 ">tandem-$output_number N=$copies L=$repeat_length F=$formatted% P=$header\n";
				print OUT2 "$tidied\n";
			}
		}
	}
	close(OUT1);
	close(OUT2);
	close(DATA);
}



###############################################################
#
# Remove duplicate sequences from combined trf file
#
###############################################################

sub remove_duplicates{	

	my ($trf_file) = @_;
	# all data will be stored in an array of hashes
	my @data;
	my $counter = 0;

	# Loop through input file, capturing sequences, headers, and copy number of each repeat
	open(FASTA,"$trf_file") or die "Can't open $trf_file\n";
	my $FA = new FAlite (\*FASTA);
	while (my $entry = $FA->nextEntry) {
		$data[$counter]{'seq'} = $entry->seq;
		$data[$counter]{'def'} = $entry->def;

		# get copy number from header
		($data[$counter]{'N'}) = $entry->def =~ />tandem-\d+ N=(\S+)/;
		$counter++;
	}       
	close(FASTA);

	# if we have an empty file we can exit 
	if($counter == 0){
		print "WARNING: $trf_file is empty\n";
		return(0);
	}

	# now loop through @data structure to find duplicate entries
	my $duplicates = 0;
	my $partial_matches = 0;
	my $forward = 0;
	my $reverse = 0;
	my $i = 0;

	foreach my $entry (@data){
		my $seq1 = ${$entry}{'seq'};

		my $j=-1;
		INNER:foreach my $entry2 (@data){		
			$j++;

			my $seq2 = ${$entry2}{'seq'};

			# skip self comparison and also skip if they are not the same length, just focus on identical same-length repeats
			next INNER if ($i == $j);
			next INNER if (length($seq1) != length($seq2));

			# form a tandem repeat and see if they match (check forward and reverse complemented)
			my $tandem = $seq2 	. $seq2;
			my $revcomp = Keith::revcomp($tandem);
			$forward++ if ($tandem =~ m/$seq1/);
			$reverse++ if ($revcomp =~ m/$seq1/);

			if(($tandem =~ m/$seq1/) or ($revcomp =~ m/$seq1/)){
				${$entry}{'N'} += ${$entry2}{'N'};

				# remove the duplicate entry from @data and count duplicates
				splice(@data,$j,1);
				$duplicates++;
				${$entry}{'duplicates'}++;		
			}
		}
		$i++;
	}

	my $percent_duplicates = sprintf("%.1f",($duplicates/$counter)*100);
	print STDERR "\n$counter sequences contained $duplicates duplicates ($percent_duplicates%), $forward forward strand & $reverse reverse strand\n";

	# print unique sequences to new file
	my $output_file = $trf_file;
	$output_file =~ s/\.trf/\.slim\.trf/;
	open(OUT,">$output_file") or die "Can't create slim file\n";
	foreach my $entry (@data){
		my $seq = Keith::tidy_seq(${$entry}{'seq'});
		my $def = ${$entry}{'def'};

		my $duplicates = 0;
		($duplicates = ${$entry}{'duplicates'}) if (exists ${$entry}{'duplicates'});

		# replace original N-copies with new value and add new duplicates value (D) to header
		$def =~ s/N=(\S+) /N=${$entry}{'N'} D=$duplicates /;
		print OUT "$def\n$seq\n";
	}
	close(OUT);	
}

sub calculate_seq_lengths{
	my ($file) = @_;
	open (FILE,"<$file") || die "Can't open file $file\n";
	my $fasta = new FAlite(\*FILE);

	while(my $entry = $fasta->nextEntry) {
		# extract seq length & header and add to hash and to grand total
	    my $length = length($entry->seq);
		$total_nt += $length;
		my $header = $entry->def;
		$header =~ s/>//;
		$seq_to_length{$header} = $length;		
	}
	close(FILE);
}
