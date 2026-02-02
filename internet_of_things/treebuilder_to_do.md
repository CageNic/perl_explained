#### Perl script that uses the HTML::TreeBuilder module to scrape a site and extract:

- Paragraphs (<p> elements)
- Image URLs (<img> tags)
```
#!/usr/bin/perl
use strict;
use warnings;
use LWP::Simple;
use HTML::TreeBuilder;

# Replace with the URL of the WordPress site you want to scrape
my $url = 'https://example.wordpress.com/';

# Get the HTML content
my $html = get($url);

# Check if content was fetched successfully
die "Couldn't fetch $url" unless defined $html;

# Parse the HTML content
my $tree = HTML::TreeBuilder->new;
$tree->parse($html);
$tree->eof;

# Extract all <p> tags (paragraphs)
print "Paragraphs:\n";
my @paragraphs = $tree->look_down(_tag => 'p');
foreach my $p (@paragraphs) {
    my $text = $p->as_text;
    print "- $text\n" if $text =~ /\S/;  # Print only non-empty paragraphs
}

# Extract all <img> tags (images)
print "\nImage URLs:\n";
my @images = $tree->look_down(_tag => 'img');
foreach my $img (@images) {
    my $src = $img->attr('src');
    print "- $src\n" if defined $src;
}

# Clean up the tree to free memory
$tree->delete;
```

#### Example Output
Paragraphs:
- Welcome to my blog!
- Here I share my thoughts on tech and life.

#### Image URLs:
- https://example.wordpress.com/wp-content/uploads/2023/10/header.jpg
- https://example.wordpress.com/wp-content/uploads/2023/10/avatar.png

#### This is a basic scraper and does not handle pagination, JavaScript rendering, or dynamic content.

#### If the paragraph is describing the image, map the paragraph and image together  
While there’s no guaranteed way to detect that a paragraph is "describing" an image, a good heuristic is:
- If an <img> and a <p> are siblings (i.e., they appear near each other in the DOM), or
- If a paragraph is immediately before or after an image,

Then we can assume the paragraph may be describing that image.

#### Map Paragraphs to Images
This version of the script will attempt to pair images with nearby paragraphs using DOM traversal.
```
#!/usr/bin/perl
use strict;
use warnings;
use LWP::Simple;
use HTML::TreeBuilder;

# URL of the WordPress site
my $url = 'https://example.wordpress.com/';

# Get the HTML content
my $html = get($url) or die "Couldn't fetch $url";

# Parse HTML
my $tree = HTML::TreeBuilder->new;
$tree->parse($html);
$tree->eof;

print "Mapped Paragraphs and Images:\n\n";

# Find all <img> tags
my @images = $tree->look_down(_tag => 'img');

foreach my $img (@images) {
    my $src = $img->attr('src');
    next unless defined $src;

    # Try to find the paragraph describing the image
    my $paragraph = find_associated_paragraph($img);

    if ($paragraph) {
        my $text = $paragraph->as_text;
        print "Image: $src\n";
        print "Description: $text\n";
        print "-" x 40 . "\n";
    } else {
        # If no nearby paragraph found, just show the image
        print "Image: $src\n";
        print "Description: [No nearby paragraph found]\n";
        print "-" x 40 . "\n";
    }
}

# Cleanup
$tree->delete;

# Function to find the nearest paragraph to an image
sub find_associated_paragraph {
    my ($img) = @_;

    # Check previous sibling
    my $prev = $img->left;
    if ($prev && $prev->tag eq 'p' && $prev->as_text =~ /\S/) {
        return $prev;
    }

    # Check next sibling
    my $next = $img->right;
    if ($next && $next->tag eq 'p' && $next->as_text =~ /\S/) {
        return $next;
    }

    # Check parent (sometimes <figure> or <div> contains both)
    my $parent = $img->parent;
    if ($parent) {
        my @ps = $parent->look_down(_tag => 'p');
        foreach my $p (@ps) {
            return $p if $p->as_text =~ /\S/;
        }
    }

    return undef;
}


#### Example Output  
Mapped Paragraphs and Images:    
Image: https://example.wordpress.com/uploads/cat.jpg  
Description: This is my cat lounging on the couch  
----------------------------------------
Image: https://example.wordpress.com/uploads/header.jpg
Description: [No nearby paragraph found]
----------------------------------------  

#### how this works
- It looks for paragraphs right before or after the <img> tag in the DOM
- If not found, it checks if both are inside the same parent (e.g. a <div> or <figure>)
- It filters out empty paragraphs (just whitespace)

Would you like to improve this further with smarter matching (e.g. using image alt attributes, or using machine learning to check text relevance)?

#### using the alt attribute of an <img> tag is a practical and semantic way to get image descriptions  
#### often in WordPress themes, authors add alt text as a description or caption for accessibility or SEO.

#### You can modify the script to:
- Use the alt attribute as the primary image description.

Fallback to nearby paragraphs only if alt is missing or empty.

#### Use alt Attributes, Fallback to Paragraphs
```
#!/usr/bin/perl
use strict;
use warnings;
use LWP::Simple;
use HTML::TreeBuilder;

# WordPress URL to scrape
my $url = 'https://example.wordpress.com/';

# Fetch HTML content
my $html = get($url) or die "Couldn't fetch $url";

# Parse HTML
my $tree = HTML::TreeBuilder->new;
$tree->parse($html);
$tree->eof;

print "Mapped Images and Descriptions:\n\n";

# Find all <img> tags
my @images = $tree->look_down(_tag => 'img');

foreach my $img (@images) {
    my $src = $img->attr('src');
    next unless defined $src;

    my $desc = '';

    # 1. Try the alt attribute
    my $alt = $img->attr('alt');
    if (defined $alt && $alt =~ /\S/) {
        $desc = $alt;
    } else {
        # 2. Fallback: find nearby paragraph
        my $p = find_associated_paragraph($img);
        $desc = $p->as_text if $p;
    }

    print "Image: $src\n";
    print "Description: ", ($desc ? $desc : '[No description found]'), "\n";
    print "-" x 40 . "\n";
}

# Cleanup memory
$tree->delete;

# Function to find the nearest paragraph to an image
sub find_associated_paragraph {
    my ($img) = @_;

    # Check previous sibling
    my $prev = $img->left;
    if ($prev && $prev->tag eq 'p' && $prev->as_text =~ /\S/) {
        return $prev;
    }

    # Check next sibling
    my $next = $img->right;
    if ($next && $next->tag eq 'p' && $next->as_text =~ /\S/) {
        return $next;
    }

    # Check parent
    my $parent = $img->parent;
    if ($parent) {
        my @ps = $parent->look_down(_tag => 'p');
        foreach my $p (@ps) {
            return $p if $p->as_text =~ /\S/;
        }
    }

    return undef;
}
```
#### Sample Output  
Mapped Images and Descriptions:  
Image: https://example.wordpress.com/uploads/logo.png  
Description: Site logo in PNG format  
----------------------------------------  
Image: https://example.wordpress.com/uploads/hero.jpg  
Description: Welcome to my blog! This is the header image  
----------------------------------------  
Image: https://example.wordpress.com/uploads/footer.png  
Description: [No description found]  
----------------------------------------  

#### This prioritizes semantic HTML (alt attributes)  
#### Still handles messy or unstructured HTML by falling back to proximity-based matching

#### synopsis of all the HTML tags and attributes used in this context
#### including their hierarchy and relationships, as relevant to scraping WordPress posts for images and their descriptions (from paragraphs or alt attributes)

#### Context Overview
We are scraping a WordPress blog page for:
- <img> elements (images)
- <p> elements (paragraphs)
- alt attributes (image description)
- optional: parent-child or sibling relationships

#### Tag and Attribute Hierarchy  
Below is a conceptual HTML structure with explanations of each tag and how they relate to one another:
```
div class="post">
  <p>This is an introductory paragraph.</p>

  <div class="image-container">
    <img src="cat.jpg" alt="A cat on a couch" />
    <p>The cat enjoys sleeping here every afternoon.</p>
  </div>

  <figure>
    <img src="dog.jpg" />
    <figcaption>This is Bruno, the family dog.</figcaption>
  </figure>
</div>
```  
#### Tags & Attributes Explained  
---------------------------------------------------------------------------------------------------------
Tag             Attribute	Type	Description
---------------------------------------------------------------------------------------------------------
<div>           Container       General container element. Used for grouping content
<p>             Block	        Paragraph of text. Might describe an image if nearby
<img>	        Inline	        Embeds an image. Core to the scraping
src (in <img>)	Attribute	The image URL (source). Used to identify the image file
alt (in <img>)	Attribute	Alternative text for the image. Often used as a caption or description
<figure>	Semantic	HTML5 container for media (images/videos) and captions
<figcaption>	Semantic	Describes the content of a <figure> (i.e., the image)
parent	        Conceptual	Refers to the element that contains another (e.g., <div> containing <img>)
left, right	Conceptual	DOM siblings to the left or right of the current element  
---------------------------------------------------------------------------------------------------------

#### Typical WordPress DOM Structure for a Post  
Here’s a real-world-style example of how images and text are commonly structured in WordPress:
```
<article class="post">
  <h2>My Cat</h2>
  <p>This is a post about my cat.</p>

  <img src="cat.jpg" alt="Fluffy the cat on a couch">

  <p>Fluffy loves this spot near the window.</p>
</article>
```

#### DOM Relationships Summary  
-----------------------------------------------
Relationship	     Description
-----------------------------------------------
Parent → Child	     <div> contains <img>, <p>, etc.
Sibling              (left/right) Paragraph immediately before or after an image
Attribute	     alt attribute of <img> as primary image description
Semantic containers  <figure> and <figcaption> as grouped media with descriptions

#### Print a structured template (like a data hash) for each image, showing:
- src (image URL)
- alt
- Nearby <p> description (if any)
- Tag name
- HTML structure it's part of (e.g. parent tag)
- Optionally: all attributes

#### Extract & Dump Image Context
```
#!/usr/bin/perl
use strict;
use warnings;
use LWP::Simple;
use HTML::TreeBuilder;
use Data::Dumper;

# The target URL
my $url = 'https://example.wordpress.com/';

# Get HTML content
my $html = get($url) or die "Could not fetch $url";

# Parse HTML
my $tree = HTML::TreeBuilder->new;
$tree->parse($html);
$tree->eof;

# Array to hold structured image data
my @images_data;

# Find all <img> elements
my @images = $tree->look_down(_tag => 'img');

foreach my $img (@images) {
    my $src = $img->attr('src');
    next unless defined $src;

    # Collect attributes
    my %attributes;
    foreach my $attr ($img->all_external_attr_names) {
        $attributes{$attr} = $img->attr($attr);
    }

    # Attempt to find a nearby description paragraph
    my $description = '';
    if (my $alt = $img->attr('alt')) {
        $description = $alt;
    } elsif (my $p = find_associated_paragraph($img)) {
        $description = $p->as_text;
    }

    # Collect parent tag info
    my $parent_tag = $img->parent ? $img->parent->tag : undef;

    # Build structured data
    my %image_data = (
        tag        => 'img',
        src        => $src,
        alt        => $img->attr('alt'),
        description => $description,
        parent     => $parent_tag,
        attributes => \%attributes,
    );

    push @images_data, \%image_data;
}

# Output using Data::Dumper
$Data::Dumper::Indent = 2;
$Data::Dumper::Terse = 1;  # Don't use variable name
print Dumper(\@images_data);

# Clean up
$tree->delete;

# Function to find nearby <p> elements
sub find_associated_paragraph {
    my ($img) = @_;

    # Check previous sibling
    my $prev = $img->left;
    if ($prev && $prev->tag eq 'p' && $prev->as_text =~ /\S/) {
        return $prev;
    }

    # Check next sibling
    my $next = $img->right;
    if ($next && $next->tag eq 'p' && $next->as_text =~ /\S/) {
        return $next;
    }

    # Check parent container
    my $parent = $img->parent;
    if ($parent) {
        my @ps = $parent->look_down(_tag => 'p');
        foreach my $p (@ps) {
            return $p if $p->as_text =~ /\S/;
        }
    }

    return undef;
}
🧾 Sample Output (Dumper Format)
[
  {
    tag => 'img',
    src => 'https://example.wordpress.com/images/cat.jpg',
    alt => 'A cat sleeping on a couch',
    description => 'A cat sleeping on a couch',
    parent => 'div',
    attributes => {
      src => 'https://example.wordpress.com/images/cat.jpg',
      alt => 'A cat sleeping on a couch',
      class => 'wp-image-42'
    }
  },
  {
    tag => 'img',
    src => 'https://example.wordpress.com/images/banner.jpg',
    alt => undef,
    description => 'Banner for the blog',
    parent => 'figure',
    attributes => {
      src => 'https://example.wordpress.com/images/banner.jpg',
      class => 'header-img'
    }
  }
]
#### Use Data::Printer for Cleaner Output
Replace Data::Dumper with:
```
use Data::Printer;
p @images_data;
```

#### This script scans all <img> tags
- Gathers their attributes and context
- Dumps a full template of the image metadata and relationships

#### extend the script to include <figcaption> when present. This is useful because:  
<figure> often wraps an <img> and its <figcaption>  
<figcaption> gives a reliable, semantic description of the image  
We'll prioritize alt first, then check for figcaption, and finally fallback to a nearby <p>  

#### Updated Script: Includes <figcaption>
```
#!/usr/bin/perl
use strict;
use warnings;
use LWP::Simple;
use HTML::TreeBuilder;
use Data::Dumper;

# URL to scrape
my $url = 'https://example.wordpress.com/';

# Fetch HTML
my $html = get($url) or die "Could not fetch $url";

# Parse HTML
my $tree = HTML::TreeBuilder->new;
$tree->parse($html);
$tree->eof;

# Storage for image data
my @images_data;

# Find all <img> elements
my @images = $tree->look_down(_tag => 'img');

foreach my $img (@images) {
    my $src = $img->attr('src');
    next unless defined $src;

    # Extract attributes
    my %attributes;
    foreach my $attr ($img->all_external_attr_names) {
        $attributes{$attr} = $img->attr($attr);
    }

    # Get parent tag (often <div> or <figure>)
    my $parent = $img->parent;
    my $parent_tag = $parent ? $parent->tag : undef;

    # --- Description logic ---
    my $description = '';

    # Priority 1: alt attribute
    if (my $alt = $img->attr('alt')) {
        $description = $alt;
    }
    # Priority 2: <figcaption> in parent
    elsif ($parent && $parent->tag eq 'figure') {
        my $figcaption = $parent->look_down(_tag => 'figcaption');
        if ($figcaption && $figcaption->as_text =~ /\S/) {
            $description = $figcaption->as_text;
        }
    }
    # Priority 3: Nearby <p>
    elsif (my $p = find_associated_paragraph($img)) {
        $description = $p->as_text;
    }

    # Build structured image data
    my %image_data = (
        tag         => 'img',
        src         => $src,
        alt         => $img->attr('alt'),
        description => $description,
        parent      => $parent_tag,
        attributes  => \%attributes,
    );

    push @images_data, \%image_data;
}

# Print using Data::Dumper
$Data::Dumper::Indent = 2;
$Data::Dumper::Terse  = 1;
print Dumper(\@images_data);

# Clean up
$tree->delete;

# Helper: Find nearby <p> tag (left/right/within parent)
sub find_associated_paragraph {
    my ($img) = @_;

    my $prev = $img->left;
    if ($prev && $prev->tag eq 'p' && $prev->as_text =~ /\S/) {
        return $prev;
    }

    my $next = $img->right;
    if ($next && $next->tag eq 'p' && $next->as_text =~ /\S/) {
        return $next;
    }

    my $parent = $img->parent;
    if ($parent) {
        my @ps = $parent->look_down(_tag => 'p');
        foreach my $p (@ps) {
            return $p if $p->as_text =~ /\S/;
        }
    }

    return undef;
}
```
#### Example Output
```
[
  {
    tag => 'img',
    src => 'https://example.wordpress.com/uploads/dog.jpg',
    alt => undef,
    description => 'Bruno is always ready for a walk!',
    parent => 'figure',
    attributes => {
      src => 'https://example.wordpress.com/uploads/dog.jpg',
      class => 'featured'
    }
  },
  {
    tag => 'img',
    src => 'https://example.wordpress.com/uploads/logo.png',
    alt => 'Site logo',
    description => 'Site logo',
    parent => 'div',
    attributes => {
      src => 'https://example.wordpress.com/uploads/logo.png',
      alt => 'Site logo'
    }
  }
]
```
