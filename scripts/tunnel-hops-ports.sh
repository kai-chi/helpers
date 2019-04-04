 #!/bin/bash

returnPortMapping () {
    line=$(printf -- '%s\n' "$2" | grep "$1")
    echo $line | awk '{split($0,a," "); print a[3]}'
}

help () {
    echo " Usage:"
    echo ""
    echo " ./tunnel-hops-ports.sh [options]"
    echo ""
    echo " -p|--ports <value> CSV list of ports to tunnel."
    echo " -h|--host  <value> Remore machine you want to "
    echo "                    create the tunnel with."
    echo " -d|--dir   <value> Location on the remote machine"
    echo "                    where the run.sh script can be found."
    echo " -k|--kill          If set kill all the existing background"
    echo "                    tunnels before establishing new ones."
    echo " --kill-only        Like --kill but after killing the tunnels"
    echo "                    exits the script immediately."
    echo " --help             This window."
    echo ""
    echo " Ports:"
    echo ""
    echo "  3306 - mysql server"
    echo "  4848 - payara server"
    echo "  8181 - https hopsworks UI"
    echo ""
    echo "Author: Kajetan Maliszewski <kajetan.maliszewski@gmail.com>"
    echo ""
    exit 1
}

PORTS='8181,4848,3306'
HOST=bbc2
DIR=/home/kaichi/karamel-chef
KILL=NO
KILL_ONLY=NO

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
    --kill-only)
    KILL_ONLY=YES
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
   
if [ $KILL = "YES" ]; then
    echo "Killing all the existing background tunnels"
    pkill -f 'ssh -N'
    if [ $KILL_ONLY = "YES" ]; then
        exit 1
    fi
fi

echo "Tunnel ports: ${PORTS[*]}"
echo "With the machine: $HOST"
echo "karamel-chef directory: $DIR"

resp=$(ssh "$HOST" "cd $DIR; ./run.sh ports")
resp=${resp}

IFS=',' read -ra PORTS_ARR <<< "$PORTS"
for port in "${PORTS_ARR[@]}"; do
    remote_port=$(returnPortMapping $port "${resp[@]}")
    ssh -N -f -L $port:localhost:$remote_port $HOST
done
