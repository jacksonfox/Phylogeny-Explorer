#!/usr/bin/perl

use Getopt::Long;
use Bio::Tree::DistanceFactory;
use Bio::Matrix::IO;
use Bio::TreeIO;

my $distances_file;

GetOptions('file=s' => \$distances_file);

my $dfactory = Bio::Tree::DistanceFactory->new(-method => 'UPGMA');
my $treeout = Bio::TreeIO->new(-format => 'newick');
my $parser = Bio::Matrix::IO->new(-format => 'phylip', -file => $distances_file);
                                  
my $matrix  = $parser->next_matrix;
my $tree = $dfactory->make_tree($matrix);

$treeout->write_tree($tree); print "\n";