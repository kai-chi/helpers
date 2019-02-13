#!/bin/bash

returnPortMapping () {
    line=$(printf -- '%s\n' "$2" | grep "$1")
    echo $line | awk '{split($0,a," "); print a[3]}'
}

help () {
    echo "Usage:"
    echo ""
    echo " ./tunnel-hops-ports.sh [options]"
    echo ""
    echo " -p|--ports <value> CSV list of ports to tunnel."
    echo " -h|--host  <value> Remore machine you want to "
    echo "                    create the tunnel with."
    echo " -d|--dir   <value> Location on the remote machine"
    echo "                    where the run.sh script can be found."
    echo " -k|--kill          If set kill all the existing tunnels"
    echo "                    before establishing new ones."
    echo " --help             This window.
    echo ""
    echo "Author: Kajetan Maliszewski <kajetan.maliszewski@gmail.com>"
    exit 1
}

PORTS='8080,2181,9091'
HOST=bbc2
DIR=/home/kaichi/karamel-chef
KILL=NO

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -p|--ports)
    PORTS="$2"
    shift
    shift
    ;;
    -h|--host) 
    HOST="$2"
    shift
    shift
    ;;
    -d|--dir)
    DIR="$2"
    shift
    shift
    ;;
    -k|--kill)
    KILL=YES
    shift
    ;;
    --help)
    help
    ;;
    *)

    ;;
esac
done
set -- "${POSITIONAL[@]}"
   
echo "Tunnel ports: ${PORTS[*]}"
echo "With the machine: $HOST"
echo "karamel-chef directory: $DIR"

if [ $KILL = "YES" ]; then
    echo "Killing all the existing tunnels"
    pkill -f 'ssh -N'
fi

resp=$(ssh "$HOST" "cd $DIR; ./run.sh ports")
resp=${resp}

IFS=',' read -ra PORTS_ARR <<< "$PORTS"
for port in "${PORTS_ARR[@]}"; do
    remote_port=$(returnPortMapping $port "${resp[@]}")
    ssh -N -f -L $port:localhost:$remote_port $HOST
done

