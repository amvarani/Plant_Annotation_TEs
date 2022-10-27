#!/usr/bin/env perl
use warnings;
use strict;
use threads;
use Thread::Queue;
use threads::shared;

#usage: perl substract_parallel.pl minuend.list subtrahend.list thread_num
#Author: Shujun Ou (oushujun@msu.edu), 08/02/2019

my $usage = "\n\tperl substract_parallel.pl minuend.list subtrahend.list thread_num\n\n";

## read thread number
my $threads = 4;
if (defined $ARGV[2]){
	$threads = $ARGV[2];
	}

## minuend − subtrahend = difference
open Minuend, "<$ARGV[0]" or die $usage;
open Subtrahend, "<$ARGV[1]" or die $usage;
open Diff, ">$ARGV[0]-$ARGV[1]" or die $!;

my %substr;
while (<Subtrahend>){
	next if /^\s+$/;
	my ($chr, $from, $to)=(split)[0,1,2];
	push @{$substr{$chr}}, [$from, $to];
	}

## multi-threading using queue, put candidate regions into queue for parallel computation
my %diff :shared;
my $queue = Thread::Queue -> new();
while (<Minuend>){
	next if /^\s+$/;
	my ($chr, $from, $to)=(split)[0,1,2];
	next unless defined $chr;
	$queue->enqueue([$chr, $from, $to]);
	}
$queue -> end();
close Minuend;

## initiate a number of worker threads and run
foreach (1..$threads){
	threads -> create(\&substract);
	}
foreach (threads -> list()){
	$_ -> join();
	}

## output results
foreach my $id (sort {$a cmp $b} keys %diff){
	my ($chr, $from, $to) = (split /:/, $id);
	print Diff "$chr\t$from\t$to\n"
	}
close Diff;

## subrotine to perform substraction
sub substract(){
	while (defined ($_ = $queue->dequeue())){
	my $keep=1;
	my ($chr, $from, $to) = (@{$_}[0], @{$_}[1], @{$_}[2]);
	Run:
	foreach my $info (@{$substr{$chr}}){
		my @range=@{$info};
		last if $range[0]>$to;
		next if $range[1]<$from;
		$keep=0 if ($range[0]<=$from and $range[1]>=$to);
		if ($range[0]>$from){
			$keep=0;
			$range[0]--;
			$diff{"$chr:$from:$range[0]"} = "$chr:$from:$range[0]"
			} # if $range[0]>$from;
		if ($range[1]<$to){
			$from=$range[1]+1;
			$keep=1;
			goto Run;
			}
		}
	$diff{"$chr:$from:$to"} = "$chr:$from:$to" if $keep==1;
	$keep=1;
	}
	}


