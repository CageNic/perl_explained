# The LWP::UserAgent module provides a way to make HTTP requests and retrieve responses
# When working with the response, you often access the content of the response in different ways: content, decoded_content, and content_ref
# These represent different methods of dealing with the HTTP response's body, particularly in terms of encoding and memory management

###########
# content #
###########

# The content method returns the raw, unprocessed content of the HTTP response as a string of bytes
# This means that it does not perform any kind of decoding (e.g., for character encoding) or handling of the content's encoding, so what you receive is exactly what was returned by the server

# This is useful if you need the exact, unmodified content of the response (for example, binary files like images, PDFs, or any other content where decoding could corrupt the data)

# Example:

use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
my $response = $ua->get('http://example.com/image.jpg');

if ($response->is_success) {
    my $raw_content = $response->content;
    # $raw_content is the raw byte content of the file
}

# In this example, $raw_content will contain the raw binary data for the image

###################
# decoded_content #
###################

# The decoded_content method automatically decodes the content if the server has set an encoding for the response (like Content-Encoding: gzip or Content-Encoding: deflate)
# It takes care of decoding the content into a usable form (usually into a UTF-8 string if the content is textual)

# This is typically used when you are dealing with textual content and you want the decoded string representation, particularly when compression like gzip or deflate is used

use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
my $response = $ua->get('http://example.com/textfile.txt');

if ($response->is_success) {
    my $decoded_content = $response->decoded_content;
    # $decoded_content will be the decoded text content of the file
}

# In this example, $decoded_content would be the text content of textfile.txt after decompressing it (if it was compressed, like with gzip).

###############
# content_ref #
###############

# The content_ref method returns a reference to the content of the response instead of returning the content itself
# This is typically used to avoid copying large data into memory, which can be important for memory-efficient handling, especially when dealing with large responses like files or large web pages.

# Use Case: This is useful when you want to handle large responses without creating a copy of the entire content in memory
# You can manipulate or read from the content without actually loading it all into memory

use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
my $response = $ua->get('http://example.com/largefile.bin');

if ($response->is_success) {
    my $content_ref = $response->content_ref;
    # $content_ref is a reference to the content, allowing you to stream or process it
}

# In this case, $content_ref is a reference to the raw content. You can use it to process large data efficiently, for example, reading it in chunks

# Key Differences:
# content: Returns the raw content as a string. No decoding or special handling is applied

# Example: Use when downloading binary files like images, PDFs, etc
# decoded_content: Decodes the content based on the Content-Encoding header (e.g., gzip, deflate)
# It is typically used for textual data
# Example: Use when the server sends compressed text data, and you need it in a readable string format
# content_ref: Returns a reference to the content (not the content itself)
# This allows for efficient handling of large responses without copying the entire content into memory

# Example: Use when handling large files, where copying the data into memory would be inefficient

# Use content for raw, unprocessed content (especially binary data).
# Use decoded_content when you expect and want automatic decoding of compressed or encoded text content.
# Use content_ref when dealing with large content, allowing you to work with the data without duplicating it in memory.

# examples of Perl's LWP::UserAgent content_ref feature
# In Perl, the LWP::UserAgent module is commonly used for making HTTP requests, and one of the methods it provides to access the response body is content_ref
# This feature returns a reference to the content of the HTTP response, which allows you to process large responses efficiently without loading the entire content into memory
# Here's a deeper explanation of what content_ref is and how you can use it, along with some examples.

# What is content_ref?
# The content_ref method in LWP::UserAgent returns a reference to the HTTP response body instead of returning the content directly as a string
# This is particularly useful for handling large responses, such as big files or datasets, where you want to avoid loading the entire content into memory at once
# When you use content_ref, you can operate on the data as a reference, which is much more memory-efficient.

# Why use content_ref?
# Memory Efficiency: If you expect to receive large amounts of data (like big files, logs, or large HTML pages), using content_ref helps avoid the overhead of copying large data into memory
# Streaming Data: You can process data in a more memory-efficient manner, potentially reading or writing it in chunks, rather than all at once
# How does content_ref work?
# When you call content_ref, it does not return the content itself but a reference to the content
# This reference is typically a scalar reference to a string (which could represent binary data, text, etc.)
# You can dereference this reference to access the actual content

####################################################
# Example 1: Accessing content_ref for Large Files #
####################################################

# Let's say you're downloading a large file, such as an image or a big binary file, and you don't want to load the entire file into memory at once
# Instead, you use content_ref to handle the data more efficiently

use LWP::UserAgent;
use File::Slurp;  # to write to files easily

my $ua = LWP::UserAgent->new;
my $url = 'http://example.com/largefile.zip';  # URL of a large file

my $response = $ua->get($url);

if ($response->is_success) {
    # Get a reference to the content
    my $content_ref = $response->content_ref;

    # Write the content directly to a file using the reference
    write_file('largefile.zip', {binmode => ':raw'}, $$content_ref);
    print "File downloaded successfully.\n";
} else {
    print "Failed to retrieve the file: " . $response->status_line . "\n";
}

# In this example

# $response->content_ref returns a reference to the raw binary data of the file
# We dereference it ($$content_ref) to write it to a file. The binmode => ':raw' ensures that we handle the file in binary mode
# This approach is more memory-efficient for large files, as we aren't holding the entire file in memory as a string

########################################################
# Example 2: Streaming Data from a Large Text Response #
########################################################

# If you're dealing with a large HTML page or a JSON response, you might want to process the response in chunks
# For instance, you can read the content in a streaming fashion or line by line, especially when the content is too large to fit comfortably in memory.

use LWP::UserAgent;

my $ua = LWP::UserAgent->new;
my $url = 'http://example.com/large-text-file';

my $response = $ua->get($url);

if ($response->is_success) {
    # Get the reference to the content
    my $content_ref = $response->content_ref;

    # For example, process the content in chunks
    my $content = $$content_ref;  # Dereferencing the reference to get the string
    my @lines = split /\n/, $content;  # Split the content by lines

    # Print the first 10 lines
    print "First 10 lines of content:\n";
    for my $line (0..9) {
        print "$lines[$line]\n" if defined $lines[$line];
    }
} else {
    print "Failed to retrieve the content: " . $response->status_line . "\n";
}

# Here:

# The content is retrieved as a reference via $response->content_ref.
# We dereference the reference using $$content_ref to get the content as a string.
# We process it by splitting it into lines and printing the first 10 lines.
# This approach is useful when you expect large text responses, and you want to minimize memory usage.

#################################################
# Example 3: Comparing content_ref with content #
#################################################

To better understand how content_ref compares with content, here's an example where we fetch the same content both ways:

use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
my $url = 'http://example.com/large-text-file';  # A URL with a large text file

my $response = $ua->get($url);

if ($response->is_success) {
    # Using content
    my $content = $response->content;  # Direct string content
    print "Using content: " . substr($content, 0, 100) . "...";  # Print first 100 characters

    # Using content_ref
    my $content_ref = $response->content_ref;
    print "\nUsing content_ref: " . substr($$content_ref, 0, 100) . "...";  # Print first 100 characters
} else {
    print "Failed to retrieve the content: " . $response->status_line . "\n";
}

# In this example:

# $response->content directly gives you the content as a string.
# $response->content_ref gives you a reference to the content, which you must dereference ($$content_ref) to access the actual content.

# Key Differences Between content and content_ref:
# content: Returns the entire content as a string. If the content is large, it loads the entire content into memory, which can be inefficient.
# content_ref: Returns a reference to the content, allowing more memory-efficient handling, particularly for large content (like files, large HTML, or JSON data)
