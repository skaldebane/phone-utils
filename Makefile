DEX = src/out/classes.dex
JAVA = src/SetNetworkModePoll.java
SDK ?= $(ANDROID_HOME)

all: $(DEX)

$(DEX): $(JAVA)
	mkdir -p src/out
	javac -d src/out -source 8 -target 8 $(JAVA)
	$(SDK)/build-tools/36.0.0/d8 --output src/out/ src/out/SetNetworkModePoll.class

clean:
	rm -rf src/out/

.PHONY: all clean
