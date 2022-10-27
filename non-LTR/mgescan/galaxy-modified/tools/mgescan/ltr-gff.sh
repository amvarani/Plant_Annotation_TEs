#!/bin/bash
#user_dir=/u/lee212
#source ~/virtualenv/retrotminer/bin/activate

if [ ! -f ~/.mgescanrc ]
then
	".mgescanrc is not found."
	exit
fi
. ~/.mgescanrc
user_dir=$MGESCAN_HOME
script_program=`which python`
script=$MGESCAN_SRC/mgescan/ltr/toGFF.py

input_file=$1
input_file_name=$2
output_file=$3

#move to the working directory
work_dir=$MGESCAN_SRC/mgescan
cd $work_dir
#create directory for input and output
mkdir -p input
t_dir=`mktemp -p input -d` #relative path
input_dir="$work_dir/$t_dir/seq" # full path
output_dir="$work_dir/$t_dir/data"
mkdir -p $input_dir
mkdir -p $output_dir

# Check tar.gz
tar tf $input_file &> /dev/null
ISGZ=$?
if [ 0 -eq $ISGZ ]
then
	tar xzf $input_file -C $input_dir
else
	/bin/ln -s $input_file $input_dir/$input_file_name
fi

#run
$script_program $script $input_dir/ltr/ltr.out $output_file

if [ $? -eq 0 ]
then
	rm -rf $work_dir/$t_dir 2> /dev/null
#else
	#cp -pr $work_dir/$t_dir $work_dir/error-cases/
fi
