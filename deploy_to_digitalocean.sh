#!/bin/bash

# ElevateAI Complete Deployment Script for DigitalOcean
# Run this script on your DigitalOcean droplet

echo "🚀 Starting ElevateAI deployment to DigitalOcean..."

# Update system packages
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install python3 python3-pip python3-venv nginx git -y

# Create application directory
sudo mkdir -p /var/www/elevateai
sudo chown -R $USER:$USER /var/www/elevateai

# Navigate to application directory
cd /var/www/elevateai

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install --upgrade pip
pip install -r requirements-prod.txt

# Create gunicorn log directory
sudo mkdir -p /var/log/gunicorn
sudo chown -R $USER:$USER /var/log/gunicorn

# Create systemd service file
sudo tee /etc/systemd/system/elevateai.service > /dev/null <<EOF
[Unit]
Description=ElevateAI Flask Application
After=network.target

[Service]
User=$USER
Group=www-data
WorkingDirectory=/var/www/elevateai
Environment="PATH=/var/www/elevateai/venv/bin"
ExecStart=/var/www/elevateai/venv/bin/gunicorn --config gunicorn.conf.py wsgi:application
ExecReload=/bin/kill -s HUP \$MAINPID
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable elevateai
sudo systemctl start elevateai

# Check service status
echo "📊 Checking service status..."
sudo systemctl status elevateai --no-pager

# Configure Nginx
sudo tee /etc/nginx/sites-available/elevateai > /dev/null <<EOF
server {
    listen 80;
    server_name www.elevateai.co.in elevateai.co.in;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
    }

    location /static {
        alias /var/www/elevateai/static;
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss;
}
EOF

# Enable the site
sudo ln -s /etc/nginx/sites-available/elevateai /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
sudo systemctl enable nginx

# Install Certbot for SSL
sudo apt install certbot python3-certbot-nginx -y

echo "✅ Deployment completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Configure your domain DNS to point to this server: $(curl -s ifconfig.me)"
echo "2. Wait for DNS propagation (5-30 minutes)"
echo "3. Run SSL setup: sudo certbot --nginx -d www.elevateai.co.in -d elevateai.co.in"
echo "4. Test your website: http://www.elevateai.co.in"
echo ""
echo "🔧 Useful commands:"
echo "- Check service status: sudo systemctl status elevateai"
echo "- View logs: sudo journalctl -u elevateai -f"
echo "- Restart service: sudo systemctl restart elevateai"
echo "- Check Nginx status: sudo systemctl status nginx"
