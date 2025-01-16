#### The Perl version is stored in a couple of different Perl special variables:
```
#!/usr/bin/env/perl
print "$^V\n";                   # "v5.32.0"
print "$]\n";                    # "5.032000"

# If you're using use English, you have additional aliases for these variables:

use English;
print "$PERL_VERSION\n";         # "v5.32.0"
print "$OLD_PERL_VERSION\n";     # "5.032000"
```
