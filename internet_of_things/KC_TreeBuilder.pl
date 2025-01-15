# to work on page iteration

# tag - a
# attribute - href
# tag - img
# attribute - src

use LWP::UserAgent;
use HTML::TreeBuilder;
use URI::URL;

# Create a UserAgent to fetch the page
my $ua = LWP::UserAgent->new;
$ua->timeout(10);

# The URL to scrape
my $url = "";

# Fetch the page
my $response = $ua->get($url);
if ($response->is_success) {
    print "Successfully fetched the page.\n";
    my $content = $response->decoded_content;

    # Parse the HTML content into a tree
    my $tree = HTML::TreeBuilder->new_from_content($content);

    # Extract and print all <a> tags (links)
    my @links = $tree->find_by_tag_name('a');
    while (@links) {
            my $link = shift @links;
        my $href = $link->attr('href');
        if ($href) {
            my $abs_url = URI::URL->new($href, $url);
            print "Link: " . $abs_url->abs . "\n";
        }
    }

    # Extract and print all <img> tags (images)
    my @images = $tree->find_by_tag_name('img');
    foreach my $img (@images) {
        my $src = $img->attr('src');
        print "Image source: $src\n" if $src;
    }

    # Extract and print all paragraphs (<p>)
    my @paragraphs = $tree->find_by_tag_name('p');
    foreach my $p (@paragraphs) {
        print "Paragraph text: " . $p->as_text . "\n";
    }

    # Extract and print elements with specific class or id
    my $content_div = $tree->look_down(_class => 'content');
    print "Content from class 'content': " . $content_div->as_text . "\n" if $content_div;

    my $div_with_id = $tree->look_down(_id => 'main');
    print "Content from ID 'main': " . $div_with_id->as_text . "\n" if $div_with_id;

    # Clean up
    $tree = $tree->delete;
} else {
    die "Failed to fetch the page: " . $response->status_line . "\n";
}
