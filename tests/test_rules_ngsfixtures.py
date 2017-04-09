#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import re
from os.path import basename, realpath, join
import logging
import yaml
import pytest
import subprocess as sp
from snakemake_rules.core import ruleinfo
from helpers import utils
from helpers.fixture import set_inputmap, set_output

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

has_ngsfixtures = False

try:
    import pytest_ngsfixtures
    has_ngsfixtures = True
    from pytest_ngsfixtures import factories
    #from pytest_ngsfixtures import filetypes
except ImportError as e:
    print("\n\n   pytest-ngsfixtures not installed; install with 'conda install -c percyfal pytest-ngsfixtures'\n\n")

THREADS = pytest.config.getoption("--ngs-threads", "1")
applications = [pytest.config.getoption("--application")] if pytest.config.getoption("--application") else pytest.rules.__all__
rule =  pytest.config.getoption("--rule") if pytest.config.getoption("--rule") else None

def create_testrules(applications, blacklist):
    """Generate list of test rules.

    Params:
      applications (list): list of applications
      blacklist (list): blacklisted rules

    Returns:
      rules (list): list of application directory/rule pairs, where
                    rule is the absolute path to the rule
    """
    testrules = []
    for x in applications:
        if x in blacklist:
            continue
        for y in getattr(pytest.rules, x):
            if not rule is None:
                if not rule in y:
                    continue
            else:
                if re.sub(".rule", "", basename(y)) in blacklist:
                    continue
            testrules.append((x,realpath(y)))
    return testrules


blacklist_list = []
testrules = create_testrules(applications, blacklist_list)

##############################
# data fixture
##############################
@pytest.fixture(scope="function", autouse=False)
def data(request, tmpdir_factory):
    """Generate fixture for rule"""
    app, rule = request.param
    if request.function.__name__ == "test_run":
        d = ruleinfo.parse_rule(rule)
        d['app'] = app
        logger.info("Setting up fixture for {}".format(d['name']))

        fixture_dir = os.path.join(app, d['name'])
        fixture = factories.safe_mktemp(tmpdir_factory, fixture_dir)

        inputmap = set_inputmap(d)
        wildcards = utils.get_wildcards(inputmap, d['wildcard_constraints'])
        output = set_output(d, wildcards)
        for wc, src in inputmap:
            if src:
                if isinstance(src, str):
                    p = factories.safe_symlink(fixture, src, basename(src))
                else:
                    for s in src:
                        p = factories.safe_symlink(fixture, s, basename(s))
    else:
        output = None
        fixture_dir = os.path.join(app, os.path.splitext(basename(rule))[0])
        fixture = factories.safe_mktemp(tmpdir_factory, fixture_dir)
    if request.config.option.ngs_show_fixture:
        logger.info("fixture directory: {}".format(str(fixture)))
        
    return app, rule, output, fixture


@pytest.mark.parametrize("data", sorted(testrules), ids=["{}/{}".format(x[0], basename(x[1])) for x in sorted(testrules)], indirect=["data"])
def test_list(data):
    app, rule, output, fixture = data
    output, err = utils.snakemake_list(fixture, "", snakefile=rule)


blacklist_slow = [
    'angsd_realsfs',
    'ansgd_thetastat_dostat',
    'ansgd_thetastat_makebed',
    'annovar_annotate_variation',
    'annovar_table_annovar',
    'bamtools_create_filter_script',
    'bcftools_call_targets',
    'bcftools_combine_target_variants',
    'bcftools_isec',
    'bedtools_intersect',
    'bedtools_intersect_make_region_baits',
    'bedtools_intersect_make_region_targets',
    'bowtie_align_pe',
    'bowtie2_align_se',
    'bowtie2_align_pe',
    'bwa',
    'picard_calculate_hs_metrics_regions',
    'picard_do_qc',
    'picard_mark_duplicates',
    'picard_merge_sam',
]
testrules = create_testrules(applications, blacklist_slow)

@pytest.mark.skipif(not has_ngsfixtures, reason="pytest-ngsfixtures not installed; will not run the workflow tests. Install with 'conda install -c percyfal pytest-ngsfixtures'")
@pytest.mark.slow
@pytest.mark.parametrize("data", sorted(testrules), ids=["{}/{}".format(x[0], basename(x[1])) for x in sorted(testrules)], indirect=["data"])
def test_run(data, ref, scaffolds):
    app, rule, targets, fixture = data
    if targets is None:
        pytest.skip("Unable to parse target for rule {}".format(basename(rule)))
    output, err = utils.snakemake_run(fixture, "", snakefile=rule, targets=targets)
