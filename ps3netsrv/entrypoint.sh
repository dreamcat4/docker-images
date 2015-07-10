#!/bin/sh


if [ "$pipework_wait" ]; then
	echo "Waiting for pipework to bring up $pipework_wait..."
	pipework --wait -i $pipework_wait
fi


echo /ps3netsrv "$@"
     /ps3netsrv "$@"

