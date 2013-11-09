#!/usr/bin/perl
##############################################################################
#   MODULE  :   mkcbp.pl
#   AUTHOR  :   Michael Uman
#   DATE    :   November 8, 2013
#   PURPOSE :   To generate a dummy Code::Blocks project from a list of files.
##############################################################################

use strict;
use XML::LibXML;

#   Default settings

my $project_title       = "Sample_Project";
my $codeblocks_project  = "/tmp/my.cbp";
my $source_files        = "/tmp/files.txt";

##############################################################################
#   Add an 'Option' node to the passed $node
##############################################################################

sub add_option($$$) {
    my $doc         = shift;
    my $node        = shift;
    my $optionarray = shift;
    my $newNode     = undef;
    
    if (ref($optionarray) eq 'ARRAY') {
        $newNode = $doc->createElement("Option");

        foreach my $option (@$optionarray) {
            if (ref($option) eq 'HASH') {
                my ($key, $value) = each(%$option);
                $newNode->addChild( $doc->createAttribute($key, $value) );
                $node->addChild($newNode);
            }
        }
    }
    return;
}

##############################################################################
#   Add files to project from source file.
##############################################################################

sub add_files_to_project($$$) {
    my $document    = shift;
    my $project     = shift;
    my $sourceFile  = shift;
    my $unit        = undef;
    
    open FH, "<$sourceFile" or die 'Unable to open source definition...\n';

    while (<FH>) {
        my $line = $_;
        chomp $line;

        $unit = $document->createElement("Unit");
        $unit->addChild( $document->createAttribute( filename => $line ) );

        $project->addChild( $unit );
    }

    close FH;
}

##############################################################################
#   Create a codeblocks project
##############################################################################

sub create_codeblocks_project($$$) {
    my $project_title       = shift;
    my $codeblocks_project  = shift;
    my $source_files        = shift;

    print "Creating new Code::Blocks project '" . $project_title . "'\n";
    
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

    add_option($doc, $proj, [ { title => $project_title } ]);
    add_option($doc, $proj, [ { pch_mode => 2 } ]);
    add_option($doc, $proj, [ { compiler => 'gcc' } ]);

    $build = $doc->createElement("Build");

    #   Create Debug target
    $target = $doc->createElement("Target");
    $target->addChild( $doc->createAttribute( title => 'Debug' ) );

    add_option($doc, $target, [ { output => 'bin/Debug/sample' }, 
                                { prefix_auto => 1 }, 
                                { extension_auto => 1 } ]);

    add_option($doc, $target, [ { object_output => 'obj/Debug' } ]);
    add_option($doc, $target, [ { type => 1 } ]);
    add_option($doc, $target, [ { compiler => 'gcc' } ]);

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

    add_files_to_project($doc, $proj, $source_files);

    $root->addChild($proj);


    $doc->toFile($codeblocks_project, 1);

    return;
}

##############################################################################
#   Begin
##############################################################################

create_codeblocks_project($project_title, $codeblocks_project, $source_files);
