## Example of How to Use DBI with user input in the Linux terminal to search for results in a database

Here's a typical program. When you run it, it waits for you to type a last name\
Then it searches the database for people with that last name and prints out the full name and ID number for each person it finds\
For example:

``` Enter name> Noether
                118: Emmy Noether

        Enter name> Smith
                3: Mark Smith
                28: Jeff Smith

        Enter name> Snonkopus
                No names matched `Snonkopus'.
        
        Enter name> ^D
```
Here is the code:

 ```use DBI;

        my $dbh = DBI->connect('DBI:Oracle:payroll')
                or die "Couldn't connect to database: " . DBI->errstr;
        my $sth = $dbh->prepare('SELECT * FROM people WHERE lastname = ?')
                or die "Couldn't prepare statement: " . $dbh->errstr;

        print "Enter name> ";
        while ($lastname = <>) {               # Read input from the user
          my @data;
          chomp $lastname;
          $sth->execute($lastname)             # Execute the query
            or die "Couldn't execute statement: " . $sth->errstr;

          # Read the matching records and print them out          
          while (@data = $sth->fetchrow_array()) {
            my $firstname = $data[1];
            my $id = $data[2];
            print "\t$id: $firstname $lastname\n";
          }

          if ($sth->rows == 0) {
            print "No names matched `$lastname'.\n\n";
          }

          $sth->finish;
          print "\n";
          print "Enter name> ";
        }
          
        $dbh->disconnect;
```
		
```use DBI;```
This loads in the DBI module. Notice that we don't have to load in any DBD module\
DBI will do that for us when it needs to.

 ```my $dbh = DBI->connect('DBI:Oracle:payroll');
                or die "Couldn't connect to database: " . DBI->errstr;
```
				
The connect call tries to connect to a database\
The first argument, DBI:Oracle:payroll, tells DBI what kind of database it is connecting to\
The Oracle part tells it to load DBD::Oracle and to use that to communicate with the database\
If we had to switch to Sybase next week, this is the one line of the program that we would change\
We would have to change Oracle to Sybase\

payroll is the name of the database we will be searching\
If we were going to supply a username and password to the database, we would do it in the connect call:

```my $dbh = DBI->connect('DBI:Oracle:payroll', 'username', 'password')
                or die "Couldn't connect to database: " . DBI->errstr;
```
				
If DBI connects to the database, it returns a database handle object, which we store into $dbh\
This object represents the database connection\
We can be connected to many databases at once and have many such database connection objects\

If DBI can't connect, it returns an undefined value\
In this case, we use die to abort the program with an error message\

```DBI->errstr``` returns the reason why we couldn't connect—``Bad password'' for example\

``` my $sth = $dbh->prepare('SELECT * FROM people WHERE lastname = ?')
                or die "Couldn't prepare statement: " . $dbh->errstr;
```
				
The prepare call prepares a query to be executed by the database\
The argument is any SQL at all\
On high-end databases, prepare will send the SQL to the database server, which will compile it\
If prepare is successful, it returns a statement handle object which represents the statement; otherwise it returns an undefined value and we abort the program\
$dbh->errstr will return the reason for failure, which might be ``Syntax error in SQL''\
It gets this reason from the actual database, if possible\

The ? in the SQL will be filled in later\
Most databases can handle this\
For some databases that don't understand the ?, the DBD module will emulate it for you and will pretend that the database understands how to fill values in later, even though it doesn't\

```print "Enter name> ";```
Here we just print a prompt for the user.

```while ($lastname = <>) {               # Read input from the user
          ...
        }
```
		
This loop will repeat over and over again as long as the user enters a last name\
If they type a blank line, it will exit\
The Perl <> symbol means to read from the terminal or from files named on the command line if there were any\

```my @data;```
This declares a variable to hold the data that we will get back from the database\

```chomp $lastname;```
This trims the newline character off the end of the user's input\

```$sth->execute($lastname)             # Execute the query
            or die "Couldn't execute statement: " . $sth->errstr;
```
			
execute executes the statement that we prepared before\
The argument $lastname is substituted into the SQL in place of the ? that we saw earlier\
execute returns a true value if it succeeds and a false value otherwise, so we abort if for some reason the execution fails\

```while (@data = $sth->fetchrow_array()) {
            ...
           }
```
fetchrow_array returns one of the selected rows from the database\
You get back an array whose elements contain the data from the selected row\
In this case, the array you get back has six elements\
The first element is the person's last name; the second element is the first name; the third element is the ID, and then the other elements are the postal code, age, and sex\

Each time we call fetchrow_array, we get back a different record from the database\
When there are no more matching records, fetchrow_array returns the empty list and the while loop exits\

```my $firstname = $data[1];
             my $id = $data[2];
```
These lines extract the first name and the ID number from the record data\

```print "\t$id: $firstname $lastname\n";```

This prints out the result.

```if ($sth->rows == 0) {
            print "No names matched `$lastname'.\n\n";
          }
```
The rows method returns the number of rows of the database that were selected\
If no rows were selected, then there is nobody in the database with the last name that the user is looking for\
In that case, we print out a message\
We have to do this after the while loop that fetches whatever rows were available, because with some databases you don't know how many rows there were until after you've gotten them all\

```$sth->finish;
          print "\n";
          print "Enter name> ";
```
Once we're done reporting about the result of the query, we print another prompt so that the user can enter another name. finish tells the database that we have finished retrieving all the data for this query and allows it to reinitialize the handle so that we can execute it again for the next query.

```$dbh->disconnect;```

When the user has finished querying the database, they type a blank line and the main while loop exits. disconnect closes the connection to the database

