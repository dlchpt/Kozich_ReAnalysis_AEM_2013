#!/usr/bin/env bash

# Obtained the raw 'fastq.gz' files from https://www.mothur.org/MiSeqDevelopmentData.html
# * Downloaded https://www.mothur.org/MiSeqDevelopmentData/StabilityWMetaG.tar
# * Ran the following from the project's root directory

wget --no-check-certificate https://www.mothur.org/MiSeqDevelopmentData/StabilityWMetaG.tar
tar xvf StabilityWMetaG.tar -C data/raw/
rm StabilityWMetaG.tar



# Download the SILVA reference file (v123). We will pull out the bacteria-specific sequences and
# clean up the directories to remove the extra files

wget http://mothur.org/w/images/1/15/Silva.seed_v123.tgz
tar xvzf Silva.seed_v123.tgz silva.seed_v123.align silva.seed_v123.tax
code/mothur/mothur "#get.lineage(fasta=silva.seed_v123.align, taxonomy=silva.seed_v123.tax, taxon=Bacteria);degap.seqs(fasta=silva.seed_v123.pick.align, processors=8)"
xmv silva.seed_v123.pick.align data/references/silva.seed.align
rm Silva.seed_v123.tgz silva.seed_v123.*
rm mothur.*.logfile

# Download the RDP taxonomy references (v14), put the necessary files in data/references, and
# clean up the directories to remove the extra files

wget -N http://www.mothur.org/w/images/8/88/Trainset14_032015.pds.tgz
tar xvzf Trainset14_032015.pds.tgz
mv trainset14_032015.pds/train* data/references/
rm -rf trainset14_032015.pds
rm Trainset14_032015.pds.tgz


# Generate a customized version of the SILVA v4 reference dataset
code/mothur/mothur "#pcr.seqs(fasta=data/references/silva.seed.align, start=11894, end=25319, keepdots=F, processors=8)"
mv data/references/silva.seed.pcr.align data/references/silva.v4.align


# Run mothur through data curation steps
code/mothur/mothur code/get_good_seqs.batch

# Run mock community data through seq.error to get sequencing error rate
code/mothur/mothur code/get_error.batch

# Run processed data through OTU clustering and making shared file
code/mothur/mothur code/get_shared_otus.batch

# Generate data to plot NMDS ordination
code/mothur/mothur code/get_nmds_data.batch

# Calculate the number of OTUs per sample when rarefying to 3000 sequences per sample
code/mothur/mothur code/get_sobs_data.batch
