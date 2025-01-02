# to work on for folder date modified - alternate to ls command with relevant flags

$dir = "/home/dir";
opendir (DIR, $dir);
     @dir=readdir(DIR);
        closedir(DIR);
         @dir = sort { -M "$dir/$a" <=> -M "$dir/$b" } (@dir);
         
## or ##

# Get a list of the files
opendir(DIR, $DirName);
@Files1 = readdir(DIR);
closedir(DIR);

# Loop thru each of these files
foreach $File (@Files1) {
	
	# Get information (including last modified date) about file
	@FileData = stat($DirName."/".$File);
	
	# Push this into a new array with date at front
	push(@Files, @FileData[9]."&&".$File);
	
}

# Sort this array
@Files = reverse(sort(@Files));

# Loop thru the files
foreach $File (@Files) {
	
	# Get the filename back from the string
	($Date,$FileName) = split(/\\&\\&/,$File);
	
	# Print the filename
	print "$FileName<BR>";
	
}
Perl stat - getting the file access time

To determine the last access (read) time of a file named foo.txt, use this sample Perl code:

$filename = 'foo.txt';
$last_access_time = (stat($filename))[8];
print "$last_access_time\n";
