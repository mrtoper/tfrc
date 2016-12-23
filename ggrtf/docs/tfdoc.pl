#!/usr/bin/perl -w
#
# TFDoc for extending GgrTF DocBook manual with embedded TF docs.
# Programmed by Matti 'ccr' Hamalainen <ccr@tnsp.org>
# (C) Copyright 2009-2016 Tecnic Software productions (TNSP)
#
use strict;
use warnings;

## Convert special characters to HTML/XML entities
sub xmlentities($)
{
  my $value = $_[0];
  $value =~ s/&/&amp;/g;
  $value =~ s/</&lt;/g;
  $value =~ s/>/&gt;/g;
  return $value;
}

sub xmlentities2($)
{
  my $value = $_[0];
  $value =~ s/&/&amp;/g;

  my $str = "";
  my $state = 0;
  foreach my $qch (split(//, $value))
  {
    if ($qch eq "\$")
    {
      $state = !$state;
      $str .= ($state ? "<emphasis>" : "</emphasis>");
    }
    else
    {
      $str .= $qch;
    }
  }
  return $str;
}


### Scan one TinyFugue script file for documentation entries
sub scan_file($)
{
  my $filename = $_[0];
  print STDERR "Scanning '$filename'\n";
  my $data = {};
  my $cmd = "";
  my $sect = "";
  my %bindtypes = ("c" => "cast", "g" => "general", "s" => "skill");

  open(FILE, "<:encoding(iso-8859-1)", $filename) or die("Could not open '$filename' for reading.\n");
  while (<FILE>)
  {
    chomp;
    if (/\/prdef(c|g|b)bind\s+-s\"(.+?)\"\s+-c\"(.+?)\"\s*(.*)$/)
    {
      my $opts = $4;
      my $type = $bindtypes{$1};
      my $tmp = {};
      $tmp->{"name"} = $2;
      $tmp->{"desc"} = $3;
      $tmp->{"quiet"} = ($opts =~ /-q/) ? 1 : 0;
      $tmp->{"notarget"} = ($opts =~ /-n/) ? 1 : 0;
      push(@{$data->{"binds"}{$type}}, $tmp);
    }
    elsif (/;\s*\@keybind\s+(.*?)\s*=\s*(.*?)$/)
    {
      $data->{"keybinds"}{$1} = $2;
    }
    elsif (/;\s*\@command\s+(\S+)\s*?(.*)$/)
    {
      $cmd = $1;
      $sect = "commands";
      $data->{$sect}{$cmd}{"opts"} = $2;
    }
    elsif (/;\s*\@desc\s+(.*)$/)
    {
      if ($sect ne "" && $cmd ne "")
      {
        $data->{$sect}{$cmd}{"desc"} .= $1." ";
      }
    }
  }

  close(FILE);
  return $data;
}


### Print out a DocBook SGML/XML table header
sub table_start
{
  my $title = shift;
  my $cols = shift;
  
  print
    "<table>\n".
    " <title>$title</title>\n".
    " <tgroup cols=\"$cols\" align=\"left\">\n".
    "  <thead>\n".
    "   <row>\n";
  
  foreach my $col (@_)
  {
    print "    <entry>$col</entry>\n";
  }
  
  print
    "   </row>\n".
    "  </thead>\n".
    "  <tbody>\n";
}

sub table_end
{
  print
    "  </tbody>\n".
    " </tgroup>\n".
    "</table>\n";
}


sub handle_directive($$$$$)
{
  my ($mode, $title, $currfile, $files, $linen) = @_;

  die("Directive '\@$mode $title' found, but no \@file directive set before it on line $linen.\n")
    unless defined($currfile);

  if ($mode eq "keybinds")
  {
    # Keyboard bindings
    if (defined($files->{$currfile}{"keybinds"}))
    {
      my $data = $files->{$currfile}{"keybinds"};
      table_start((defined($title) ? xmlentities($title)." k" : "K")."eybindings", "2", "Key(s)", "Function");
      foreach my $tmp (sort keys %{$data})
      {
        print
          "   <row><entry>".xmlentities($tmp)."</entry>".
          "<entry>".xmlentities($data->{$tmp})."</entry></row>\n";
      }
      table_end();
    }
  }
  elsif ($mode eq "binds")
  {
    # Command bindings
    if (defined($files->{$currfile}{"binds"}))
    {
      my $data = $files->{$currfile}{"binds"};
      foreach my $type (sort keys %{$data})
      {
        my $entry = $data->{$type};
        table_start((defined($title) ? xmlentities($title)." " : "")."'$type' type command bindings", "4", "Command", "Quiet", "NoTarget", "Description");
        foreach my $entry (sort @{$data->{$type}})
        {
          print
            "   <row><entry>".xmlentities($entry->{"name"})."</entry>".
            "<entry>".($entry->{"quiet"} ? "X" : "")."</entry>".
            "<entry>".($entry->{"notarget"} ? "X" : "")."</entry>".
            "<entry>".xmlentities($entry->{"desc"})."</entry></row>\n";
        }
        table_end();
      }
    }
  }
  elsif ($mode eq "commands")
  {
    # Macro commands
    if (defined($files->{$currfile}{"commands"}))
    {
      my $data = $files->{$currfile}{"commands"};
      
      table_start((defined($title) ? xmlentities($title)." m" : "M")."acro commands", "2", "Command", "Description");
      foreach my $tmp (sort keys %{$data})
      {
        print
          "   <row><entry><emphasis>".xmlentities($tmp)."</emphasis> ".xmlentities($data->{$tmp}{"opts"})."</entry>".
          "<entry>".xmlentities2($data->{$tmp}{"desc"}).
          "</entry></row>\n";
      }
      table_end();
    }
  }
  else
  {
    die("Invalid/unsupported directive '\@$mode $title' on line $linen.\n");
  }
}


###
### Main program
###
my $basepath = shift or die("Usage: <tfdir basepath> < input.sgml > output.sgml\n");

print STDERR "Using TF-basepath '$basepath'\n";

binmode(STDOUT, ":utf8");
binmode(STDIN, ":utf8");

my $linen = 0;
my ($currfile, $currtitle);
my $files = {};

while (<STDIN>) {
  $linen++;
  # Get module filenames from section titles
  if (/<title>(.*?)\((\S+?\.tf)\)<\/title>/)
  {
    print $_;
    $currtitle = $1;
    $currfile = $2;
    if (!defined($files->{$currfile}))
    {
      $files->{$currfile} = scan_file($basepath.$currfile);
    }
  }
  elsif (/<!--\s*\@file\s+\"(.+?)\"\s+\"(.+?)\"\s*-->/)
  {
    $currfile = $1;
    $currtitle = $2;
    if (!defined($files->{$currfile}))
    {
      $files->{$currfile} = scan_file($basepath.$currfile);
    }
  }
  elsif (/<!--\s*\@([a-z]+)\s+\"(.+?)\"\s*-->/)
  {
    handle_directive($1, $2, $currfile, $files, $linen);
  }
  elsif (/<!--\s*\@([a-z]+)\s*-->/)
  {
    handle_directive($1, $currtitle, $currfile, $files, $linen);
  }
  else
  {
    print $_;
  }
}
