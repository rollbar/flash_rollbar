#! /bin/sh

target="$1"
debug=
verbose=

if [ $# -gt 1 ]
then
    echo "Building with -debug"
    debug="-debug=true"
else
    debug=""
fi

if [ $# -gt 2 ]
then
    echo "Building with -compiler.verbose-stacktraces"
    verbose="-compiler.verbose-stacktraces=true"
else
    verbose=""
fi

if [ "$target" = "test" ]
then
    echo 'Building Test SWF into build/swf/test.swf'
    mxmlc -compiler.source-path=./src -static-link-runtime-shared-libraries=true $debug $verbose ./src/com/ratchet/notifier/Test.as -output build/swf/test.swf
elif [ "$target" = "swc" ]
then
    echo 'Building Ratchet SWC into build/swc/Ratchet.swc'
    compc -include-sources ./src -output build/swc/Ratchet.swc
else
    echo 'Building Notifier SWF into build/swf/RatchetNotifier.swf'
    mxmlc -compiler.source-path=./src -static-link-runtime-shared-libraries=true $debug $verbose ./src/com/ratchet/notifier/RatchetNotifier.as -output build/swf/RatchetNotifer.swf
fi

echo 'Done'
