#!/bin/bash

if !([ "$#" -ge 1 ] && [ "$#" -le 3 ]); then
	echo "Usage: ./tester.bash [file] [host] [port]"
	exit 1
fi

ruby test.rb $1 $2 $3
