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
    mxmlc -compiler.source-path=./src -static-link-runtime-shared-libraries=true $debug $verbose ./src/io/rollbar/notifier/Test.as -output build/swf/test.swf
elif [ "$target" = "swc" ]
then
    echo 'Building Rollbar SWC into build/swc/Rollbar.swc'
    compc -include-sources ./src -output build/swc/Rollbar.swc
else
    echo 'Building Notifier SWF into build/swf/RollbarNotifier.swf'
    mxmlc -compiler.source-path=./src -static-link-runtime-shared-libraries=true $debug $verbose ./src/io/rollbar/notifier/RollbarNotifier.as -output build/swf/RollbarNotifer.swf
fi

echo 'Done'
