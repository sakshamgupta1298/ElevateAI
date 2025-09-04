#!/bin/bash

# ElevateAI Deployment Script for DigitalOcean
echo "🚀 Starting ElevateAI deployment..."

# Update system packages
sudo apt update && sudo apt upgrade -y

# Install Python 3 and pip
sudo apt install python3 python3-pip python3-venv nginx -y

# Create application directory
sudo mkdir -p /var/www/elevateai
sudo chown -R $USER:$USER /var/www/elevateai

# Create virtual environment
cd /var/www/elevateai
python3 -m venv venv
source venv/bin/activate

# Install dependencies
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

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable elevateai
sudo systemctl start elevateai

# Configure Nginx
sudo tee /etc/nginx/sites-available/elevateai > /dev/null <<EOF
server {
    listen 80;
    server_name www.elevateai.co.in elevateai.co.in;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /static {
        alias /var/www/elevateai/static;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# Enable the site
sudo ln -s /etc/nginx/sites-available/elevateai /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test and restart Nginx
sudo nginx -t
sudo systemctl restart nginx

# Install Certbot for SSL
sudo apt install certbot python3-certbot-nginx -y

echo "✅ Deployment completed! Next steps:"
echo "1. Upload your code to /var/www/elevateai/"
echo "2. Configure your domain DNS"
echo "3. Run: sudo certbot --nginx -d www.elevateai.co.in -d elevateai.co.in"
