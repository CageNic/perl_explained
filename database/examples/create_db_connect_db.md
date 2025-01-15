## perl dbi - create a database, connect to database and create table using subroutines

create the table in a file called schema.sql\
read that file in usinf File::Slurp\
2 subroutines in the main_script.pl\
the 1st subroutine (connect_db) - create the database (and connect - or connect if already created)\
the 2nd subroutine (init_db)    - assign the 1st subroutine to a variable ($my $db) inside the 2nd subroutine\
read the the sql file in (assigning it to a variable using read_file from File::Slurp)\
execute the table creation using "do"

### cat schema.sql

```create table if not exists entries (
  id integer primary key autoincrement,
  title string not null,
  text string not null
);
```

### cat main_script.pl

```sub connect_db {
       my $dbh = DBI->connect("dbi:SQLite:dbname=".setting('database')) or
               die $DBI::errstr;
       return $dbh;
} 
sub init_db {
       my $db = connect_db();
       my $schema = read_file('./schema.sql');
       $db->do($schema) or die $db->errstr;
	   }
```
