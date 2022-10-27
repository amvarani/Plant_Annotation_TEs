#!/usr/bin/perl  -w
use strict;
use Getopt::Long;
use Cwd 'abs_path';
use File::Basename;
use File::Temp qw/ tempfile unlink0 /;
use lib (dirname abs_path $0) . '/lib';
use Prompt qw(prompt_yn);

my $debug;
$debug = $ENV{'MGESCAN_DEBUG'};

my $pdir = dirname(abs_path($0))."/";
my $hmm_dir = $pdir."pHMM/";
my $hmmerv;

my @all_clade = ('CR1', 'I', 'Jockey', 'L1', 'L2', 'R1', 'RandI', 'Rex', 'RTE', 'Tad1', 'R2','CRE');
my @en_clade = ('CR1', 'I', 'Jockey', 'L1', 'L2', 'R1', 'RandI', 'Rex', 'RTE', 'Tad1');
my $genome="";   
my $dir;
my $domain;
my $seq_dir;
my $validation_dir;
my $validation_file;
my $evalue_file;
my $tree_dir;
my $seq;

get_parameter(\$dir, \$hmmerv);

# copy seq from out2 dir into info dir
system("mkdir -p ".$dir."info/full");

# get_full_frag()
# Description: First function to collect full fragmentations from results in
#              forward and backward (complement and reverse complement)
#
# Inputs: f/out2/[@all_clade]_full
#        b/out2/[@all_clade]_full
#
# Outputs: info/full/[@all_clade]/[@all_clade].dna
#         info/full/[@all_clade]/[@all_clade].pep
#
# Tips: No *_full files produce no results
#
get_full_frag($genome, $dir, \@all_clade);

# get domain seq
#
# Desciption: If .pep files exist, then run hmmsearch for searching protein sequences in a database
#
# Inputs: info/full/[@all_clade]/[@all_clade].pep
#         info/full/[@all_clade]/[@all_clade].dna
#
# Outputs: info/full/[@all_clade]/[@all_clade].[en|rt].pep
#
# Tips: "en", "rt" can be executed in parallel
#
get_domain_for_full_frag($genome, "en", \@en_clade, $dir, $hmm_dir);
get_domain_for_full_frag($genome, "rt", \@all_clade, $dir, $hmm_dir);

#######################################################
# Should be a function call for en|rt
#######################################################

# get Q value after running pHMM for EN in full elements
$validation_dir = $dir."info/validation/";
system("mkdir ".$validation_dir);

$domain = "en";
$seq_dir = $dir."info/full/";
$validation_file = $validation_dir.$domain;
$evalue_file = $validation_dir.$domain."_evalue";

opendir(DIRHANDLE, $seq_dir) || die ("Cannot open directory ".$seq_dir);
foreach my $name (sort readdir(DIRHANDLE)) {
	# Exception for R2 and CRE (skipping)
	if ($name !~ /^\./ && $name ne "R2" && $name ne "CRE" ){
		$seq = $seq_dir.$name."/".$name.".".$domain.".pep";
		vote_hmmsearch($seq, $hmm_dir, $domain, $validation_file, $evalue_file, \@en_clade);
	}
}
closedir(DIRHANDLE);

# get Q value after running pHMM for RT in full elements
$domain = "rt";
$seq_dir = $dir."info/full/";
$validation_file = $validation_dir.$domain;
$evalue_file = $validation_dir.$domain."_evalue";

opendir(DIRHANDLE, $seq_dir) || die ("Cannot open directory ".$seq_dir);
foreach my $name (sort readdir(DIRHANDLE)) {
	if ($name !~ /^\./){
		$seq = $seq_dir.$name."/".$name.".".$domain.".pep";
		vote_hmmsearch($seq, $hmm_dir, $domain, $validation_file, $evalue_file, \@all_clade);
	}
}
close(DIRHANDLE);
#system("rm ".$seq_dir."*/*.pep");
#system("rm ".$seq_dir."*/*.rt.*");
#system("rm ".$seq_dir."*/*.en.*");
system("rm -r ".$dir."b") if (not $debug);
system("rm -r ".$dir."f") if (not $debug);

###############################################################################
# Subroutines
###############################################################################

sub get_parameter{

	my ($dir, $hmmerv);

	GetOptions(
		'data_dir=s' => \$dir,
		'hmmerv=s' => \$hmmerv,
	);

	if (! -e $dir){
		print "ERROR: The directory $dir does not exist.\n";
		usage();
	}
	if (length($hmmerv)==0){
		print "ERROR: HMMER version not provided.\n";
		usage();
		exit;
	}

	${$_[0]} = $dir."/";
	${$_[1]} = $hmmerv;
}



sub get_domain_for_full_frag{

	my $genome = $_[0];
	my $domain = $_[1]; # en|rt
	my @all_clade = @{$_[2]};
	my $hmm_dir = $_[4]; # ./pHMM
	my ($dir);
	my ($pep_file, $dna_file);
	my ($phmm_file, $result_pep_file, $result_dna_file);

	print "get_domain_for_full_frag" if ($debug);

	for (my $i=0; $i<=$#all_clade; $i++){

		my $clade = $all_clade[$i];

		$dir = $_[3]."info/full/".$clade."/";
		$pep_file = $dir.$clade.".pep";
		$dna_file = $dir.$clade.".dna";

		if (-e $pep_file ){

			$phmm_file = $hmm_dir.$clade.".".$domain.".hmm";
			$result_pep_file = $dir.$clade.".".$domain.".pe";
			$result_dna_file = $dir.$clade.".".$domain.".dna";

			my $flag = 2;  #1: protein-protein, 2: protein-dna 
			get_domain_pep_seq($pep_file, $phmm_file, $result_pep_file);
			get_domain_dna_seq($pep_file, $phmm_file, $result_dna_file, $dna_file, $flag);

			my $command = "sed 's/>/>".$clade."_/' ".$result_pep_file." > ".$result_pep_file."p";
			print $command if ($debug);
			if ($debug && not prompt_yn("Continue?")) {
				exit;
			}
			system($command);
			system("rm ".$result_pep_file) if (not $debug);

		}
	}
}




sub get_full_frag{

	my $genome=$_[0];
	my $dir = $_[1];
	my @all_clade = @{$_[2]};
	my $file;
	my $clade_dir;
	my ($dna_file, $pep_file, $file_f, $file_b);

	print "get_full_frag" if ($debug);

	for (my $i=0; $i<=$#all_clade; $i++){

		# create a clade dir
		$clade_dir = $dir."info/full/".$all_clade[$i]."/";
		$file_f = $dir."f/out2/".$all_clade[$i]."_full";
		$file_b = $dir."b/out2/".$all_clade[$i]."_full";
		if (-e $file_f || -e $file_b){
			system("mkdir ".$clade_dir);
		}

		# copy full length in + strand
		if (-e $file_f){
			my $command = "cat ".$file_f." > ".$clade_dir.$all_clade[$i].".dna";
			print $command if ($debug);
			system($command);
		}

		# copy full length in - strand
		if (-e $file_b){
			my $command = "cat ".$file_b." >> ".$clade_dir.$all_clade[$i].".dna";
			print $command if ($debug);
			system($command);
		}

		# translate
		$dna_file = $dir."info/full/".$all_clade[$i]."/".$all_clade[$i].".dna";
		$pep_file = $dir."info/full/".$all_clade[$i]."/".$all_clade[$i].".pep";	   
		if (-e $dna_file){
			my $command = "transeq -frame=f -sequence=".$dna_file." -outseq=".$pep_file." 2>/dev/null";
			print $command if ($debug);
			system($command);
		}
	}
}

#
# Almost identical to get_domain_dna_seq
#
sub get_domain_pep_seq{

	#$_[0]: pep seq file
	#$_[1]: domain hmm file
	#$_[2]: output domain pep seq file 

	my %domain_start=();
	my %domain_end=();
	my %result_start=();
	my %result_end=();
	my %uniq_head=();
	my $fh;
	my $tmpfile;
	my $hmm_result;

	($fh, $tmpfile) = tempfile( UNLINK => 1, SUFFIX => '.tbl');

	if ($hmmerv == 3){
		#system("hmmconvert ".$_[1]." > ".$_[1]."c");
		#system("hmmsearch  --noali --domtblout ".$hmm_dir."tbl ".$_[1]."c ".$_[0]." > /dev/null");
		#system("hmmsearch  --noali --domtblout ".$hmm_dir."tbl ".$_[1]."3 ".$_[0]." > /dev/null");
		my $command = ("hmmsearch --noali --domtblout ".$tmpfile." ".$_[1]."3 ".$_[0]." > /dev/null");
		print $command if ($debug);
		system($command);
		#my $hmm_command = "cat ".$hmm_dir."tbl";
		#my $hmm_result = `$hmm_command`;
		local $/ = undef;
		$hmm_result = <$fh>;
		close $fh;
		unlink0($fh, $tmpfile);
		#while ($hmm_result =~ /\n((?!#).*)\n/g){
		my @sp = split /\n/, $hmm_result;
		for my $line (@sp) {
			next if ($line =~ /^#/);
			my @temp = split(/\s+/, $line);
			#	if ($temp[9]<0.000001 ){
			my $key = substr($temp[0],0,length($temp[0]));
			my $uniq_key = substr($temp[0],0,length($temp[0])-2);

			if (exists $uniq_head{$uniq_key}){
			}else{
				$uniq_head{$uniq_key} = 1;
				$result_start{$key} = $temp[17];
				$result_end{$key} = $temp[18];
			}
			#	}
		}
	}else{
		my $hmm_command = "hmm2search  ".$_[1]." ".$_[0];
		my $hmm_result = `$hmm_command`;
		while ($hmm_result =~ /((\d|\w|\-|\_|\#|\/|\.)+\s+\d+\/\d+\s+\d+\s+\d+\s+(\[|\.)(\]|\.)\s+\d+\s+\d+\s+(\[|\.)(\]|\.)\s+(\-)*\d+\.\d+\s+((\d|\-|\.|e)+))\s*/g){
			my @temp = split(/\s+/, $1);
			#	if ($temp[9]<0.000001 ){
			my $key = substr($temp[0],0,length($temp[0]));
			my $uniq_key = substr($temp[0],0,length($temp[0])-2);

			if (exists $uniq_head{$uniq_key}){
			}else{
				$uniq_head{$uniq_key} = 1;
				$result_start{$key} = $temp[2];
				$result_end{$key} = $temp[3];
			}
			#	}
		}
	}


	my $flag=0;
	my $head="";
	my $seq="";
	open (IN, $_[0]);
	open OUT, ">$_[2]";
	while(my $each_line=<IN>){
		chomp($each_line);
		if ($each_line =~ /\>/){
			if (length($head)>0 && $flag==1 ){
				print OUT ">".$head."\n";
				print OUT substr($seq, $result_start{$head}, eval($result_end{$head}-$result_start{$head}+1))."\n";
			}
			my @temp = split(/\s+/, $each_line);
			if (exists $result_start{substr($temp[0], 1, length($temp[0])-1)}){
				$flag=1;
				$head = substr($temp[0], 1, length($temp[0])-1);
			}else{
				$flag=0;
			}
			$seq="";
		}else{
			if($flag==1){
				$seq .= $each_line;
			}
		}
	}
	if($flag==1){
		print OUT ">".$head."\n";
		print OUT substr($seq, $result_start{$head}, eval($result_end{$head}-$result_start{$head}+1))."\n";
	}
	close(IN);
	close(OUT);
}


sub get_domain_dna_seq{

	#$_[0]: pep seq file
	#$_[1]: domain hmm file
	#$_[2]: output domain dna seq file 
	#$_[3]: dna seq file
	my %domain_start=();
	my %domain_end=();
	my %result_start=();
	my %result_end=();
	my %uniq_head=();
	my $fh;
	my $tmpfile;
	my $hmm_result;

	($fh, $tmpfile) = tempfile( UNLINK => 1, SUFFIX => '.tbl');

	if ($hmmerv == 3){
		#system("hmmconvert ".$_[1]." > ".$_[1]."c");
		#system("hmmsearch  --noali --domtblout ".$hmm_dir."tbl ".$_[1]."c ".$_[0]." > /dev/null");
		#system("hmmsearch  --noali --domtblout ".$hmm_dir."tbl ".$_[1]."3 ".$_[0]." > /dev/null");
		my $command = ("hmmsearch --noali --domtblout ".$tmpfile." ".$_[1]."3 ".$_[0]." > /dev/null");
		print $command if ($debug);
		system($command);
		#my $hmm_command = "cat ".$hmm_dir."tbl";
		#my $hmm_result = `$hmm_command`;
		local $/ = undef;
		$hmm_result = <$fh>;
		close $fh;
		unlink0($fh, $tmpfile);

		my @sp = split /\n/, $hmm_result;
		#while ($hmm_result =~ /\n((?!#).*)\n/g){
		for my $line (@sp) {
			next if ($line =~ /^#/);
			my @temp = split(/\s+/, $line);
			my $key = substr($temp[0],0,length($temp[0]));
			my $uniq_key = substr($temp[0],0,length($temp[0])-2);

			if (exists $result_start{$uniq_key}){
			}else{
				$uniq_head{$uniq_key} = 1;
				if ($_[4] ==1){
					$result_start{$key} = $temp[17];
					$result_end{$key} = $temp[18];
				}elsif($_[4] ==2){
					$result_start{$uniq_key} = $temp[17];
					$result_end{$uniq_key} = $temp[18];
				}
			}
		}
	}else{
		my $hmm_command = "hmm2search  ".$_[1]." ".$_[0];
		my $hmm_result = `$hmm_command`;

		while ($hmm_result =~ /((\d|\w|\-|\_|\#|\/|\.)+\s+\d+\/\d+\s+\d+\s+\d+\s+(\[|\.)(\]|\.)\s+\d+\s+\d+\s+(\[|\.)(\]|\.)\s+(\-)*\d+\.\d+\s+((\d|\-|\.|e)+))\s*/g){
			my @temp = split(/\s+/, $1);
			my $key = substr($temp[0],0,length($temp[0]));
			my $uniq_key = substr($temp[0],0,length($temp[0])-2);

			if (exists $result_start{$uniq_key}){
			}else{
				$uniq_head{$uniq_key} = 1;
				if ($_[4] ==1){
					$result_start{$key} = $temp[2];
					$result_end{$key} = $temp[3];
				}elsif($_[4] ==2){
					$result_start{$uniq_key} = $temp[2];
					$result_end{$uniq_key} = $temp[3];
				}
			}
		}
	}
	my $flag=0;
	my $head="";
	my $seq="";
	open (IN, $_[3]);
	open OUT, ">$_[2]";
	while(my $each_line=<IN>){
		chomp($each_line);
		if ($each_line =~ /\>/){
			if (length($head)>0 && $flag==1 ){
				print OUT ">".$head."\n";
				print OUT substr($seq, $result_start{$head}*3-3, eval(($result_end{$head}-$result_start{$head}+1)*3+3))."\n";
			}
			my @temp = split(/\s+/, $each_line);
			if (exists $result_start{substr($temp[0], 1, length($temp[0])-1)}){
				$flag=1;
				$head = substr($temp[0], 1, length($temp[0])-1);
			}else{
				$flag=0;
			}
			$seq="";
		}else{
			if($flag==1){
				$seq .= $each_line;
			}
		}
	}
	if($flag==1){
		print OUT ">".$head."\n";
		print OUT substr($seq, $result_start{$head}*3-3, eval(($result_end{$head}-$result_start{$head}+1)*3+3))."\n";
	}
	close(IN);
	close(OUT);
}



sub vote_hmmsearch{

	my @line = @{$_[5]};
	my %evalue;
	my %save_evalue;
	my %clade;
	my %sig;
	my $i;
	my $anno_clade; 

	if (-z $_[0]){
		return;
	}

	open (IN, $_[0]);
	while(my $each_line=<IN>){
		if ($each_line=~ /\>/){
			chomp($each_line);
			my $uniq_key = substr($each_line,1,length($each_line)-1);
			$evalue{$uniq_key} = 1000;
			$save_evalue{$uniq_key} = 1000;
			$clade{$uniq_key} = "-";
			$sig{$uniq_key} = 1;
		}
	}
	close(IN);

	my $fh;
	my $tmpfile;
	my $hmm_result;

	for ($i=0; $i<=$#line; $i++){
		($fh, $tmpfile) = tempfile( UNLINK => 1, SUFFIX => '.tbl');
		if ($hmmerv == 3){
			#system("hmmconvert ".$_[1].$line[$i].".".$_[2].".hmm "." > ".$_[1].$line[$i].".".$_[2].".hmmc");
			#system("hmmsearch --noali --domtblout ".$hmm_dir."tbl ".$_[1].$line[$i].".".$_[2].".hmmc ".$_[0]." > /dev/null");
			my $command = ("hmmsearch --noali --domtblout ".$tmpfile." ".$_[1].$line[$i].".".$_[2].".hmm3 ".$_[0]." > /dev/null");
			system($command);
			print $command if ($debug);
			#my $command = "cat ".$hmm_dir."tbl";
			#my $hmm_result = `$command`;
			local $/ = undef;
			$hmm_result = <$fh>;
			close $fh;
			unlink0($fh, $tmpfile);
			my @sp = split /\n/, $hmm_result;
			#while ($hmm_result =~ /\n((?!#).*)\n/g){
			for my $line (@sp) {
				next if ($line =~ /^#/);

				my @temp = split(/\s+/, $line);
				my $uniq_key = substr($temp[0],0,length($temp[0]));

				$save_evalue{$uniq_key} = $save_evalue{$uniq_key}."\t".$line[$i]."\t".$temp[11];
				#print $uniq_key."\t\t".$clade{$uniq_key}."\t".$line[$i]."\t".$temp[9]."\n";
				if ($evalue{$uniq_key} > $temp[11]){
					$sig{$uniq_key} = $temp[11]/$evalue{$uniq_key};
					#print $uniq_key."\t\t".$clade{$uniq_key}."\t".$evalue{$uniq_key}."\t".$line[$i]."\t".$temp[9]."\n";
					$evalue{$uniq_key} = $temp[11];
					$clade{$uniq_key} = $line[$i];
				}elsif ($evalue{$uniq_key}/$temp[11] > $sig{$uniq_key}){
					$sig{$uniq_key} = $evalue{$uniq_key}/$temp[11];
				}
			}
		}else{
			my $command = "hmm2search ".$_[1].$line[$i].".".$_[2].".hmm ".$_[0];
			my $hmm_result = `$command`;

			while ($hmm_result =~ /((\d|\w|\-|\_|\#|\/|\.)+\s+\d+\/\d+\s+\d+\s+\d+\s+(\[|\.)(\]|\.)\s+\d+\s+\d+\s+(\[|\.)(\]|\.)\s+\-*\d+\.\d+\s+((\d|\-|\.|e)+))\s*/g){
				my @temp = split(/\s+/, $1);
				my $uniq_key = substr($temp[0],0,length($temp[0]));

				$save_evalue{$uniq_key} = $save_evalue{$uniq_key}."\t".$line[$i]."\t".$temp[9];
				#print $uniq_key."\t\t".$clade{$uniq_key}."\t".$line[$i]."\t".$temp[9]."\n";
				if ($evalue{$uniq_key} > $temp[9]){
					$sig{$uniq_key} = $temp[9]/$evalue{$uniq_key};
					#print $uniq_key."\t\t".$clade{$uniq_key}."\t".$evalue{$uniq_key}."\t".$line[$i]."\t".$temp[9]."\n";
					$evalue{$uniq_key} = $temp[9];
					$clade{$uniq_key} = $line[$i];
				}elsif ($evalue{$uniq_key}/$temp[9] > $sig{$uniq_key}){
					$sig{$uniq_key} = $evalue{$uniq_key}/$temp[9];
				}
			}
		}

	}
	open (OUT, ">>$_[3]");
#    open (OUT1, ">>$_[4]");
	if ($_[0] =~ /\/((\w|\d)+)\./){
		$anno_clade = $1;
	}
	print OUT "$anno_clade-------------------------------------\n";
	for my $key (keys %evalue){
		print OUT $key."\t".$clade{$key}."\t".$evalue{$key}."\t";
		printf OUT "%.1e\n", $sig{$key};
#	print OUT1 $key."\t".$save_evalue{$key}."\n";
	}
	close(OUT);
#    close(OUT1);

}
