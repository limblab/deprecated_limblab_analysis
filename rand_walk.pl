#!/usr/bin/perl -W
# $Id$

use strict;

## Check that datafile exists
#if (!$1) {
#  die "Usage: rand_walk.pl <filename>";
#}

### HACK
#my $filename = "../fitz_robot067_bdf.mat";
my $filename = "../data_cache/Arthur_S1_012.mat";

#my $filename = $1;
if (! -f $filename) {
  die "cannot find $filename";
}

# Check for temporary directory
if (-d "tmp") {
  #die "tmp/ exists";
}

mkdir "tmp";

#
# Generate and run matlab script
####################################################
my $matlab = <<HERE;
addpath 'lib';
addpath 'spike';
file_name = '$filename';
open('$filename');
rand_walk_cl(data);
exit;
HERE

my $matlab_cmd = "matlab -nosplash -nodesktop -r \"$matlab\"";

system($matlab_cmd);

#
# Build summary page
##################################################
my $title = $filename;
$title =~ s/^.*\/(.*)$/$1/;
$title =~ s/_/\\_/g;
$title =~ s/\..*$//;

my $latex_table = "";
open CSV, "<tmp/summary.txt";
while (<CSV>) {
  chomp;
  my ($chan, $unit, $pk, $wd, $gc, $pd, $bl, $pdp) = split /,/;

  $pk = int(1000 * $pk);
  $wd = int($wd);

  if ($gc) {
    $latex_table .= "\\rowcolor{highlight}\n";
    $latex_table .= sprintf("%d & %d & %d ms & %d ms & %.2f & %.1f Hz & %.3f \\\\ \n",
			    $chan, $unit, $pk, $wd, $pd, $bl, $pdp);
  } else {
    $latex_table .= sprintf("%d & %d & %d ms & & & %.1f Hz & %.3f \\\\ \n",
			    $chan, $unit, $pk, $bl, $pdp);
  }

}
close CSV;

my $latex = <<HERE;
\\documentclass[11pt,letter]{article}

\\usepackage{colortbl}
\\definecolor{highlight}{rgb}{.18,.47,.74}

\\oddsidemargin=-.25in
\\evensidemargin=-.25in
\\textwidth=6.5in
\\topmargin=-1.25in
\\textheight=9.5in

\\title{$title}
\\date{}
\\author{}

\\pagestyle{empty}

\\begin{document}

\\raggedbottom
\\maketitle

\\begin{center}
\\begin{tabular}{|cc|ccccc|}
\\hline
Unit & Chan & MI Peak & Width & Pref. Dir. & Baseline & Peak \\\\
\\hline
$latex_table
\\hline
\\end{tabular}
\\end{center}

\\end{document}
HERE

my $latex_file_name = "tmp/summary.tex";
open LATEX, ">$latex_file_name";
print LATEX $latex;
close(LATEX);

system("pdflatex $latex_file_name >/dev/null 2>/dev/null");
system("pdf2ps summary.pdf >/dev/null");

#
# Build pdf from ps files
###################################################

my @ps_files = split /\n/, `ls tmp/*.ps`;
my $ps_cmd = "gs -dNOPAUSE -dBATCH -sDEVICE=pswrite " .
  "-sOutputFile=tmp/fig.ps ";

$ps_cmd .= join " ", @ps_files;
$ps_cmd .= " >/dev/null 2>/dev/null";

system($ps_cmd);

# convert to pdf
system("ps2pdf tmp/fig.ps");



