#!/usr/bin/env bash

echo 'PEARL_PACKAGES["fonts"]={"url": "https://github.com/pearl-hub/fonts.git"}' >> $HOME/.config/pearl/pearl.conf
echo "PEARL_PACKAGES['test']={'url': '${PWD}', 'depends': ('fonts',)}" >> ~/.config/pearl/pearl.conf
