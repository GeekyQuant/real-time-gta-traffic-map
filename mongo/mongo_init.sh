#!/bin/sh


mongo localhost:27017/${MONGO_ADMIN} <<-EOF
db.createUser(
    {
        user: "${MONGO_ADMIN}",
        pwd: "${MONGO_ADMIN}",
        roles: [
            {
                role: "userAdminAnyDatabase",
                db: "${MONGO_ADMIN}"
            },
            "readWriteAnyDatabase"
        ]
    }
);
EOF

mongo -u ${MONGO_ADMIN} -p ${MONGO_ADMIN} localhost:27017/${MONGO_ADMIN} <<-EOF
db.createUser(
    {
        user: "${MONGO_USER}",
        pwd: "${MONGO_USER}",
        roles: [
            {
                role: "readWrite",
                db: "traffic_db"
            }
        ]
    }
);
EOF