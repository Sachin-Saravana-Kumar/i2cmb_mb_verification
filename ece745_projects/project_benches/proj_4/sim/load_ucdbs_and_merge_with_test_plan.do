xml2ucdb -format Excel ./i2cmb_test_plan.xml ./i2cmb_test_plan.ucdb
add testbrowser ./*.ucdb
vcover merge -stats=none -strip 0 -totals regression.ucdb ./*.ucdb
coverage open ./regression.ucdb
