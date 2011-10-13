#!/usr/bin/perl

use Getopt::Long;
use Bio::Tree::DistanceFactory;
use Bio::Matrix::IO;
use Bio::TreeIO;

my $distances_file = '';
my @exclude_species = ();

GetOptions('file=s' => \$distances_file, 'exclude=s' => \@exclude_species);
@exclude_species = split(/,/,join(',',@exclude_species));

my $dfactory = Bio::Tree::DistanceFactory->new(-method => 'NJ');
my $treeout = Bio::TreeIO->new(-format => 'newick');
my $parser = Bio::Matrix::IO->new(-format => 'phylip', -file => $distances_file);
                                  
my $matrix  = $parser->next_matrix;
my $tree = $dfactory->make_tree($matrix);

$tree->splice(-remove_id => \@exclude_species);
$treeout->write_tree($tree); print "\n";