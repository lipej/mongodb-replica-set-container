#!/bin/bash

MACHINEDNS=MYMACHINENAME.local  #put yout machine local network DNS  EX: MACHINENAME.local

echo "**********************************************" ${MACHINEDNS}
echo "Waiting for startup.."
until curl http://${MACHINEDNS}:27017/serverStatus\?text\=1 2>&1 | grep uptime | head -1; do
  printf '.'
  sleep 1
done

echo SETUP.sh time now: `date +"%T" `
mongo --host ${MACHINEDNS}:27017 <<EOF
var cfg = {
    "_id": "rs0",
    "protocolVersion": 1,
    "version": 1,
    "members": [
        {
            "_id": 0,
            "host": "${MACHINEDNS}:27017",
            "priority": 2
        },
        {
            "_id": 1,
            "host": "${MACHINEDNS}:27018",
            "priority": 0
        },
        {
            "_id": 2,
            "host": "${MACHINEDNS}:27019",
            "priority": 0
        }
    ],settings: {chainingAllowed: true}
};
rs.initiate(cfg, { force: true });
rs.reconfig(cfg, { force: true });
rs.slaveOk();
db.getMongo().setReadPref('nearest');
db.getMongo().setSlaveOk(); 
EOF