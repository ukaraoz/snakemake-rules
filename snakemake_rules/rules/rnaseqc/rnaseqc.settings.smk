# -*- snakemake -*-
include: '../ngs.settings.smk'

RNASEQC_JAR_PROGRAM = "RNA-SeQC.jar"

config_default = { 
    'bio.ngs.rnaseq.rnaseqc' : {
        'java_mem' : config['settings']['java']['java_mem'],
        'java_tmpdir' : config['settings']['java']['java_tmpdir'],
        'BWArRNA' : "",
        'run_bwarrna' : False,
        'home' : os.curdir,
        'options' : '-n 1000',
        'transcript_annot_gtf' : config['bio.ngs.settings']['annotation']['transcript_annot_gtf'],
        'ref' : config['bio.ngs.settings']['db']['ref'],
    },
}

update_config(config_default, config)
config = config_default


config_default2 = {
    'bio.ngs.rnaseq.rnaseqc' : {
        'jar' : os.path.join(rnaseqc_conf['home'], RNASEQC_JAR_PROGRAM)},
}

update_config(config_default2, config)
config = config_default2


config_default3 = {
    'bio.ngs.rnaseq.rnaseqc' : {
        'cmd' : "java -Xmx" + rnaseqc_conf['java_mem'] + " -Djava.io.tmpdir=" + rnaseqc_conf['java_tmpdir'] +  " -jar " + rnaseqc_conf['jar']},
}

update_config(config_default3, config)
config = config_default3

# RNASEQC uses tophat alignments as input!
rule rnaseqc_main:
    """Run RNA-SeQC on sample"""
    params: cmd = config['bio.ngs.rnaseq.rnaseqc']['cmd'],
            options = " ".join([config['bio.ngs.rnaseq.rnaseqc']['options'], 
                      "-r", config['bio.ngs.rnaseq.rnaseqc']['ref'], 
                      "-t", config['bio.ngs.rnaseq.rnaseqc']['transcript_annot_gtf'],
                      " ".join(" -BWArRNA", config['bio.ngs.rnaseq.rnaseqc']['BWArRNA']) if config['bio.ngs.rnaseq.rnaseqc']['run_bwarrna'] else ""])
    input: bam="{prefix}.bam", bai="{prefix}.bai"
    output: "{prefix}.rnaseqc"
    shell: "{params.cmd} {params.options} -o {output}.tmp -s \"sample|{input.bam}|rnaseqc\" && mv {output}.tmp {output}"
