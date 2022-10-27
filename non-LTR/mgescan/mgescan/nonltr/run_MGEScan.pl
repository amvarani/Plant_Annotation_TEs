#!/usr/bin/perl
use strict;
use Getopt::Long;
use Cwd 'abs_path';
use File::Basename;
use Sys::Hostname;
use lib (dirname abs_path $0) . '/lib';
use Prompt qw(prompt_yn);

my $program_dir = dirname(abs_path($0))."/";


############################################
# INPUT
############################################
my $conf_file;
my $main_data_dir;
my $plus_dna_dir;
my $plus_out_dir;
my $minus_dna_dir;
my $minus_out_dir;
my $phmm_dir;
my $genome_dir;
my $hmmerv;
my $nmpi;
my $host = hostname;

my $debug;
my $host_file;
my $hf_option;
$debug = $ENV{'MGESCAN_DEBUG'};
$host_file = "";
$hf_option = "";
$host_file = $ENV{'MGESCAN_HOME'}."/host_file" if -f $ENV{'MGESCAN_HOME'}."/host_file";
$host_file = $ENV{'MGESCAN_SRC'}."/host_file" if -f $ENV{'MGESCAN_SRC'}."/host_file";

print "\n\n";
GetOptions(
	'data=s' => \$main_data_dir,
	'genome=s' => \$genome_dir,
	'hmmerv=s' => \$hmmerv,
	'mpi=s' => \$nmpi,
);

if (length($genome_dir)==0){
	print "ERROR: An input genome directory was not specified.\n";
	print_usage();
	exit;
}elsif (! -e $genome_dir){
	print "ERROR: The input genome directory [$genome_dir] does not exist.\n";
	print_usage();
	exit;
}elsif (length($hmmerv)==0){
	print "ERROR: HMMER version was not specified.\n";
	print_usage();
	exit;
}else{
	if (substr($genome_dir, length($genome_dir)-1, 1) ne "/"){
		$minus_dna_dir = $genome_dir."_b/";
		$plus_dna_dir = $genome_dir."/";

	}else {
		$minus_dna_dir = substr($genome_dir, 0, length($genome_dir)-1)."_b/";
		$plus_dna_dir = $genome_dir;
	}
}

if (length($main_data_dir) == 0 ){
	print "ERROR: An output directory was not specified.\n";
	print_usage();
	exit;
}else{
	if (!-e $main_data_dir){
		system("mkdir ".$main_data_dir);
	}
	if (substr($main_data_dir, length($main_data_dir)-1, 1) ne "/"){
		$main_data_dir .= "/";
	}
}

$conf_file = $program_dir."path_conf";
$phmm_dir = $program_dir."pHMM/";
$plus_out_dir=$main_data_dir."f/";
$minus_out_dir=$main_data_dir."b/";

############################################
# Forward strand
############################################ 
printf "Running forward...\n";

# IF MPI ENABLED
# CALL MPI_MGESCAN
#
if ($nmpi) {
	my $mpi_program = $program_dir."/../mpi_mgescan";
	$hf_option = "-hostfile $host_file " if ($host_file != "");
	my $mpi_option = $hf_option."-mca btl ^openib"; # ignore finding infiniteband
	my $command = "mpirun -n ".$nmpi." ".$mpi_option." ".$mpi_program." --prg nonltr --genome ".$plus_dna_dir." --data ".$plus_out_dir." --hmmerv ".$hmmerv;
	system($command);
} else {
	opendir(DIRHANDLE, $plus_dna_dir) || die ("Cannot open directory ".$plus_dna_dir);
	foreach my $name (sort readdir(DIRHANDLE)) {
		#print STDERR $name."\n";
		if ($name !~ /^\./){  

			my $plus_dna_file = $plus_dna_dir.$name;
			my $command = $program_dir."run_hmm.pl --dna=".$plus_dna_file."  --out=".$plus_out_dir." --hmmerv=".$hmmerv;
			printf $command."\n" if ($debug);
			if ($debug and not prompt_yn("continue?")) {
				exit;
			}
			system($command);
		}
	}
}


system("rm -f ".$plus_out_dir."out1/*.aaaaa"); 
system("rm -f ".$plus_out_dir."out1/*.bbbbb");
system("rm -f ".$plus_out_dir."out1/ppppp.*");
system("rm -f ".$plus_out_dir."out1/qqqqq.*");

my $command = $program_dir."post_process.pl --dna=".$plus_dna_dir." --out=".$plus_out_dir." --rev=0";
printf $command."\n" if ($debug);
if ($debug and not prompt_yn("continue?")) {
	exit;
}
system($command);


############################################
#Backward strand
############################################
printf "Running backward...\n";
invert_seq($plus_dna_dir, $minus_dna_dir);
if ($nmpi) {
	my $mpi_program = $program_dir."/../mpi_mgescan";
	$hf_option = "-hostfile $host_file " if ($host_file != "");
	my $mpi_option = $hf_option."-mca btl ^openib"; # ignore finding infiniteband
	my $command = "mpirun -n ".$nmpi." ".$mpi_option." ".$mpi_program." --prg nonltr --genome ".$minus_dna_dir." --data ".$minus_out_dir." --hmmerv ".$hmmerv;
	system($command);
} else {

	opendir(DIRHANDLE, $minus_dna_dir) || die ("Cannot open directory ".$minus_dna_dir);
	foreach my $name (sort readdir(DIRHANDLE)) {

		if ($name !~ /^\./){  
			my $minus_dna_file = $minus_dna_dir.$name;
			my $command = $program_dir."run_hmm.pl --dna=".$minus_dna_file." --out=".$minus_out_dir." --hmmerv=".$hmmerv;
			printf $command."\n" if ($debug);
			if ($debug and not prompt_yn("continue?")) {
				exit;
			}
			system($command);

		}
	}
}
system("rm -f ".$minus_out_dir."out1/*.aaaaa");
system("rm -f ".$minus_out_dir."out1/*.bbbbb");
system("rm -f ".$minus_out_dir."out1/ppppp.*");
system("rm -f ".$minus_out_dir."out1/qqqqq.*");

my $command = $program_dir."post_process.pl --dna=".$minus_dna_dir." --out=".$minus_out_dir." --rev=1";
printf $command."\n" if ($debug);
if ($debug and not prompt_yn("continue?")) {
	exit;
}
system($command);

###########################################
#validation for Q value
###########################################

my $command = $program_dir."post_process2.pl --data_dir=".$main_data_dir." --hmmerv=".$hmmerv;
printf $command."\n" if ($debug);
if ($debug and not prompt_yn("continue?")) {
	exit;
}
system($command);

system("rm -rf ".$minus_dna_dir);

sub invert_seq{

	if (!-e $_[1]){
		system("mkdir ".$_[1]);
	}    

	opendir(DIRHANDLE, $_[0]) || die ("Cannot open directory ".$_[0]);
	foreach my $name1 (sort readdir(DIRHANDLE)) {

		my $file = $_[0].$name1;
		open (IN, $file)||die "Couldn't open ".$file;
		my @temp=<IN>;
		close(IN);

		if ($temp[0] =~ /\>/){
			shift(@temp);
		}
		chomp(@temp);
		my $seq1 = join("", @temp);
		my $seq2 = reverse($seq1);
		$seq2 =~ tr/[A,C,G,T,a,c,g,t]/[T,G,C,A,t,g,c,a]/;

		my $head = ">".$name1;
		my $file2 = $_[1].$name1;
		open OUT, ">$file2";
		print OUT $head."\n";

		my $i=0;
		my $seq_len = length($seq2);

		while($i<$seq_len-60){
			print OUT substr($seq2, $i, 60)."\n";
			$i += 60;
		}
		print OUT substr($seq2, $i, $seq_len-$i)."\n";
		close(OUT);
	}
}
sub print_usage{

	print "USAGE: ./run_MGEScan.pl -genome=[a directory name for genome sequences] -data=[a directory name for output files] -hmmerv=[2,3]\n\n\n\n";

}
