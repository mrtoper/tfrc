#!/usr/bin/perl -w
#
# Utility for "normalizing" XML/SGML files
# Programmed by Matti 'ccr' Hamalainen <ccr@tnsp.org>
# (C) Copyright 2007,2009 Tecnic Software productions (TNSP)
#
use strict;
use warnings;

sub dorep($$)
{
  my $str = $_[0];
  my @vals = split(/ /, $_[1]);
  $str =~ s/\$(\d+)/$vals[$1 - 1]/eg;
  return $str;
}

my %xmlentities = ();
my $entMode = 0;
my $entData;
my $entName;

binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");

while (<STDIN>) {
  if (/<!ENTITY ([A-Za-z][A-Za-z0-9_]+) +SYSTEM +\"([^\"]*)\">/) {
    # Handle external entities
    my $name = $1;
    my $extfname = $2;
    local($/, *INFILE);
    open(INFILE, "<", $extfname) or die("Could not open entity file '$extfname'.\n");
    $xmlentities{$name} = <INFILE>;
    close(INFILE);
  } elsif (/<!ENTITY ([A-Za-z][A-Za-z0-9_]+) \"(.*?)\">/) {
    # One-line entities
    $xmlentities{$1} = $2;
  } elsif (/<!ENTITY ([A-Za-z][A-Za-z0-9_]+) \"(.*)$/) {
    # Multi-line entities
    $entName = $1;
    $entData = $2;
    $entMode = 1;
  } elsif ($entMode == 1) {
    if (/^(.*)\">/) {
      $entData .= $1;
      $xmlentities{$entName} = $entData;
      $entMode = 0;
    } else {
      $entData .= $_;
    }
  } else {
    # Expand entities for five levels at most
    my $str = $_;
    for (my $depth = 1; $depth < 5; $depth++) {
      while (my ($k, $v) = each(%xmlentities)) {
        $str =~ s/&$k;/$v/g;
        $str =~ s/&$k\s+([A-Za-z0-9 ]+);/dorep($v,$1)/eg;
      }
      last unless ($str =~ /&/);
    }
    print $str;
  }
}
