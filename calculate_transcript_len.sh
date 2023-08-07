#!/bin/zsh

# Input should be file with list of gene_ids as specified in mm10 annotation gtf file
INPUT=$1

rm -f gene_lenghts.txt
cp mm10.ncbiRefSeq.exons.gtf tmp.gtf
for gene in $(cat ${INPUT}); do
	echo Processing ${gene}
	grep -w ${gene} tmp.gtf | \
		grep -w exon | \
		perl -ne '@x=split /\t/;$x[3]-=1;print "$x[0]\t$x[3]\t$x[4]\t.\t$x[6]\n"' | \
		sort -k2n > tmp.bed

	LEN=$(bedtools merge -i tmp.bed | perl -e 'while(<>){chomp; @x=split /\t/; $len += abs($x[2]-$x[1]);} print "$len"')
	echo "${gene}\t${LEN}" >> gene_lenghts.txt

	grep -w -v ${gene} tmp.gtf > tmp2.gtf
	mv tmp2.gtf tmp.gtf
done

