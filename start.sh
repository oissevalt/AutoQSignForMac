SKIP_DELAY=0
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -s | --skip-delay)
            SKIP_DELAY=1
            ;;
        *)
            echo "unknown arg $1"
            exit 1
            ;;
    esac
    shift
done


jq=$(readlink -f "./bin/jq-osx-amd64")
if [[ ! -x $jq ]]; then
    chmod +x "$jq"
fi
if [[ $(which jq) ]]; then
    jq=$(which jq)
fi

jre=$(readlink -f "./jre")
if [[ $(which java) ]]; then
    jre="" # provide empty string for qsign to use installed java
fi

TXLIB_VER=${TXLIB_VER:-'8.9.63'}
TXLIB_VER_FILE=".txlib_version"
QSIGN_CFG_FILE="./txlib/$TXLIB_VER/config.json"

QSIGN_HOST=""
QSIGN_PORT=""
QSIGN_KEY=""

echo "AutoQSignForMac v1.1.1 by 檀轶步棋"

if [[ -f $TXLIB_VER_FILE ]]; then
    TXLIB_VER=$(cat $TXLIB_VER_FILE)
    echo "Using previous txlib version $TXLIB_VER."

    QSIGN_CFG_FILE="./txlib/$TXLIB_VER/config.json"
    if [[ ! -f $QSIGN_CFG_FILE ]]; then
        echo "QSign configuration file for txlib $TXLIB_VER does not exist."
        exit 1
    fi

    QSIGN_HOST=$($jq -r ".server.host" $QSIGN_CFG_FILE)
    QSIGN_PORT=$($jq -r ".server.port" $QSIGN_CFG_FILE)
    QSIGN_KEY=$($jq -r ".key" $QSIGN_CFG_FILE)
else
    echo -n "Select a txlib version: "; ls txlib
    read -r -p "txlib version (default:$TXLIB_VER) > " TXLIB_READ
    if [[ -n $TXLIB_READ ]]; then
        TXLIB_VER=$TXLIB_READ
        QSIGN_CFG_FILE="./txlib/$TXLIB_VER/config.json"
        if [[ ! -f $QSIGN_CFG_FILE ]]; then
            echo "QSign configuration file for txlib $TXLIB_VER does not exist."
            exit 1
        fi
    fi

    read -r -p "Enter QSign host (default:localhost) > " QSIGN_HOST
    if [[ -z $QSIGN_HOST ]]; then QSIGN_HOST="localhost"; fi
    read -r -p "Enter QSign port (default:13579) > " QSIGN_PORT
    if [[ -z $QSIGN_PORT ]]; then QSIGN_PORT="13579"; fi
    read -r -p "Enter QSign API key (default: randomly genarated) > " QSIGN_KEY
    if [[ -z $QSIGN_KEY ]]; then QSIGN_KEY=$RANDOM; fi

    cp "$QSIGN_CFG_FILE" "$QSIGN_CFG_FILE.bak"
    $jq \
        ". + { \"server\":{ \"host\":\"$QSIGN_HOST\", \"port\": ${QSIGN_PORT} }, \"key\":\"$QSIGN_KEY\", \"auto_register\":true }" \
        "$QSIGN_CFG_FILE.bak" > "$QSIGN_CFG_FILE"
    echo "$TXLIB_VER" > "$TXLIB_VER_FILE"
fi

export jq="$jq" JAVA_HOME="$jre"

if [[ $SKIP_DELAY -eq 0 ]]; then
    echo "After 5 seconds QSign will start on http://$QSIGN_HOST:$QSIGN_PORT ..."
    sleep 5
fi

bin/unidbg-fetch-qsign --basePath="txlib/$TXLIB_VER"
