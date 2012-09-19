# $Id: update_version.pl 851 2012-04-04 22:52:59Z brian $
# 
# Automatically updates the version fields in words.h

use strict;

my $filename = "words.h";
my $rev = substr('$Rev: 412 $', 6, -1);

my $dec_line = "#define __BUILD_UPDATED__ 1\n";

#
# Create new words.h with updated version number
#################################################
open OLD_FILE, "<$filename";
open NEW_FILE, ">_$filename";

while (my $line = <OLD_FILE>) {
  chomp $line;

  # update the revision from words.h
  if ($line =~ /\$Rev: (\d+) \$/ ) {
    $rev = $1;
  }

  if (substr($line, 0, 30) eq "#define BEHAVIOR_VERSION_MICRO") {
    $line = "#define BEHAVIOR_VERSION_MICRO $rev";
  }
  
  if (substr($line, 0, 30) eq "#define BEHAVIOR_VERSION_BUILD") {
    $line = "#define BEHAVIOR_VERSION_BUILD ".(substr($line, 30)+1);
  }
  
  print NEW_FILE "$line\n";
}

close OLD_FILE;
close NEW_FILE;

#
# At this point we have updated the counters and just need to prepend a 
# a declaration to the file to prevent build errors

unlink $filename;
open OLD_FILE, "<_$filename";
open NEW_FILE, ">$filename";

print NEW_FILE $dec_line;
while (<OLD_FILE>) {
  print NEW_FILE $_;
}

close OLD_FILE;
close NEW_FILE;



