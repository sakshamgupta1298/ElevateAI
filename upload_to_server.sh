#!/bin/bash

# Script to upload ElevateAI files to DigitalOcean server
# Usage: ./upload_to_server.sh YOUR_SERVER_IP YOUR_USERNAME

if [ $# -ne 2 ]; then
    echo "Usage: $0 <server_ip> <username>"
    echo "Example: $0 123.456.789.0 yourusername"
    exit 1
fi

SERVER_IP=$1
USERNAME=$2

echo "🚀 Uploading ElevateAI files to server $SERVER_IP..."

# Create a deployment package
echo "📦 Creating deployment package..."
tar -czf elevateai-deploy.tar.gz \
    --exclude='venv' \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='.git' \
    --exclude='instance' \
    --exclude='*.log' \
    --exclude='*.jpg' \
    --exclude='*.jpeg' \
    --exclude='*.zip' \
    --exclude='*.bat' \
    app.py \
    templates/ \
    static/ \
    requirements.txt \
    requirements-prod.txt \
    gunicorn.conf.py \
    wsgi.py \
    deploy_to_digitalocean.sh

echo "📤 Uploading files to server..."
scp elevateai-deploy.tar.gz $USERNAME@$SERVER_IP:/tmp/

echo "🔧 Running deployment on server..."
ssh $USERNAME@$SERVER_IP << 'EOF'
    cd /var/www/elevateai
    tar -xzf /tmp/elevateai-deploy.tar.gz
    chmod +x deploy_to_digitalocean.sh
    ./deploy_to_digitalocean.sh
    rm /tmp/elevateai-deploy.tar.gz
EOF

echo "✅ Upload and deployment completed!"
echo "🌐 Your server IP is: $SERVER_IP"
echo "📋 Next steps:"
echo "1. Configure DNS for www.elevateai.co.in to point to $SERVER_IP"
echo "2. Wait for DNS propagation"
echo "3. Run SSL setup on server: sudo certbot --nginx -d www.elevateai.co.in -d elevateai.co.in"

# Clean up local file
rm elevateai-deploy.tar.gz
