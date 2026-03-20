ARTIFACT_DIR = build/.artifacts

PREFIX ?= $(HOME)/.local
DATA_DIR = $(PREFIX)/share/phone
BIN_DIR = $(PREFIX)/bin
BASH_COMP_DIR = $(PREFIX)/share/bash-completion/completions
ZSH_COMP_DIR = $(PREFIX)/share/zsh/site-functions

all: $(ARTIFACT_DIR)/classes.dex

$(ARTIFACT_DIR)/classes.dex: refresh/SetNetworkModePoll.java
	mkdir -p $(ARTIFACT_DIR)
	javac -d $(ARTIFACT_DIR) -source 8 -target 8 $<
	$(ANDROID_HOME)/build-tools/36.0.0/d8 --output $(ARTIFACT_DIR) $(ARTIFACT_DIR)/SetNetworkModePoll.class

install: all
	mkdir -p $(BIN_DIR)
	install -Dm 755 phone.sh $(DATA_DIR)/phone.sh
	install -Dm 755 refresh/phone-refresh.sh $(DATA_DIR)/phone-refresh.sh
	install -Dm 644 $(ARTIFACT_DIR)/classes.dex $(DATA_DIR)/classes.dex
	ln -sf $(abspath $(DATA_DIR)/phone.sh) $(BIN_DIR)/phone
	install -Dm 644 completions/bash/phone $(BASH_COMP_DIR)/phone
	install -Dm 644 completions/zsh/_phone $(ZSH_COMP_DIR)/_phone

run: all
	$(MAKE) install PREFIX=build
	./build/bin/phone refresh

uninstall:
	rm -f $(BIN_DIR)/phone
	rm -f $(BASH_COMP_DIR)/phone
	rm -f $(ZSH_COMP_DIR)/_phone
	rm -rf $(DATA_DIR)

clean:
	rm -rf build

.PHONY: all install run uninstall clean
