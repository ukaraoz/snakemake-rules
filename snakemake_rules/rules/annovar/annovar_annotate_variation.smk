# -*- snakemake -*-
include: "annovar.settings.smk"

config_default = {'annovar' :{'annotate_variation' : _annovar_config_rule_default.copy()}}


update_config(config_default, config)
config = config_default


rule annovar_annotate_variation:
    """Download annovar databases"""
    params: cmd='annotate_variation.pl',
            buildver=config['annovar']['buildver'],
            db = config['annovar']['db'],
            runtime = config['annovar']['annotate_variation']['runtime'],
    #output: os.path.join(config['annovar']['home'], config['annovar']['db'], "{db}")
    output: db="{db}"
    threads: config['annovar']['annotate_variation']['threads']
    shell: "{params.cmd} -buildver {params.buildver} -downdb {wildcards.db} {params.db}"
