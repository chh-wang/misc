#!rules.mak

ifndef project_dir
$(error "Unknow project root directory")
endif

include $(project_dir)/scripts/env.mak

#=============================================================================
# The rules of Make. Do Not Change these rules.
#=============================================================================

#----------------------------------------------------------------------------
# The inner variables of Makefile
#----------------------------------------------------------------------------

# The soure files variables of Makefile
src 	 		:= $(shell /bin/find $(SRC_DIR) -name "*.c")
test_src		:= $(shell /bin/find $(TEST_DIR) -name "*.c")
header			:= $(wildcard include/*.h)

#----------------------------------------------------------------------------
# The inner target variables of Makefile
#----------------------------------------------------------------------------
ifneq (,$(TAR_LIB))
target_lib  	:= $(tarlib_dir)/lib$(TAR_LIB).a
endif

# target variable of Makefile
ifneq ($(TARGET),)
obj 			:= $(patsubst %.c,$(obj_dir)/$(MODULE)/%.o,$(src))
dep 			:= $(patsubst %.c,$(dep_dir)/$(MODULE)/%.d,$(src))
target_elf		:= $(tarelf_dir)/$(TARGET).elf
target_map		:= $(tarelf_dir)/$(TARGET).map
target_bin		:= $(tarbin_dir)/$(TARGET).bin
target_header 	:= $(addprefix $(tarhdr_dir)/, $(notdir $(header)))
endif

# test target variable of Makefile
ifneq ($(TEST),)
test_obj 		:= $(patsubst %.c,$(obj_dir)/$(MODULE)/%.o,$(test_src))
test_dep 		:= $(patsubst %.c,$(dep_dir)/$(MODULE)/%.d,$(test_src))
test_target_elf	:= $(tarelf_dir)/$(TEST).elf
test_target_bin	:= $(tarbin_dir)/$(TEST).bin
endif

# depend library 
LDFLAGS			+= $(addprefix -L, $(DEP_LIBS_PATH))
DEP_LIBS		:= $(addprefix -l, $(DEP_LIBS))

ifneq (,$(LD_SCRIPT_NAME))
LDSCRIPTS 		:= $(addprefix -T, $(project_dir)/ld/$(LD_SCRIPT_NAME))
endif

# Get all the obj files but excludes the obj files in the tests directory
ifeq ($(obj_dir), $(wildcard $(obj_dir)))
all_objs := $(shell /bin/find $(obj_dir) -name 'tests' -prune -o -name '*.o' -a -print)
endif

#----------------------------------------------------------------------------
# The phony target rules. Do Not Change these rules.
#----------------------------------------------------------------------------

# Phony targets
.PHONY : default clean cleanall depand test lib bin $(MODULE) help install


# Default targets
default : $(target_lib) 
	
bin : $(target_lib) $(target_bin)
	@echo "make $@ successfully"

lib libs : $(target_lib)
	@echo "make $@ successfully"

# Make the specific module only.
$(MODULE) : $(target_lib)

# Make the depend files only.
depand : $(dep)

# Make the install head files.
install : $(target_header) $(header)
	@echo $(MODULE) install successfully

# Make the test target of the module.
test : $(test_target_bin)
	@echo "make $@ module : \"$(MODULE)\" successfully!"

# Clean all of the object files.
clean :
	@rm -rf $(obj_dir)
	@rm -rf $(dep_dir)
	@rm -rf $(elf_dir)
	@echo remove directory: $(obj_dir) $(dep_dir) $(elf_dir)

# Clean all of the object files and depend files and test object files.
cleanall : clean
	@rm -rf $(project_dir)/build
	@echo remove directory: $(project_dir)/build

help :
	@echo "Usage: make [target]"
	@echo "Make target of this project. The [target] is optional. When"
	@echo "the target is absent, the default target is to make bin target with release version"
	@echo "target:"
	@echo "	libs/lib	Make target libary. The library is locate $(abspath $(tarlib_dir))"
	@echo ""
	@echo "	bin		Make target excute binary files (include ELF format and Binary format)"
	@echo "				The target binay is locate $(abspath $(tarbin_dir))"
	@echo ""
	@echo "	debug		Make default target, but with debug flag on" 
	@echo ""
	@echo "	clean		Clean the object files"
	@echo ""
	@echo "	cleanall	Clean the object files and depend files"
	@echo ""
	@echo "	test		Make all of the tests of modules"
	@echo ""
	@echo "	install		Make install the static libary, dynamic libary, include"
	@echo "	       			files, binary files"
	@echo "	module_name	Module_name is one of the follow string:"
	@echo "	           		\"$(all_modules)\", "
	@echo "	           		which to make a sigle moudle"
	@echo ""
	@echo "	help		show this page"

#----------------------------------------------------------------------------
# The actual target rules.
#----------------------------------------------------------------------------

# Make the libary only.
$(target_lib) : $(dep) $(obj)
	@mkdir -p $(dir $@)
	$(AR) rcs $@ $(obj)
	@echo "Update $@"

# Install the header files.
$(target_header) : $(header)
	install -d $(tarhdr_dir)
	install  -p $(header) -t $(tarhdr_dir)
	@echo "Headers: $^ \nInstall to directory: $(tarhdr_dir)"

$(target_elf) : $(all_objs)
	@mkdir -p $(dir $@)
	$(LD) -Wl,--Map -Wl,$(target_map) $(LDFLAGS) $(LDSCRIPTS) $(all_objs) $(DEP_LIBS) -o $@

$(target_bin) : $(target_elf)
	@mkdir -p $(dir $@)
	$(OBJCOPY) -O binary $^ $@

$(test_target_elf) : $(test_dep) $(target_lib) $(test_obj)
	@mkdir -p $(dir $@)
	$(LD) $(LDFLAGS) $(LDSCRIPTS) $(test_obj) $(target_lib) $(DEP_LIBS) -o $@

$(test_target_bin) : $(test_target_elf)
	@mkdir -p $(dir $@)
	$(OBJCOPY) -O binary $^ $@

# Pattern rule of depend files rule.
# "Sed" is the patch for cygwin environment, not nessary in linux
$(dep_dir)/$(MODULE)/%.d : %.c
	@mkdir -p $(dir $@)
	@set -e; \
		$(CC) -MM -MF $@ -E $< -MT $(@:%.d=%.o) -MT $@ $(CFLAGS); \
		sed -i 's,\\\([^$$]\),/\1,g;s,\([^.]d\|.[^d]\):/svn,$(svn_root),g' $@

# Pattern rule of object files.
$(obj_dir)/$(MODULE)/%.o : %.c $(dep_dir)/$(MODULE)/%.d
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<

# include the depend files.
ifneq (,$(filter-out clean cleanall help, $(MAKECMDGOALS)))
-include $(dep)
endif
