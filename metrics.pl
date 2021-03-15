#!/usr/bin/perl
#
# metrics.pl
# Issue some z/VM commands and capture the output for display
# Author: Vic Cross <viccross@au.ibm.com>

use strict;
use warnings;
use POSIX;

my $httpdir  = '/var/www/html';

my $gridcount = 0;
my $avgproc = 0;
my $paging = 0;
my $topicint = 60;

my @cpresult = `vmcp Q USERS`;
($gridcount) = $cpresult[0] =~ / *(.+) USER/;

# Write out guest count to the HTTP directory
my $guestmax = (int($gridcount/20) + 2) * 20;
open HTTPFILE, ">$httpdir/count.txt" or die "can't open guest count file in HTTP directory: $!\n";
print HTTPFILE "$gridcount";
close HTTPFILE;

@cpresult = `vmcp IND`;

open HTTPFILE, ">$httpdir/indicate.txt" or die "can't open INDICATE file in HTTP directory: $!\n";
foreach my $line (@cpresult) {
    print HTTPFILE "$line";
}
close HTTPFILE;

($avgproc) = $cpresult[0] =~ /AVGPROC-0*(.+)%/;
($paging) = $cpresult[2] =~ /PAGING-(.+)\/SEC/;

my @storcmd = `vmcp q stor`;
my ($storage) = $storcmd[0] =~ /STORAGE = (.+) CONF/;
my ($standby) = $storcmd[0] =~ /STANDBY = (.+) RESE/;
my $stornum = "";
if ( ($stornum) = $storage =~ /(.+)G/ ) {
    $stornum *= 1024;
} else {
    ($stornum) = $storage =~ /(.+)M/;
}
my $stbynum = "";
if ( ($stbynum) = $standby =~ /(.+)G/ ) {
    $stbynum *= 1024;
} else {
    ($stbynum) = $standby =~ /(.+)M/;
}

# Write out the graph values to HTTP directory
open HTTPFILE, ">$httpdir/paging.txt" or die "can't open paging rate file in HTTP directory: $!\n";
print HTTPFILE "$paging";
close HTTPFILE;
open HTTPFILE, ">$httpdir/cpu.txt" or die "can't open CPU use file in HTTP directory: $!\n";
print HTTPFILE "$avgproc";
close HTTPFILE;
open HTTPFILE, ">$httpdir/mem.txt" or die "can't open memory size file in HTTP directory: $!\n";
print HTTPFILE "$stornum";
close HTTPFILE;

@cpresult = `vmcp q alloc page`;
open HTTPFILE, ">$httpdir/allocpage.txt" or die "can't open page allocation file in HTTP directory: $!\n";
foreach my $line (@cpresult) {
    print HTTPFILE "$line";
}
close HTTPFILE;

my $lastline = scalar @cpresult - 1;
my ($usable) = $cpresult[$lastline] =~ /USABLE .* (.+)%$/;
open HTTPFILE, ">$httpdir/pageusable.txt" or die "can't open page usable file in HTTP directory: $!\n";
print HTTPFILE "$usable";
close HTTPFILE;

my $time = strftime "%a %e %H:%M" , localtime();
my $statusstring = "At $time, system status is: z/VM average CPU usage is $avgproc%, with $gridcount guests active. Paging rate is $paging/sec.";
open HTTPFILE, ">$httpdir/topic.txt" or die "can't open IRC topic file in HTTP directory: $!\n";
print HTTPFILE "$statusstring ";
close HTTPFILE;

open HTTPFILE, ">$httpdir/zvmstats.json" or die "can't open JSON stats file in HTTP directory: $!\n";
printf HTTPFILE "{\"guests\": %d, \"cpu\": %d, \"paging\": %d, \"pageuse\": %d, \"mem\": %d, \"stbmem\": %d }", $gridcount,$avgproc,$paging,$usable,$stornum,$stbynum;
close HTTPFILE;
