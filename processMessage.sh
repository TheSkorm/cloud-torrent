#!/bin/bash
cd $2
transmission-cli -f /root/done.sh -w . -u 0.1 -ep "$1"
