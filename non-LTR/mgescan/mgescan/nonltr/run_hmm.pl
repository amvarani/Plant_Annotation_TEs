#!/usr/bin/perl  -w
use strict;
use Getopt::Long;
use Cwd 'abs_path';
use File::Basename;
use File::Temp qw/ tempfile unlink0 /;
use lib (dirname abs_path $0) . '/lib';
use Parallel::ForkManager;
use Prompt qw(prompt_yn);

my $pdir = dirname(abs_path($0))."/";
my $phmm_dir = $pdir."pHMM/";
my $hmmerv;

my $debug;
$debug = $ENV{'MGESCAN_DEBUG'};

##########################################################
# get input parameter of dna file, pep file, output dir
##########################################################
#print "Getting input parameter...\n";
my ($dna_file, $pep_file, $out_dir, $dna_name, $command);
my ($out1_dir, $out_file, $pos_dir);
get_parameter(\$dna_file, \$out_dir, \$hmmerv);
get_id(\$dna_file, \$dna_name);

$out1_dir = $out_dir."out1/";
if (-e $out1_dir){
}else{
	system("mkdir ".$out1_dir);
}
$pos_dir = $out_dir."pos/";
if (-e $pos_dir){
}else{
	system("mkdir ".$pos_dir);
}

##########################################################
# get signal for some state of ORF1, RT, and APE
# need HMMSEARCH
##########################################################
print "Getting signal...\n";
my ($phmm_file, $domain_rt_pos_file, $domain_ape_pos_file, $domain_orf1_pos_file);

print "    Protein sequence...\n";
$pep_file = $out_dir.$dna_name.".pep";
$command = $pdir."translate -d ".$dna_file." -h ".$dna_name." -p ".$pep_file;
system($command);

# RT|APE can be run in parallel
print "    RT signal...\n";
$phmm_file = $phmm_dir."ebi_ds36752_seq.hmm";
$domain_rt_pos_file = $pos_dir.$dna_name.".rt.pos";
#get_signal_domain(\$pep_file, \$phmm_file, \$domain_rt_pos_file);

print "    APE signal...\n";
$phmm_file = $phmm_dir."ebi_ds36736_seq.hmm";
$domain_ape_pos_file = $pos_dir.$dna_name.".ape.pos";
#get_signal_domain(\$pep_file, \$phmm_file, \$domain_ape_pos_file);
my @files;
@files = ([$phmm_dir."ebi_ds36752_seq.hmm",$domain_rt_pos_file],
	[$phmm_dir."ebi_ds36736_seq.hmm", $domain_ape_pos_file]); 
my $pm = new Parallel::ForkManager(2);
foreach my $filearray (@files) {
	$pm->start and next;
	my $file;
	($phmm_file, $file) = @$filearray;
	get_signal_domain(\$pep_file, \$phmm_file, \$file);
	$pm->finish;
}
$pm->wait_all_children;

##############################################################################
# generate corresponsing empty domains files if either of them does not exist 
##############################################################################
if (-e $domain_rt_pos_file  || -e $domain_ape_pos_file ){

	print $dna_name."\n";

	if (! -e $domain_rt_pos_file){
		open OUT, ">$domain_rt_pos_file";
		print OUT "";
		close(OUT);
	}elsif (! -e $domain_ape_pos_file){
		open OUT, ">$domain_ape_pos_file";
		print OUT "";
		close(OUT);
	}

	$out_file = $out1_dir.$dna_name;
	# MGEScan -m ./hmm/chr.hmm -s ./aaa/NC_003070.9.fa -r ./test/f/pos/NC_003070.9.fa.rt.pos -a ./test/f/pos/NC_003070.9.fa.ape.pos -o ./test/f/out1/NC_003070.9.fa -p ./ -d ./test/f/out1/ -v 3
	# -m HMM file
	# -s sequence file
	# -r RT
	# -a APE
	# -o output file
	# -p program path
	# -d output path
	$command = $pdir."hmm/MGEScan -m ".$pdir."hmm/chr.hmm -s ".$dna_file." -r ".$domain_rt_pos_file." -a ".$domain_ape_pos_file." -o ".$out_file." -p ".$pdir." -d ".$out1_dir." -v ".$hmmerv;
	print $command."\n" if ($debug);
	if ($debug && not prompt_yn("Continue?")) {
		exit;
	}
	system($command); 
}


if (-e $pep_file){
	#system("rm ".$pep_file);
}

###########################################################
#                        SUBROUTINE                       #
###########################################################

sub get_signal_domain{

	# Inputs $_[0], $_[1]
	# Outputs $_[2], $_[2]'temp', $_[2]'temp2'
	#
	#$_[0]: pep seq file
	#$_[1]: domain hmm file
	#$_[2]: output domain dna position file

	my %domain_start=();
	my %domain_end=();
	my $evalue;
	my $temp_file = ${$_[2]}."temp";
	my $temp_file2 = ${$_[2]}."temp2";
	my $output_file = ${$_[2]};
	my $fh;
	my $tmpfile;
	my $hmm_result;

	print "get_signal_domain" if ($debug);
	# print "\n".${$_[0]}. ${$_[1]}. ${$_[2]}."\n";

	($fh, $tmpfile) = tempfile( UNLINK => 1, SUFFIX => '.tbl');

	open (OUT, ">$temp_file");
	if ($hmmerv == 3){
		#system("hmmconvert ".${$_[1]}." > ".${$_[1]}."c");
		my $hmm_command = "hmmsearch  -E 0.00001 --noali --domtblout ".$tmpfile." ".${$_[1]}."3 ".${$_[0]}." > /dev/null";
		print $hmm_command if ($debug);
		if ($debug && not prompt_yn("Continue?")) {
			exit;
		}

		system($hmm_command);
		#$hmm_command = "cat ".$tmpfile;
		local $/ = undef;
		$hmm_result = <$fh>;
		close $fh;
		#system("rm -rf ".$tmpfile);
		unlink0($fh, $tmpfile);
		# run hmmsearch to find the domain and save it in the temprary file   
		# e.g.
		# target name        accession   tlen query name           accession   qlen   E-value  score  bias   #  of  c-Evalue  i-Evalue  score  bias  from    to  from    to  from    to  acc description of target
		# ------------------- ---------- ----- -------------------- ---------- ----- --------- ------ ----- --- --- --------- --------- ------ ----- ----- ----- ----- ----- ----- ----- ---- ---------------------
		#
		# NC_003070.9.fa_3     -          10142556 ebi_ds36752_seq      -            437         0 1118.0   6.0   3  11   1.5e-70   1.5e-70  225.5   0.0     2   435 3453451 3453883 3453450 3453885 0.91 -
		#
		my @sp = split /\n/, $hmm_result;
		#while ($hmm_result =~ /\n((?!#).*)\n/g){
		for my $line (@sp) {
			next if ($line =~ /^#/);
			
			my @temp = split(/\s+/, $line);
			if ($temp[11]<0.001 ){
				# from to from(first one) to(first) score c-Evalue
				print OUT eval($temp[17]*3)."\t".eval($temp[18]*3)."\t".$temp[15]."\t".$temp[16]."\t".$temp[13]."\t".$temp[11]."\n";
			}
		}
	}else{
		my $hmm_command = "hmm2search  -E 0.00001 ".${$_[1]}." ".${$_[0]};
		my $hmm_result = `$hmm_command`;
		print $hmm_result if($debug);
		# run hmmsearch to find the domain and save it in the temprary file    
		# e.g.
		#
		# Sequence         Domain  seq-f seq-t    hmm-f hmm-t      score  E-value
		# --------         ------- ----- -----    ----- -----      -----  -------
		#
		# NC_003070.9.fa_2   3/3   4698218 4698604 ..     1   492 []    61.4    1e-18
		#
		while ($hmm_result =~ /((\S)+\s+\d+\/\d+\s+\d+\s+\d+\s+(\[|\.)(\]|\.)\s+\d+\s+\d+\s+(\[|\.)(\]|\.)\s+(-)*\d+\.\d+\s+((\d|\-|\.|e)+))\s*/g){
			my @temp = split(/\s+/, $1);
			if ($temp[9]<0.001 ){
				# seq-f seq-t hmm-?(1)  hmm-?(492) score E-value
				print OUT eval($temp[2]*3)."\t".eval($temp[3]*3)."\t".$temp[5]."\t".$temp[6]."\t".$temp[8]."\t".$temp[9]."\n";
			}
		}
	}
	close(OUT);
	if (-s $temp_file >0){
		system("sort +0 -1n ".$temp_file." > ".$temp_file2);

		my $start = -1;
		my $end = -1;
		my @pre = (-1000, -1000, -1000, -1000, -1000, -1000);
		open(IN, $temp_file2);
		open OUT, ">$output_file";
		while(my $each_line=<IN>){
			my @temp = split(/\s+/, $each_line);

			if ($temp[0] - $pre[1] < 300 ) {
				$end = $temp[1];
				$evalue = $evalue * $temp[5];
			}else{
				if($start>=0 && $evalue < 0.00001){
					print OUT $start."\t".$end."\t".$pre[4]."\t".$pre[5]."\n";
				}
				$start = $temp[0];
				$end = $temp[1];
				$evalue = $temp[5];
			}
			@pre = @temp;
		}
		if($start>=0 && $evalue < 0.00001){ 
			print OUT $start."\t".$end."\t".$pre[4]."\t".$pre[5]."\n";
		}
		close(IN);
		close(OUT);
		#system("rm ".$temp_file2);
	}
	#system("rm ".$temp_file);
}

sub get_id{

	my @temp = split(/\//, ${$_[0]});
	${$_[1]} = $temp[$#temp];

	# use Bio::SeqIO;
	# my $seqio_obj = Bio::SeqIO->new(-file => ${$_[0]}, -format => "fasta" );
	# my $seq = $seqio_obj->next_seq;
	# ${$_[1]} = $seq->display_id;


	# post_process.pl searches original sequence files with its id. The file
	# name, because of that, needs to be changed to id.
	# my $name;
	# my $path;
	# my $suffix;
	# ($name,$path,$suffix) = fileparse(${$_[0]});
	# rename(${$_[0]}, $path ."/".${$_[1]});
	# ${$_[0]} = $path ."/".${$_[1]};
}


sub usage {
	die "Usage: run_hmm.pl --dna=<dna_file_path>  --out=<output_dir> --hmmerv=<2,3>";
}


sub get_parameter{

	my ($dna, $out, $hmmerv);

	GetOptions(
		'dna=s' => \$dna,
		'out=s' => \$out,
		'hmmerv=s' => \$hmmerv,
	);

	if (! -e $dna){
		print "ERROR: The file $dna does not exist.\n";
		usage();
	}
	if (length($hmmerv)==0){
		print "ERROR: HMMER version not provided.\n";
		usage();
		exit;
	}
	if (! -d $out){
		system("mkdir ".$out);
	}

	${$_[0]} = $dna;
	${$_[1]} = $out;
	${$_[2]} = $hmmerv;
}



sub get_sequence{  # file name, variable for seq, variable for head                                   \


	open(GENOME, $_[0])|| die("ERROR: Couldn't open genome_file $_[0]!\n");
	while( my $each_line=<GENOME>)  {

		if ($each_line =~ m/>/){
			${$_[1]} = "";
			chomp($each_line);
			${$_[2]} = $each_line;
		}else{
			chomp($each_line);
			${$_[1]} .= $each_line;
		}
	}
	close(GENOME);
}


