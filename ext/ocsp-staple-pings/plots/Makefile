# Domain that is checked for OCSP-Stapling support.
DOM:=__DOMAIN_NAME__

# Data sources.
# NOTE: Update `.ssh/config` for password-less logins.
#
SRC1:=__HOST1__:__PATH1__
SRC2:=__HOST2__:__PATH2__
SRC3:=__HOST3__:__PATH3__

# Short identifiers for data sources (used for plots).
TAG1:=__HOST1_SHORT_ID__
TAG2:=__HOST2_SHORT_ID__
TAG3:=__HOST3_SHORT_ID__

# Experiment directory name.
EXP_LOC=exp--$(DOM)

# File containing OCSP-Staple pings.
DATA_FILE=ocsp-pings--$(DOM).txt

ALL:=ocsp-pings--m1.txt		\
	ocsp-pings--m2.txt		\
	ocsp-pings--m3.txt		\
	ocsp-pings--m12.txt		\
	ocsp-pings--$(DOM).txt	\
	ocsp-pings--$(DOM).pdf


.PHONY: all clean clean-data update-data

all: $(ALL)

clean:
	@rm -f $(ALL)

clean-data:
	@rm -f ocsp-pings--*.txt

update-data: clean-data all


ocsp-pings--m1.txt:
	@scp -q $(SRC1)/$(EXP_LOC)/$(DATA_FILE) $@

ocsp-pings--m2.txt:
	@scp -q $(SRC2)/$(EXP_LOC)/$(DATA_FILE) $@

ocsp-pings--m3.txt:
	@scp -q $(SRC3)/$(EXP_LOC)/$(DATA_FILE) $@

ocsp-pings--m12.txt: ocsp-pings--m1.txt ocsp-pings--m2.txt
	@join -j1 $^ > $@

ocsp-pings--$(DOM).txt: ocsp-pings--m12.txt ocsp-pings--m3.txt
	@join -j1 $^ > $@


NUM_SAMPLES=`cat ocsp-pings--$(DOM).txt | wc -l`

ocsp-pings--$(DOM).pdf: plot-ocsp-pings.gp ocsp-pings--$(DOM).txt
	@gnuplot                            \
		-e "IN_FILE='$(word 2, $^)'"    \
        -e "OUT_FILE='$@'"              \
        -e "X_MAX=$(NUM_SAMPLES)"       \
        -e "DS1='$(TAG1)'"				\
        -e "DS2='$(TAG2)'"				\
        -e "DS3='$(TAG3)'"				\
        $(word 1, $^)
