#!/bin/bash

set -e

NODE_ADDRESS="localhost"
WS_RPC_PORT="9944"
TIMEOUT=1

print_usage() {
    echo "Usage: $0 [OPTIONS] <JSON-RPC-METHOD> [PARAMS...]"
    echo
    echo "Options:"
    echo "  -a, --address ADDRESS   Set the node address (default: localhost)"
    echo "  -p, --port PORT         Set the WebSocket RPC port (default: 9944)"
    echo "  -t, --timeout SECONDS   Set the timeout in seconds (default: 1)"
    echo "  -f, --file FILE         Read JSON-RPC payload from a file"
    echo "  -i, --stdin             Read JSON-RPC payload from stdin"
    echo "  -h, --help              Display this help message"
    echo
    echo "Examples:"
    echo "  $0 system_name"
    echo "  $0 -a 192.168.1.100 -p 9933 author_insertKey \"aura\" \"seed_key\" \"pub_key\""
    echo "  $0 -f payload.json"
    echo "  echo '{\"method\": \"system_name\", \"params\": []}' | $0 -i"
}


if [[ $# -eq 0 ]]; then
    echo "Error: No method specified. Use -h for help."
    print_usage
    exit 1
fi

# Parse command-line options
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--address)
            NODE_ADDRESS="$2"
            shift 2
            ;;
        -p|--port)
            WS_RPC_PORT="$2"
            shift 2
            ;;
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        -f|--file)
            PAYLOAD_FILE="$2"
            shift 2
            ;;
        -i|--stdin)
            READ_FROM_STDIN=true
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

if ! command -v wscat &> /dev/null; then
    echo "Error: wscat is not installed. Please install it using 'npm install -g wscat'."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install it using your package manager."
    exit 1
fi

if [[ -n "$PAYLOAD_FILE" ]]; then
    PAYLOAD=$(cat "$PAYLOAD_FILE")
elif [[ "$READ_FROM_STDIN" = true ]]; then
    PAYLOAD=$(cat)
else
    METHOD="$1"
    shift
    PARAMS="$@"
    PAYLOAD=$(jq -n \
                  --arg method "$METHOD" \
                  --argjson params "[$PARAMS]" \
                  '{jsonrpc: "2.0", id: 1, $method, $params}')
fi

wscat --connect "ws://${NODE_ADDRESS}:${WS_RPC_PORT}" -w "$TIMEOUT" -x "$PAYLOAD"
