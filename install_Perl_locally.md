## Install Perl locally  
https://help.dreamhost.com/hc/en-us/articles/360028572351-Installing-a-custom-version-of- 
Installing a custom version of Perl locally
If your server is currently running Ubuntu 18 (Bionic), the Perl version is 5.26. This article shows how to install a different version if your site requires it. It's recommended that you only use a version of Perl which is currently maintained. You can view a full list of versions and their status here:
•	https://www.cpan.org/src/
Installing
1.	Log into your server via SSH.
2.	Visit https://www.cpan.org/src/ to download your version of Perl. Run the wget command to download the tar.gz file.
wget https://www.cpan.org/src/5.0/perl-5.18.4.tar.gz
3.	Decompress this file.
tar zxf perl-5.18.4.tar.gz
4.	Change into the new directory.
cd perl-5.18.4
5.	Run the configure command for the directory you wish to install into. This example installs into a directory named /opt/perl under your username.
./Configure -des -Dprefix=$HOME/opt/perl
6.	Run make, make test, and finally make install.
7.	make
8.	make test
make install
9.	Add code to your .bash_profile to find the local version.
export PATH=$HOME/opt/perl/bin:$PATH
10.	source the .bash_profile.
 ~/.bash_profile
11.	Check to confirm the new version is being used.
12.	perl -v
This is perl 5, version 18, subversion 4 (v5.18.4) built for x86_64-linux

