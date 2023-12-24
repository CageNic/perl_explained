# How to Install Perlbrew  

Original version : https://www.digitalocean.com/community/tutorials/how-to-install-perlbrew-and-manage-multiple-versions-of-perl-5-on-centos-7

Adapted to install on Ubuntu 20.04.1 which does not use .bash_profile
Ubuntu 20.04.1 does have ~/.profile - but adding this line to it (source ~/perl5/perlbrew/etc/bashrc) in testing did not work

Instead adding source ~/perl5/perlbrew/etc/bashrc to the ~/.bashrc file after installing (and starting a new terminal) worked. 

# Step 1 – Installing Perlbrew
Perlbrew needs gcc, a compiler, and bzip2, a compression utility, in order to compile and install Perl. 
Note: The package version numbers you see in the following examples may be higher than shown in this guide because revisions are periodically being made to these packages.
Building Perl requires two gcc-related packages, libgcc and gcc. To see if you already have these packages, execute the following command:  

```bash
rpm -qa | grep gcc
```
If they’re installed, you’ll see the following output:  

libgcc-4.8.5-11.el7.x86_64
gcc-4.8.5-11.el7.x86_64  

You also need the bzip2-libs and bzip2 packages. Check to see that they’re installed as well:
### rpm -qa | grep bzip2

If they’re both installed, you’ll see the following:

bzip2-libs-1.0.6-13.el7.x86_64
Bzip2-1.0.6-13.el7.x86_64  

With the prerequisites out of the way, you can install Perlbrew. Download the installation script to your server:

### curl -L https://install.perlbrew.pl -o install.perlbrew.pl

Pipe the script to bash to run the installation script:

### cat install.perlbrew.pl | bash

This will create a new directory structure in /home/username/perl5, where Perlbrew will store its support files and versions of Perl. You’ll see the following output from the installation script:
Output

### Download the latest perlbrew

### Installing perlbrew
perlbrew is installed: ~/perl5/perlbrew/bin/perlbrew

perlbrew root (~/perl5/perlbrew) is initialized.

Append the following piece of code to the end of your ~/.bash_profile and start a
new shell, perlbrew should be up and fully functional from there:

    source ~/perl5/perlbrew/etc/bashrc

Simply run `perlbrew` for usage details.

Happy brewing!

 Installing patchperl

 Done


Next, use the perlbrew utility to create some initial configuration files and directories in /home/username/perl5/perlbrew:
Type this command:
~/perl5/perlbrew/bin/perlbrew self-install

You’ll see the following output:
Output

You are already running the installed perlbrew:
    /home/sammy/perl5/perlbrew/bin/perlbrew

#### Perlbrew is now installed, but you’ll want to modify your shell’s configuration files to make it easier to use  

# Step 2 – Editing Your .bashrc to Include Perlbrew

Open the file ~/.bashrc in your editor:
### vi ~/.bashrc

Add the following line at the bottom of the file to include the Perlbrew settings:
### source ~/perl5/perlbrew/etc/bashrc

Save the file and exit the editor
Then log out and then log back in to ensure that your .bashrd file loads Perlbrew’s settings. It will now add /home/username/perl5/perlbrew/bin to the front of your PATH environment variable, and set some other environment variables Perlbrew needs.
Verify that these environment variables have been set by running the env command and filtering the results with grep for the text PERL:

## env | grep PERL  

You should see entries similar to the following:
Output

PERLBREW_BASHRC_VERSION=0.78  
PERLBREW_ROOT=/home/username/perl5/perlbrew
PERLBREW_HOME=/home/username/.perlbrew

These environment variables tell Perlbrew where important directories are located. The version number may be higher if Perlbrew was revised after this tutorial was published.
Typing which perlbrew should now identify the full path to the perlbrew command:
which perlbrew

You should see the following in your terminal:
Expected Output

~/perl5/perlbrew/bin/perlbrew

Now that Perlbrew is installed and configured, let’s start using it  

# Step 3 – Installing and Building Your Perl Version  

Let’s use Perlbrew to install a stable version of Perl 5. Use the perlbrew command to see which Perl versions are available for installation:
perlbrew available
You’ll see a listing similar to the following partial listing:
Partial Listing
 perl-5.25.11
  perl-5.24.1
  perl-5.22.3
  perl-5.20.3
  perl-5.18.4
  ...

Odd-numbered major versions, such as perl-5.25, are under active development and are not considered stable or production-ready. In general, you won’t use versions older than 5.10.1 unless you have legacy code that requires one of these older versions.
According to the output, perl-5.24.1 is the most recent stable version, as it has the largest even major number. You can pick any Perl version shown in the list, but for this tutorial, we’ll install perl-5.24.1.

Install it with perlbrew install:

## perlbrew install perl-5.24.1

The Perl installation can take quite a while to build and install, generally about 20 minutes. Do not interrupt the build process. If you want to see the build’s progress, you can open a separate terminal session and monitor the build log with tail -f ~/perl5/perlbrew/build.perl-5.24.1.log.
After the build completes, you will see the following output from Perlbrew:
[secondary_label Output] 

perl-5.24.1 is successfully installed

When the build completes, the last line of the build log file will be:
Output

##### Brew Finished #####

You can repeat this process for each version of Perl you want to install. This guide only demonstrates installing one version, but this step can be repeated for as many versions as you need  

# Step 4 – Managing Your New Perl Installation
To use your new Perl installation, run the following command:
perlbrew use perl-5.24.1
This command updates the PERLBREW_PERL environment variable to point to the specified Perl version for your current login session.
If you want a version of Perl to be your default each time you log in, run this command:
perlbrew switch perl-5.24.1
This command sets the PERLBREW_PERL environment variable to point to the specified Perl version every time you log in.

Verify that you’re now using Perl 5.24.1:  

## perl -V

You should see the following output:
Parial Output
...
%ENV:
    PERLBREW_BASHRC_VERSION="0.78"
    PERLBREW_HOME="/home/sammy/.perlbrew"
    PERLBREW_MANPATH="/home/sammy/perl5/perlbrew/perls/perl-5.24.1/man"
    PERLBREW_PATH="/home/sammy/perl5/perlbrew/bin:/home/sammy/perl5/perlbrew/perls/perl-5.24.1/bin"
    PERLBREW_PERL="perl-5.24.1"
    PERLBREW_ROOT="/home/sammy/perl5/perlbrew"
    PERLBREW_VERSION="0.78"
@INC:
    /home/sammy/perl5/perlbrew/perls/perl-5.24.1/lib/site_perl/5.24.1/x86_64-linux
    /home/sammy/perl5/perlbrew/perls/perl-5.24.1/lib/site_perl/5.24.1
    /home/sammy/perl5/perlbrew/perls/perl-5.24.1/lib/5.24.1/x86_64-linux
    /home/sammy/perl5/perlbrew/perls/perl-5.24.1/lib/5.24.1
    .

Perlbrew installs just the core Perl code. To see which modules comprise the core for a particular version of Perl, execute this command:
corelist -v 5.24.1
At any time after using the perlbrew use or perlbrew switch commands, you can return to using the vendor version of Perl by using the command perlbrew off. If you used perlbrew switch to set a new default Perl, you can remove that default setting with perlbrew switch-off.
The perlbrew command, issued with no flags, generates a simple listing of helpful commands. The command perlbrew help generates more detailed help information.

# Step 5 – Testing Your Perl Installation by Installing Modules from CPAN
Perl provides a vast array of public code modules that extend the core language. These modules are stored in the Comprehensive Perl Archive Network (CPAN). The code you are thinking of writing may already be written, tested, and available in CPAN. You can use the CPAN repository to avoid re-inventing the wheel.
App::cpanminus is a Perl module that lets you explore the CPAN repository and download modules. It’s popular and easy to use. Let’s install this module and use it to test your new Perl installation.
Ensure you are using your new Perl installation:  

## perlbrew use perl-5.24.1  

Install the cpanminus module with:  

## curl -L https://cpanmin.us | perl - App::cpanminus
You’ll see the following output:  
Output

--> Working on App::cpanminus
Fetching http://www.cpan.org/authors/id/M/MI/MIYAGAWA/App-cpanminus-1.7043.tar.gz ... OK
Configuring App-cpanminus-1.7043 ... OK
Building and testing App-cpanminus-1.7043 ... OK
Successfully installed App-cpanminus-1.7043
1 distribution installed
Verify that the cpanminus module is now present:
perlbrew list-modules
You should see App::cpanimus in the output:
Output
App::cpanminus
Perl

You can now use the command-line utility cpanm to install additional modules and their dependencies. Let’s use it to install the Email::Simple module, which you’d need if you were writing some Perl code to send email messages.
cpanm Email::Simple

When the installation is complete, review the list of modules again:  

## perlbrew list-modules

Expected Output

App::cpanminus
Email::Date::Format
Email::Simple
Perl
