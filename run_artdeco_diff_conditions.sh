#!/bin/zsh

# ARTDeco -home-dir ARTDECO_DIR_FPKM_0.003_dog2kb_wind500bp_dogcov0.05_doglen2kb  -bam-files-dir ./ARTDeco_input -gtf-file ./ARTDeco_input/chr_all.gtf -cpu 6 -chrom-sizes-file ./ARTDeco_input/chromosome_sizes.txt -layout PE --overwrite --read-in-fpkm 0.003 -stranded True -orientation Reverse -dog-window 500 -min-dog-len 2000 -min-dog-coverage 0.05

# It need to activate ARTDeco environment

# Failed command
# ARTDECO_DIR_FPKM_0.25_MDL_4000_MDC_0.05_WIN_650_S/dogs

WD=`pwd`
fpkm=0.25 #'0.25 0.15 0.01 0.003'
mdl=4000 #'4000 2000'
mdc=0.05 #'0.15 0.05'
win=650 #'350 500 650'

for FPKM in ${fpkm}; do
	for MDL in ${mdl}; do
		for MDC in ${mdc}; do
			for WIN in ${win}; do
				OUTDIR="ARTDECO_DIR_FPKM_${FPKM}_MDL_${MDL}_MDC_${MDC}_WIN_${WIN}_S"
				echo
				echo Running ARTDeco with FPKM=${FPKM}, MDL=${MDL}, MDC=${MDC}, WIN=${WIN}
				echo Output dir=${OUTDIR}
				if [[ ! -d ${OUTDIR} ]]; then
					mkdir ${OUTDIR}
				fi

				# Run ARTDeco
				ARTDeco -home-dir ${OUTDIR} \
					-bam-files-dir ${WD}/ARTDeco_input \
					-gtf-file ${WD}/ARTDeco_input/chr_all.gtf \
					-cpu 6 \
					-chrom-sizes-file ${WD}/ARTDeco_input/chromosome_sizes.txt \
					-layout PE \
					--overwrite \
					-read-in-fpkm ${FPKM} \
					-stranded True -orientation Reverse \
					-dog-window ${WIN} \
					-min-dog-len ${MDL} \
					-min-dog-coverage ${MDC}
				echo Done!
				echo "###########################################################################################"
			done
		done
	done
done
