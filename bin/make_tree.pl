#!/usr/bin/perl

use Getopt::Long;
use Bio::Tree::DistanceFactory;
use Bio::Matrix::IO;
use Bio::TreeIO;
use Data::Dumper;

my $distances_file;
my @species;

GetOptions('file=s' => \$distances_file, 'species=s' => \@species);
@species = split(/,/,join(',',@species));

my $dfactory = Bio::Tree::DistanceFactory->new(-method => 'UPGMA');
my $treeout = Bio::TreeIO->new(-format => 'newick');
my $parser = Bio::Matrix::IO->new(-format => 'phylip', -file => $distances_file);
                                  
my $matrix  = $parser->next_matrix;
my $tree = $dfactory->make_tree($matrix);

$tree->reroot($tree->find_node(@species[0]));
$tree->splice(-keep_id => \@species);

$treeout->write_tree($tree); print "\n";