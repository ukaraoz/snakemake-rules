# -*- snakemake -*-
# Rule to remove soft-clipping
include: "rsem.settings.smk"

rule rsem_remove_soft_clipping:
    """Remove soft clipping from alignments. 

    Helper rule for RSEM to remove soft clipping from alignments. This
    is required if aligner outputs soft-clipped reads, as is the case
    for STAR alignments to transcriptome-based references.

    The command is based on the code provide by Alex Dobin in the
    following post:
    
    https://groups.google.com/forum/#!msg/rna-star/gfz1mvylkTk/9SqPYBErkhsJ

    """
    params: runtime = config['rsem']['runtime']
    input: bam = "{prefix}.bam"
    output: bam = "{prefix}.noS.bam"
    threads: config['rsem']['threads']
    conda: "env.yaml"
    shell: "samtools view -h {input.bam} | awk 'BEGIN {{OFS=\"\\t\"}} {{split($6,C,/[0-9]*/); split($6,L,/[SMDIN]/); if (C[2]==\"S\") {{$10=substr($10,L[1]+1); $11=substr($11,L[1]+1)}}; if (C[length(C)]==\"S\") {{L1=length($10)-L[length(L)-1]; $10=substr($10,1,L1); $11=substr($11,1,L1); }}; gsub(/[0-9]*S/,\"\",$6); print}}' | samtools view -bS - > {output.bam}"
