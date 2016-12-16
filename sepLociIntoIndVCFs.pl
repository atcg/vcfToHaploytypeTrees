#!/usr/bin/perl

use strict;
use warnings;
use Parallel::ForkManager;

# The file "loci" contains the locus ("chromosome") names from the VCF. Harvest these using:
#    grep contig= ../HSEM031-040.bqsr.snps.q30.passOnly.minGQ20MaxMiss90p.recode.vcf | perl -p -e 's/^\#\#contig\=\<ID\=//g' | perl -p -e 's/\,.*//g' > loci
open(my $locusFH, "<", "loci") or die "couldn't open loci for reading: $!\n";
unless (-d "lociFiles") {
    mkdir "lociFiles";
}


# Run 30 threads simulataneously
my $fm = Parallel::ForkManager->new(30);

while (my $locus = <$locusFH>) {
    $fm->start and next;
    chomp($locus);

    my $locusVCF = "\'lociFiles/" . $locus . ".vcf\'";
    $locusVCF =~ s/\|/\-\-/g;

    
    # This GATK command pulls out the variants that match "locus"
    system("java -Xmx3g -jar /home/evan/bin/GATK/GenomeAnalysisTK.jar -R ../../reference/all.RBBH.fasta -T SelectVariants -V ../HSEM031-040.bqsr.snps.q30.passOnly.minGQ20MaxMiss50p.recode.vcf -L \'$locus\' -o $locusVCF");

    $fm->finish;
}
$fm->wait_all_children();