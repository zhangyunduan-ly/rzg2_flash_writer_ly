#
# Copyright (c) 2022, Renesas Electronics Corporation. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

DEVICE = RZFIVE
ifeq ("$(BOARD)", "")
BOARD = RZFIVE_SMARC
endif

ifeq ("$(BOARD)", "RZFIVE_SMARC")
#--------------------------------------
# RZ/Five Smarc board
#--------------------------------------
FILENAME_ADD = _RZFIVE_SMARC
CONNECT  = DDR_C_011_D4_01_2
SWIZZLE  = T3BCUD2
else ifeq ("$(BOARD)", "RZFIVE_13MMSQ_DEV")
#--------------------------------------
# RZ/Five 13mmSQ Dev board
#--------------------------------------
FILENAME_ADD = _RZFIVE_13MMSQ_DEV
CONNECT  = DDR_C_011_D4_01_2
SWIZZLE  = T3BCUD
else ifeq ("$(BOARD)", "RZFIVE_13MMSQ_DDR3L_DEV")
#--------------------------------------
# RZ/Five 13mmSQ DDR3L Dev board
#--------------------------------------
FILENAME_ADD = _RZFIVE_13MMSQ_DDR3L_DEV
CONNECT  = DDR_C_011_D3_01_2
SWIZZLE  = T3BCUL
else ifeq ("$(BOARD)", "RZFIVE_11MMSQ_DEV")
#--------------------------------------
# RZ/Five 11mmSQ Dev board
#--------------------------------------
FILENAME_ADD = _RZFIVE_11MMSQ_DEV
CONNECT  = DDR_C_011_D4_01_2
SWIZZLE  = T11BV
EMMC     = DISABLE
else ifeq ("$(BOARD)", "USER")
#--------------------------------------
# User board
#--------------------------------------
FILENAME_ADD = _USER
#CONNECT  = DDR_C_011_D4_01_2
#SWIZZLE  = T3BCUD2
#EMMC     = DISABLE
endif

# Select SERIAL_FLASH("ENABLE"or"DISABLE" )
ifeq ("$(SERIAL_FLASH)", "")
SERIAL_FLASH = ENABLE
endif

# Select EMMC("ENABLE"or"DISABLE" )
ifeq ("$(EMMC)", "")
EMMC = ENABLE
endif

# Select QSPI IO Voltage("1_8V"or"3_3V" )
ifeq ("$(QSPI_IOV)", "")
QSPI_IOV=1_8V
endif

# Select eMMC IO Voltage("1_8V"or"3_3V" )
ifeq ("$(EMMC_IOV)", "")
EMMC_IOV=1_8V
endif

#CPU
CPU     =
AArch   = RISCV
ALIGN   = -mstrict-align
BOOTDIR     = riscv_boot
OUTPUT_DIR  = riscv_output
OBJECT_DIR  = riscv_obj
CROSS_COMPILE ?= riscv64-unknown-linux-gnu-

CFLAGS += -O0 -fno-stack-protector -fno-exceptions -fno-unwind-tables -fno-asynchronous-unwind-tables
BOOT_DEF    = Writer
FILE_NAME   = $(OUTPUT_DIR)/Flash_Writer_SCIF$(FILENAME_ADD)

ifeq ("$(DEVICE)", "RZFIVE")
	CFLAGS += -DRZFIVE=1
endif

ifeq ("$(CONNECT)", "DDR_C_011_D4_01_1")
	CFLAGS += -DDDR_C_011_D4_01_1=1
endif
ifeq ("$(CONNECT)", "DDR_C_011_D4_01_2")
	CFLAGS += -DDDR_C_011_D4_01_2=1
endif
ifeq ("$(CONNECT)", "DDR_C_011_D4_01_3")
	CFLAGS += -DDDR_C_011_D4_01_3=1
endif
ifeq ("$(CONNECT)", "DDR_C_011_D4_01_4")
	CFLAGS += -DDDR_C_011_D4_01_4=1
endif

ifeq ("$(CONNECT)", "DDR_C_011_D3_01_2")
	CFLAGS += -DDDR_C_011_D3_01_2=1
endif
ifeq ("$(CONNECT)", "DDR_C_011_D3_01_3")
	CFLAGS += -DDDR_C_011_D3_01_3=1
endif

ifeq ("$(SWIZZLE)", "T3BCUD")
	CFLAGS += -DSWIZZLE_T3BCUD=1
endif
ifeq ("$(SWIZZLE)", "T3BCUD2")
	CFLAGS += -DSWIZZLE_T3BCUD2=1
endif
ifeq ("$(SWIZZLE)", "T11BV")
	CFLAGS += -DSWIZZLE_T11BV=1
endif
ifeq ("$(SWIZZLE)", "T3BCUL")
	CFLAGS += -DSWIZZLE_T3BCUL=1
endif

ifeq ("$(SERIAL_FLASH)", "ENABLE")
	CFLAGS += -DSERIAL_FLASH=1
endif
ifeq ("$(SERIAL_FLASH)", "DISABLE")
	CFLAGS += -DSERIAL_FLASH=0
endif

ifeq ("$(EMMC)", "ENABLE")
	CFLAGS += -DEMMC=1
endif
ifeq ("$(EMMC)", "DISABLE")
	CFLAGS += -DEMMC=0
endif

ifeq ("$(QSPI_IOV)", "1_8V")
	CFLAGS += -DQSPI_IO_1_8V=1
endif
ifeq ("$(EMMC_IOV)", "1_8V")
	CFLAGS += -DEMMC_IO_1_8V=1
endif

LINKER_FILE := memory_writer.def.s

ifeq ("$(TRUSTED_BOARD_BOOT)", "ENABLE")
	CFLAGS += -DTRUSTED_BOARD_BOOT=1
endif

MEMORY_DEF := $(LINKER_FILE:%.def.s=$(OBJECT_DIR)/%.def)

LIBS        = -L$(subst libc.a, ,$(shell $(CC) -print-file-name=libc.a 2> /dev/null)) -lc
LIBS        += -L$(subst libgcc.a, ,$(shell $(CC) -print-libgcc-file-name 2> /dev/null)) -lgcc

INCLUDE_DIR = include
DDR_COMMON = ddr/common
ifeq ("$(DEVICE)", "RZFIVE")
DDR_SOC    = ddr/five
endif
TOOL_DEF = "REWRITE_TOOL"

OUTPUT_FILE = $(FILE_NAME).axf

#Object file
OBJ_FILE_BOOT =				\
	$(OBJECT_DIR)/start.o

SRC_FILE :=				\
	main.c				\
	init_scif.c			\
	scifdrv.c			\
	devdrv.c			\
	common.c			\
	dgtable.c			\
	dgmodul1.c			\
	memory_cmd.c			\
	Message.c			\
	ramckmdl.c			\
	cpudrv.c			\
	sys/sysc.c			\
	sys/rzfive_cpg.c		\
	sys/rzfive_pfc.c		\
	sys/tzc_400.c			\
	ddrcheck.c			\
	ddr/common/ddr.c
ifeq ("$(DEVICE)", "RZFIVE")
SRC_FILE +=				\
	ddr/five/ddr_five.c
endif

ifeq ("$(SERIAL_FLASH)", "ENABLE")
SRC_FILE +=				\
	dgmodul4.c			\
	rpcqspidrv.c			\
	spiflash1drv.c
endif

ifeq ("$(EMMC)", "ENABLE")
SRC_FILE +=				\
	dg_emmc_config.c		\
	dg_emmc_access.c		\
	emmc_cmd.c			\
	emmc_init.c			\
	emmc_interrupt.c		\
	emmc_mount.c			\
	emmc_write.c			\
	emmc_erase.c			\
	emmc_utility.c
endif

OBJ_FILE := $(addprefix $(OBJECT_DIR)/,$(patsubst %.c,%.o,$(SRC_FILE)))

#Dependency File
DEPEND_FILE = $(patsubst %.lib, ,$(OBJ_FILE:%.o=%.d)) $(LINKER_FILE:.s=.d)

###################################################
#C compiler
CC = $(CROSS_COMPILE)gcc
#C++ compiler
CPP = $(CROSS_COMPILE)cpp
#Assembler
AS = $(CROSS_COMPILE)as
#Linker
LD = $(CROSS_COMPILE)ld
#Liblary
AR = $(CROSS_COMPILE)ar
#Object dump
OBJDUMP = $(CROSS_COMPILE)objdump
#Object copy
OBJCOPY = $(CROSS_COMPILE)objcopy

#clean
CL = rm -rf

###################################################
# Suffixes
.SUFFIXES : .s .c .o

###################################################
# Command

.PHONY: all
all: $(OBJECT_DIR) $(OUTPUT_DIR) $(OBJ_FILE_BOOT) $(OBJ_FILE) $(MEMORY_DEF) $(OUTPUT_FILE)

#------------------------------------------
# Make Directory
#------------------------------------------
$(OBJECT_DIR):
	-mkdir "$(OBJECT_DIR)"

$(OUTPUT_DIR):
	-mkdir "$(OUTPUT_DIR)"

#------------------------------------------
# Compile
#------------------------------------------
$(OBJECT_DIR)/%.o:$(BOOTDIR)/%.s
	$(AS)  -g $(CPU) --MD $(patsubst %.o,%.d,$@) -I $(BOOTDIR) -I $(INCLUDE_DIR) -I $(DDR_COMMON) -I $(DDR_SOC) $< -o $@ --defsym $(AArch)=0 --defsym $(BOOT_DEF)=0 --defsym $(TOOL_DEF)=0

$(OBJECT_DIR)/%.o:%.c
	@if [ ! -e `dirname $@` ]; then mkdir -p `dirname $@`; fi
	$(CC) -g -Os $(ALIGN) $(CPU) -MMD -MP -c -I $(BOOTDIR) -I $(INCLUDE_DIR) -I $(DDR_COMMON) -I $(DDR_SOC) $< -o $@ -D$(AArch) -D$(BOOT_DEF)=0 -D$(TOOL_DEF)=0 $(CFLAGS)

$(OBJECT_DIR)/%.def:%.def.s
	@if [ ! -e `dirname $@` ]; then mkdir -p `dirname $@`; fi
	$(CPP) $(CPU) $(CFLAGS) -I $(BOOTDIR) -I $(INCLUDE_DIR) -x assembler-with-cpp -MMD -MP -P $< -o $@

#------------------------------------------
# Linker
#------------------------------------------
$(OUTPUT_FILE): $(OBJ_FILE_BOOT) $(OBJ_FILE) $(MEMORY_DEF)
	$(LD) $(OBJ_FILE_BOOT) $(OBJ_FILE) 	\
	-T '$(MEMORY_DEF)'			\
	-o '$(OUTPUT_FILE)'			\
	-Map '$(FILE_NAME).map' 		\
	-static					\
	$(LIBS)

#   Make MOT file
	$(OBJCOPY) -O srec --srec-forceS3 "$(OUTPUT_FILE)" "$(FILE_NAME).mot"

#   Make Binary file
	$(OBJCOPY) -O binary "$(OUTPUT_FILE)" "$(FILE_NAME).bin"

#   Dis assemble
	$(OBJDUMP) -d -S "$(OUTPUT_FILE)" > "$(FILE_NAME)_disasm.txt"

#	Time Stamp
	@echo ==========  `date`  ==========
	@echo ========== !!! Compile Complete !!! ==========


.PHONY: clean
clean:
	$(CL)  $(OBJECT_DIR)/* $(OUTPUT_DIR)/*

-include $(DEPEND_FILE)
