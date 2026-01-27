## Perl bind columns  

#### step-by-step guide to bind columns in Perl using SQLite
#### specifically using the DBI module, which is the standard database interface module in Perl 

Binding columns means associating Perl variables with columns in a query result, so that when you fetch, the variables are automatically populated.

#### Step-by-Step Example
#### Step 1: Create the SQLite database and a sample table
```
use DBI;
# Connect to SQLite database (creates file if it doesn't exist)
my $dbh = DBI->connect("dbi:SQLite:dbname=test.db","","", {
    RaiseError => 1,
    AutoCommit => 1,
});
# Create a table
$dbh->do("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT, age INTEGER)");

# Insert some data
$dbh->do("INSERT INTO users (name, age) VALUES (?, ?)", undef, 'Alice', 30);
$dbh->do("INSERT INTO users (name, age) VALUES (?, ?)", undef, 'Bob', 25);
```
#### Step 2: Prepare a SELECT statement  
```
my $sth = $dbh->prepare("SELECT id, name, age FROM users");
$sth->execute();  
```
#### Step 3: Bind columns to Perl variables
```
my ($id, $name, $age);
$sth->bind_columns(\$id, \$name, \$age);  
```
bind_columns() links each column of the result to a Perl scalar reference  
The order must match the column order in the SELECT

#### Fetch data (the variables are populated automatically)
```
while ($sth->fetch) {
    print "ID: $id, Name: $name, Age: $age\n";
}
```
#### Clean up  
```
$sth->finish;
$dbh->disconnect;
```
#### Full Example Code  
```
use strict;
use warnings;
use DBI;

my $dbh = DBI->connect("dbi:SQLite:dbname=test.db", "", "", {
    RaiseError => 1,
    AutoCommit => 1,
});

# Uncomment if you need to initialize the table
# $dbh->do("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT, age INTEGER)");
# $dbh->do("INSERT INTO users (name, age) VALUES (?, ?)", undef, 'Alice', 30);
# $dbh->do("INSERT INTO users (name, age) VALUES (?, ?)", undef, 'Bob', 25);

my $sth = $dbh->prepare("SELECT id, name, age FROM users");
$sth->execute();

my ($id, $name, $age);
$sth->bind_columns(\$id, \$name, \$age);

while ($sth->fetch) {
    print "ID: $id, Name: $name, Age: $age\n";
}

$sth->finish;
$dbh->disconnect;
```
bind_columns() is optional  
you can use fetchrow_array() or fetchrow_hashref() instead—but it offers cleaner syntax for repeated fetching in a loop.  
It's most useful when dealing with many columns or in performance-critical code.

#### Binding columns in Perl using bind_columns()
more memory efficient because it avoids unnecessary data copying and reuses the same memory locations for each row retrieved from the database.

#### What Happens Without bind_columns()  
If you fetch rows using methods like:
```
my @row = $sth->fetchrow_array;
```
Here's what happens:  
For each row, a new array is allocated  
The DBI driver copies the row’s data into a new array structure  
These new arrays are returned again and again for every row in your result set  
More allocations = more memory overhead, especially with large datasets

#### What Happens With bind_columns
```
my ($id, $name, $age);
$sth->bind_columns(\$id, \$name, \$age);
while ($sth->fetch) {
    print "$name\n";
}
```
You are telling DBI:  
Use these pre-allocated scalar variables to store column values  
For each row, the data is simply written directly into those scalars  
No new memory allocations or copies of data structures are made  
The same scalars are reused across every iteration  

#### Memory Efficiency Benefits
1. Reduced Allocation Overhead  
Avoids per-row memory allocation for arrays or hashes  
Especially important when fetching thousands or millions of rows.

2. Faster Execution  
Less copying means less CPU time  

Binding is optimized at the DBI level  

3. Lower Memory Footprint  
Reuses existing scalars instead of creating new ones per row  

Embedded devices or low-RAM environments
