#!makefile

all_modules := $(shell ls -A |grep -v [mM]akefile|grep -v .svn)
export all_modules
REST_GOALS:=$(filter-out $(all_modules) bin help clean cleanall, $(MAKECMDGOALS))

.PHONY : bin help clean cleanall $(all_modules) $(REST_GOALS)

bin: $(all_modules)
	@$(MAKE) -C $(firstword $(all_modules)) bin

help clean cleanall:
	@$(MAKE) -C $(firstword $(all_modules)) $@

$(REST_GOALS): 
	@for sub in $(all_modules);			\
	do 									\
		$(MAKE) -C $$sub $@ || exit 1;	\
	done

$(all_modules): 
	@$(MAKE) -C $@ default

