#!/usr/bin/perl
##############################################################################
#   MODULE  :   mkcbp.pl
#   DATE    :   November 8, 2013
#   PURPOSE :   To generate a dummy Code::Blocks project from a list of files.
##############################################################################

use XML::LibXML;


my $project_title = "Sample_Project";

##############################################################################
#   Add an 'Option' node to the passed $node
##############################################################################

sub add_option($$$$) {
    my $doc = shift;
    my $node = shift;
    my $optname = shift;
    my $optval = shift;
    my $newNode = undef;
    
    $newNode = $doc->createElement("Option");
    $newNode->addChild( $doc->createAttribute($optname, $optval) );
    $node->addChild($newNode);
    
    return;
}

##############################################################################
#   Begin
##############################################################################

my $doc = XML::LibXML::Document->new("1.0", "UTF-8");
my $root = $doc->createElement("CodeBlocks_project_file");
my $node;
my ($proj, $build, $target, $comp, $link, $unit); # project node

$doc->setDocumentElement($root);
$doc->setStandalone(1);

$node = $doc->createElement("FileVersion");
$node->addChild( $doc->createAttribute( major => 1 ) );
$node->addChild( $doc->createAttribute( minor => 6 ) );

$root->addChild($node);

$proj = $doc->createElement("Project");

add_option($doc, $proj, "title", $project_title);
add_option($doc, $proj, "pch_mode", "2");
add_option($doc, $proj, "compiler", "gcc");

$build = $doc->createElement("Build");

$target = $doc->createElement("Target");

$target->addChild( $doc->createAttribute( title => Debug ) );

$node = $doc->createElement("Option");
$node->addChild( $doc->createAttribute( output => 'bin/Debug/sample' ) );
$node->addChild( $doc->createAttribute( prefix_auto => 1 ) );
$node->addChild( $doc->createAttribute( extension_auto => 1 ) );
$target->addChild($node);

$node = $doc->createElement("Option");
$node->addChild( $doc->createAttribute( object_output => 'obj/Debug' ) );
$target->addChild($node);


$node = $doc->createElement("Option");
$node->addChild( $doc->createAttribute( type => 1) );
$target->addChild($node);

$node = $doc->createElement("Option");
$node->addChild( $doc->createAttribute( compiler => gcc ) );
$target->addChild($node);

#   Create the 'Compiler' node...
$comp = $doc->createElement("Compiler");

$node = $doc->createElement("Add");
$node->addChild( $doc->createAttribute( option => '-g' ) );
$comp->addChild($node);

$target->addChild($comp);

$build->addChild($target);

$proj->addChild($build);

$comp = $doc->createElement("Compiler");
$node = $doc->createElement("Add");
$node->addChild( $doc->createAttribute( option => '-Wall' ) );
$comp->addChild( $node );

$proj->addChild($comp);

# Add units
open FH, "</tmp/files.txt";

while (<FH>) {
	my $line = $_;
	chomp $line;

	print $line . "\n";
	$unit = $doc->createElement("Unit");
	$unit->addChild( $doc->createAttribute( filename => $line ) );

	$proj->addChild( $unit );
}

#$unit = $doc->createElement("Unit");
#$unit->addChild( $doc->createAttribute( filename => 'main.cpp' ) );

$proj->addChild( $unit );

close FH;

$root->addChild($proj);


$doc->toFile("/tmp/my.cbp", 1);


