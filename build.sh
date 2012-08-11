#! /bin/sh

# Notifier SWF
echo 'Building Notifier SWF'
#mxmlc -compiler.source-path=./src -static-link-runtime-shared-libraries=true ./src/com/ratchet/notifier/RatchetNotifier.as -output build/swf/RatchetNotifer.swf

# Ratchet SWC
echo
echo 'Building Ratchet SWC'
#compc -include-sources ./src -output build/swc/Ratchet.swc

# Test SWF
echo
echo 'Building Test SWF'
mxmlc -compiler.source-path=./src -static-link-runtime-shared-libraries=true ./src/com/ratchet/notifier/Test.as -debug -output build/swf/test.swf

echo
echo 'Done'
