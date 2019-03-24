#!/usr/bin/env bash

set -e

source $HOME/.bashrc

echo -e "y\n2.0.0\nUbuntuMono\n\n0\n\n\n\n" | pearl install test

[ -d $PEARL_HOME/packages/default/test ] || { echo "Error: The package test does not exist after installing it."; exit 1; }

cat $HOME/.Xdefaults
cat $HOME/.Xresources

echo -e "y\n2.0.0\nUbuntuMono\n\n0\n\n\n\n" | pearl update test

pearl remove test

if [[ -f $HOME/.Xdefaults ]]
then
    echo "ERROR: Xdefaults does still exist after removal."
    exit 11
else
    echo "Xdefaults does not exist after removal"
fi

if [[ -f $HOME/.Xresources ]]
then
    echo "ERROR: Xresources does still exist after removal."
    exit 11
else
    echo "Xresources does not exist after removal"
fi
