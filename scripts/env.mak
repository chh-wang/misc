#! env.mak

ifndef project_dir
$(error "Unknow project root directory")
else
svn_root = $(project_dir)/../../..
endif

DATE:=$(shell date +%Y%m%d)
TARGET:= kmp

# The switch of build debug version.
DEBUG_ON ?= n

# The build libary name
TAR_LIB := kmp

# Software version
SW_VER	:= 0.0.0.1

# The depend pal version


# The depend libaries.
# DO NOT PUT libc.a before libpthrea.a, there is a bug of this situation.

# The header files search path.
INCLUDE_PATH	+= ./include 

# Some tools need absolute path to parse the directory
# Note: Current Cygwin compiler not support absolute path
# INCLUDE_PATH 	:= $(abspath $(INCLUDE_PATH))

# The libary files search path.
DEP_LIBS_PATH	+= $(project_dir)/lib

LD_SCRIPT_NAME 	:=  

CFLAGS          := -w $(addprefix -I, $(INCLUDE_PATH))
ifeq ($(DEBUG_ON), y)
# CAMSDK use macro DEBUG, not recommend in high level. Recommend to use _DEBUG
CFLAGS 			+= -g 
else
CFLAGS 			+= -O2
endif
CFLAGS 			+= -D_SWVERSION=\"$(SW_VER)\"

# The rootfs do not have dynamic libary, so target link with static libary.
LDFLAGS			:= 

# The prefix of cross compiler.
CROSS_COMPILE   := 

# Environment variables. Do not modify.
CC              := $(CROSS_COMPILE)gcc
LD              := $(CROSS_COMPILE)gcc
AR              := $(CROSS_COMPILE)ar
OBJCOPY			:= $(CROSS_COMPILE)objcopy

# Build directories, Do not modify unless you modify the directory structure 
ifeq ($(strip $(DEBUG_ON)),y)
build_dir 		:= $(project_dir)/build/debug
else
build_dir 		:= $(project_dir)/build/release
endif
obj_dir			:= $(build_dir)/objs
dep_dir			:= $(build_dir)/deps
tarbin_dir		:= $(build_dir)/bin
tarelf_dir		:= $(build_dir)/elf
tarlib_dir	 	:= $(build_dir)/lib
tarhdr_dir		:= $(build_dir)/include

