#!/bin/bash

docker_service() {
#checking docker service
PID=$(cat /var/run/docker.pid)
if [ -s /var/run/docker.pid -a "$PID" -eq "$(/usr/bin/pgrep dockerd)" ] 
then
        echo "- docker service: OK"
else
        echo "- docker service: FAIL"
        exit 1	
fi
}

ping_test() {
#ping test before pulling docker image
echo -e "8.8.8.8\n8.8.4.4" >> /tmp/dns_list.txt
while read server
do
        /bin/ping -c2 $server 2>&1 > /dev/null
        if [ $? -ne 0 ]
        then
                echo "- ping test to $server:  FAIL"
                exit 1
        fi
done < /tmp/dns_list.txt
echo "- ping test: OK"
}

pull_image() {
#pulling docker image
docker pull mcharanrm/infinite-loop:lite 2>&1 > /dev/null
IMAGE=$(docker images mcharanrm/infinite-loop:lite --quiet)
if [ -z "$IMAGE" ]
then
        echo "- pulling image: FAIL"
        exit 1
else
        echo "- pulling image: OK"
fi
}

start_container() {
#starting a container
docker run -d --name "loop" mcharanrm/infinite-loop:lite 2>&1 > /dev/null
CONTAINER=$(docker ps --quiet --filter status=running --filter name=loop)
if [ -z "$CONTAINER" ]
then
        echo "- starting container: FAIL"
        exit 1
else
        echo "- starting container: OK"
fi
}

function_main() {
        docker_service
        ping_test
        pull_image
        start_container
}
function_main
