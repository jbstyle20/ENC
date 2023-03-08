#!/bin/bash

_APISERVER=127.0.0.1:10085
_XRAY=/usr/bin/xray/xray

apidata () {
    local ARGS=
    if [[ $1 == "reset" ]]; then
      ARGS="reset: true"
    fi
    $_XRAY api statsquery --server=$_APISERVER "${ARGS}" \
    | awk '{
        if (match($1, /"name":/)) {
            f=1; gsub(/^"|link"|,$/, "", $2);
            split($2, p,  ">>>");
            printf "%s:%s->%s\t", p[1],p[2],p[4];
        }
        else if (match($1, /"value":/) && f){
          f = 0;
          gsub(/"/, "", $2);
          printf "%.0f\n", $2;
        }
        else if (match($0, /}/) && f) { f = 0; print 0; }
    }'
}

print_connections() {
    local DATA="$1"
    local PREFIX="$2"
    local SORTED=$(echo "$DATA" | grep "^${PREFIX}" | sort -r)
    echo "$SORTED" | while read line; do
        USER=$(echo "$line" | awk -F ':' '{print $1}')
        CONN=$(echo "$line" | awk '{print $2}')
        printf "%s has %s connections\n" "$USER" "$CONN"
    done
}

DATA=$(apidata $1)
echo "-----------Connections--------"
print_connections "$DATA" "user"
echo "-----------------------------"
