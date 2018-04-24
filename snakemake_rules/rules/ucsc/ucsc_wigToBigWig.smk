# -*- snakemake -*-
include: "ucsc.settings.smk"
include: "ucsc_fetchChromSizes.smk"

config_default = {'ucsc' :{'wigToBigWig' : _ucsc_config_rule_default.copy()}}
config_default['ucsc']['wigToBigWig'].update(
    {
        'cmd' : 'wigToBigWig',
        'options' : '-clip',
    })

update_config(config_default, config)
config = config_default


rule ucsc_wigToBigWig:
    """Convert wig file to bigWig.

    Run wigToBigWig to convert wig file to bigWig.
    """
    params: cmd = config['ucsc']['wigToBigWig']['cmd'],
            options = config['ucsc']['wigToBigWig']['options'],
            runtime = config['ucsc']['wigToBigWig']['runtime']
    log: "{prefix}.wig.log"
    input: wig = "{prefix}.wig",
           sizes = "chrom.sizes"
    output: bigwig = "{prefix}.bigWig"
    threads: config['ucsc']['wigToBigWig']['threads']
    conda: "envs/ucsc_wigtobigwig.yaml"
    shell: "{params.cmd} {params.options} {input.wig} {input.sizes} {output.bigwig} 2> {log}"

