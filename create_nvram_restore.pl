#!/usr/bin/perl -w

use Cwd;
use File::Basename;
use strict;

my $scriptdir = dirname Cwd::abs_path($0);

my %varre;
my @varfiles = qw(vars_to_skip vars_to_include vars_preferred);

my $nvram = $ARGV[0];

get_vars_files();

open(NVRAM,$nvram) or die "couldn't open $nvram\n";
my $buf;
while (<NVRAM>) {
  $buf.=$_;
}
$buf = substr $buf, 8;
while ($buf) {
  my $vlen = unpack("C",$buf);
  $buf = substr $buf, 1;
  my $var = substr $buf, 0, $vlen;
  $buf = substr $buf, $vlen;
  my $len = unpack "S", $buf;
  $buf = substr $buf, 2;
  my $val = substr $buf, 0, $len;
  $buf = substr $buf, $len;
  
  if ($var !~ /$varre{vars_to_skip}/) {
    my $encval = $val;
    $encval =~ s/([\$`"\\])/\\$1/g;
    print "nvram set $var=\"$encval\"\n";
  }
}


sub get_vars_files
{
  foreach my $vtype (@varfiles) {
    my $file = $vtype;
    $file = "$scriptdir/$vtype" unless -f $file;
    next unless -f $file;
    open(FILE, $file);
    my @patterns;
    while (<FILE>) {
      chomp;
      push @patterns, $_;
    }
    push @patterns, "^traff-";
    close(FILE);
    $varre{$vtype} = "(" . join('|', @patterns) . ")";
  }
}
