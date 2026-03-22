ARTIFACT_DIR = build/.artifacts

ANDROID_HOME ?= $(HOME)/Android/Sdk
D8 ?= $(shell command -v d8 2>/dev/null)
ifeq ($(D8),)
D8 := $(shell ls -1d "$(ANDROID_HOME)"/build-tools/* 2>/dev/null | sort -V | tail -n1)/d8
endif

PREFIX ?= $(HOME)/.local
DATA_DIR = $(PREFIX)/share/phone
BIN_DIR = $(PREFIX)/bin
BASH_COMP_DIR = $(PREFIX)/share/bash-completion/completions
ZSH_COMP_DIR = $(PREFIX)/share/zsh/site-functions

all: check-tools $(ARTIFACT_DIR)/classes.dex

check-tools:
	@test -x "$(D8)" || (echo "d8 not found. Set D8=/path/to/d8 or ANDROID_HOME=/path/to/Sdk"; exit 1)

$(ARTIFACT_DIR)/classes.dex: src/java/SetNetworkModePoll.java
	mkdir -p $(ARTIFACT_DIR)
	javac -d $(ARTIFACT_DIR) -source 8 -target 8 $<
	$(D8) --output $(ARTIFACT_DIR) $(ARTIFACT_DIR)/SetNetworkModePoll.class

install: all
	mkdir -p $(BIN_DIR)
	install -Dm 755 src/shell/phone.sh $(DATA_DIR)/phone.sh
	install -Dm 755 src/shell/refresh.sh $(DATA_DIR)/refresh.sh
	install -Dm 755 src/shell/usb.sh $(DATA_DIR)/usb.sh
	install -Dm 755 src/shell/hotspot.sh $(DATA_DIR)/hotspot.sh
	install -Dm 644 $(ARTIFACT_DIR)/classes.dex $(DATA_DIR)/classes.dex
	ln -sf $(abspath $(DATA_DIR)/phone.sh) $(BIN_DIR)/phone
	install -Dm 644 completions/bash/phone $(BASH_COMP_DIR)/phone
	install -Dm 644 completions/zsh/_phone $(ZSH_COMP_DIR)/_phone

uninstall:
	rm -f $(BIN_DIR)/phone
	rm -f $(BASH_COMP_DIR)/phone
	rm -f $(ZSH_COMP_DIR)/_phone
	rm -rf $(DATA_DIR)

clean:
	rm -rf build

.PHONY: all check-tools install uninstall clean
