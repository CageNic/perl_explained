## How to get unique array values  
Using "map" function  
This method looks as the simplest one as it doesn't require any implicit or explicit conditional operators or arithmetic operations:  
```  
my %unique = map { $_ => 1 } @a;  
my @result = keys %unique;
```      
Unfortunately, simplicity of this method doesn't mean it's the fastest one  
Quite the opposite - the method is the slowest one, on Linux system it's at least 40% slower than any other method posted on this page. 
#### Replacing "map" with explicit loop  
It's not clear why the method above is very slow - it could be due to the fact that the map function needs to build an anonymous array which is twice as large as the original one, or it could be because "=" operation is not very efficient when arrays are assigned to hashes, or a combination of both  
Let's eliminate all inefficient parts by replacing the "map" function with foreach loop and see if it improves things:  
```  
my %unique = ();
foreach (@a)
{
    $unique{$_} = 1;
}
my @result = keys %unique;  
```   
This code executes 40% faster under Linux or 8 times faster under Windows    
Using hash to flag already seen values  
Let's use a little different approach      
Rather than getting list of all keys from a hash which we used to store all array values, we are going to use the hash to flag the values we've seen already, and store all un-seen values in a separate array    
```  
my @result = ();
my %seen = ();
foreach (@a)
{
    next if ($seen{$_});
    $seen{$_} = 1;
    push (@result, $_);
}
```  
Surprisingly enough, this code performs better than the previous example. It seems that the keys function is not that fast after all. Speed gain over previous example: 12% on Linux and 55% on Windows    
#### Using grep to eliminate explicit loop  
Perl has very useful function grep that loops implicitly over all array elements and returns only elements that satisfy certain condition. This function looks like a good fit for our task. Let's try to use it:  
```  
my %seen = ();
my @result = grep { !$seen{$_}++ } @a;  
```  
Well, the code looks very simple right now, and it executes 10% faster on Linux than the previous example  
There is no speed advantage of using this code on Windows  
#### Using "sort" function  
Using grep method is so simple that it's not clear how it can be improved any further    
But still, let's try completely different approach. What if we eliminate "already seen" hash completely?    
We can do it if we sort the array first, then loop through all array elements and store only values that differ from previous value from the same array:  
```  
my @result = ( $a[0] );
my $last = $a[0];
foreach (sort @a)
{
    push (@result, ($last = $_)) if ($_ ne $last);
}
```    
This method turns out to be the fastest from all methods from this page  
The speed of this method depends on how many duplicate records are in the original array  
The fewer duplicates records are in the original array, the faster this method is when compared to grep method  
The speed of both sort and grep methods is about the same when the original array has 6 - 8 duplicate values for each unique value  
The grep method becomes faster when the original array contains more than 8 duplicate values for each unique value  
Below are a few benchmarks that I did:  
no duplicate values - sort method is 225% faster on Linux  
2 duplicate values for each unique value - sort method is 40% faster on Linux, and 210% faster on Windows  
9 duplicate values for each unique value - grep method is 36% faster on Linux  
## How to identify duplicate hash keys    
In Perl, a hash cannot contain duplicate keys  
If you assign the same key more than once, the later value overwrites the earlier one:  
```  
my %hash = (
    foo => 1,
    bar => 2,
    foo => 3,
);

print $hash{foo};   3
```  

So if you mean “how can I detect duplicate keys in the source data?”, it depends on how you're creating the hash.

If you have a list of key/value pairs
You can detect duplicates before constructing the hash by constructing an array, not an array of hashes  
the => is just another way of writing , so effectively this is just an array where a comma separates each element, and as such, makes it easy to identify duplicate hash keys when using the while loop and shifting off the key and then shifting off the value so it becomes a hash key => value  
```  
my @pairs = (
    foo => 1,
    bar => 2,
    foo => 3,
);

my %seen;

while (@pairs) {
    my $key = shift @pairs;
    my $value = shift @pairs;

    if ($seen{$key}++) {
        warn "Duplicate key: $key\n";
    }

    # process the pair...
}
```   
Duplicate key: foo  

## How to identify duplicate hash keys   
If you want the keys sharing each value  
This is often more useful:  
```  
my %hash = (
    foo => 10,
    bar => 20,
    baz => 10,
    qux => 30,
    xyz => 20,
);

my %values;

push @{ $values{ $hash{$_} } }, $_ for keys %hash;

for my $value (keys %values) {
    if (@{ $values{$value} } > 1) {
        print "Value $value is used by: ",
              join(", ", @{ $values{$value} }), "\n";
    }
}
```      
Possible output:  

Value 10 is used by: foo, baz  
Value 20 is used by: bar, xyz  

This approach lets you identify all duplicate values and the hash keys associated with them.
