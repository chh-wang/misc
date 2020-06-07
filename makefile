#!Makefile

ifeq ($(MAKECMDGOALS),)
MAKECMDGOALS := bin 
else ifeq ($(MAKECMDGOALS), help)
NOPRINTDIRFLAG := --no-print-directory
endif


MAKECMDGOALS := $(filter-out debug, $(MAKECMDGOALS))

$(MAKECMDGOALS) : 
	@$(MAKE) $(NOPRINTDIRFLAG) -C src $(MAKECMDGOALS)|| exit 1;

debug:
	@$(MAKE) DEBUG_ON=y -C src bin|| exit 1;
	

