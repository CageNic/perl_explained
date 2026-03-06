## Perl m feature in regex  
In Perl, adding the m (multiline) modifier changes how the anchors ^ and $ behave. It does not change the search from “string” to “line”; the regex is still applied to the entire string, but ^ and $ are allowed to match at line boundaries inside the string (around newlines).

What changes with /m
Without /m:
```
^ = start of the entire string

$ = end of the entire string (or just before the final newline)
```
With /m:
```
^ = start of the string or right after \n

$ = end of the string or right before \n
```
Important: /m affects only ^ and $.
It does not affect . — that’s what /s (single-line / dotall) is for.

Example 1: Matching a line start

```
my $text = "one\ntwo\nthree";
$text =~ /^two/;    # false
$text =~ /^two/m;   # true
```
Explanation:
Without /m, ^ only matches the very start of "one\ntwo\nthree".
With /m, ^ also matches right after \n, so "two" is found.

Example 2: Matching a line end

```
my $text = "cat\ndog\nfox";
$text =~ /dog$/;    # false
$text =~ /dog$/m;   # true
```
Explanation:
Without /m, $ matches only the end of the entire string.
With /m, $ also matches before a newline, so "dog" matches.

Example 3: Anchors still don’t limit the search to one line

```
my $text = "a\nb\nc";
$text =~ /^b$/m;    # true
```
Explanation:
The regex engine still scans the whole string.
^b$ matches the line containing just "b" because /m allows both anchors to apply to line boundaries.

Example 4: /m vs no modifier with global matching

```
my $text = "x=1\ny=2\nz=3";
my @no_m = ($text =~ /^(\w)=/g);    # ()
my @m    = ($text =~ /^(\w)=/mg);   # ('x', 'y', 'z')
```
Explanation:
Without /m, ^ matches only once (start of string).
With /m, ^ matches at the start of each line, so all variables are captured.

Example 5: /m does not affect .

```
my $text = "hello\nworld";
$text =~ /^hello.world$/m;  # false
$text =~ /^hello.world$/sm; # true
```
Explanation:
Even with /m, . does not match \n.
Only /s allows . to match newlines. /m affects anchors only.

Key takeaway
/m does not make Perl “search line by line”

It simply allows ^ and $ to match internal line boundaries

Use:

/m → change anchor behavior

/s → let . match newlines

\A and \z → always mean start/end of string, regardless of /m

If you want, I can also show how this compares to regex behavior in other languages like Python or Java.

## what about the 'm' in front, so for example; my $text = 'abcd'; $text =~ m/b/;

Good question — this is a different “m” and it often causes confusion.

In this code:

```
my $text = 'abcd';
$text =~ m/b/;
```
the m is NOT the multiline modifier.

What m// means in Perl
m// is simply the match operator.

These are exactly equivalent:

```
$text =~ m/b/;
$text =~ /b/;
```
So in your example:

```
$text =~ m/b/;
```
Perl is just checking:

“Does $text contain the pattern b?”

And the answer is yes.

Why does Perl have m// at all?
Historically, Perl supports several operators:

OperatorPurposem//matchs///substitutetr///transliterate

The plain /pattern/ form is just a shortcut for m/pattern/.

Important distinction: operator vs modifier
✅ This m is the operator


m/b/
✅ This m is the modifier


/b/m
They are completely unrelated.

## Side-by-side comparison


## Match operator
```
$text =~ m/b/;     # same as /b/
# Multiline modifier
$text =~ /^b/m;    # ^ now matches after newlines
```
Example showing both together

```
my $text = "a\nb\nc";
$text =~ m/^b/m;   # true
```
Here:

first m → match operator

second m → multiline modifier

## Summary
m// = match operator

/pattern/ = shorthand for m/pattern/

/m after the pattern = multiline modifier

They do not mean the same thing
