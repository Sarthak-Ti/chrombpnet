#!/bin/bash

cell_line=GM12878
data_type="DNASE_SE"

date=$(date +'%m.%d.%Y')
setting=$data_type"_withk562bias_"$date
cur_file_name="withk562bias_gm12878_dnase_fold_0.sh"
tranfer_cell_line=K562
transfer_setting=DNASE_SE_12.30.2021

### SIGNAL INPUT

blacklist_region=/mnt/data/annotations/blacklist/GRch38/GRch38_unified_blacklist.bed.gz
chrom_sizes=/mnt/data/annotations/by_release/hg38/hg38.chrom.sizes
ref_fasta=/mnt/data/GRCh38_no_alt_analysis_set_GCA_000001405.15.fasta
genomewide_gc="/oak/stanford/groups/akundaje/anusri/refs/genomewide_gc_hg38_stride_50_inputlen_2114_no_header.bed"
fold=/oak/stanford/groups/akundaje/projects/chrombpnet/model_inputs/ENCODE_ATAC_downloads/splits/fold_0.json
oak_dir=/oak/stanford/groups/akundaje/projects/chrombpnet_paper_new/$data_type/$cell_line/

main_dir=$PWD/results/chrombpnet/$data_type/$cell_line
data_dir=$main_dir/data
output_dir=$main_dir/$setting
neg_dir=$main_dir/negatives_data
bias_threshold_factor=0.5
inputlen=2114
gpu=4

function timestamp {
    # Function to get the current time with the new line character
    # removed 
    
    # current time
    date +"%Y-%m-%d_%H-%M-%S" | tr -d '\n'
}


## CREATE DIRS
if [[ -d $main_dir ]] ; then
    echo "main director already exists"
else
    mkdir $main_dir
fi

if [[ -d $output_dir ]] ; then
    echo "output director already exists"
else
    mkdir $output_dir
fi


overlap_peak=$data_dir/peaks_no_blacklist.bed


### STEP 2 - TRAIN CHROMBPNET MODEL

if [[ -d $output_dir/chrombpnet_model ]] ; then
    echo "skipping chrombpnet model training  - directory present "
else
    mkdir $output_dir/chrombpnet_model
    CUDA_VISIBLE_DEVICES=$gpu bash step6_train_chrombpnet_model.sh $ref_fasta $data_dir"/"$cell_line"_unstranded.bw" $overlap_peak $neg_dir/negatives_with_summit.bed $fold $PWD/results/chrombpnet/$data_type/$tranfer_cell_line/$transfer_setting/bias_model/bias.h5 $output_dir/chrombpnet_model $data_type
fi

### INTERPRET SEQUENCE MODEL

if [[ -d $output_dir/chrombpnet_model/interpret ]] ; then
    echo "skipping sequence model interpretation - directory present "
else
    mkdir $output_dir/chrombpnet_model/interpret

    logfile=$output_dir/chrombpnet_model/interpret/interpret.log
    touch $logfile

    echo $( timestamp ):"python $PWD/src/evaluation/interpret/interpret.py \
        --genome=$ref_fasta \
        --regions=$data_dir/30K.subsample.overlap.bed \
        --output_prefix=$output_dir/chrombpnet_model/interpret/$cell_line \
        --model_h5=$output_dir/chrombpnet_model/chrombpnet_wo_bias.h5" |  tee -a $logfile

    CUDA_VISIBLE_DEVICES=$gpu python $PWD/src/evaluation/interpret/interpret.py \
        --genome=$ref_fasta \
        --regions=$data_dir/30K.subsample.overlap.bed \
        --output_prefix=$output_dir/chrombpnet_model/interpret/$cell_line \
        --model_h5=$output_dir/chrombpnet_model/chrombpnet_wo_bias.h5  | tee -a $logfile
fi

if [[ -d $oak_dir/$setting/ ]]; then
    echo "dir exists"
else
    mkdir $oak_dir/$setting/
    mkdir $oak_dir/$setting/SIGNAL
fi

if [[ -f $oak_dir/$setting/SIGNAL/$cell_line.counts_scores.h5  && -f $oak_dir/$setting/SIGNAL/$cell_line.profile_scores.h5 ]] ; then
    echo "chrombpnet model files already present on oak"
else
    echo "copying counts and profile scores to oak"
    cp $output_dir/chrombpnet_model/interpret/$cell_line.counts_scores.h5 $oak_dir/$setting/SIGNAL/
    cp $output_dir/chrombpnet_model/interpret/$cell_line.profile_scores.h5 $oak_dir/$setting/SIGNAL/
fi

