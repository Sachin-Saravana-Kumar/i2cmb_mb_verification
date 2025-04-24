#!/bin/sh

#FSM test
make cli GEN_TEST_TYPE=transitions
make cli GEN_TEST_TYPE=feedback_test
make cli GEN_TEST_TYPE=directed_test
#compulsory tests
make cli GEN_TEST_TYPE=rand_read
make cli GEN_TEST_TYPE=rand_write
make cli GEN_TEST_TYPE=rand_alt
#register tests
make cli GEN_TEST_TYPE=er_handling
make cli GEN_TEST_TYPE=FSMR_rd_test
make cli GEN_TEST_TYPE=check_default_vals

#merge coverage and testplan
make merge_coverage_with_test_plan
