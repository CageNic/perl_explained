In modern versions of Perl (since Perl 5.14), the s/// substitution operator has a feature called the /r flag, which allows you to perform a substitution and return the modified string while leaving the original string unchanged.

#### Here’s how you can use it: 

#### Using the /r Flag 
The /r flag performs the substitution on a copy of the string and returns the modified version, leaving the original string intact 

```
my $original = "Hello, world!"; 
```

#### Perform substitution on a copy of the string, and return the modified version 

```
my $modified = $original =~ s/world/Perl/r; 
```
```
print "Original: $original\n";   # "Hello, world!" 
print "Modified: $modified\n";   # "Hello, Perl!"
``` 
In this example: 

$original remains unchanged 

$modified contains the result of the substitution ("Hello, Perl!") 

Key Points: 

/r flag: It performs the substitution on a copy of the string and returns the modified string.

Original string remains unchanged.

This approach is a cleaner and more idiomatic way to perform substitutions while keeping the original string intact, rather than manually creating a copy or working with references.
