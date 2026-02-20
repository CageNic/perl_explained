#### In Perl, undef and false are related but not the same thing  
#### This distinction is especially important when reading CSV data  

#### undef (Undefined Value)

An undefined value means the variable has no value at all
```
my $x;
print "undef\n" unless defined $x;
```
- defined($x) → false  
- $x in boolean context → false  
- $x eq "" → warning (uninitialized value)  

#### Typical causes  

- Variable declared but not assigned
= Missing CSV column

#### Explicit undef  

- False Value (Defined but False)  

A false value is defined, but evaluates to false in boolean context.

#### Common false values in Perl:

- ""      # empty string  
- 0       # numeric zero  
- "0"     # string zero  

#### Example  
```
my $x = "";
print "defined\n" if defined $x;      # true
print "false\n" unless $x;            # true
```

- defined($x) → true
- $x in boolean context → false
- $x eq "" → true

#### In a CSV Context  

Consider this CSV row  
```
John,,25
```

If parsed correctly:

- Column 1 → "John"
- Column 2 → "" (empty string, defined but false)
- Column 3 → "25"  

But if a column is missing entirely (short row):
```
John,25
```

Then the third column might be  

undef (depending on parser behavior)

#### How to Properly Check
- Check if value exists at all:
```
if (defined $value) {
# Check if value is non-empty
if (defined $value && $value ne "") {
# Avoid this if you need to distinguish
if ($value) {   # WRONG if 0 is valid
```
Because this treats these as the same  
- undef
- ""
- "0"
- 0

#### Best Practice for CSV

If empty fields are meaningful, always check
```
if (!defined $value) {
    # column missing
}
elsif ($value eq "") {
    # column present but empty
}
```

If you're using plain split /,/ to read CSV data, the difference between undef and false (empty string) becomes very clear — because split never returns undef for a field that exists  

#### What split actually returns

Example:
```
my $line = "John,,25";
my @fields = split /,/, $line;
```

Result:
```
@fields = ("John", "", "25");
```
The middle field is:
- "" (empty string)
- defined
- false in boolean context

#### When Do You Get undef?

You get undef only if you access an index that doesn’t exist:
```
my $line = "John,25";
my @fields = split /,/, $line;

print defined $fields[2] ? "defined\n" : "undef\n";
```
Output  
undef  

Because index 2 was never created.

#### Important Gotcha: Trailing Empty Fields  

By default, split removes trailing empty fields.
```
my $line = "John,25,";
my @fields = split /,/, $line;
```
Result

("John", "25")   # last empty field is LOST

To preserve trailing empty fields:
```
my @fields = split /,/, $line, -1;
```
Output  

("John", "25", "")

#### How to Distinguish Properly
```
Check if column exists
if (exists $fields[2]) {
    print "Column exists\n";
}
Check if defined
if (defined $fields[2]) {
    print "Defined\n";
}
Check if empty
if (defined $fields[2] && $fields[2] eq "") {
    print "Empty but present\n";
}
```
#### Summary (Using split)
- John,,25	"" (defined, empty)
- Missing column	undef
- Trailing comma (without -1)	field removed
- Trailing comma (with -1)	""  

If column count matters
```
my @fields = split /,/, $line, -1;

if (!exists $fields[2]) {
    print "Column missing\n";
}
elsif ($fields[2] eq "") {
    print "Column empty\n";
}
```
