########################################
# perl hash of arrays examined part 24 #
########################################

# emulating partial and full joins
# # use of - if exists $hash{$key} on the push function
# means only keys already existing in the hash of arrays
# created from the first file have their data merged in the hash of arrays
# created in the second file

# keys 5 and 6 in file_2.txt are not present in file_1.txt so keys 5 and 6 do not form part of the join
# in order for keys 5 and 6 to form part of the join - remove the - if exists $hash{$key} part of the code

# cat file_1.txt

# 1,hello,from file 1
# 2,hello,from file 1
# 3,hello,from file 1
# 4,hello,from file 1

# cat file_2.txt

# 1,hello,from file 2
# 2,hello,from file 2
# 3,hello,from file 2
# 4,hello,from file 2
# 5,hello,from file 2
# 6,hello,from file 2

# required output

# {
#  1 => ["hello", "from file 1", "hello", "from file 2"],
#  2 => ["hello", "from file 1", "hello", "from file 2"],
#  3 => ["hello", "from file 1", "hello", "from file 2"],
#  4 => ["hello", "from file 1", "hello", "from file 2"],
# }

# notice the subtle difference when pushing an array and an array referene to the hash key

# pushing an array - best method - each column from each file is an array element

#!/usr/bin/perl
use strict;
use warnings;
use Data::Dump qw'dd';

my $file_1 = 'file_1.txt';
my $file_2 = 'file_2.txt';

my %hoa;

open (my $fh,'<',$file_1) or die $!;
while (my $lines = <$fh>) {
	chomp $lines;
	my @arr = split(/,/,$lines);
	my $id = shift @arr;
	$hoa{$id} = \@arr;

}
close $fh;

open (my $in,'<',$file_2) or die $!;
while (my $lines = <$in>) {
	chomp $lines;
	my @arr = split(/,/,$lines);
	my $id = shift @arr;
	push (@{$hoa{$id}}, @arr) if exists $hoa{$id}; 
}
close $in;

dd(\%hoa);

############
# produces #
# ##########

# {
#  1 => ["hello", "from file 1", "hello", "from file 2"],
#  2 => ["hello", "from file 1", "hello", "from file 2"],
#  3 => ["hello", "from file 1", "hello", "from file 2"],
#  4 => ["hello", "from file 1", "hello", "from file 2"],
# }

# if you push an array reference (for file 2)
# it adds all of file 2 columns as 1 element

# push (@{$hoa{$id}}, \@arr) if exists $hoa{$id};

# {
#  1 => ["hello", "from file 1", ["hello", "from file 2"]],
#  2 => ["hello", "from file 1", ["hello", "from file 2"]],
#  3 => ["hello", "from file 1", ["hello", "from file 2"]],
#  4 => ["hello", "from file 1", ["hello", "from file 2"]],
# }

foreach my $id (keys %hoa) {
	print join ("\t", $id, @{$hoa{$id}});
	print "\n";
}
exit;
