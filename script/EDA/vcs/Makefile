.PHONY: format com lca sim simt clean

FILE_NAME = $(FILE).v
TESTBENCH = tb_$(FILE).v
# Path of vTbgenerator
vTbgenerator = ./vTbgenerator.py

OUTPUT = $(FILE).out
SIM_LOG = $(FILE)_sim.log
VCS_LOG = $(FILE)_vcs.log
ALL_DEFINE = +define+DUMP_VPD
# VPD_NAME = +vpdfile+$(OUTPUT).vpd
FSDB_NAME = $(OUTPUT).fsdb
WAVERC = 
VCS = 

VCSRUN = $(VCS) +vc -sverilog -race=all -ignore unique_checks -full64 \
        -timescale=1ns/1ps \
        -assert svaext +lint=TFIPC-L +lint=PCWM \
        -Mupdate -debug_access -debug_pp \
        -kdb -lca -j32 \
        +define+VERILATOR+CV32E40P_ASSERT_ON \
        -f $(CV_CORE_MANIFEST) \
        -o $(OUTPUT) \
        $(TBSRC_PKG) $(TBSRC)
# SIMRUN = ./$(OUTPUT) $(VPD_NAME) -l $(SIM_LOG)
SIMRUN = ./$(OUTPUT) -l $(SIM_LOG)
    
guard-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi

gen-tb: guard-FILE 
	python3 $(vTbgenerator) $(FILE_NAME) > $(TESTBENCH)

vcs-run: guard-FILE
	$(VCSRUN)
	$(SIMRUN)

vcs-run-profile: guard-FILE
	$(VCSRUN) -lca -simprofile
	$(SIM) -simprofile time

# wave: guard-FILE
# 	dve -vpd $(OUTPUT).vpd &
wave:
    verdi -nologo -elab simv.daidir/kdb -ssf ${FSDB_NAME} -sswr ${WAVERC}
    	
clean:
	rm -rf ucli.key *.log *.vpd *.out* csrc DVEfiles profileReport* simprofile_dir*
