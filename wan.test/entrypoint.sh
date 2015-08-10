#!/bin/bash -x


if [ "$pipework_wait" ]; then
	for _pipework_if in $pipework_wait; do
		echo "Waiting for pipework to bring up $_pipework_if..."
		pipework --wait -i $_pipework_if
	done
	sleep 1
fi


# do nothing forever (allows us to login to container with '$ docker exec -it want.test bash')
while true; do
	sleep 1000
done



