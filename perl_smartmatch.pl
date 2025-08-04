#!/usr/bin/perl
use strict;
use warnings;

# dont mix strings and numbers
# smartmatch unreliable and experimertal
# use either or
# eq string == number

my @search = qw/2112 211/;
my @codes;
my @pats;
my $start_date = 2017;

my $file = "test.txt";
open (my $fh, '<', $file) or die $!;
my $header = <$fh>;
chomp $header;
while (my $lines = <$fh>) {
  chomp $lines;
  my @array = split (/,/,$lines);
  my ($year, $month, $day) = split (/-/,$array[3]);
  if ($array[1] ~~ @search && $year >= 2017) {
    push (@codes, $array[1]);
    push (@pats, $array[0]);
  }
}
close $fh;

# deduplicate the code and pat arrays
# for codes that means all the matched data from @search
# with this subroutine

sub uniq_counter {
    my  @sub_array = (@_);
    my $counts = {};
    $counts->{$_}++ for @sub_array;
    return scalar keys %$counts;
}

sub counter_per_item {
    my  @sub_array = (@_);
    my %counts;
    $counts{$_}++ for @sub_array;
    foreach my $key (keys %counts) {
      print "code: $key - frequency of occurence: $counts{$key}\n";
    }
    return;    
}

# report

print "Total codes from code list found in data: ", scalar @codes , "\n";
print "Unique codes from code list found in data: ", uniq_counter(@codes) , "\n";
print "Total patient search count: ", scalar @pats, "\n";
print "Unique patient count: ", uniq_counter(@pats) , "\n";
print "\n";
print "Code counts per item" , "\n";
print "Per item total to match total codes found\n";
counter_per_item(@codes);
print "\n";

#### without smartmatch ###
#
# list::util module
# use List::Util 'any';

cat test.txt
PAT,CODE,SOMETHING,
1,2112,stuff,2017-01-01
1,2112,stuff,2017-01-01
2,2112,stuff,2017-01-01
2,2112,stuff,2017-01-02
3,2112,stuff,2017-01-03
4,2112,stuff,2017-01-04
5,2112,stuff,2017-01-05
6,2112,stuff,2017-02-01
7,2112,stuff,2017-02-02
8,2112,stuff,2017-02-03
9,2112,stuff,2017-02-04
10,2112,stuff,2017-02-05
11,2112,stuff,2017-02-06
12,2112,stuff,2017-02-07
13,2112,stuff,2017-02-08
14,2112,stuff,2017-02-09
15,2112,stuff,2017-02-10
16,2112,stuff,2017-02-11
17,2112,stuff,2017-02-12
18,2112,stuff,2017-02-13
19,2112,stuff,2017-02-14
20,2112,stuff,2017-02-15
21,2112,stuff,2017-02-16
22,2112,stuff,2017-02-17
23,2112,stuff,2017-02-18
24,2112,stuff,2017-02-19
25,2112,stuff,2017-02-20
26,2112,stuff,2017-02-21
27,2112,stuff,2017-02-22
28,2112,stuff,2017-02-23
29,2112,stuff,2017-02-24
30,2112,stuff,2017-02-25
31,211,stuff,2017-02-26
32,211,stuff,2017-02-27
33,211,stuff,2017-02-28
34,211,stuff,2017-03-01
35,211,stuff,2017-03-02
36,211,stuff,2017-03-03
37,211,stuff,2017-03-04
38,211,stuff,2017-03-05
39,211,stuff,2017-03-06
40,211,stuff,2017-03-07
41,211,stuff,2017-03-08
42,211,stuff,2017-03-09
43,211,stuff,2017-03-10
44,211,stuff,2017-03-11
45,211,stuff,2017-03-12
46,211,stuff,2017-03-13
47,211,stuff,2017-03-14
48,211,stuff,2017-03-15
49,211,stuff,2017-03-16
50,211,stuff,2017-03-17
51,211,stuff,2017-03-18
52,211,stuff,2017-03-19
53,211,stuff,2017-03-20
54,211,stuff,2017-03-21
55,211,stuff,2017-03-22
56,211,stuff,2017-03-23
57,211,stuff,2017-03-24
58,211,stuff,2017-03-25
59,211,stuff,2017-03-26
60,211,stuff,2017-03-27
61,211,stuff,2017-03-28
62,211,stuff,2017-03-29
63,211,stuff,2017-03-30
64,211,stuff,2017-03-31
65,211,stuff,2017-04-01
66,211,stuff,2017-04-02
67,211,stuff,2017-04-03
68,211,stuff,2017-04-04
69,211,stuff,2017-04-05
70,211,stuff,2017-04-06
71,211,stuff,2017-04-07
72,211,stuff,2017-04-08
73,211,stuff,2017-04-09
74,211,stuff,2017-04-10
75,211,stuff,2017-04-11
76,211,stuff,2017-04-12
77,211,stuff,2017-04-13
78,211,stuff,2017-04-14
79,211,stuff,2017-04-15
80,211,stuff,2017-04-16
81,211,stuff,2017-04-17
82,211,stuff,2017-04-18
83,211,stuff,2017-04-19
84,211,stuff,2017-04-20
85,211,stuff,2017-04-21
86,211,stuff,2017-04-22
87,211,stuff,2017-04-23
88,211,stuff,2017-04-24
89,211,stuff,2017-04-25
90,211,stuff,2017-04-26
91,211,stuff,2017-04-27
92,211,stuff,2017-04-28
93,211,stuff,2017-04-29
94,211,stuff,2017-04-30
95,211,stuff,2017-05-01
96,211,stuff,2017-05-02
97,211,stuff,2017-05-03
