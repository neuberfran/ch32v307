# ----------------------------------------------------------------------
#  Macros for User App
# ----------------------------------------------------------------------
USER_DIR	= .
USER_OBJS	= main.o system_ch32v30x.o
USER_SOURCES	= $(USER_OBJS:.o=.c)
USER_DEPENDS	= $(USER_OBJS:.o=.d)
APP_NAME	= gpio_toggle
ELF_FILE_NAME	= $(APP_NAME).elf
DUMP_FILE_NAME	= $(APP_NAME).lst
HEX_FILE_NAME	= $(APP_NAME).hex
MAP_FILE_NAME	= $(APP_NAME).map

# ----------------------------------------------------------------------
#  Macros for WCH common library sources
# ----------------------------------------------------------------------
WCH_DIR			= ../../../SRC
WCH_CORE_INC_DIR	= $(WCH_DIR)/Core

WCH_START_INC_DIR	= $(WCH_DIR)/Startup
WCH_START_SRC_DIR	= $(WCH_DIR)/Startup
WCH_START_OBJS		= startup_ch32v30x_D8C.o
WCH_START_SOURCES	= $(WCH_START_OBJS:.o=.s)
WCH_START_DEPENDS	= $(WCH_START_SOURCES:.s=.d)

WCH_PERI_INC_DIR	= $(WCH_DIR)/Peripheral/inc
WCH_PERI_SRC_DIR	= $(WCH_DIR)/Peripheral/src
WCH_PERI_OBJS		= \
  ch32v30x_gpio.o ch32v30x_usart.o ch32v30x_rcc.o ch32v30x_misc.o
WCH_PERI_SOURCES	= $(WCH_PERI_OBJS:.o=.c)
WCH_PERI_DEPENDS	= $(WCH_PERI_SOURCES:.c=.d)

WCH_DEBUG_INC_DIR	= $(WCH_DIR)/Debug
WCH_DEBUG_SRC_DIR	= $(WCH_DIR)/Debug
WCH_DEBUG_OBJS		= debug.o
WCH_DEBUG_SOURCES	= $(WCH_DEBUG_OBJS:.o=.c)
WCH_DEBUG_DEPENDS	= $(WCH_DEBUG_SOURCES:.c=.d)

WCH_LD_SCRIPT		= $(WCH_DIR)/Ld/Link.ld

# ----------------------------------------------------------------------
#  Macros for Common part
# ----------------------------------------------------------------------
SOURCES	= $(USER_SOURCES) $(WCH_START_SOURCES) $(WCH_PERI_SOURCES) $(WCH_DEBUG_SOURCES)
DEPENDS	= $(USER_DEPENDS) $(WCH_START_DEPENDS) $(WCH_PERI_DEPENDS) $(WCH_DEBUG_DEPENDS)
OBJS	= $(USER_OBJS)    $(WCH_START_OBJS)    $(WCH_PERI_OBJS)    $(WCH_DEBUG_OBJS)
VPATH	= $(USER_DIR)     $(WCH_START_SRC_DIR) $(WCH_PERI_SRC_DIR) $(WCH_DEBUG_SRC_DIR)
TARGETS	= $(HEX_FILE_NAME)

# ----------------------------------------------------------------------
#  Build Options
# ----------------------------------------------------------------------
TOOL_PREFIX	= riscv32-unknown-elf
TOOL_PATH	= $(HOME)/x-tools/$(TOOL_PREFIX)
TOOL_LIB	= $(TOOL_PATH)/$(TOOL_PREFIX)
CC		= $(TOOL_PREFIX)-gcc
LD		= $(CC)
OBJCOPY		= $(TOOL_PREFIX)-objcopy
OBJDUMP		= $(TOOL_PREFIX)-objdump
INCLUDES	= \
  -I $(USER_DIR) -I $(WCH_CORE_INC_DIR) -I $(WCH_PERI_INC_DIR) -I $(WCH_DEBUG_INC_DIR)
COMMON_FLAGS	= \
  -mabi=ilp32 -msmall-data-limit=8 -mno-save-restore \
  -O0 -g -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections \
  -Wunused -Wuninitialized -MMD
SFLAGS		= -march=rv32imac_zicsr $(COMMON_FLAGS)
CFLAGS		= -march=rv32imac $(COMMON_FLAGS)
LDFLAGS 	= -march=rv32imac $(COMMON_FLAGS) -T $(WCH_LD_SCRIPT) \
  -nostartfiles -Xlinker --gc-sections -Wl,-Map,$(MAP_FILE_NAME) \
  -specs=nano.specs -specs=nosys.specs

# ----------------------------------------------------------------------
#  Default Rules
# ----------------------------------------------------------------------
.s.o:
	$(CC) $(SFLAGS) $(INCLUDES) -o $@ -c $<

.c.o:
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ -c $<

.c.d:
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ -c $<

# ----------------------------------------------------------------------
#  Build Rules
# ----------------------------------------------------------------------
all: $(TARGETS)

$(DEPENDS) : $(SOURCES)

$(TARGETS) : $(OBJS)
	$(CC) $(LDFLAGS) -o $(ELF_FILE_NAME) $(OBJS)
	$(OBJCOPY) -O ihex $(ELF_FILE_NAME) $@
	$(OBJDUMP) --all-headers --demangle --disassemble $(ELF_FILE_NAME) > $(DUMP_FILE_NAME)

.PHONY : clean depend
clean:
	$(RM) $(TARGETS) $(OBJS) $(DEPENDS) $(ELF_FILE_NAME) $(DUMP_FILE_NAME) $(MAP_FILE_NAME) $(WCH_START_SOURCES)

-include $(DEPENDS)
