#!/usr/bin/perl

use strict;
use warnings;
use Parallel::ForkManager;


open(my $locusFH, "<", "loci") or die "couldn't open loci for reading: $!\n";



my $fm = Parallel::ForkManager->new(30);

while (my $locus = <$locusFH>) {
    $fm->start and next;
    chomp($locus);
    
    $locus =~ s/\|/\-\-/g;

    my $locusVCF = "\'lociFiles/" . $locus . ".vcf\'";
    my $locusGDS = "\'lociFiles/" . $locus . ".gds\'";
    my $locusPCAPNG = "\'lociFiles/" . $locus . ".PCA.png\'";
    my $locusTreePNG = "\'lociFiles/" . $locus . ".tree.png\'";

    system("Rscript PCALocus.R $locusVCF $locusGDS $locusPCAPNG");
    system("Rscript locusDist.R $locusGDS $locusTreePNG");

    unlink($locusGDS);

    $fm->finish;
}
$fm->wait_all_children();
