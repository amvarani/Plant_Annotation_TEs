#!/usr/bin/perl
use strict;
use Cwd 'abs_path';
use File::Basename;
use Getopt::Long;
use File::Copy;
use File::Basename;

###################################################
# path configuration
###################################################
my $this_dir = dirname(abs_path($0));
my $conf_file = $this_dir."/path.conf";
my $genome_dir;
my $data_dir;

my ($scaffold_file, $genome_dir, $tool_rm, $rm_dir, $data_dir);
my ($sw_rm, $scaffold);
get_path($conf_file, \$scaffold_file, \$tool_rm, \$rm_dir);
$tool_rm=`which RepeatMasker 2> /dev/null`;
chomp $tool_rm;
GetOptions(
	'data=s' => \$data_dir,
	'genome=s' => \$genome_dir,
	'sw_rm:s' => \$sw_rm,
	'scaffold:s' => \$scaffold
);

###########################################
### get values in path.conf from parameters
if ($sw_rm eq "Yes"){
	# If RepeatMasker exists
	if (length($tool_rm)!=0) {
		$rm_dir = $data_dir."/repeatmasker/";
	}
}
if (length($scaffold) > 0){
	$scaffold_file = $scaffold;
}
###########################################

if (length($genome_dir)==0){
	print "ERROR: An input genome directory was not specified.\n";
	print_usage();
	exit;
}elsif (! -e $genome_dir){
	print "ERROR: The input genome directory [$genome_dir] does not exist.\n";
	print_usage();
	exit;
}else{
	if (substr($genome_dir, length($genome_dir)-1, 1) ne "/"){
		$genome_dir .= "/";
	}
}

if (length($data_dir) == 0 ){
	print "ERROR: An output directory was not specified.\n";
	print_usage();
	exit;
}else{
	if (!-e $data_dir){
		system("mkdir ".$data_dir);
	}
	if (substr($data_dir, length($data_dir)-1, 1) ne "/"){
		$data_dir .= "/";
	}
}
my $ltr_genome_dir = $data_dir."genome/";

################################################
# make seperate files from one big scaffold file
################################################
if (length($scaffold_file)>0){

	if (-e $scaffold_file){
		system("mkdir -p ".$genome_dir);                               
		create_scaffold_files($scaffold_file, $genome_dir);
	}else{
		print "ERROR: incorrect $scaffold_file\n";
	}
}

################################################
# mask known repeats except LTR
################################################
if (length($rm_dir)>0){
	print "mask repeat except ltr\n"; 
	system("mkdir ".$rm_dir);                                  
	run_rm($genome_dir, $rm_dir);
	call_remove_ltr_and_short_rm_result($rm_dir);
	call_mask_repeat($genome_dir, $rm_dir, $ltr_genome_dir);
}else{
	move ($genome_dir, $ltr_genome_dir);
	mkdir $genome_dir, 0755;
	#system("for file in `ls ".$ltr_genome_dir."`; do ln -s ".$ltr_genome_dir."/\$file ".$genome_dir."; done");
	my @gfiles;
	my $gfile;
	my $gfilename;
	@gfiles = <$ltr_genome_dir/*>;
	foreach $gfile (@gfiles) {
		$gfilename = basename($gfile);
		symlink($gfile, $genome_dir."/".$gfilename);
	}
}


sub get_path{

	open(IN, $_[0]);
	while (my $each_line=<IN>){

		chomp($each_line);
		my @temp = split(/\=/, $each_line);
		if ($temp[0] eq "scaffold"){
			${$_[1]} = $temp[1];
		}
		if ($temp[0] eq "sw_rm"){
			${$_[2]} = $temp[1];
		}
		if ($temp[0] eq "rm_dir"){
			${$_[3]} = $temp[1];
		}

	}
	close(IN);
}

sub run_rm{

	opendir(DIRHANDLE, $_[0]) || die ("Cannot open directory ".$_[0]);
	foreach my $name (sort readdir(DIRHANDLE)) {

		if ($name !~ /^\./){
			$name = $_[0].$name;
			system($tool_rm." ".$name." -dir=".$_[1]);  
		}
	}
}

sub call_remove_ltr_and_short_rm_result{

	opendir(DIRHANDLE, $_[0]) || die ("Cannot open directory ".$_[0]);
	foreach my $name (sort readdir(DIRHANDLE)) {

		if ($name =~ /\.out$/){
			$name = $_[0].$name;
			print $name."\n";
			my $out_file = $name.".pos";
			remove_ltr_and_short_rm_result($name, $out_file);
		}
	}
}

sub remove_ltr_and_short_rm_result {

	my $min_len=50;
	open (IN, $_[0]) || die "Couldn't find ".$_[0];
	open OUT, ">$_[1]";

	while (my $each_line = <IN>){

		my @temp = split(/\s+/, $each_line);
		if (length($temp[0])==0){
			shift @temp;
		}
		if ($each_line !~ /LTR/ && $temp[6]-$temp[5] >$min_len){
			print OUT $temp[4]."\t".$temp[5]."\t".$temp[6]."\n";   
		}
	}
	close(IN);
	close(OUT);
}

sub call_mask_repeat{

	system("mkdir ".$_[2]);
	opendir(DIRHANDLE, $_[0]) || die ("Cannot open directory ".$_[0]);
	foreach my $name (sort readdir(DIRHANDLE)) {

		if ($name !~ /^\./){
			print $name."\n";
			my $repeat_file = $_[1].$name.".out.pos";
			my $genome_file = $_[0].$name;
			my @temp = split(/\./, $name);
			my $output_file = $_[2].$temp[0];

			if (-e $repeat_file){
				mask_repeat($repeat_file, $genome_file, $output_file);
			}else{
				system("cp ".$genome_file." ".$output_file);
			}
		}
	}
}    

#--------------------------------------------------------------------------
# mask repeat given position file
#--------------------------------------------------------------------------

sub mask_repeat{

	#-------------------------------------------------
	# read genome file
	#-------------------------------------------------
	my ($head, $genome); 
	get_sequence($_[1], \$genome, \$head);
	my $len_genome = length($genome);
	print $len_genome."\n";

	#---------------------------------------------
	# read repeat position and mask repeats
	#---------------------------------------------
	my @pos;
	my $temp;
	open (IN, $_[0]) || die "Couldn't find ".$_[0];   #repeat position file, start from 0 not 1
	while(my $each_pos = <IN>){
		chomp($each_pos);
		@pos = split(/\s+/, $each_pos);
		$temp = substr($genome, $pos[1], $pos[2]-$pos[1]+1);
		$temp =~ s/\w/N/g;
		substr($genome, $pos[1], $pos[2]-$pos[1]+1)=$temp;
	}
	close(IN);
	print length($genome)."\n";

	#---------------------------------------------
	# print it in file
	#---------------------------------------------
	open OUT, ">$_[2]";
	print OUT $head."\n";
	for (my $i=0; $i<$len_genome/50; $i++){
		print OUT substr($genome, $i*50, 50)."\n";
	}
	close(OUT);
}

sub get_sequence{

	open(INPUT, $_[0])|| die("ERROR: Couldn't open genome_file $_[0]!\n");
	while( my $each_line=<INPUT>)  {

		if ($each_line =~ m/>/){
			${$_[1]} = "";
			chomp($each_line);
			${$_[2]} = $each_line;
		}else{
			chomp($each_line);
			${$_[1]} .= $each_line;
		}
	}
	close(INPUT);
}




#----------------------------------------------------------------------
#     create files for each scaffold sequence
#-----------------------------------------------------------------------
sub create_scaffold_files {

	my $seq="";
	my $head="";
	open(DAT, $_[0])|| die("Couldn't open ".$_[0]."\n");
	while(my $each_line=<DAT>){

		chomp($each_line);
		if ($each_line =~ /^>/){

			if (length($seq)>0){

				#save a scaffold into a file      
				my $seq_file = $_[1].substr($head, 1,eval(length($head)-1)).".fa";
				open OUT, ">$seq_file";
				print OUT $head."\n";
				print OUT $seq;
				close(OUT);
			}
			my @temp = split(/\s+/, $each_line);
			$head = ">".substr($temp[0],1,length($temp[0])-1);
			$seq = "";

		}elsif($each_line !~ /^>/) {

			$seq .= $each_line."\n";
		}
	}
	if (length($seq)>0){

		#save a scaffold into a file      
		my $seq_file = $_[1].substr($head, 1,eval(length($head)-1)).".fa";
		open OUT, ">$seq_file";
		print OUT $head."\n";
		print OUT $seq;
		close(OUT);
	}

	close(DAT);
}

sub print_usage{

	print "USAGE: ./pre_process.pl -genome=[a directory name for genome sequences] -data=[a directory name for output files] \n\n\n\n";

}
