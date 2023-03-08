#!/bin/bash

_APISERVER=127.0.0.1:10000
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

sum_data() {
    local DATA="$1"
    local PREFIX="$2"
    local SUM_UP=0
    local SUM_DOWN=0
    while read -r line; do
        if [[ $line == ${PREFIX}* ]]; then
            local VALUE=$(echo $line | awk '{print $2}')
            if [[ $line == *->up* ]]; then
                SUM_UP=$(($SUM_UP + $VALUE))
            elif [[ $line == *->down* ]]; then
                SUM_DOWN=$(($SUM_DOWN + $VALUE))
            fi
        fi
    done <<< "$DATA"
    local SUM_TOTAL=$(($SUM_UP + $SUM_DOWN))
    echo -e "$DATA" | grep "^${PREFIX}" | sort -r | awk -v up="$SUM_UP" -v down="$SUM_DOWN" -v total="$SUM_TOTAL" '
        BEGIN{
            printf "SUM->up:\t%s\nSUM->down:\t%s\nSUM->TOTAL:\t%s\n", up, down, total;
        }{print}'
}

DATA=$(apidata $1)
echo "------------Inbound----------"
sum_data "$DATA" "inbound"
echo "-----------------------------"
echo "------------Outbound----------"
sum_data "$DATA" "outbound"
echo "-----------------------------"
echo
echo "-------------User------------"
sum_data "$DATA" "user"
echo "-----------------------------"
