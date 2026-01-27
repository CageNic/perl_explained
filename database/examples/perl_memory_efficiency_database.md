## Perl memory efficiency in database queries


Andy Campbell <ionewis@gmail.com>
Nov 5, 2025, 8:14 PM
to me

In Perl, what is the most memory efficient way of querying 4 columns in a large database
ChatGPT said:
Good question — in Perl, when querying a few columns from a large database, your goal is to avoid pulling the entire result set into memory at once. The key is to stream results efficiently using DBI (Perl’s standard database interface) and control fetching behavior.

Here’s a breakdown of the most memory-efficient approach:

✅ 1. Use DBI with a prepared statement and streamed fetching
use DBI;

my $dbh = DBI->connect("dbi:SQLite:dbname=mydb.sqlite","","", {
    RaiseError => 1,
    PrintError => 0,
    AutoCommit => 1,
});

my $sth = $dbh->prepare("SELECT col1, col2, col3, col4 FROM big_table WHERE ...");
$sth->execute();

while (my @row = $sth->fetchrow_array) {
    # Process each row immediately
    # e.g. print "$row[0], $row[1], $row[2], $row[3]\n";
}
$sth->finish;
$dbh->disconnect;
Why this is memory efficient:

fetchrow_array fetches one row at a time, so Perl doesn’t store the whole result set.

The DBI driver (e.g. DBD::mysql, DBD::Pg, etc.) handles rows as a cursor/stream.

You only have 4 scalars in memory per row (plus any processing you do).

⚙️ 2. DBI tuning options
If you’re using MySQL, use:

$dbh->{mysql_use_result} = 1;
before calling prepare, e.g.:

my $dbh = DBI->connect("DBI:mysql:database=mydb", "user", "pass", {
    mysql_use_result => 1,  # Stream rows, don't buffer them all
});
Explanation:

mysql_use_result tells the driver to stream results row-by-row instead of buffering all rows client-side.

This drastically reduces memory use for huge queries.

For PostgreSQL, DBI automatically streams results unless you call fetchall_* methods.

⚠️ Avoid
❌ fetchall_arrayref() or selectall_arrayref() — these load all rows into memory.

❌ Storing rows into arrays unless absolutely needed.

🧠 Bonus: Even more control (for massive datasets)
If you expect billions of rows, you can:

Use cursors explicitly (in PostgreSQL).

Paginate with LIMIT/OFFSET or a streaming key.

Pipe data directly to disk or another process rather than holding it in RAM.

Example (PostgreSQL cursor):

$dbh->do("BEGIN");
my $sth = $dbh->prepare("DECLARE mycursor CURSOR FOR SELECT col1, col2, col3, col4 FROM big_table");
$sth->execute();

my $fetch = $dbh->prepare("FETCH 1000 FROM mycursor");
while (1) {
    $fetch->execute();
    my $rows = $fetch->fetchall_arrayref;
    last unless @$rows;
    for my $row (@$rows) {
        # process $row->[0..3]
    }
}
$dbh->do("CLOSE mycursor");
$dbh->do("COMMIT");
✅ Summary
Technique	Memory Use	Notes
fetchrow_array in a loop	🟢 Minimal	Best general method
mysql_use_result (MySQL)	🟢 Minimal	Stream results
fetchall_arrayref()	🔴 High	Avoid for large tables
Cursors (PostgreSQL)	🟢 Minimal	Good for massive tables
Would you like me to show a version tailored to a specific database (e.g. MySQL, PostgreSQL, SQLite, or Oracle)? That can slightly change the optimal configuration.

You said:
what about binding columns
ChatGPT said:
Excellent follow-up — yes, binding columns with bind_columns() is even more memory-efficient and faster than repeatedly fetching row arrays.

Let’s unpack why and how to use it properly.

🧠 Why bind_columns() helps
When you use:

while (my @row = $sth->fetchrow_array) { ... }
Perl allocates new scalars for each fetched row, copies values into them, and then discards them at the next iteration — that’s a lot of memory churn.

With bind_columns(), DBI reuses the same scalar variables for every row fetched.
This:

Avoids per-row scalar allocation,

Reduces copying,

Minimizes Perl’s memory footprint and improves cache locality.

✅ Example: Most memory-efficient DBI pattern
use DBI;

my $dbh = DBI->connect("DBI:mysql:database=mydb", "user", "pass", {
    RaiseError => 1,
    PrintError => 0,
    AutoCommit => 1,
    mysql_use_result => 1,  # For MySQL, avoids buffering entire result
});

my $sth = $dbh->prepare("SELECT col1, col2, col3, col4 FROM big_table");
$sth->execute();

my ($col1, $col2, $col3, $col4);
$sth->bind_columns(\$col1, \$col2, \$col3, \$col4);

while ($sth->fetch) {
    # Process one row at a time
    # These variables are reused each iteration
    print "$col1 | $col2 | $col3 | $col4\n";
}

$sth->finish;
$dbh->disconnect;
🔍 How it works internally
bind_columns() tells DBI to store fetched column data directly into the specified scalar references.

Each call to $sth->fetch overwrites those same variables in place.

No new arrays or strings are allocated per row, unless you copy the data yourself.

This can make a big difference when you’re processing millions of rows.

⚙️ Advanced notes
Works with all DBI drivers (MySQL, PostgreSQL, SQLite, Oracle, etc.).

Use with mysql_use_result => 1 for MySQL to ensure streaming mode (otherwise DBI buffers the full result).

Avoid mixing fetchrow_* calls after binding — they reset the binding.

🧪 Benchmark comparison (typical result)
Method	Memory Use	CPU Overhead	Notes
fetchrow_array	Medium	Medium	Allocates new array each time
fetchrow_hashref	High	High	New hash each time
bind_columns + fetch	Low	Low	Reuses scalars; fastest & lightest
✅ In summary

If you care about memory and performance when querying large tables:

Use prepared statements (prepare, execute).

Use bind_columns() to reuse scalars.

Stream rows (mysql_use_result for MySQL or cursors in PostgreSQL).

Process each row as you fetch it — don’t accumulate results.

Would you like me to show a PostgreSQL-optimized example using bind_columns() and cursors (for huge datasets)? It’s slightly different in how it streams data.

You said:
yes
ChatGPT said:
Perfect 👍 — let’s look at the PostgreSQL-optimized version for querying large tables efficiently in Perl using DBI + bind_columns() + cursors.

This combination gives you true streaming with minimal memory footprint.

🧩 Why cursors help in PostgreSQL
By default, PostgreSQL (via DBD::Pg) will buffer all rows from a query before returning control to your Perl code. For huge tables, that can consume a lot of RAM.

The way to fix this is to:

Start a transaction manually (BEGIN);

Declare a cursor on the query;

Fetch rows in batches;

Use bind_columns() so Perl doesn’t create new scalars each time.

✅ Full Example
use strict;
use warnings;
use DBI;

# Connect to PostgreSQL
my $dbh = DBI->connect(
    "dbi:Pg:dbname=mydb;host=localhost",
    "user",
    "pass",
    {
        AutoCommit => 0,   # Important: we’ll use a transaction
        RaiseError => 1,
        PrintError => 0,
    }
);

# 1️⃣ Start a transaction and declare a cursor
$dbh->do("BEGIN");
$dbh->do("DECLARE mycursor CURSOR FOR SELECT col1, col2, col3, col4 FROM big_table");

# 2️⃣ Prepare a statement to fetch batches of rows from the cursor
my $sth = $dbh->prepare("FETCH 1000 FROM mycursor");

# 3️⃣ Bind columns to scalar refs (reused for each row)
my ($col1, $col2, $col3, $col4);
$sth->bind_columns(\$col1, \$col2, \$col3, \$col4);

# 4️⃣ Loop until no more rows
while (1) {
    $sth->execute();
    my $rows_fetched = 0;

    while ($sth->fetch) {
        $rows_fetched++;
        # Process each row immediately
        print "$col1 | $col2 | $col3 | $col4\n";
    }

    last if $rows_fetched == 0;  # No more rows
}

# 5️⃣ Clean up
$dbh->do("CLOSE mycursor");
$dbh->do("COMMIT");
$dbh->disconnect;
🧠 Why this is optimal
Step	Optimization
AutoCommit => 0	Keeps transaction open for cursor streaming
Cursor (DECLARE mycursor)	PostgreSQL streams results, doesn’t buffer entire query
FETCH 1000 FROM	Reads rows in chunks (tunable batch size)
bind_columns()	Reuses scalars, avoids per-row allocations
No arrays/hashes stored	Keeps memory constant regardless of result size
⚙️ Optional: Fetch size tuning
You can adjust:

FETCH 5000 FROM mycursor
to balance round-trip overhead (fewer = less memory, more = faster).

⚠️ Gotchas
Always use BEGIN / COMMIT around cursor operations — cursors only exist inside a transaction.

Do not use fetchall_* or selectall_*; they buffer everything.

If you close the $dbh early, the cursor is gone.

🚀 TL;DR — PostgreSQL + Perl DBI Memory-Efficient Query Pattern
AutoCommit => 0

BEGIN

DECLARE CURSOR FOR SELECT ...

FETCH n FROM cursor

Use bind_columns() with $sth->fetch

CLOSE and COMMIT

This is the most memory-efficient way to query large tables in Perl + PostgreSQL.

Would you like me to show a version where you stream directly to a file (CSV or TSV) without ever holding rows in memory? That’s a common next optimization for large exports.

You said:
yes
ChatGPT said:
Excellent — streaming directly to a file (like CSV or TSV) is the final step toward true constant-memory database querying in Perl.

You can process billions of rows this way without ever holding more than a few scalars in RAM.

✅ Goal
We’ll:

Use a PostgreSQL cursor for streaming;

Use bind_columns() to reuse scalars;

Write directly to a file (e.g. CSV or TSV);

Keep constant memory usage regardless of table size.

🧩 Example: Stream to CSV file efficiently
use strict;
use warnings;
use DBI;
use Text::CSV;

# Connect to PostgreSQL
my $dbh = DBI->connect(
    "dbi:Pg:dbname=mydb;host=localhost",
    "user",
    "pass",
    {
        AutoCommit => 0,   # Required for cursors
        RaiseError => 1,
        PrintError => 0,
    }
);

# Prepare CSV writer
my $csv = Text::CSV->new({ binary => 1, eol => "\n" })
    or die "Cannot create CSV handle: " . Text::CSV->error_diag();

open my $fh, ">:encoding(utf8)", "output.csv"
    or die "Cannot open output.csv: $!";

# Optional: print header row
$csv->print($fh, [qw(col1 col2 col3 col4)]);

# 1️⃣ Begin transaction & declare cursor
$dbh->do("BEGIN");
$dbh->do("DECLARE mycursor CURSOR FOR SELECT col1, col2, col3, col4 FROM big_table");

# 2️⃣ Prepare FETCH statement
my $sth = $dbh->prepare("FETCH 5000 FROM mycursor");

# 3️⃣ Bind columns to reusable scalars
my ($col1, $col2, $col3, $col4);
$sth->bind_columns(\$col1, \$col2, \$col3, \$col4);

# 4️⃣ Stream rows directly to file
while (1) {
    $sth->execute();
    my $rows = 0;

    while ($sth->fetch) {
        $csv->print($fh, [$col1, $col2, $col3, $col4]);
        $rows++;
    }

    last if $rows == 0;  # No more rows
}

# 5️⃣ Clean up
close $fh;
$dbh->do("CLOSE mycursor");
$dbh->do("COMMIT");
$dbh->disconnect;

print "Finished streaming to output.csv\n";
🧠 Why this is maximally efficient
Technique	Benefit
AutoCommit => 0 + cursor	PostgreSQL streams results
FETCH 5000 FROM	Tunable batch size for performance
bind_columns()	Reuses scalars (no new allocations)
Writing line-by-line	No data buffering in Perl
No arrays or hashes	Memory stays constant
⚙️ Notes & Options
Change FETCH 5000 → FETCH 10000 for fewer round trips if latency is high.

For TSV output, just replace Text::CSV with a simple print "$col1\t$col2\t$col3\t$col4\n".

You can compress output on the fly:

open my $fh, "| gzip > output.csv.gz" or die $!;
For extremely large exports, you could also use PostgreSQL’s native COPY TO STDOUT — even faster, though less flexible for custom logic.

🚀 TL;DR
Task	Best Practice
Large table read	Use cursor (DECLARE ... FETCH)
Memory efficiency	Use bind_columns()
Output	Stream to file directly
PostgreSQL setting	AutoCommit => 0 (transactions on)
Extra	Optionally compress output (gzip)
Would you like me to show the PostgreSQL COPY TO STDOUT approach next?
It’s even faster than DBI cursors if you’re purely exporting data (no per-row logic).

You said:
yes
ChatGPT said:
Excellent — let’s now go one level deeper: using PostgreSQL’s native COPY TO STDOUT command.

This is the fastest and most memory-efficient way to export query results to a file in Perl, often 10–50× faster than fetching rows via a cursor — because the database server streams raw text directly to your Perl process, bypassing DBI row handling entirely.

🧩 How it works
PostgreSQL executes your query server-side.

Instead of transferring results row-by-row through DBI’s normal fetch mechanism, it streams the raw output over the wire.

Your Perl script reads that stream incrementally and writes it directly to a file (or pipe, or compressor).

This means:

Virtually zero memory use (constant RAM footprint).

Maximum throughput (no Perl-level data copying).

Ideal for large exports (tens/hundreds of GB).

✅ Example: Stream query to CSV using COPY TO STDOUT
use strict;
use warnings;
use DBI;

# Connect to PostgreSQL
my $dbh = DBI->connect(
    "dbi:Pg:dbname=mydb;host=localhost",
    "user",
    "pass",
    {
        RaiseError => 1,
        PrintError => 0,
        AutoCommit => 1,   # COPY TO STDOUT does not require explicit transaction
    }
);

# Prepare output file (or pipe to gzip)
open my $fh, ">:encoding(utf8)", "output.csv"
    or die "Cannot open output.csv: $!";

# Define your query — can include WHERE, JOIN, etc.
my $query = q{
    COPY (
        SELECT col1, col2, col3, col4
        FROM big_table
        WHERE some_condition = true
    ) TO STDOUT WITH CSV HEADER
};

# Execute COPY TO STDOUT
my $copy_sth = $dbh->prepare($query);
$copy_sth->execute();

# Stream from PostgreSQL to file
while (my $line = $dbh->pg_getcopydata) {
    print $fh $line;
}

close $fh;
$copy_sth->finish;
$dbh->disconnect;

print "Export complete: output.csv\n";
⚙️ Explanation
Step	Function
COPY (SELECT ...) TO STDOUT	PostgreSQL streams query results
pg_getcopydata	Reads the next chunk of data from the stream
print $fh $line	Writes directly to disk — no buffering
No Perl-level row handling	Near-constant memory usage
WITH CSV HEADER	Adds a header row automatically
🔥 Performance Notes
Fastest possible method for exporting query results in Perl.

pg_getcopydata returns data in chunks (usually several KBs), which you can write immediately.

Since PostgreSQL does the CSV serialization internally, you avoid overhead of Text::CSV or manual formatting.

💾 Optional: Gzip compression on the fly
You can stream directly to a compressed file without touching disk twice:

open my $fh, "| gzip > output.csv.gz" or die "Cannot open gzip pipe: $!";
Then use the same copy loop — PostgreSQL streams → Perl → gzip → file.

🧠 When to use this vs. cursors
Use case	Recommended method
Need to process each row in Perl (transform, filter, join, compute)	Cursor + bind_columns()
Just exporting to a file	COPY TO STDOUT (fastest, simplest)
Want CSV with headers	COPY ... WITH CSV HEADER
Want TSV	COPY ... WITH (FORMAT text, DELIMITER E'\t')
🧪 Example for TSV export
my $query = q{
    COPY (
        SELECT id, name, created_at
        FROM users
    ) TO STDOUT WITH (FORMAT text, DELIMITER E'\t', NULL '\N')
};
✅ Summary

Feature	Cursor + bind_columns	COPY TO STDOUT
Memory use	Very low	Minimal (lowest possible)
Speed	Good	Excellent
Custom per-row logic	✅ Yes	❌ No (bulk only)
CSV formatting	You	PostgreSQL does it
Use case	Data processing	Fast export / backup
Would you like me to show a version that uses COPY TO STDOUT directly into a Perl data stream (e.g., piping it into another process or network socket)?
That’s great for ETL pipelines or parallel data ingestion.

You said:
yes
ChatGPT said:
Perfect — now you’re thinking like a data engineer 👏

Let’s take the final step: streaming PostgreSQL query results directly into another process or network destination — without ever writing an intermediate file.

This technique lets you build ultra–memory-efficient ETL or data pipelines purely in Perl.

🧩 Concept
We’ll still use PostgreSQL’s COPY TO STDOUT, but instead of writing to disk, we’ll pipe the data stream directly into:

Another command (e.g., gzip, aws s3 cp, psql, etc.)

A socket or network stream (e.g., for real-time ingestion)

Any Perl filehandle that accepts a write stream

✅ Example 1: Stream query → gzip → S3 upload
use strict;
use warnings;
use DBI;

# Connect to PostgreSQL
my $dbh = DBI->connect(
    "dbi:Pg:dbname=mydb;host=localhost",
    "user",
    "pass",
    {
        RaiseError => 1,
        PrintError => 0,
        AutoCommit => 1,
    }
);

# Open a pipeline: gzip compress and upload to S3 via AWS CLI
open my $out, "| gzip | aws s3 cp - s3://my-bucket/big_table.csv.gz"
    or die "Cannot open gzip+S3 pipe: $!";

# Define COPY query
my $query = q{
    COPY (
        SELECT col1, col2, col3, col4
        FROM big_table
        WHERE processed = true
    ) TO STDOUT WITH CSV HEADER
};

# Execute COPY and stream data
my $sth = $dbh->prepare($query);
$sth->execute();

while (my $chunk = $dbh->pg_getcopydata) {
    print {$out} $chunk;
}

close $out;
$sth->finish;
$dbh->disconnect;

print "✅ Streamed directly to S3 via gzip\n";
🧠 How it works
Step	Description
COPY ... TO STDOUT	PostgreSQL streams data in chunks
$dbh->pg_getcopydata	Reads the next data block (binary safe)
print $out $chunk	Sends to any filehandle (pipe, socket, etc.)
`gzip	aws s3 cp - ...`
Constant memory	Perl never buffers or stores the dataset
⚙️ Example 2: Stream to another process (e.g. load into another DB)
You can even pipe between two databases efficiently:

open my $pipe, "| psql -h dest-host -U dest_user -d dest_db -c \"COPY new_table FROM STDIN WITH CSV HEADER\"" 
    or die "Cannot open pipe to psql: $!";

my $query = q{
    COPY (
        SELECT col1, col2, col3, col4
        FROM big_table
    ) TO STDOUT WITH CSV HEADER
};

my $sth = $dbh->prepare($query);
$sth->execute();

while (my $chunk = $dbh->pg_getcopydata) {
    print {$pipe} $chunk;
}

close $pipe;
$sth->finish;
$dbh->disconnect;

print "✅ Streamed directly from one Postgres DB to another\n";
That’s a zero-intermediate Postgres→Postgres transfer — no temp files, no buffering, minimal latency.

⚙️ Example 3: Stream to a TCP socket (real-time ingestion)
use IO::Socket::INET;

# Connect to a TCP server (e.g. ETL collector)
my $sock = IO::Socket::INET->new(
    PeerAddr => 'etl-server.example.com',
    PeerPort => 9000,
    Proto    => 'tcp',
) or die "Cannot connect to ETL server: $!";

my $query = q{
    COPY (
        SELECT col1, col2, col3, col4 FROM big_table
    ) TO STDOUT WITH CSV
};
my $sth = $dbh->prepare($query);
$sth->execute();

while (my $chunk = $dbh->pg_getcopydata) {
    print $sock $chunk;
}

close $sock;
$sth->finish;
$dbh->disconnect;

print "✅ Streamed to ETL server over TCP\n";


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
