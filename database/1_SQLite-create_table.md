## Introduction to SQLite CREATE TABLE statement
To create a new table in SQLite, you use CREATE TABLE statement using the following syntax:
```
CREATE TABLE [IF NOT EXISTS] [schema_name].table_name (
	column_1 data_type PRIMARY KEY,
   	column_2 data_type NOT NULL,
	column_3 data_type DEFAULT 0,
	table_constraints
) [WITHOUT ROWID];
```

In this syntax:

First, specify the name of the table that you want to create after the ```CREATE TABLE``` keywords\
The name of the table cannot start with sqlite_ because it is reserved for the internal use of SQLite\
Second, use ```IF NOT EXISTS``` option to create a new table if it does not exist\
Attempting to create a table that already exists without using the ```IF NOT EXISTS``` option will result in an error\
Third, optionally specify the schema_name to which the new table belongs\
The schema can be the main database, temp database or any attached database\
Fourth, specify the column list of the table. Each column has a name, data type, and the column constraint\
SQLite supports ```PRIMARY KEY```, ```UNIQUE```, ```NOT NULL```, and ```CHECK``` column constraints\
Fifth, specify the table constraints such as ```PRIMARY KEY```, ```FOREIGN KEY```, ```UNIQUE```, and ```CHECK``` constraints\
Finally, optionally use the ```WITHOUT ROWID``` option\
By default, a row in a table has an implicit column, which is referred to as the ```rowid```, ```oid``` or ```_rowid_``` column\
The ```rowid``` column stores a 64-bit signed integer key that uniquely identifies the row inside the table\
If you don’t want SQLite creates the rowid column, you specify the ```WITHOUT ROWID``` option\
A table that contains the rowid column is known as a rowid table\
Note that the ```WITHOUT ROWID``` option is only available in SQLite 3.8.2 or later\
Note that the primary key of a table is a column or a group of columns that uniquely identify each row in the table

## SQLite CREATE TABLE examples
Suppose you have to manage contacts using SQLite.

Each contact has the following information:

First name
Last name
Email
Phone

The requirement is that the email and phone must be unique\
In addition, each contact belongs to one or many groups, and each group can have zero or many contacts

Based on these requirements, we came up with three tables:

The contacts table that stores contact information\
The groups table that stores group information\
The contact_groups table that stores the relationship between contacts and groups\
The following database diagram illustrates tables:contacts groups, and contact_groups\

## SQLite Create Table
The following statement creates the contacts table.

```CREATE TABLE contacts (
	contact_id INTEGER PRIMARY KEY,
	first_name TEXT NOT NULL,
	last_name TEXT NOT NULL,
	email TEXT NOT NULL UNIQUE,
	phone TEXT NOT NULL UNIQUE
);
```
The contact_id is the primary key of the contacts table.

Because the primary key consists of one column, you can use the column constraint

The first_name and last_name columns have ```TEXT``` storage class and these columns are ```NOT NULL```
It means that you must provide values when you insert or update rows in the contacts table.

The email and phone are unique therefore we use the ```UNIQUE``` constraint for each column

The following statement creates the groups table:

```CREATE TABLE groups (
   group_id INTEGER PRIMARY KEY,
   name TEXT NOT NULL
);
```
The groups table is quite simple with two columns: group_id and name
The group_id column is the primary key column.

The following statement creates contact_groups table:

```CREATE TABLE contact_groups(
   contact_id INTEGER,
   group_id INTEGER,
   PRIMARY KEY (contact_id, group_id),
   FOREIGN KEY (contact_id) 
      REFERENCES contacts (contact_id) 
         ON DELETE CASCADE 
         ON UPDATE NO ACTION,
   FOREIGN KEY (group_id) 
      REFERENCES groups (group_id) 
         ON DELETE CASCADE 
         ON UPDATE NO ACTION
);
```
The contact_groups table has a primary key that consists of two columns: contact_id and group_id.

To add the table primary key constraint, you use this syntax:

```PRIMARY KEY (contact_id, group_id)```

In addition, the contact_id and group_id are the foreign keys. Therefore, you use FOREIGN KEY constraint to define a foreign key for each column.

```FOREIGN KEY (contact_id) 
   REFERENCES contacts (contact_id) 
      ON DELETE CASCADE 
      ON UPDATE NO ACTION
FOREIGN KEY (group_id) 
    REFERENCES groups (group_id) 
      ON DELETE CASCADE 
      ON UPDATE NO ACTION
);
```
