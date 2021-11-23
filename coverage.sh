#! sh

# Install:
#  - Place this file next to the Package.swift in your project
#  - Open a terminal and cd to the project directory
#  - Run: brew install lcov
#  - Run: chmod +x coverage.sh
#
# Usage:
#  Run: ./coverage.sh
#  Command click the HTML output path to open the coverage report in your browser
#

# Precondition
if ! command -v genhtml &> /dev/null
then
    echo "Error genhtml not found. Run 'brew install lcov'" >&2
    exit -1
fi

CONFIGURATION="debug"
COVERAGE_BUILD_PATH=".build/coverage-build"

# Assuming one package..
PACKAGE_NAME=`swift package describe | grep "Name: " | grep -v "Tests" | awk '{print $2}' | head -n 1`

CODECOV_PROFDATA_PATH="$COVERAGE_BUILD_PATH/$CONFIGURATION/codecov/default.profdata"
PACKAGE_TESTS_PATH="$COVERAGE_BUILD_PATH/$CONFIGURATION/${PACKAGE_NAME}PackageTests.xctest/Contents/MacOS/${PACKAGE_NAME}PackageTests"

COVERAGE_OUTPUT_PATH=".build/coverage"
LCOV_INFO_PATH="$COVERAGE_OUTPUT_PATH/lcov.info"

XCODE_PATH=`xcode-select -p`
LLVMCOV_PATH="$XCODE_PATH/Toolchains/XcodeDefault.xctoolchain/usr/bin/llvm-cov"

# Clean
rm -r $COVERAGE_BUILD_PATH $COVERAGE_OUTPUT_PATH 2>/dev/null
swift package clean

# Test
swift test --enable-code-coverage -c $CONFIGURATION --build-path $COVERAGE_BUILD_PATH

# Build coverage report
mkdir -p $COVERAGE_OUTPUT_PATH
$LLVMCOV_PATH export -format=lcov -instr-profile=$CODECOV_PROFDATA_PATH $PACKAGE_TESTS_PATH > $LCOV_INFO_PATH

genhtml $LCOV_INFO_PATH --output-directory $COVERAGE_OUTPUT_PATH

echo "HTML output: $COVERAGE_OUTPUT_PATH/index.html"
# open "$COVERAGE_OUTPUT_PATH/index.html"
