package Prompt;
use strict;
use warnings;
 
use Exporter qw(import);
 
our @EXPORT_OK = qw(prompt_yn);

# http://stackoverflow.com/a/18104317
sub prompt {
	my ($query) = @_; # take a prompt string as argument
	local $| = 1; # activate autoflush to immediately show the prompt
	print $query;
	chomp(my $answer = <STDIN>);
	return $answer;
}

sub prompt_yn {
	my ($query) = @_;
	my $answer = prompt("$query (Y/n): ");
	return lc($answer) ne 'n';
}

1;
