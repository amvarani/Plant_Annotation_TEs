#!/usr/bin/perl
use strict;
use Getopt::Long;
use Cwd 'abs_path';
use File::Basename;
use File::Temp qw/ tempfile unlink0 /;

###################################################
# path configuration
###################################################
my $program_dir = dirname(abs_path($0));
my $conf_file = $program_dir."/path.conf";
my $value_file = $program_dir."/value.conf";
my $tool_matrix = $program_dir."/matrix/EDNAFULL";
my $tool_pfam = $program_dir."/pfam/";
my $tool_ltr = $program_dir."/MER/ltr";
my $tool_trf = `which trf`;
chomp $tool_trf;
#my $tool_emboss;
#my $tool_hmmer = "/nfs/nfs4/home/wazimoha/softwares/hmmer-3.1b1/src/";
my $main_dir;           # directory of output data            
my $main_genome_dir;    # directory of input genomes
my $hmmerv=3;		# version of hmmer
my $nmpi;


###################################################
# parameter configuration
###################################################
my $MIN_LEN_MEM=10;        # length of exact match 
my $MIN_DIST;           # distance between LTRs: the length of retrotransposon including a ltr
my $MAX_DIST;
my $MIN_LEN_LTR;        # length of LTR
my $MAX_LEN_LTR;
my $MIN_LEN_ORF;        # length of ORF
my $LTR_SIM_CONDITION;          
my $CLUSTER_SIM_CONDITION;      # similarity of LTRs to be in a cluster  
my $LEN_CONDITION;              # length of LTRs to be in a cluster
my $RANGE_BIN=500;         # range in the bin
my $FLANKING_LEN=20;

my $path_genome;
my $path_ltr;
my $chr_name;
my $run_hmm;

my $debug;
my $host_file;
my $hf_option;
$debug = $ENV{'MGESCAN_DEBUG'};
$host_file = "";
$hf_option = "";
$host_file = $ENV{'MGESCAN_HOME'}."/host_file" if -f $ENV{'MGESCAN_HOME'}."/host_file";
$host_file = $ENV{'MGESCAN_SRC'}."/host_file" if -f $ENV{'MGESCAN_SRC'}."/host_file";

###################################################
# HMM for domain
###################################################
my @pf=("PF03732_fs.hmm",                                      #GAG   
	"PF00077_fs.hmm","PF05380_fs.hmm",                     #Protease
	"PF00075_fs.hmm",                                      #RNase
	"PF00665_fs.hmm","PF00552_fs.hmm","PF02022_fs.hmm",    #IN
	"PF00429_fs.hmm","PF03056_fs.hmm");                    #ENV  

my @rt=("anno_nonLTR_rt.hmm","anno_dirs_rt.hmm",
	"anno_gypsy_rt.hmm", "anno_copia_rt.hmm", "anno_bel_rt.hmm",     #rt
	"anno_erv1_rt.hmm", "anno_erv2_rt.hmm", "anno_erv3_rt.hmm");


##################################################
# get congifuration from input
##################################################
#get_path_conf($conf_file, \$tool_trf);
get_value_conf($value_file, \$MIN_DIST,\$MAX_DIST,\$MIN_LEN_LTR,\$MAX_LEN_LTR,\$LTR_SIM_CONDITION,\$CLUSTER_SIM_CONDITION,\$LEN_CONDITION, );

##############################################
# get values in value.conf from parameters
##############################################
my ($min_dist, $max_dist, $min_len_ltr, $max_len_ltr, $ltr_sim_condition, $cluster_sim_condition, $len_condition);
GetOptions(
	'path_genome=s' => \$path_genome,
	'path_ltr=s' => \$path_ltr,
	'chr_name=s' => \$chr_name,
	'run_hmm=s' => \$run_hmm,
);
##############################################

if (length($path_genome)==0){
	print "ERROR: An input genome directory was not specified.\n";
	usage();
	exit;
}elsif (! -e $path_ltr){
	print "ERROR: The output genome directory [$path_ltr] does not exist.\n";
	usage();
	exit;
}

if (length($chr_name) == 0 ){
	print "ERROR: An filename was not specified.\n";
	usage();
	exit;
}


#if ($hmmerv > 2){
#    $tool_pfam = $program_dir."/pfam_3/"; 
#}else{
#    $tool_pfam = $program_dir."/pfam_2/";
#}

#####################################################
# Output configuration
#####################################################
my $genome_dir = $main_dir."genome/";
my $ltr_dir = $main_dir."ltr/";
my $ltr_data_dir = $ltr_dir."ltr/";
my $ltr_seq_dir = $ltr_dir."ltr_seq/";
my $ir_seq_dir =  $ltr_dir."ir_seq/";
my $element_seq_dir = $ltr_dir."element_seq/";
my $sim_file = $ltr_dir."ltr.localsim";
my $family_file =  $ltr_dir."ltr.out.temp";
my $family_selected_file = $ltr_dir."ltr.out";
my $ltr=1;
#my $run_hmm = 1;   #for simulation:0 

#####################################################
# genome being used in find_ltr()
#####################################################
my $genome_seq="";
my $genome_head="";

find_ltr_pair($path_genome, $path_ltr, $chr_name, $run_hmm);

sub call_find_ltr_for_each_chr{   #$genome_dir, $main_dir, $ltr_dir, $ltr_data_dir);
	system("mkdir ".$_[2]);
	system("mkdir ".$_[3]);   
	if ($nmpi) {
		my $mpi_program = $program_dir."/../mpi_mgescan";
		$hf_option = "-hostfile " . $host_file . " " if ($host_file ne "");
		my $mpi_option = $hf_option."-mca btl ^openib"; # ignore finding infiniteband
		my $prg_name = "ltr";
		my $command = "mpirun -n ".$nmpi." ".$mpi_option." ".$mpi_program." --prg ".$prg_name." --genome ".$_[0]." --data ".$_[3]." --hmmerv ".$hmmerv;
		system($command);
	} else {
		opendir(DIRHANDLE, $_[0]) || die ("Cannot open directory ".$_[0]);
		foreach my $name (sort readdir(DIRHANDLE)) {

			if ($name !~ /^\./){  
				print $name."\n";

				my $genome_path = $_[0].$name;
				if (! -e $genome_path){
					print "ERROR: The file $genome_path does not exist.\n";
					usage();
				}
				find_ltr_pair($_[0], $_[3], $name, $run_hmm);
			}    
		}
	}
}


sub get_path_conf{

	open(IN, $_[0]);
	while (my $each_line=<IN>){

		chomp($each_line);
		my @temp = split(/\=/, $each_line);
		if ($temp[0] eq "sw_trf"){
			${$_[1]} = $temp[1];
		}
	}
	close(IN);
}


sub get_value_conf{

	open(IN, $_[0]);
	while (my $each_line=<IN>){

		chomp($each_line);
		my @temp = split(/\=/, $each_line);
		if ($temp[0] eq "min_dist"){
			${$_[1]} = $temp[1];
		}elsif ($temp[0] eq "max_dist"){
			${$_[2]} = $temp[1];
		}elsif ($temp[0] eq "min_len_ltr"){
			${$_[3]} = $temp[1];
		}elsif ($temp[0] eq "max_len_ltr"){
			${$_[4]} = $temp[1];
		}elsif ($temp[0] eq "ltr_sim_condition"){
			${$_[5]} = $temp[1];
		}elsif ($temp[0] eq "cluster_sim_condition"){
			${$_[6]} = $temp[1];
		}elsif ($temp[0] eq "len_condition"){
			${$_[7]} = $temp[1];
		}
	}
	close(IN);
}


sub select_putative_family{

	my $count=0;
	my $total=0;
	my $saved="";
	my $tg=0;
	my $offset_sum=0;
	my $saved_head="";
	my ($ltr5left, $ltr5right, $ltr3left, $ltr3right);

	open OUT, ">$_[1]";
	open(IN, $_[0])||die "Couldn't find ".$_[0];
	while(my $each_line =<IN>){

		chomp($each_line);
		if ($each_line =~ /\-\-\-/ ){

			if (($count +1)*2 > $total && $count>0){
				print OUT $saved_head."***\n";
			}else{
				print OUT $saved_head."\n";
			}
			print OUT $saved;

			$saved_head = $each_line;
			$saved = "";
			$count=0;
			$total=0;
		}else{
			$total++;
			my @temp = split(/\s+/, $each_line);
			$offset_sum = abs($temp[17])+abs($temp[18])+abs($temp[19])+abs($temp[20]);

			if ($each_line =~ /TG/ && ($offset_sum<20 || ($temp[17]==0 && $temp[19]==0) || ($temp[18]==0 && $temp[20]==0))){
				$count++;
			}
			if ($temp[5] eq "+"){
				$ltr5left = $temp[1]+$temp[17];
				$ltr5right = $temp[2]+$temp[18];
				$ltr3left = $temp[3]+$temp[19];
				$ltr3right = $temp[4]+$temp[20]; 
			}else{
				$ltr5left = $temp[1]-$temp[20];
				$ltr5right = $temp[2]-$temp[19];
				$ltr3left = $temp[3]-$temp[18];
				$ltr3right = $temp[4]-$temp[17];
			}
			$saved .= $temp[0]."\t".$ltr5left."\t".$ltr5right."\t".$ltr3left."\t".$ltr3right."\t";
			$saved .= $temp[5]."\t".($ltr5right-$ltr5left+1)."\t".($ltr3right-$ltr3left+1)."\t";
			$saved .= ($ltr3right-$ltr5left+1)."\t".$temp[10]."\t";
			$saved .= $temp[11]."\t".$temp[12]."\t".$temp[13]."\t".$temp[14]."\t".$temp[15]."\t".$temp[16]."\t";
#	    $saved .= $temp[21]."\n";
			$saved .= "\n";
		}
	}

	if (($count +1)*2 > $total && $count>0){
		print OUT $saved_head."***\n";
	}else{
		print OUT $saved_head."\n";
	}
	print OUT $saved;

	close(IN);
	close(OUT);
	system("rm -rf ".$_[0]);
}



sub get_ltr_ir_seq{ #$genome_dir, $ltr_data_dir, $ltr_seq_dir, $ir_seq_dir, $element_seq_dir)

	system("mkdir ".$_[2]);
	system("mkdir ".$_[3]);
	my $genome_seq_sub;
	my $genome_head_sub;
	my $seq;

	my @pre_temp=(0,0,0,0);
	opendir(DIRHANDLE, $_[1]) || die ("Cannot open directory ".$_[1]);
	foreach my $name (sort readdir(DIRHANDLE)) {

		if ($name =~ /\.ltr$/ ){
			my $file1 = $_[1].$name;
			my $chr = substr($name, 0, length($name)-4);   
			my $count=0;
			open (IN, $file1)||die "Couldn't open ".$file1;

			my $genome_file = $_[0].$chr;
			get_sequence($genome_file, \$genome_seq_sub, \$genome_head_sub);

			while (my $each_line = <IN>){

				$count++;		    
				my @temp = split(/\s+/, $each_line);


				if (!($pre_temp[0]-5<=$temp[0] && $temp[1]<=$pre_temp[1]+5 && $pre_temp[2]-5<=$temp[2] && $temp[2]<=$pre_temp[2]+5)&&
					!($temp[0]-5<=$pre_temp[0] && $pre_temp[1]<=$temp[1]+5 && $temp[2]-5<=$pre_temp[2] && $pre_temp[2]<=$temp[2]+5)){

					my $file2 = $_[2].$chr."_".$count."_1";
					my $file3 = $_[2].$chr."_".$count."_2";
					my $file4 = $_[3].$chr."_".$count;
					my $file5 = $_[4].$chr."_".$count;
					if ($temp[4] eq "+") {

						open OUT, ">$file2";
						print OUT $genome_head_sub."_".$count."_1\n";
						$seq = substr($genome_seq_sub, $temp[0]+$temp[16]-$FLANKING_LEN, ($temp[1]+$temp[17])-($temp[0]+$temp[16])+1+$FLANKING_LEN*2);
						print OUT $seq."\n";
						close(OUT);

						open OUT, ">$file3";
						print OUT $genome_head_sub."_".$count."_2\n";
						$seq = substr($genome_seq_sub, $temp[2]+$temp[18]-$FLANKING_LEN, ($temp[3]+$temp[19])-($temp[2]+$temp[18])+1+$FLANKING_LEN*2);
						print OUT $seq."\n";
						close(OUT);

						open OUT, ">$file4";
						print OUT $genome_head_sub."_".$count."\n";
						$seq = substr($genome_seq_sub, $temp[1]+$temp[17], ($temp[2]+$temp[18])-($temp[1]+$temp[17])+1);
						print OUT $seq."\n";
						close(OUT);
						system("transeq -sequence ".$file4." -outseq ".$file4.".pep -frame=f 2> /dev/null");

						open OUT, ">$file5";
						print OUT $genome_head_sub."_".$count."\n";
						$seq = substr($genome_seq_sub, $temp[0]+$temp[16], ($temp[3]+$temp[19])-($temp[0]+$temp[16])+1);
						print OUT $seq."\n";
						close(OUT);

					}elsif ($temp[4] eq "-"){

						my $temp_seq;
						open OUT, ">$file2";
						print OUT $genome_head_sub."_".$count."_1\n";
						$seq = substr($genome_seq_sub, $temp[2]-$temp[17]-$FLANKING_LEN, ($temp[3]-$temp[16])-($temp[2]-$temp[17])+1+$FLANKING_LEN*2);
						$seq =~ tr/[A,C,G,T,a,c,g,t]/[T,G,C,A,t,g,c,a]/;
						$temp_seq = reverse($seq);
						print OUT $temp_seq."\n";
						close(OUT);

						open OUT, ">$file3";
						print OUT $genome_head_sub."_".$count."_2\n";
						$seq = substr($genome_seq_sub, $temp[0]-$temp[19]-$FLANKING_LEN, ($temp[1]-$temp[18])-($temp[0]-$temp[19])+1+$FLANKING_LEN*2);
						$seq =~ tr/[A,C,G,T,a,c,g,t]/[T,G,C,A,t,g,c,a]/;
						$temp_seq = reverse($seq);
						print OUT $temp_seq."\n";
						close(OUT);

						open OUT, ">$file4";
						print OUT $genome_head_sub."_".$count."\n";
						$seq = substr($genome_seq_sub, $temp[1]-$temp[18], ($temp[2]-$temp[17])-($temp[1]-$temp[18])+1);
						$seq =~ tr/[A,C,G,T,a,c,g,t]/[T,G,C,A,t,g,c,a]/;
						$temp_seq = reverse($seq);
						print OUT $temp_seq."\n";
						close(OUT);
						system("transeq -sequence ".$file4." -outseq ".$file4.".pep -frame=f 2> /dev/null");


						open OUT, ">$file5";
						print OUT $genome_head_sub."_".$count."\n";
						$seq = substr($genome_seq_sub, $temp[0]-$temp[19], ($temp[3]-$temp[16])-($temp[0]-$temp[19])+1);
						$seq =~ tr/[A,C,G,T,a,c,g,t]/[T,G,C,A,t,g,c,a]/;
						$temp_seq = reverse($seq);
						print OUT $temp_seq."\n";
						close(OUT);


					}
					@pre_temp = @temp;
				}
			}
			close(IN);
		}
	}
}

sub run_matcher{ #$ltr_seq_dir, $sim_file, $ltr

	my $file_count=0;
	my ($file1, $file2);
	open OUT, ">$_[1]";
	opendir(DIRHANDLE, $_[0]) || die ("Cannot open directory ".$_[0]);
	foreach my $name1 (sort readdir(DIRHANDLE)) {

		my $condition1;
		if ($_[2]==1){
			$condition1 = ($name1 !~ /^\./ && $name1 =~/\_1$/);	    
		}else{
			$condition1 = ($name1 !~ /^\./ );
		}

		if ($condition1){

			$file_count++;
			if ($file_count%10==0){
				print $file_count."\t";
			}
			$file1 = $_[0].$name1;

			opendir(DIRHANDLE, $_[0]) || die ("Cannot open directory ".$_[0]);
			foreach my $name2 (sort readdir(DIRHANDLE)) {

				$file2 = $_[0].$name2;
				my $file1_size = -s $file1;
				my $file2_size = -s $file2;

				my $condition2;
				if ($_[2]==1){
					$condition2 = $name2 !~ /^\./ && $name2 =~ /\_1$/ && $name2 le $name1 && abs($file1_size-$file2_size)<80;
				}else{
					$condition2 = $name2 !~ /^\./  && $name2 le $name1 && abs($file1_size-$file2_size)<80;
				}

				if ($condition2){

					my @result = find_sim_by_matcher($file1, $file2);
					if ($result[0]>=$CLUSTER_SIM_CONDITION && $result[1]>=$LEN_CONDITION){  # $result[0]:similarity $result[1]:length
						print OUT $name1, "\t", $name2, "\t",$result[0],"\t", $result[1],"\n";
						#last;
					}
				}
			}
		}
	}
	close(OUT);
}



sub cluster_family{#$sim_file, $family_file, $ltr, $ltr_data_dir

	my $count=0;
	my %family;
	open(IN, $_[0]) ||die "Couldn't find ".$_[0];
	open OUT, ">$_[1]";
	while(my $each_line=<IN>){

		chomp($each_line);
		my @temp = split(/\s+/, $each_line);
		if ($_[2]==1){
			$temp[0]=substr($temp[0],0,length($temp[0])-2);
			$temp[1]=substr($temp[1],0,length($temp[1])-2);
		}
		if($temp[2] >= $CLUSTER_SIM_CONDITION && $temp[3] >= $LEN_CONDITION){
			if ( (! exists $family{$temp[0]}) && (! exists $family{$temp[1]})){
				$count++;
				$family{$temp[0]}=$count;
			}elsif (exists $family{$temp[0]} && (!exists $family{$temp[1]})){
				$family{$temp[1]} = $family{$temp[0]};
			}elsif (!exists $family{$temp[0]} && (exists $family{$temp[1]})){
				$family{$temp[0]} = $family{$temp[1]};
			}elsif (exists $family{$temp[0]} && exists $family{$temp[1]} && $family{$temp[0]} != $family{$temp[1]}){
				while ( my ($k, $v) =each  %family ) {
					if ($v==$family{$temp[1]}){
						$family{$k} = $family{$temp[0]};
					}
				}
				$family{$temp[1]} = $family{$temp[0]};
			}
		}
	}
	close(IN);

	my %ltr=();
	opendir(DIRHANDLE, $_[3]) || die ("Cannot open directory ".$_[3]);
	foreach my $name (sort readdir(DIRHANDLE)) {

		if ($name =~ /\.ltr/){
			my $file1 = $_[3].$name;
			my $count=0;
			open(IN,$file1)||die "Couldn't open ".$file1;
			while (my $each_line=<IN>){
				chomp($each_line);
				$count++;
				my $key = substr($name, 0,length($name)-4)."_".$count;
				$ltr{$key}=$each_line;
			}
			close(IN);
		}
	}
	closedir(DIRHANDLE);

	for (my $i=1; $i<=$count; $i++){
		print OUT $i."----------\n";
		while ( my ($k, $v) = each  %family ) {
			if ($v==$i){
				print OUT $k."\t".$ltr{$k}."\n";
			}
		}
	}
	close(OUT);
}


sub find_sim_by_matcher{

	my @result=();
	my $temp_matcher;

	if ($ltr==1){
		$temp_matcher = "matcher -datafile=".$tool_matrix." -asequence=".$_[0]." -bsequence=".$_[1]." -outfile=stdout -awidth3=4000 2>/dev/null";
	}else{
		$temp_matcher = "matcher -asequence=".$_[0]." -bsequence=".$_[1]." -outfile=stdout -awidth3=4000 2>/dev/null";
	}

	my $str_result = `$temp_matcher`;

	if ($str_result =~ /(Identity:\s+\d+\/\d+\s*\((\d+.\d+)%\))/){
		$result[0]=$2;
	}

	if ($str_result =~ /(Length:\s+(\d+)\s*)/){
		$result[1]=$2;
	}

	return @result;
}


sub get_sequence{  # file name, variable for seq, variable for head                                                                                                   

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

sub usage {
	die "Usage: find_ltr_pair.pl -data=<> -genome=<> -hmmerv=<>";
}

sub find_ltr_pair{  #$path_genome, $path_ltr, $chr_name, $run_hmm

	my $path_genome = $_[0];
	my $path_ltr = $_[1];
	my $chr_name = $_[2];

	my $genome_file = $path_genome.$chr_name;
	my $mask_file = $path_ltr.$chr_name.".mask";
	my $mem_file = $path_ltr.$chr_name.".mem";
	my $dist_file = $path_ltr.$chr_name.".dist";
	my $bin_file = $path_ltr.$chr_name.".bin";
	my $ltr_file = $path_ltr.$chr_name.".ltr";
	my $ltr_pre_file = $path_ltr.$chr_name.".ltr0";
	my $ltrseq_file = $path_ltr.$chr_name.".ltr.seq";
	my $nested_file = $path_ltr.$chr_name.".ltr.nested";

	#get MEM
	#Preparing input (masked by TRF) to get mem
	get_sequence($genome_file, \$genome_seq, \$genome_head);
	print "Finding LTRs\n";
	if (find_mem($genome_file, $mask_file, $mem_file) == 0){
		print "WARNING: no MEM in $chr_name\n";
		return 0;
	} 
	elsif (make_bin($mem_file, $dist_file, $bin_file) == 0){
		print "WARNING: no bin in $chr_name\n";
		return 0;
	}elsif (find_putative_ltr($bin_file, $ltr_pre_file, $_[3])==0){
		print "WARNING: no putative LTR in $chr_name\n";
		return 0;
	}else {
		chain_putative_ltrs($ltr_pre_file, $ltr_file);
	}

	$genome_seq="";
	return 1;
}



sub find_mem{ #$genome_file, $mask_file, $mem_file

	my $genome_file_sub = $_[0];
	my $mask_file_sub = $_[1];
	my $mem_file_sub = $_[2];

	print "Finging MEM\n";
	my $command = $tool_trf." ".$genome_file_sub." 2 7 7 80 10 50 500 -m -h  > /dev/null 2>&1";
	system($command);
	my @temp = split(/\//, $genome_file_sub.".2.7.7.80.10.50.500");
	system("mv ".$temp[$#temp].".mask ".$mask_file_sub);
	system("rm -rf ".$temp[$#temp].".dat");

	#Run ltr to get mem
	system($tool_ltr." -i ".$mask_file_sub." -o ".$mem_file_sub." -s ".$MIN_LEN_MEM." -d ".$MIN_DIST." -D ".$MAX_DIST);
	system("rm -rf ".$mask_file_sub);

	#Remove the mem file when it doesn't have data
	if(!(-e $mem_file_sub)){	
		return 0;
	}elsif(-s $mem_file_sub==0){
		system("rm -rf $mem_file_sub");
		return 0;
	}else{
		return 1;
	}
}

sub make_bin { #$mem_file, $dist_file, $bin_file

	my $mem_file_sub = $_[0];
	my $dist_file_sub = $_[1];
	my $bin_file_sub = $_[2];

	print "Making bin\n";
	system("sort -k 4n  $mem_file_sub > $dist_file_sub");
	open(DAT, $dist_file_sub)|| die("Couldn't open $dist_file_sub!\n");
	open OUTPUT, ">$bin_file_sub";

	my (@line_array, @line_array_bin);
	my ($prev1, $prev2);
	my $flag = 0;    
	my $temp_file1 = $dist_file_sub.".temp1";
	my $temp_file2 = $dist_file_sub.".temp2";
	my $start_dist = $MIN_DIST;
	my $line_count=0;
	print OUTPUT "------------------------------------------------------------------------\n";
	while(my $each_line =<DAT>) {

		@line_array = split(/\t/, $each_line);

		if ($flag==0)   {        # to print out the first line
			open TEMP, ">$temp_file1";
			print TEMP $each_line;
			$flag=1;

			# for each bin, add lines in the bin into a temp file(temp1)
		}elsif ($line_array[3] < ($start_dist+$RANGE_BIN) && $flag==1) {  

			print TEMP $each_line;

			#at the last line of the bin, sort them by the start position of mem and put them into a temp file(temp2)
		} else  { 

			$prev1 = 0;   #the ending position of previous MEM
			$prev2 = 0;

			#after sorting each file of a bin, add it into bin_file
			close(TEMP);
			system ("sort -k 1n,2n   $temp_file1 > $temp_file2");       
			#save the sorted lines in a bin into bin file
			open (TEMP_SORTED, $temp_file2) || die("Couldn't open sorted bin file!\n");
			foreach my $each_line_bin (<TEMP_SORTED>) {

				chop($each_line_bin);
				@line_array_bin = split(/\s+/, $each_line_bin);

				#--------------------------------------------------------------------
				# if gap > 0.5, make seperate element
				#--------------------------------------------------------------------
				if ((($line_array_bin[2]+$line_array_bin[0]-$prev1> $line_array_bin[2]*0.5) && 
						($line_array_bin[2]+$line_array_bin[1]-$prev2> $line_array_bin[2]*0.5)) ||
					$line_array_bin[2]>=100){

					$line_count++;

					print OUTPUT $line_array_bin[0]."\t".$line_array_bin[1]."\t".$line_array_bin[2]."\t".$line_array_bin[3]."\t";
					print OUTPUT ($line_array_bin[0]-$prev1)."\t".($line_array_bin[1]-$prev2)."\n";
					$prev1 = $line_array_bin[0]+$line_array_bin[2];
					$prev2 = $line_array_bin[1]+$line_array_bin[2];
				}
			}
			close(TEMP_SORTED);

			#open a temp file again for the next bin
			print OUTPUT "------------------------------------------------------------------------\n";

			open TEMP, ">$temp_file1";
			print TEMP $each_line;

			@line_array =  split(/\s+/,$each_line);
			$start_dist = $start_dist + $RANGE_BIN;

			while ($start_dist+$RANGE_BIN <= $line_array[3])  {

				$start_dist = $start_dist + $RANGE_BIN;

			}
			$flag =1;
		}	
	}    
	close(DAT);

	$prev1 = 0;   #the ending position of previous MEM
	$prev2 = 0;

	#after sorting each file of a bin, add it into bin_file
	close(TEMP);
	system ("sort -k 1n,2n $temp_file1 > $temp_file2");       
	#save the sorted lines in a bin into bin file
	open (TEMP_SORTED, $temp_file2) || die("Couldn't open sorted bin file!\n");
	foreach my $each_line_bin (<TEMP_SORTED>) {

		chop($each_line_bin);
		@line_array_bin = split(/\s+/, $each_line_bin);	

		if ((($line_array_bin[2]+$line_array_bin[0]-$prev1> $line_array_bin[2]*0.5) && 
				($line_array_bin[2]+$line_array_bin[1]-$prev2> $line_array_bin[2]*0.5)) ||
			$line_array_bin[2]>=100){

			$line_count++;

			print OUTPUT $line_array_bin[0]."\t".$line_array_bin[1]."\t".$line_array_bin[2]."\t".$line_array_bin[3]."\t";
			print OUTPUT ($line_array_bin[0]-$prev1)."\t".($line_array_bin[1]-$prev2)."\n";
			$prev1 = $line_array_bin[0]+$line_array_bin[2];
			$prev2 = $line_array_bin[1]+$line_array_bin[2];
		}
	}
	close(TEMP_SORTED);
	close(OUTPUT);

	system("rm -rf $temp_file1");
	system("rm -rf $temp_file2");
	system("rm -rf $dist_file_sub");   
	system("rm -rf $mem_file_sub");

	if ($line_count ==0){
		system("rm -rf ".$bin_file_sub);
		return 0;
	}else {
		return 1;
	}
}

sub find_putative_ltr{ #$bin_file, $ltr_pre_file, $run_hmm

	my $bin_file_sub = $_[0];
	my $ltr_pre_file_sub = $_[1];

	print "Finding putative ltr\n";
	my ($count, $seq1, $seq2, $seq3, $plus, $minus ); 
	my (@long_orf, @out_ltr);
	my (@temp, @temp_prev, @temp_str, $str, @plus_minus, $temp_matcher, $direction, $is_ltr, $domain, @ltr_result);

	my $file1 = $bin_file_sub.".temp1";
	my $file2 = $bin_file_sub.".temp2";
	my $file3 = $bin_file_sub.".temp3";
	my $file4 = $bin_file_sub.".temp4";
	my $file5 = $bin_file_sub.".temp5";

	open(INPUT, $bin_file_sub)||die("couldn't open $bin_file_sub\n");
	open OUTPUT2, ">$file5";

	my $start_find=0;
	my $start=0;
	my $start_ltr1=0;
	my $start_ltr2=0;
	my $end_ltr1=0;
	my $end_ltr2=0;
	my $prev="";
	my $num_line=0;
	my $sum_match=0;
	my $sum_gap1=0;
	my $sum_gap2=0;    
	my $count=0;
	my $count_bin=0;
	my $line_count=0;
	my $count_alignment=0;
	my $each_count=0;


	foreach my $each_line (<INPUT>){
		$each_count++;
		if ($each_count % 10000==0){
			print $each_count."\t";
		}
		if($each_line =~ /--/){

			if ($start_find==1&& $start==1){
				$count_alignment++;
				@ltr_result=check_putative_ltr($start_ltr1, $end_ltr1, $start_ltr2, $end_ltr2, $sum_gap1, $sum_gap2, $count_bin, $_[2], $bin_file_sub);
				if ($ltr_result[0]==1 ){
					for(my $iii=1; $iii<=$#ltr_result; $iii++){
						print OUTPUT2 $ltr_result[$iii]."\t";
					}
					$line_count++;
					print OUTPUT2 "\n";
				}
			}else{
				$start_find=1;
			}
			$prev = "1000 1000 0 1000 1000 1000";	    
			$start=0;

		}elsif ($each_line !~ /--/){

			chomp($each_line);
			@temp = split(/\s+/, $each_line);
			@temp_prev = split(/\s+/, $prev);


			if ( $temp[4]<100 && $temp[5]<100 && abs($temp[3]-$temp_prev[3])<100 && $start==0){

				$start=1;
				$start_ltr1 = $temp_prev[0];
				$start_ltr2 = $temp_prev[1];
				$end_ltr1 = $temp[0]+$temp[2];
				$end_ltr2 = $temp[1]+$temp[2];
				$sum_match =$temp_prev[2]+$temp[2];
				$sum_gap1 =$temp[4];
				$sum_gap2 =$temp[5];	
				$count_bin=2;

			}elsif ($temp[4]<100 && $temp[5]<100 && abs($temp[3]-$temp_prev[3])<100 && $start==1){

				$end_ltr1 = $temp[0]+$temp[2];
				$end_ltr2 = $temp[1]+$temp[2];
				$sum_match = $sum_match + $temp[2];
				$sum_gap1 =$sum_gap1 + $temp[4];
				$sum_gap2 =$sum_gap2 + $temp[5];	
				$count_bin++;

			}elsif ($start==1){

				$start=0;
				$count_alignment++;
				@ltr_result=check_putative_ltr($start_ltr1, $end_ltr1, $start_ltr2, $end_ltr2, $sum_gap1, $sum_gap2, $count_bin, $_[2], $bin_file_sub);

				if ($ltr_result[0]==1){
					for(my $iii=1; $iii<=$#ltr_result; $iii++){
						print OUTPUT2 $ltr_result[$iii]."\t";
					}
					$line_count++;
					print OUTPUT2 "\n";
				}

				$sum_match=0;
				$sum_gap1=0;
				$sum_gap2=0;
				$count_bin=0;

				if($temp[2]>50){

					$start=1;
					$start_ltr1 = $temp[0];
					$start_ltr2 = $temp[1];
					$end_ltr1 = $temp[0]+$temp[2];
					$end_ltr2 = $temp[1]+$temp[2];
					$sum_match = $temp[2];
					$sum_gap1 = 0;
					$sum_gap2 = 0;
					$count_bin=1;
				}

			}elsif ( $temp[2]>50 && $start==0 )  {

				$start=1;
				$start_ltr1 = $temp[0];
				$start_ltr2 = $temp[1];
				$end_ltr1 = $temp[0]+$temp[2];
				$end_ltr2 = $temp[1]+$temp[2];
				$sum_match = $temp[2];
				$sum_gap1 = 0;
				$sum_gap2 = 0;	
				$count_bin=1;
			}
			$prev = $each_line;
		}
	}
	close(OUTPUT2);
	close(INPUT);

	if (-e $file1){
		system("rm -rf $file1");
	}
	if (-e $file2){
		system("rm -rf $file2");
	}
	if (-e $file3){
		system("rm -rf $file3");
	}
	if (-e $file4){
		system("rm -rf $file4");
	}
	system("rm -rf ".$bin_file_sub);

	if ($line_count == 0){
		system("rm -rf $file5");
		return 0;
	}else {
		system("sort -k 1n  ".$file5." > ".$ltr_pre_file_sub);
		system("rm -rf $file5");
		return 1;
	}
}

sub check_putative_ltr{ # $start_ltr1, $end_ltr1, $start_ltr2, $end_ltr2, $sum_gap1, $sum_gap2, $count_bin,$run_hmm, $bin_file

	my $start_ltr1=$_[0];
	my $end_ltr1=$_[1];
	my $start_ltr2=$_[2];
	my $end_ltr2=$_[3];

	my $sum_gap1=$_[4];
	my $sum_gap2=$_[5];
	my $count_bin=$_[6];
	my $run_hmm_sub = $_[7];
	my $bin_file_sub = $_[8];

	my ($seq1, $seq2, $seq3, @plus_minus, @out_ltr, @temp_str, @ltr_result, @tsd_result, @orf);
	my $file1 = $bin_file_sub.".temp1";
	my $file2 = $bin_file_sub.".temp2";
	my $file3 = $bin_file_sub.".temp3";
	my $file4 = $bin_file_sub.".temp4";

	my $direction="*";
	my $domain=1;
	my @long_orf=(0,"*");
	my $is_ltr=0;

	if ($end_ltr1-$start_ltr1>=$MIN_LEN_LTR && $end_ltr1-$start_ltr1<=$MAX_LEN_LTR && 
		$end_ltr2-$start_ltr2>=$MIN_LEN_LTR && $end_ltr2-$start_ltr2<=$MAX_LEN_LTR && 
		((abs(($end_ltr2-$start_ltr2) - ($end_ltr1-$start_ltr1))< $MIN_LEN_LTR &&
				$sum_gap1 <= 0.9* ($end_ltr1-$start_ltr1) &&
				$sum_gap2 <= 0.9* ($end_ltr2-$start_ltr2))||$count_bin==1)&&
		($start_ltr2-$end_ltr1)>$MIN_DIST ){

		$start_ltr1=$_[0]-500;
		if ($start_ltr1<0){
			$start_ltr1=0;
		}
		$end_ltr1=$_[1]+500;
		$start_ltr2=$_[2]-500;
		if ($start_ltr2<0){
			$start_ltr2=0;
		}
		$end_ltr2=$_[3]+500;

		$seq1 = substr($genome_seq, $start_ltr1, eval($end_ltr1-$start_ltr1+1));
		$seq2 = substr($genome_seq, $start_ltr2, eval($end_ltr2-$start_ltr2+1));
		$seq3 = substr($genome_seq, $end_ltr1+1, eval($start_ltr2-$end_ltr1));

		open SEQ1, ">$file1";
		print SEQ1 ">1_\n";
		print SEQ1 $seq1."\n";
		close(SEQ1);

		open SEQ2, ">$file2";
		print SEQ2 ">2_\n";
		print SEQ2 $seq2."\n";
		close(SEQ2);

		open SEQ3, ">$file3";
		print SEQ3 ">3\n";
		print SEQ3 $seq3."\n";
		close(SEQ3);

		@temp_str = find_sim($file1, $file2); 
		if (($temp_str[0]>$LTR_SIM_CONDITION) && ($temp_str[3]-$temp_str[1] >= $MIN_LEN_LTR) && ($temp_str[4]-$temp_str[2] >= $MIN_LEN_LTR) ){

			@plus_minus = (1,1);
			@orf = (0,"");
			if ($run_hmm_sub==1){
				@plus_minus = find_domain($file3, $file4);   #returning evalue for + strand and - strand
				@orf = check_long_orf($file4);
			}else{
				@plus_minus = (-1,-1);
			}

			$out_ltr[0] = eval($start_ltr1+$temp_str[1]-1);
			$out_ltr[1] = eval($start_ltr1+$temp_str[3]-1);
			$out_ltr[2] = eval($start_ltr2+$temp_str[2]-1);
			$out_ltr[3] = eval($start_ltr2+$temp_str[4]-1);
			$out_ltr[4] = $out_ltr[1] -  $out_ltr[0] + 1;
			$out_ltr[5] = $out_ltr[3] -  $out_ltr[2] + 1;
			$out_ltr[6] = $out_ltr[2] -  $out_ltr[0];


			if ($plus_minus[0] < $plus_minus[1] && $plus_minus[0] < 1e-10){   #forward strand

				$direction = "+";
				$is_ltr=1;
				$domain = $plus_minus[0];

				#check tsd and dinucleotide
				@tsd_result = check_tsd($direction, $out_ltr[0], $out_ltr[1], $out_ltr[2], $out_ltr[3]);  
				#@tsd_result = tsd5, tsd3, di55, di53, di35, di33, offset55, offset53, offset35, offset33


			}elsif($plus_minus[1] < $plus_minus[0] && $plus_minus[1] < 1e-10){   #backward strand

				$direction = "-";
				$is_ltr=1;
				$domain = $plus_minus[1];


				#check tsd and dinucleotide
				@tsd_result = check_tsd($direction, $out_ltr[0], $out_ltr[1], $out_ltr[2], $out_ltr[3]);  
				#@tsd_result = tsd5, tsd3, di55, di53, di35, di33, offset55, offset53, offset35, offset33

			}elsif($plus_minus[0]==-1 && $plus_minus[1]==-1){    #for simulation

				$is_ltr=1;

			}


			if ($is_ltr==1){
				@ltr_result = (1, $out_ltr[0], $out_ltr[1], $out_ltr[2], $out_ltr[3], $direction, $out_ltr[4], $out_ltr[5], $out_ltr[6], $temp_str[0], $domain);
				push(@ltr_result, @tsd_result);

				if ($direction eq $plus_minus[3]){
					push(@ltr_result, $plus_minus[2]);

				}else{
					push(@ltr_result, "-");
				}

			}else{
				@ltr_result = (0);
			}
		}
	}

	return @ltr_result;
}

sub check_tsd{ #$direction, $out_ltr[0], $out_ltr[1], $out_ltr[2], $out_ltr[3]

	my ($seq55, $seq53, $seq35, $seq33, $seq);
	my ($offset55, $offset53, $offset35, $offset33);
	my ($temp_offset55, $temp_offset53, $temp_offset35, $temp_offset33);
	my ($di55, $di53, $di35, $di33, $temp_di55, $temp_di53, $temp_di35, $temp_di33);
	my ($tsd5, $tsd3, $temp_tsd5, $temp_tsd3);
	my @result;

	if ($_[0] eq "+"){
		$seq55 = substr($genome_seq, $_[1]-20, 41);
		$seq53 = substr($genome_seq, $_[2]-20, 41);
		$seq35 = substr($genome_seq, $_[3]-20, 41);
		$seq33 = substr($genome_seq, $_[4]-20, 41);
	}else{
		$seq = substr($genome_seq, $_[4]-20, 41);
		$seq =~ tr/[A,C,G,T,a,c,g,t]/[T,G,C,A,T,G,C,A]/;
		$seq55 = reverse($seq);

		$seq = substr($genome_seq, $_[3]-20, 41);
		$seq =~ tr/[A,C,G,T,a,c,g,t]/[T,G,C,A,T,G,C,A]/;
		$seq53 = reverse($seq);

		$seq = substr($genome_seq, $_[2]-20, 41);
		$seq =~ tr/[A,C,G,T,a,c,g,t]/[T,G,C,A,T,G,C,A]/;
		$seq35 = reverse($seq);

		$seq = substr($genome_seq, $_[1]-20, 41);
		$seq =~ tr/[A,C,G,T,a,c,g,t]/[T,G,C,A,T,G,C,A]/;
		$seq33 = reverse($seq);
	}

	# find the tsd (the last 5' and the first 3')
	#result: $found, $offset55, $offset53, $offset35, $offset33, $di55, $di53, $di35, $di33, $tsd5, $tsd3
	my @temp_result=(0,100,100,100,100,"","","","","","");

	@result=find_tsd($seq55, $seq53, $seq35, $seq33, 4,4);
	if ($result[0]==1){
		my $offset_old = abs($temp_result[1])+abs($temp_result[2])+abs($temp_result[3])+abs($temp_result[4]);
		my $offset_new = abs($result[1])+abs($result[2])+abs($result[3])+abs($result[4]);

		if ($offset_old > $offset_new){
			@temp_result = @result;
		}
	}

	@result=find_tsd($seq55, $seq53, $seq35, $seq33, 5,5);
	if ($result[0]==1){
		my $offset_old = abs($temp_result[1])+abs($temp_result[2])+abs($temp_result[3])+abs($temp_result[4]);
		my $offset_new = abs($result[1])+abs($result[2])+abs($result[3])+abs($result[4]);

		if ($offset_old > $offset_new){
			@temp_result = @result;
		}
	}

	@result=find_tsd($seq55, $seq53, $seq35, $seq33, 6,6);
	if ($result[0]==1){
		my $offset_old = abs($temp_result[1])+abs($temp_result[2])+abs($temp_result[3])+abs($temp_result[4]);
		my $offset_new = abs($result[1])+abs($result[2])+abs($result[3])+abs($result[4]);

		if ($offset_old > $offset_new){
			@temp_result = @result;
		}
	}

	@result=find_tsd($seq55, $seq53, $seq35, $seq33, 4,3);
	if ($result[0]==1){
		my $offset_old = abs($temp_result[1])+abs($temp_result[2])+abs($temp_result[3])+abs($temp_result[4]);
		my $offset_new = abs($result[1])+abs($result[2])+abs($result[3])+abs($result[4]);

		if ($offset_old > $offset_new){
			@temp_result = @result;
		}
	}

	@result=find_tsd($seq55, $seq53, $seq35, $seq33, 5,4);
	if ($result[0]==1){
		my $offset_old = abs($temp_result[1])+abs($temp_result[2])+abs($temp_result[3])+abs($temp_result[4]);
		my $offset_new = abs($result[1])+abs($result[2])+abs($result[3])+abs($result[4]);

		if ($offset_old > $offset_new){
			@temp_result = @result;
		}
	}

	@result=find_tsd($seq55, $seq53, $seq35, $seq33, 6,5);
	if ($result[0]==1){
		my $offset_old = abs($temp_result[1])+abs($temp_result[2])+abs($temp_result[3])+abs($temp_result[4]);
		my $offset_new = abs($result[1])+abs($result[2])+abs($result[3])+abs($result[4]);

		if ($offset_old > $offset_new){
			@temp_result = @result;
		}
	}

	if ($temp_result[0]==1){
		return ($temp_result[9], $temp_result[10], $temp_result[5], $temp_result[6], $temp_result[7], $temp_result[8], $temp_result[1], $temp_result[2], $temp_result[3], $temp_result[4]);
	}else{
		return ("-","-","-","-","-","-",0,0,0,0);
	}
}


sub find_sim{#$file1, $file2

	my @result=();
	my $temp_matcher = "matcher -datafile=".$tool_matrix." -asequence=".$_[0]." -bsequence=".$_[1]." -outfile=stdout -awidth3=4000 2>/dev/null";
	my $str_result = `$temp_matcher`;
	my @line = split(/\n/, $str_result);
	my @space1 = split(/\d+/, $line[31]);
	my @pos1 = split(/\s+/, $line[31]);
	my @space2 = split(/\d+/, $line[35]);
	my @pos2 = split(/\s+/, $line[35]);

	if ($str_result =~ /(Identity:\s+\d+\/\d+\s*\((\d+.\d+)%\))/){
		$result[0]=$2;
	}
	$result[1]=$pos1[1]-length($space1[0])-(length($pos1[1])-1)+7;
	if ($#pos1>$#space1) {
		$result[3]=$pos1[$#pos1];
	}else{
		$result[3]=$pos1[$#pos1]+length($space1[$#space1]);
	}
	$result[2]=$pos2[1]-length($space2[0])-(length($pos2[1])-1)+7;
	if ($#pos2>$#space2) {
		$result[4]=$pos2[$#pos2];
	}else{
		$result[4]=$pos2[$#pos2]+length($space2[$#space2]);
	}
	return @result;
}



sub find_domain{ #$file3, $file4

	system("transeq -sequence ".$_[0]." -outseq ".$_[1]." -frame=6  2>/dev/null");
	my $plus = 1;
	my $minus = 1;
	my $evalue = 0.00001;
	my $class = -1;
	my $sign = "";
	my $class_strand=0;
	my $class_name="-";
	my $fh;
	my $tmpfile;

	for (my $j=0; $j<=$#rt; $j++){
		if ($hmmerv == 3){
			#($fh, $tmpfile) = tempfile( UNLINK => 1, SUFFIX => '.tbl');
			#system("hmmconvert ".$tool_pfam.$rt[$j]." > ".$tool_pfam."c_".$rt[$j]);
			#system("hmmsearch -E 0.000001 --noali --tblout ".$tmpfile." ".$tool_pfam."".$rt[$j]."3 ".$_[1]."> /dev/null");
			my $temp_tool="hmmsearch -E 0.000001 --noali ".$tool_pfam."".$rt[$j]."3 ".$_[1];
			my $str = `$temp_tool`;
			#local $/ = undef;
			#my $str = <$fh>;
			#close $fh;
			#unlink0($fh, $tmpfile);
			#if ($str =~ /\n(\d+.*)\n/){
			if ($str =~ /-----------\n\s+(\d+.*)\n/) {
				my @temp_plus = split(/\s+/, $1);
				if ($temp_plus[0]<$evalue){
					$evalue=$temp_plus[0];
					$class = $j;

					if ($temp_plus[8]=~ /(\_1|\_2|\_3)/){
						$sign = "+";
					}else{
						$sign = "-";
					}
				}
			}

		}else{
			#system("hmmconvert -F ".$tool_pfam.$rt[$j]." ".$tool_pfam."c_".$rt[$j]);
			my $temp_tool="hmm2search -E 0.000001 ".$tool_pfam."".$rt[$j]." ".$_[1];
			my $str = `$temp_tool`;

			if ($str =~ /\s---\n(\d+\_\d\s+\d+\.\d+\s+((\d|\-|\.|e)+))\s/){
				my @temp_plus = split(/\s+/, $1);

				if ($temp_plus[2]<$evalue){
					$evalue=$temp_plus[2];
					$class = $j;

					if ($temp_plus[0]=~ /(\_1|\_2|\_3)/){
						$sign = "+";
					}else{
						$sign = "-";
					}
				}
			}
		}


	}


	if ($class == 0 || $class == 1){         #nonLTR
		$plus = 1;
		$minus = 1;
	}elsif ($class == -1){    #no RT
		$plus = 1;
		$minus = 1;
	}else {
		if ($sign eq "+"){
			$plus = $evalue;
			$minus = 1;
			$class_strand = "+";
		}else {
			$plus = 1;
			$minus = $evalue;
			$class_strand = "-";
		}
		if ($class ==2){
			$class_name = "Gypsy";
		}if ($class ==3){
			$class_name = "Copia";
		}if ($class ==4){
			$class_name = "Bel";
		}if ($class ==5){
			$class_name = "ERV1";
		}if ($class ==6){
			$class_name = "ERV2";
		}if ($class ==7){
			$class_name = "ERV3";
		}
	}

	if ($class > 1 || $class <0 ){
		my $fh;
		my $tmpfile;
		my $template;

		for (my $j=0; $j<=$#pf; $j++){
			if ($hmmerv == 3){
				#($fh, $tmpfile) = tempfile( UNLINK => 1, SUFFIX => '.tbl');
				#system("hmmconvert ".$tool_pfam.$pf[$j]." > ".$tool_pfam."c_".$pf[$j]);
				#system("hmmsearch -E 0.000001 --noali --tblout ".$tmpfile." ".$tool_pfam."".$pf[$j]."3 ".$_[1]."> /dev/null");
				my $temp_tool="hmmsearch -E 0.000001 --noali ".$tool_pfam."".$pf[$j]."3 ".$_[1];
				my $str = `$temp_tool`;
				#local $/ = undef;
				#my $str = <$fh>;
				#close $fh;
				#unlink0($fh, $tmpfile);
				#if ($str =~ /\n(\d+.*)\n/){
				if ($str =~ /-----------\n\s+(\d+.*)\n/) {
					my @temp_plus = split(/\s+/, $1);

					if ($temp_plus[8]=~ /(\_1|\_2|\_3)/){
						$plus = $plus * $temp_plus[0];
					}else{
						$minus = $minus * $temp_plus[0];
					}
				}
			}else{
				#system("hmmconvert -F ".$tool_pfam.$pf[$j]." ".$tool_pfam."c_".$pf[$j]);
				my $temp_tool="hmm2search -E 0.000001 ".$tool_pfam."".$pf[$j]." ".$_[1];
				my $str = `$temp_tool`;

				if ($str =~ /\s---\n(\d+\_\d\s+\d+\.\d+\s+((\d|\-|\.|e)+))\s/){
					my @temp_plus = split(/\s+/, $1);

					if ($temp_plus[0]=~ /(\_1|\_2|\_3)/){
						$plus = $plus * $temp_plus[2];
					}else{
						$minus = $minus * $temp_plus[2];
					}
				}
			}


		}
	}

	return ($plus, $minus, $class_name, $class_strand );
}



sub check_long_orf{ #$file4

	open(DAT, $_[0])||die("ERROR: Couldn't open $_[0]\n");
	my @temp = <DAT>;
	chomp(@temp);

	my $temp_frame;
	my @max_len;
	my $max_frame;
	$max_len[0]=0;
	my $i=0;
	my $long = join("",@temp);
	while ($long=~ m/\>\d+_\d+((\w|\*)+)/g){
		$temp_frame = $1;
		$i++;
		while($temp_frame =~ m/(\w+)/g){
			if (length($1) > $max_len[0]){
				$max_len[0] = length($1);
				$max_frame = $i;
			}
		}
	}
	if ($max_frame == 1 || $max_frame ==2 || $max_frame ==3){
		$max_len[1] = "+";
	}else {
		$max_len[1] = "-";
	}

	return @max_len;
}



sub chain_putative_ltrs{ #$ltr_pre_file, $ltr_file

	my $ltr_pre_file_sub = $_[0];
	my $ltr_file_sub = $_[1];

	open(INPUT, $ltr_pre_file_sub) || die("couldn't open $ltr_pre_file_sub\n");
	open OUTPUT, ">$ltr_file_sub";
#    open NESTED, ">$nested_file";

	my @temp=();
	my @pre=(-1000, -10000, -1000, -10000,"*", 0,0,0,0);
	my $start=0;
	my $seq;
	my $temp_file1=$ltr_file_sub.".temp1";
	my $temp_file2=$ltr_file_sub.".temp2";
	my $temp_stretcher;
	my $result;
	my $index=0;

	foreach my $each_line(<INPUT>){

		chomp($each_line);
		@temp = split(/\s+/, $each_line);

		if ($temp[1] < $pre[2] ){ #if overlapped elements, keep the more similar one

			if ($temp[8] > $pre[8]){
				@pre = @temp;
			}

		}else{

			if ($start==0){
				$start=1;
			}else{
				$index++;
				print OUTPUT $pre[0]."\t".$pre[1]."\t".$pre[2]."\t".$pre[3]."\t";
				print OUTPUT $pre[4]."\t".$pre[5]."\t".$pre[6]."\t".$pre[7]."\t".$pre[8]."\t".$pre[9]."\t";
				print OUTPUT $pre[10]."\t".$pre[11]."\t".$pre[12]."\t".$pre[13]."\t".$pre[14]."\t".$pre[15]."\t";
				print OUTPUT $pre[16]."\t".$pre[17]."\t".$pre[18]."\t".$pre[19]."\t".$pre[20]."\n";
			}
			@pre=@temp;

		}
	}
	$index++;
	print OUTPUT $pre[0]."\t".$pre[1]."\t".$pre[2]."\t".$pre[3]."\t";
	print OUTPUT $pre[4]."\t".$pre[5]."\t".$pre[6]."\t".$pre[7]."\t".$pre[8]."\t".$pre[9]."\t";
	print OUTPUT $pre[10]."\t".$pre[11]."\t".$pre[12]."\t".$pre[13]."\t".$pre[14]."\t".$pre[15]."\t";
	print OUTPUT $pre[16]."\t".$pre[17]."\t".$pre[18]."\t".$pre[19]."\t".$pre[20]."\n";
	close(OUTPUT);
	close(INPUT);
}


sub diff_string{

	my @temp1 = split(//, $_[0]);
	my @temp2 = split(//, $_[1]);
	my $count=0;

	if ($#temp1 != $#temp2){
		return -1;
	}

	for (my $i=0; $i<= $#temp1; $i++){
		if ($temp1[$i] eq $temp2[$i]){
			$count++;
		}
	}
	return $count;
}


sub find_tsd{

	my ($offset55, $offset53, $offset35, $offset33);
	my ($temp_offset55, $temp_offset53, $temp_offset35, $temp_offset33);
	my ($di55, $di53, $di35, $di33, $temp_di55);
	my ($temp_di53, $temp_di35, $temp_di33);
	my ($tsd5, $tsd3, $temp_tsd5, $temp_tsd3);

	my $seq55 = $_[0];
	my $seq53 = $_[1];
	my $seq35 = $_[2];
	my $seq33 = $_[3];
	my $tsd_len = $_[4];
	my $tsd_sim_len = $_[5];

	my $found=0;
	while ($seq55 =~ m/TG/g){

		$temp_di55="TG";
		if (substr($seq55, pos($seq55), 1) eq "T"){
			$temp_di55 =$temp_di55."T";
		}
		$temp_tsd5 = substr($seq55, pos($seq55)-($tsd_len+2), $tsd_len);
		$temp_offset55 = pos($seq55)-1;

		my $temp_found=0;
		while($seq33 =~ m/CA/g){
			if ($temp_found==0){
				$temp_di33="CA";
				if (substr($seq33, pos($seq33)-3, 1) eq "A"){
					$temp_di33 ="A".$temp_di33;
				}
				$temp_tsd3 = substr($seq33, pos($seq33), $tsd_len);
				$temp_offset33 = pos($seq33);

				my $offset_old = abs($offset55-21)+abs($offset33-21);
				my $offset_new = abs($temp_offset55-21)+abs($temp_offset33-21);

				if (diff_string($temp_tsd5, $temp_tsd3)>=$tsd_sim_len && $offset_new < $offset_old){

					$di55 = $temp_di55;
					$di33 = $temp_di33;
					$tsd5 = $temp_tsd5;
					$tsd3 = $temp_tsd3;
					$offset55 = $temp_offset55;
					$offset33 = $temp_offset33;
					$offset53=10000;
					$offset35=10000;
					while ($seq53 =~ m/CA/g){

						if (abs(pos($seq53)-$offset33)< abs($offset53-$offset33)){
							$di53="CA";
							if (substr($seq53, pos($seq53)-3, 1) eq "A"){
								$di53 = "A".$di53;
							}
							$offset53 = pos($seq53);
						}
					}
					while ($seq35 =~ m/TG/g){

						if (abs(pos($seq35)-$offset55)< abs($offset35-$offset55)){
							$di35="TG";
							if (substr($seq35, pos($seq35), 1) eq "T"){
								$di35 =$di35."T";
							}

							$offset35 = pos($seq35)-1;
						}
					}
					$temp_found=1;
					$found=1;
				}
			}
		}
	}
	return ($found, $offset55-21, $offset53-21, $offset35-21, $offset33-21, $di55, $di53, $di35, $di33, $tsd5, $tsd3);
}

