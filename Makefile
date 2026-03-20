JAVA_SRC = refresh/SetNetworkModePoll.java
ARTIFACT_DIR = build/.artifacts
DEX_OUT = $(ARTIFACT_DIR)/classes.dex
JAVA_OUT = $(ARTIFACT_DIR)

PREFIX ?= $(HOME)/.local
DATA_DIR = $(PREFIX)/share/phone
BIN_DIR = $(PREFIX)/bin
BASH_COMP_DIR = $(PREFIX)/share/bash-completion/completions
ZSH_COMP_DIR = $(PREFIX)/share/zsh/site-functions

all: $(DEX_OUT)

$(DEX_OUT): $(JAVA_SRC)
	mkdir -p $(JAVA_OUT)
	javac -d $(JAVA_OUT) -source 8 -target 8 $<
	$(ANDROID_HOME)/build-tools/36.0.0/d8 --output $(JAVA_OUT) $(JAVA_OUT)/SetNetworkModePoll.class

install: all
	mkdir -p $(BIN_DIR)
	install -Dm 755 phone.sh $(DATA_DIR)/phone.sh
	install -Dm 755 refresh/phone-refresh.sh $(DATA_DIR)/phone-refresh.sh
	install -Dm 644 $(DEX_OUT) $(DATA_DIR)/classes.dex
	ln -sf $(abspath $(DATA_DIR)/phone.sh) $(BIN_DIR)/phone
	install -Dm 644 completions/bash/phone $(BASH_COMP_DIR)/phone
	install -Dm 644 completions/zsh/_phone $(ZSH_COMP_DIR)/_phone

dev: all
	$(MAKE) install PREFIX=build
	./build/bin/phone refresh

uninstall:
	rm -f $(BIN_DIR)/phone
	rm -f $(BASH_COMP_DIR)/phone
	rm -f $(ZSH_COMP_DIR)/_phone
	rm -rf $(DATA_DIR)

clean:
	rm -rf build

.PHONY: all install dev uninstall clean
