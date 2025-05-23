BIN_NAME=DaylightLeft

# Type consts
TYPECHECK_SILENT=0
TYPECHECK_GRADUAL=1
TYPECHECK_INFORMATIVE=2
TYPECHECK_STRICT=3

# Default device
DEV=fenix6pro

SDK_DIR=$(shell cat "$(HOME)/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg")
DEVELOPER_KEY=/Users/rick/Documents/keys/developer_key
TMPDIR=./bin/temp
TMP_BIN=$(TMPDIR)/$(BIN_NAME).prg

# Quotes are needed because the directory name can contain spaces
BUILD="$(SDK_DIR)/bin/monkeyc" -o $(TMP_BIN) -w -y $(DEVELOPER_KEY) -d $(DEV) -f monkey.jungle

DIR=./bin
TARGET_BIN=$(DIR)/$(BIN_NAME).prg

DEBUG_XML=$(BIN_NAME).prg.debug.xml
TMP_DBG=$(TMPDIR)/$(DEBUG_XML)
TARGET_DBG=$(DIR)/$(DEBUG_XML)

clean:
	rm -rf ./bin/

build:
	@mkdir -p $(TMPDIR)
	@$(BUILD)
	@mv $(TMP_BIN) $(TARGET_BIN)
	@mv $(TMP_DBG) $(TARGET_DBG)
	@rm -rf $(TMPDIR)

# Gradual
grad:
	@mkdir -p $(TMPDIR)
	@$(BUILD) -l $(TYPECHECK_GRADUAL)
	@mv $(TMP_BIN) $(TARGET_BIN)
	@mv $(TMP_DBG) $(TARGET_DBG)
	@rm -rf $(TMPDIR)

# Informative
inf: grad
	@mkdir -p $(TMPDIR)
	@$(BUILD) -l $(TYPECHECK_INFORMATIVE)
	@mv $(TMP_BIN) $(TARGET_BIN)
	@mv $(TMP_DBG) $(TARGET_DBG)
	@rm -rf $(TMPDIR)

# Strict
strict: inf
	@mkdir -p $(TMPDIR)
	@$(BUILD) -l $(TYPECHECK_STRICT)
	@mv $(TMP_BIN) $(TARGET_BIN)
	@mv $(TMP_DBG) $(TARGET_DBG)
	@rm -rf $(TMPDIR)
