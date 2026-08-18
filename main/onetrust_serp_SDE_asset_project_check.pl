#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

# timestamp for file output
my @t = localtime;
my $day = $t[3];
my $month = $t[4] + 1;
my $year  = $t[5] + 1900;

# format the date - need a leading 0 for days months that are not double digits
my $file_date = sprintf(
    "%02d-%02d-%04d",
    $t[3],        # day
    $t[4] + 1,    # month
    $t[5] + 1900  # year
);

my $file = "vendor status.txt";
open (my $fh, '<', $file) or die "Cannot open $file: $!\n";

# read header row
my $header = <$fh>;
chomp $header;

# remove Windows carriage return if present
$header =~ s/\r$//;

# split header into columns
my @headers = split /\t/, $header, -1;

# remove unwanted whitespace
for (@headers) {
    s/^\s+|\s+$//g;
}

########################################################################
# map column names to positions - need this as no Text::CSV in GitBash #
########################################################################

my %col;

for my $i (0 .. $#headers) {
    $col{$headers[$i]} = $i;
}

# Check required columns exist - name in list is checked as a hash key
for my $required ('Name', 'Primary Vendor Contact Name') {
    die "Missing column: $required\n"
        unless exists $col{$required};
}

my %vendor_data;

# read lines
while (<$fh>) {

    chomp;
    # remove carraige returns
    s/\r$//;

    # preserve empty trailing columns
    my @fields = split (/\t/, $_, -1);

    # do not inlcude archived projects
    my $status = $fields[$col{'Status'}];
    next if $status ne 'Active';

    my $notes = $fields[$col{'SDE User Notes'}];
    next unless $notes =~ /SDE/gi;

    # extract values - give emtpy string - false value if no name or eamil
    my $vendor = $fields[$col{'Name'}] // '';
    my $email = lc($fields[$col{'Primary Vendor Contact Name'}]) // '';
    
   $vendor_data{$vendor} = ($email);  

}
close $fh;

# check for those with no emails

my @email_check;

for my $key (sort keys %vendor_data) {
        push @email_check, $key if $vendor_data{$key} eq '';
    }

if (@email_check) {
    die "these vendors need email addresses..." , join(", ",@email_check),"\n".
    "add to OneTrust file, donwload vendor status.txt\n"
}

# print Dumper (\%vendor_data);
exit;

# read in a SeRP report where the email addresses can be macthed
# the report must also haave data folders as these are the assets
# and another file is created where each line is an emauk address and an asset fro OneTrust, a data folder from SeRP and the matched name
# an extra column of OneTrust / SeRP match must be included
# b


