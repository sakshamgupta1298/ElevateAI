#!/bin/bash

# ElevateAI Update Deployment Script
echo "🚀 Updating ElevateAI deployment to remove customers tab..."

# Set the server details (update these with your actual server details)
SERVER_USER="root"  # or your username
SERVER_HOST="your-server-ip"  # Replace with your DigitalOcean server IP
APP_DIR="/var/www/elevateai"

echo "📋 Current local changes to be deployed:"
echo "- Customers route commented out in app.py"
echo "- Customers navigation links commented out in base.html"
echo "- Customers page template exists but is not accessible"

# Create a temporary deployment package
echo "📦 Creating deployment package..."
tar -czf elevateai-update.tar.gz \
    --exclude='venv' \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='.git' \
    --exclude='instance' \
    --exclude='*.log' \
    app.py \
    templates/ \
    static/ \
    requirements.txt \
    requirements-prod.txt \
    gunicorn.conf.py \
    wsgi.py

echo "✅ Deployment package created: elevateai-update.tar.gz"
echo ""
echo "🔧 Next steps to deploy:"
echo "1. Upload the package to your server:"
echo "   scp elevateai-update.tar.gz $SERVER_USER@$SERVER_HOST:/tmp/"
echo ""
echo "2. SSH into your server:"
echo "   ssh $SERVER_USER@$SERVER_HOST"
echo ""
echo "3. Run these commands on your server:"
echo "   cd $APP_DIR"
echo "   sudo systemctl stop elevateai"
echo "   tar -xzf /tmp/elevateai-update.tar.gz"
echo "   source venv/bin/activate"
echo "   pip install -r requirements-prod.txt"
echo "   sudo systemctl start elevateai"
echo "   sudo systemctl status elevateai"
echo ""
echo "4. Clean up:"
echo "   rm /tmp/elevateai-update.tar.gz"
echo "   rm elevateai-update.tar.gz  # (on your local machine)"
echo ""
echo "⚠️  Make sure to update SERVER_USER and SERVER_HOST variables in this script!"
