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

if [ "$target" = "swf" ]
then
    echo 'Building Test SWF into build/swf/test.swf'
    mxmlc -compiler.source-path=./src -static-link-runtime-shared-libraries=true $debug $verbose ./src/com/rollbar/notifier/Test.as -output build/swf/test.swf
elif [ "$target" = "swc" ]
then
    echo 'Building Rollbar SWC into build/swc/Rollbar.swc'
    compc -include-sources ./src/com/rollbar/json -include-sources ./src/com/rollbar/notifier -include-sources ./src/com/rollbar/stacktrace -output build/swc/Rollbar.swc
elif [ "$target" = "test" ]
then
    echo 'Building test suite into build/swf/testsuite.swf'
    mxmlc -compiler.source-path=./src -static-link-runtime-shared-libraries=true -debug=true -compiler.verbose-stacktraces=true -include-libraries=./libs/flexunit-4.1.0-8-as3_4.1.0.16076.swc ./src/com/rollbar/tests/TestRunner.as -output build/swf/testsuite.swf
    ret_code=$?
    if [ $ret_code == 0 ]; then
        expect -c "spawn fdb build/swf/testsuite.swf; send -- continue\r; expect eof;"
    else
        echo 'Aborting test suite due to build failure'
    fi
else
    echo 'Building Notifier SWF into build/swf/RollbarNotifier.swf'
    mxmlc -compiler.source-path=./src -static-link-runtime-shared-libraries=true $debug $verbose ./src/com/rollbar/notifier/RollbarNotifier.as -output build/swf/RollbarNotifer.swf
fi

echo 'Done'
