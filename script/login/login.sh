#!/bin/bash

IPARRAY=(44)
ADDRESS="NULL"
path=$(dirname $(readlink -f $0))

for i in ${IPARRAY}
do
    if [ $i = $1 ]; then
        ADDRESS="真实IP"
        break
    fi
done

if [ ${ADDRESS} = "NULL" ]; then
    ADDRESS="其他IP"
fi

# ${path}/login.exp ${ADDRESS}

expect -c "
set timeout 3
spawn ssh -X ${ADDRESS}
expect {
    \"*password:\" { send \" 密码\\r\" }\
    \".*continue.\*\?\" { send \"yes\\r\" send \" 密码\\r\" }
}
interact
"