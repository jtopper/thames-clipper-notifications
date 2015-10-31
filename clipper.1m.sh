#!/bin/bash

# Don't like doing this, but the profile is where I set rbenv up
. ~/.profile

SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)/`basename "${BASH_SOURCE[0]}"`

# Shenanigans to make sure we pushd to the right path before running the script

if [ -L $SCRIPT_PATH ] ; then
    PLUGIN_FOLDER=$(dirname $SCRIPT_PATH)
    CHECKOUT_FOLDER=$(dirname $(readlink $SCRIPT_PATH))
    pushd ${PLUGIN_FOLDER}/${CHECKOUT_FOLDER} 2>&1 >/dev/null
else
    CHECKOUT_FOLDER=$(dirname $SCRIPT_PATH)
    pushd $CHECKOUT_FOLDER 2>&1 >/dev/null
fi

bundle exec ./clipper.rb
