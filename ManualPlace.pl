#!/usr/bin/perl
use strict;
use warnings;
use File::Path qw(remove_tree);
use Image::Magick;

# usage : Manualplace.pl image componentsCoordinates (image resolution)
# the componentsCoordinates file should have 6 columns, the separator is space
# the columns order is : component name, x, y, orientation, value and package
# lines with less or more data are ignored

my $ppp = 300;
my $markerSize = 1;
my $file = $ARGV[0] or die "Need to get CSV file on the command line\n";
my $file2 = $ARGV[1] or die "Need to get base image on the command line\n";
if ($#ARGV >= 3) {
	$ppp=$ARGV[2];
}
 
open(my $data, '<', $file) or die "Could not open '$file' $!\n";

my @lines = ();
 
while (my $line = <$data>) {
  chomp $line;
 
  my @fields = split " " , $line;
  if ($#fields != 5) {
    if ($#fields > 0) {
	print "Invalid number of fields($#fields) on line: @fields\n";
    }
  } else {
    push (@lines, \@fields);
  }
}

my $success = mkdir("Assembly");
if ($success == 0)
{
	print "The Assembly folder will be cleared, do you want to continue(y/n)?\n";
	my $input = <STDIN>;
	chomp($input);
	if ($input eq "y" || $input eq "Y")
	{
		remove_tree("Assembly");
		mkdir("Assembly");
	} else {
	print("Folder already exists\n");
	exit 1;
	}
}


my $baseImage = Image::Magick->new;
$baseImage->Read($ARGV[1]);

my $height = $baseImage->GetAttribute('height');

my $index = 0;
my $indexstring = "";

# remaining lines
my @remaining;
my @kept;

print "Generating global image\n";
my $image = $baseImage->Clone();
foreach my $row (@lines) {
	my $x = $ppp*@$row[1]/25.4;
	my $x2 = $x+$markerSize*$ppp/25.4;
	my $y = $height - $ppp*@$row[2]/25.4;
	$image->Draw(fill=>"#0000FF80", primitive=>'circle', points=>"$x,$y $x2,$y");
}
$image->Write(filename=>"Assembly/Global.png");

while ($#lines >= 0) {


@remaining = ();
@kept = ();

my $value = $lines[0]->[4];
my $package = $lines[0]->[5];
print "Generating image for value:$value and package:$package\n";

my $image = $baseImage->Clone();

foreach my $row (@lines) {
	if ($value eq @$row[4] and $package eq @$row[5]) {
		push (@kept, $row);
	} else {
		push (@remaining, $row);
	}
}

$image = $baseImage->Clone();
my $name ="";
my $quantity = 0;
foreach my $row (@kept) {
	$quantity++;
	my $x = $ppp*@$row[1]/25.4;
	my $x2 = $x+$markerSize*$ppp/25.4;
	my $y = $height - $ppp*@$row[2]/25.4;
	$name = join " ", $name, @$row[0];
	$image->Draw(fill=>"#0000FF80", primitive=>'circle', points=>"$x,$y $x2,$y");
}
$image->Splice(height=>50, width=>0);
$image->Annotate(pointsize=>32, text=>" ${value} x$quantity,$name", x=>0, y=>34, stretch=>'Condensed');
$indexstring = sprintf("%03d", $index);
$image->Write(filename=>"Assembly/Image${indexstring}.png");
$index += 1;

@lines = (); # copy the remaining data back into the lines array
foreach my $row (@remaining) {
	push (@lines, $row);
}
}
