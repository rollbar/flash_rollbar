#! /bin/sh

target=$1
if [ "$target" = "test" ]
then
    echo 'Building Test SWF into build/swf/test.swf'
    mxmlc -compiler.source-path=./src -static-link-runtime-shared-libraries=true ./src/com/ratchet/notifier/Test.as -debug -output build/swf/test.swf
elif [ "$target" = "swc" ]
then
    echo 'Building Ratchet SWC into build/swc/Ratchet.swc'
    compc -include-sources ./src -output build/swc/Ratchet.swc
else
    echo 'Building Notifier SWF into build/swf/RatchetNotifier.swf'
    mxmlc -compiler.source-path=./src -static-link-runtime-shared-libraries=true ./src/com/ratchet/notifier/RatchetNotifier.as -output build/swf/RatchetNotifer.swf
fi

echo 'Done'
