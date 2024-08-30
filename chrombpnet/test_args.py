# import sys
# sys.path.append("chrombpnet/utils")
import parsers as parsers


def main():
    args = parsers.read_parser()
    
    # Print out all arguments
    # print("Parsed Arguments:")
    # print(f"Genome file: {args.genome}")
    # print(f"Peaks file: {args.peaks}")
    # print(f"Chromosome sizes file: {args.chrom_sizes}")
    # print(f"Fold JSON file: {args.fold_json}")
    # print(f"Blacklist file: {args.blacklist}")
    # print(f"Output directory: {args.output}")
    print(args)
    print(args.skip_preprocessing)
    print(args.save_data)
    # print(args.inputlen) #we can see that this accesses that specific thing!
    return args

if __name__ == "__main__":
    main()


#example
#simply copy this and paste this in, this will show how their parser works and uses these commands and what the args is actually
'''
cd /data/leslie/sarthak/chrombpnet/chrombpnet
python test_args.py pipeline \
        -ibam merged.bam \
        -d "ATAC" \
        -g hg38.fa \
        -c hg38.chrom.sizes \
        -p peaks_no_blacklist.bed \
        -n output_negatives.bed \
        -fl splits/fold_0.json \
        -b bias_model/models/k562_bias.h5 \
        -o chrombpnet_model/ \
        --skip_preprocessing
        
#The bias test

python test_args.py bias pipeline \
        -ibam merged.bam \
        -d "ATAC" \
        -g hg38.fa \
        -c hg38.chrom.sizes \
        -p peaks_no_blacklist.bed \
        -n output_negatives.bed \
        -fl splits/fold_0.json \
        -b 0.5 \
        -o bias_model_1000/ \
        -fp k562 \
        -il 1024 \
        -ol 1000 \
        --skip_preprocessing \
'''