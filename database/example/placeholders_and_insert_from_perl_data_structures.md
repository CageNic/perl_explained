```#!/usr/bin/perl
use strict ;
use warnings ;
use DBI ;

my $table = "table1" ;
my $database = "database.db" ;

# create the database
my $dbh = DBI->connect( "dbi:SQLite:$database" ) || print "Cannot connect: $DBI::errstr";

create the table/fields
my @field_names = qw(id name salary) ;

$dbh->do ("DROP TABLE IF EXISTS $table") ;
my $create_table = qq{
                       create table $table (
                       $field_names[0] int primary key not null,
                       $field_names[1] char(20) not null,
                       $field_names[2] int
                                           )
                      };
                      
$dbh->do($create_table);
my $fieldlist = join (",",@field_names);
my $field_placeholders = join ", ", map {'?'} @field_names;
my $insert_query = ( "INSERT INTO $table ( $fieldlist ) VALUES ( $field_placeholders )" ) ;

# or this alternate method of inserting...
# $insert_query = "INSERT INTO $table ( id, name, salary ) VALUES ( ?, ?, ? )" ;```

my $sth= $dbh->prepare( $insert_query );

# view database before inserting values - note there are no entries in the fields

# insert values
# insert scalars - using execute

($field_names[0] , $field_names[1] , $field_names[2]) = (1, 'Sal', 4500) ;
 $sth->execute($field_names[0] , $field_names[1] , $field_names[2]) ;
 
# view database after inserting values - note there are entries in the fields 

# insert values
# insert array of arrays - using execute

my @aoa = (
        [2, 'Fred',   5000],
        [3, 'Joshua', 5000],
        [4, 'Marco' , 5000]
    );
    foreach my $element (@aoa) {
        $sth->execute(@$element);
    }

# insert values
# insert array of hashes - using execute

# method1

# If we want to be sure that each value is going to the corresponding column in the database
# we can use a data structure where the values are referred by name, rather than by position
# A list of hashes looks like the best solution for this problem.

The naive approach would be to iterate the list and access the items by name.

    my @employees_loh = (
        {id => 5, name => 'Kim',  salary =>  5600},
        {id => 6, name => 'Dave', salary =>  6000},
    );
    foreach my $thing (@employees_loh) {
        $sth->execute($thing->{id}, $thing->{name}, $thing->{salary});
    }
    
# But this style of coding, although correct, may take long for a large number of columns
# and we can still make a mistake and swap positions, thus resulting in an incorrect insertion
# It's better to take advantage of our column list and exploit Perl capability of creating hash slices.

# method2
# hash slices...

@field_names is from the global array - my @field_names = qw(id name salary) ;

foreach my $other_thing (@employees_loh_2) {
        $sth->execute( @{$other_thing}{@field_names} ) ;
                     }

# or create a new array list as the slice
my @slice = ("id","name","salary") ;

# In this example, not only we write less
# but we are also sure that the order of values comes according to the columns list
# which was the one we used to create the insertion query in the first place
# For large datasets with many columns, this idiom is definitely the best way

my @employees_loh_2 = (
        {id => 7, name => 'Kim',  salary =>  5600},
        {id => 8, name => 'Dave', salary =>  6000}
                      ) ;

    foreach my $other_thing (@employees_loh_2) {
        $sth->execute( @{$other_thing}{@slice} ) ;
                     }

# update the database with standard perl syntax
# not using the DBI update method

# this doesn't update the name as the id in the aoh is already 7                   
                      
$employees_loh_2[0]{name}="Kimbra" unless exists $employees_loh_2[0]{id}==7 ;

# this does update the name as the id in the aoh is not 7

$employees_loh_2[0]{name}="Kimbra" unless exists $employees_loh_2[0]{id}==7 ;

    foreach my $other_thing (@employees_loh_2) {
        $sth->execute( @{$other_thing}{@slice} ) ;

$dbh->disconnect ;
exit ;    
```
