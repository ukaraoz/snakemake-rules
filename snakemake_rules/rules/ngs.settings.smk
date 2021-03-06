# -*- snakemake -*-
# Settings related to ngs programs
include: "main.settings.smk"

config_default = {
    'ngs.settings' : {
        'annotation' : {
            'annot_label' : "",
            'transcript_annot_gtf' : "",
            'sources': [],
        },
        'db' : {
            'dbsnp' : "",
            'ref' : "",
            'extra_ref' : [],
            'build' : '',
            'build_config' : None,
            'chrom_sizes': "",
        },
        'fastq_suffix' : ".fastq.gz",
        'fastq_suffix_re' : "(\.fastq|\.fq|\.fastq\.gz|.fq\.gz)",
        'filter_suffix': "_1.fastq.gz",
        'read1_label' : "_1",
        'read2_label' : "_2",
        'read_label_re' : "(|_1|_2|_R1|_R2)",
        'read1_label_re' : "(_1|_R1)",
        'read2_label_re' : "(_2|_R2)",
        'read1_suffix' : ".fastq.gz",
        'read2_suffix' : ".fastq.gz",
        'read_length' : 100,
        'regions': [],
        'rnaseq': {
            'ref_is_transcriptome': False,
            '_quantification' : [],
            '_transcriptome_quantification' : False,
        },
        'sequence_capture': {
            'bait_regions' : "",
            'target_regions': "",
        },
        'zip_re' : "(\.gz|\.zip|\.bz2)",
    },
}

update_config(config_default, config)
config = config_default
