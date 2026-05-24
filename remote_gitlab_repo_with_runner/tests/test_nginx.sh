#!/bin/bash
set -e

scp -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no nginx/default.conf $DEPLOY_USER@$DEPLOY_HOST:/tmp/test-server.conf

echo "Testing nginx config"
ssh $DEPLOY_USER@$DEPLOY_HOST "bash -c '
    cat > /tmp/test-full.conf << EOF
events { worker_connections 1024; }
pid /tmp/nginx-test.pid;
error_log /dev/null;
http {
    access_log off;
    include /tmp/test-server.conf;
}
EOF
    nginx -t -c /tmp/test-full.conf 

    if [ \$? -eq 0 ]; then
        echo \"Syntax OK\"
    else
        echo \"Syntax FAILED\"
    fi

    rm -f /tmp/test-full.conf /tmp/nginx-test.pid /tmp/test-server.conf
'"