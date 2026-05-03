#!/bin/bash
set -e
export PATH=$PATH:/home/marian/gatk-4.4.0.0

mkdir -p data/gvcf
mkdir -p data/vcf
mkdir -p results/4
mkdir -p results/4/plots_P13_variants
mkdir -p results/4/plots_P13_somatic



gatk HaplotypeCaller -ERC GVCF -R data/hg38/hg38.fa -I data/clean/P13_T.bwa.cleaned.bam  -O data/gvcf/P13_T.g.vcf.gz --dbsnp data/dbsnp/dbsnp.chr.vcf.gz
gatk GenotypeGVCFs -R data/hg38/hg38.fa -V data/gvcf/P13_T.g.vcf.gz -O data/vcf/P13_T.variants.vcf.gz

bcftools stats data/vcf/P13_T.variants.vcf.gz > results/4/P13_T.vcf.stats
plot-vcfstats -p results/4/plots_P13_variants/ results/4/P13_T.vcf.stats || true

NORMAL_SAMPLE=$(samtools samples data/clean/P13_C.bwa.cleaned.bam | cut -f1)

gatk Mutect2 -R data/hg38/hg38.fa -I data/clean/P13_T.bwa.cleaned.bam -I data/clean/P13_C.bwa.cleaned.bam -normal $NORMAL_SAMPLE -O data/vcf/P13_T_C.somatic.raw.vcf.gz

gatk FilterMutectCalls -R data/hg38/hg38.fa -V data/vcf/P13_T_C.somatic.raw.vcf.gz -O data/vcf/P13_T_C.somatic.filtered.vcf.gz

bcftools stats data/vcf/P13_T_C.somatic.filtered.vcf.gz > results/4/P13_T_C.somatic.vcf.stats
plot-vcfstats -p results/4/plots_P13_somatic/ results/4/P13_T_C.somatic.vcf.stats || true

delly call -g data/hg38/hg38.fa -o Tumor.delly.bcf data/clean/P13_T.bwa.cleaned.bam
bcftools view -i 'QUAL>20' Tumor.delly.bcf -Oz -o results/4/P13_T.delly.filtered.vcf.gz

delly call -g data/hg38/hg38.fa -o results/4/P13_somatic.delly.bcf data/clean/P13_T.bwa.cleaned.bam data/clean/P13_C.bwa.cleaned.bam

TUMOR_SAMPLE=$(samtools samples data/clean/P13_T.bwa.cleaned.bam | cut -f1)
NORMAL_SAMPLE=$(samtools samples data/clean/P13_C.bwa.cleaned.bam | cut -f1)
echo -e "${TUMOR_SAMPLE}\ttumor\n${NORMAL_SAMPLE}\tcontrol" > sample_map.tsv

delly filter -f somatic -o results/4/P13_somatic.delly.filtered.bcf -s sample_map.tsv results/4/P13_somatic.delly.bcf 

bcftools view results/4/P13_somatic.delly.filtered.bcf > results/4/P13_somatic.delly.filtered.vcf

rm -f Tumor.delly.bcf
rm -f results/4/P13_somatic.delly.bcf
rm -f results/4/P13_somatic.delly.filtered.bcf

rm -f sample_map.tsv

rm -f results/4/*.csi
rm -f results/4/*.tbi

