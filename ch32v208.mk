SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
BUILD_DIR = objs
$(info self at: $(SELF_DIR))
$(info build dir at : $(BUILD_DIR))

######################################
# Source
######################################
# C sources
C_SOURCES +=	\
$(wildcard $(SELF_DIR)libs/Core/*.c) \
$(wildcard $(SELF_DIR)libs/Debug/*.c) \
$(wildcard $(SELF_DIR)libs/Peripheral/src/*.c) 

# c sources here
C_SOURCES += \
$(wildcard ./*.c) 

# ASM sources
ASM_SOURCES = $(SELF_DIR)libs/Startup/startup_ch32v20x_D8W.S


######################################
# Includes
######################################
# C includes
C_INCLUDES +=	\
-I"$(SELF_DIR)libs/Peripheral/inc" \
-I"$(SELF_DIR)libs/Core" \
-I"$(SELF_DIR)libs/Debug" 

# add your includes here
C_INCLUDES += \
-I"./"

# AS includes
AS_INCLUDES = -I"$(SELF_DIR)libs/Startup" 

# optimization
OPT = -Os

######################################
# Defines
######################################
# macros for gcc
C_DEFS = CH32V20x_D8W=1

# AS defines
AS_DEFS = CH32V20x_D8W=1


#######################################
# Linker
#######################################
# link script
LDSCRIPT = $(SELF_DIR)libs/Ld/Link.ld


PATH_TO_TOOLCHAIN = /mnt/c/MRStoolChain/'RISC-V Embedded GCC12'/bin/
#######################################
# Binaries
#######################################
PREFIX = $(PATH_TO_TOOLCHAIN)riscv-wch-elf-
CC = $(PREFIX)gcc
AS = $(PREFIX)gcc
CP = $(PREFIX)objcopy
AR = $(PREFIX)ar
SZ = $(PREFIX)size --format=berkeley
OD = $(PREFIX)objdump
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S
 

#######################################
# Flags
#######################################
# architecture
ARCH = -march=rv32imacxw -mabi=ilp32

# compile gcc flags
CFLAGS = $(ARCH)
CFLAGS += -msmall-data-limit=8 -msave-restore -fmax-errors=20 $(OPT)\
-fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections\
-fno-common -Wunused -Wuninitialized
CFLAGS += -g
CFLAGS += $(C_INCLUDES)
CFLAGS += -std=gnu17 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)"

ASFLAGS = $(ARCH)
ASFLAGS += -msmall-data-limit=8 -msave-restore -fmax-errors=20 $(OPT)\
-fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections\
-fno-common -Wunused -Wuninitialized
ASFLAGS += -g -x assembler-with-cpp 
ASFLAGS += $(AS_INCLUDES)
ASFLAGS += -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)"



# libraries
LIBS = -lprintf
LIBDIR =
LDFLAGS = $(ARCH)  $(LIBDIR) $(PERIFLIB_SOURCES)

LDFLAGS += -msmall-data-limit=8 -msave-restore -fmax-errors=20\
-Os -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections\
-fno-common -Wunused -Wuninitialized -g\
-T $(LDSCRIPT)\
-nostartfiles -Xlinker --gc-sections\
-Xlinker --print-memory-usage\
-Wl,-Map,$(BUILD_DIR)/$(TARGET).map\
--specs=nano.specs --specs=nosys.specs\

# default action: build all
all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin




#######################################
# Build the application
#######################################
# list of objects
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))

# list of ASM program objects
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.S=.o)))
vpath %.S $(sort $(dir $(ASM_SOURCES)))

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR) 
	@echo "CC $<"
	@$(CC) $(CFLAGS) -c -o "$@" "$<"

$(BUILD_DIR)/%.o: %.S Makefile | $(BUILD_DIR)
	@echo "AS $<"
	@$(AS) $(ASFLAGS) -c -o "$@" "$<"

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) Makefile
	@echo "LD $@"
	@$(CC) $(LDFLAGS) -o $@ $(OBJECTS) $(LIBS)
	@echo "OD $@"
	@$(OD) --all-headers --demangle --disassemble -M xw $(BUILD_DIR)/$(TARGET).elf > $(BUILD_DIR)/$(TARGET).lst 
	@echo "SZ $@"
	@$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(HEX) $< $@
	
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(BIN) $< $@	
	
$(BUILD_DIR):
	mkdir -p $@

#######################################
# Clean up
#######################################

clean:
	-rm -fR .dep $(BUILD_DIR)

clangd :
	make clean
	touch .clangd
	echo "CompileFlags:" > .clangd
	echo "  Remove: [-march=*, -mabi=*, -mcpu=*]" >> .clangd
	bear -- make build

clangd_clean :
	rm -f compile_commands.json
	rm -rf .cache

build: $(BUILD_DIR)/$(TARGET).bin
