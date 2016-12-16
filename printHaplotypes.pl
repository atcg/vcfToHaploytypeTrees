#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my $inFile = shift();
my $outFile = shift();
open(my $inFH, "<", $inFile) or die "Couldn't open $inFile for reading: $!\n";
open(my $outFH, ">", $outFile) or die "Couldn't open $outFile for writing: $!\n";
my %haplotypes; # Store haplotypes here

my @samples; # We'll populate this when we get to the header line in the VCF
while (my $line = <$inFH>) { # Iterate through VCF
    chomp($line);
    if ($line =~ /^#CHROM/) { # This is the VCF column header line--samples start at 10th column
        @samples = split(/\t/, $line);
    }
    if ($line =~ /^#/) { # Skip header lines
        next;
    }
    my @fields = split(/\t/, $line);
    my $lastFieldIndex = scalar(@fields)-1; # 0-indexed arrays

    foreach my $sampleIndex (9..$lastFieldIndex) {
        my @gtFields = split(/\:/, $fields[$sampleIndex]); # The first colon-delimited field is the genotype
        my @alleles = split(/\|/, $gtFields[0]);
        
        # The data structure looks like $hash{'locus'}{'sample'}{'left/right'}{'00000101011101'}
        push(@{$haplotypes{$fields[0]}{$samples[$sampleIndex]}{'left'}}, $alleles[0]);
        push(@{$haplotypes{$fields[0]}{$samples[$sampleIndex]}{'right'}}, $alleles[1]);
    }
}

# Now %haplotypes is a hash where the first keys are loci. Each locus contains a
# hash where the keys are samples. Each sample contains two arrays ('left' and
# 'right'), which are ordered alleles which will next be flattened into haplotype strings

my %sampleHash;
foreach my $locus (keys %haplotypes) {
    foreach my $sample (keys %{$haplotypes{$locus}}) {
        # Collapse the arrays of genotypes into strings:
        my $leftHap = join('', @{$haplotypes{$locus}{$sample}{'left'}});
        my $rightHap = join('', @{$haplotypes{$locus}{$sample}{'right'}});

        $sampleHash{$sample}{$locus}{'left'} = $leftHap;
        $sampleHash{$sample}{$locus}{'right'} = $rightHap;        
    }
}


my @loci;
foreach my $locus (keys %haplotypes) {
    push(@loci, $locus);
}
# Print out the header info
print $outFH "Sample\t";
foreach my $locus (@loci) {
    print $outFH $locus . "\t";
}
print $outFH "\n";

foreach my $sample (sort keys %sampleHash) {
    print $outFH $sample . "\t";

    # Print out the left haplotypes
    foreach my $locus (@loci) {
        print $outFH $sampleHash{$sample}{$locus}{'left'} . "\t";
    }
    print $outFH "\n";

    # Print out the right haplotypes
    print $outFH $sample . "\t";
    foreach my $locus (@loci) {
        print $outFH $sampleHash{$sample}{$locus}{'right'} . "\t";
    }
    print $outFH "\n"; # Move on to next sample
}