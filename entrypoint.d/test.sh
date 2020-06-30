#!/bin/sh

set -eu

## Variables
: "${TESTVAR:="not set"}"  # Test  

echo ">> Test: ${TESTVAR}"
