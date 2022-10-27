#!/bin/bash

input_file=$1
new_file="_"$input_file
template=".record_perl.txt"

cat $template > $new_file

cat $input_file | replace 'system(' 'my_system(' >> $new_file
