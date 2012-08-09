#! /bin/sh

mxmlc -compiler.source-path=./src -static-link-runtime-shared-libraries=true ./src/com/ratchet/json/JSON.as -output build/JSON.swf
mxmlc -compiler.source-path=./src -static-link-runtime-shared-libraries=true ./src/com/ratchet/notifier/RatchetNotifier.as -output build/RatchetNotifer.swf
