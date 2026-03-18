JAVA_SRC = refresh/SetNetworkModePoll.java
DEX_OUT = build/share/phone/classes.dex
JAVA_OUT = build/share/phone

PREFIX ?= $(HOME)/.local
DATA_DIR = $(PREFIX)/share/phone
BIN_DIR = $(PREFIX)/bin

all: $(DEX_OUT)

$(DEX_OUT): $(JAVA_SRC)
	mkdir -p $(JAVA_OUT)
	javac -d $(JAVA_OUT) -source 8 -target 8 $<
	$(ANDROID_HOME)/build-tools/36.0.0/d8 --output $(JAVA_OUT) $(JAVA_OUT)/SetNetworkModePoll.class

dev: all
	./phone.sh refresh

install: all
	install -Dm 755 refresh/phone-refresh.sh $(DATA_DIR)/phone-refresh.sh
	install -Dm 644 $(DEX_OUT) $(DATA_DIR)/classes.dex
	install -Dm 755 phone.sh $(DATA_DIR)/phone.sh
	ln -sf $(DATA_DIR)/phone.sh $(BIN_DIR)/phone

uninstall:
	rm -f $(BIN_DIR)/phone
	rm -rf $(DATA_DIR)

clean:
	rm -rf build/share/phone

.PHONY: all dev install uninstall clean
