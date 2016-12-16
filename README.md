### vcfToHaploytypeTrees ###
Starting with a phased (e.g. with beagle) VCF, parse into independent loci, build alignment files with reference, pull in ax/tig data, build trees, and visualize


### Separating loci ###
Take a multi-locus VCF file and generate new VCFs for each locus:
```bash
perl sepLociIntoIndVCFs.pl
```

### Make individual-locus PCAs and distance-based dendrograms ###
```bash
perl PCAandDistLocus.pl
```

### Haplotype Trees ###
We want to include phylogenetic trees that include:

  1. All of the haplotypes recovered in the CTS data
  2. As much A. mexicanum data as we can recover
  3. Data from some other A. tigrinum we have processed
  
We'll first generate a collection of haplotypes for each locus, and a graph that tells
us which animals have which haplotypes. Unfortunately, there doesn't appear to be
software that takes a phased VCF and outputs modified reference sequence haplotypes
(vcf-consensus does not appear to be phasing-aware). So we'll roll our own here. In
this case, we'll start with a VCF that was phased using BEAGLE (though this should work
with any VCF that is vertical-bar phased). We can cull these using something like this:

```bash
perl printHaplotypes.pl /mnt/Data1/CTScombined/haplotyping/HSEM031-040.bqsr.snps.q30.passOnly.minGQ20MaxMiss50p.nuke3sparse.beaglePhased.rename.vcf haplotypeData.tsv
```

