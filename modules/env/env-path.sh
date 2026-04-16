#!/bin/bash

prepend_path_if_dir() {
	if [[ -d "$1" && ":$PATH:" != *":$1:"* ]]; then
		PATH="$1:$PATH"
	fi
}

append_path_if_dir() {
	if [[ -d "$1" && ":$PATH:" != *":$1:"* ]]; then
		PATH="$PATH:$1"
	fi
}

prepend_path_if_dir "$HOME/.install/nvim-linux-x86_64/bin"
append_path_if_dir "$HOME/.local/bin"
append_path_if_dir "$HOME/.local/npm/bin"
append_path_if_dir "/usr/local/go/bin"
append_path_if_dir "/opt/wine64/bin"
append_path_if_dir "/opt/arm-soft-linux-gnueabi/bin"
append_path_if_dir "$HOME/esp/tool_chain/esp8266/xtensa-lx106-elf/bin"

if [[ -d "/usr/local/jdk1.8.0_144" ]]; then
	export JAVA_HOME="/usr/local/jdk1.8.0_144"
	export JRE_HOME="$JAVA_HOME/jre"
	export CLASSPATH=".:$JAVA_HOME/lib:$JRE_HOME/lib"
fi

if [[ -d "$HOME/esp/esp8266/ESP8266_RTOS_SDK" ]]; then
	export IDF_PATH="$HOME/esp/esp8266/ESP8266_RTOS_SDK"
fi

if [[ -d "/usr/lib/jni" ]]; then
	export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}/usr/lib/jni"
fi

if [[ -d "/usr/local/bin/openssl" ]]; then
	export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}/usr/local/bin/openssl"
fi

if [[ -d "/usr/local/lib" ]]; then
	export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}/usr/local/lib"
fi
