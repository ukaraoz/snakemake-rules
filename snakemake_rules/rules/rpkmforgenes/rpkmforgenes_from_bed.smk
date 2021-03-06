# -*- snakemake -*-
include: 'rpkmforgenes.settings.smk'

rule rpkmforgenes_from_bed:
    """Run rpkmforgenes from bed input"""
    params: cmd = config['rpkmforgenes']['cmd'],
            options = " ".join([
                config['rpkmforgenes']['options'],
                " -u {}".format(config['rpkmforgenes']['unique']) if config['rpkmforgenes']['unique'] else "",
                " -a {}".format(config['rpkmforgenes']['annotation']) if config['rpkmforgenes']['annotation'] else "",
            ]),
            runtime = config['rpkmforgenes']['runtime'],
    input: unique = [config['rpkmforgenes']['unique']] if not config['rpkmforgenes']['unique'] is None else [],
           annotation = [config['rpkmforgenes']['annotation']] if config['rpkmforgenes']['annotation'] else [],
           bed = "{prefix}.bed" 
    output: rpkmforgenes = "{prefix}.rpkmforgenes"
    log: "{prefix}.rpkmforgenes.log"
    threads: config['rpkmforgenes']['threads']
    conda: "env.yaml"
    shell:
        " ".join(["{params.cmd} {params.options} ",
                  "-bed -i {input.bed} -o {output.rpkmforgenes} ",
                  " &> {log}"])
