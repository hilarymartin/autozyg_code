#!/bin/sh

#tabix vcf.gz files

# convert VCF to plink format
vcftools --vcf $invcf --plink-tped --out $outdir/$scaffold
plink --noweb --tfile  $outdir/$scaffold --make-bed --out $outdir/$scaffold

# use plink to extract SNPs with MAF>0.05
plink --noweb --bfile $outdir/relatives_excluded/$scaffold --geno 0.1 --maf 0.05 --make-bed --out $outdir/relatives_excluded.MAF_0.05_in_combined_population/$scaffold

# thin SNPs
plink --noweb --bfile $outdir/relatives_excluded.MAF_0.05_in_combined_population/$scaffold  --indep-pairwise 50 5 0.1  --out $outdir/relatives_excluded.MAF_0.05_in_combined_population/SNPs_to_remove/$scaffold
plink --noweb --bfile $outdir/relatives_excluded.MAF_0.05_in_combined_population/$scaffold --exclude $outdir/relatives_excluded.MAF_0.05_in_combined_population/SNPs_to_remove/$scaffold.prune.out --make-bed --out $outdir/relatives_excluded.MAF_0.05_in_combined_population/thinned/$scaffold

#merge chromosomes
ls $dir/*bed |sed "s/.bed//g"|awk 'OFS="\t"{print $1".bed",$1".bim",$1".fam"}'|grep -vP "Contig1\." > $dir/file_list.txt
plink --bfile $dir/Contig1  --merge-list $dir/file_list.txt  --recode --out $dir/$prefix

#might want to label samples by cohort or by reported place of birth

##### now need to make config file for EIGENSTRAT


#### run PCA
pcadir="/well/donnelly/PlatypusSeq/EIGENSOFT_analysis/PCA"
bindir="/well/donnelly/PlatypusSeq/git_hilary_platypus/platypus/"

parfile=PCA_in_EIGENSOFT.relatives_excluded.MAF_0.05_in_combined_population
/apps/well/eigensoft/5.0.2/bin/smartpca -p $bindir/$parfile.par >$bindir/$parfile.log
