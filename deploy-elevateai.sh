#!/bin/bash

# ElevateAI Deployment Script for /root/ElevateAI
# This script deploys your Flask app with the correct path structure

echo "🚀 Starting ElevateAI deployment to /root/ElevateAI..."

# Check if running as root user
if [ "$USER" != "root" ]; then
    echo "⚠️  This script should be run as the 'root' user"
    echo "Please run: sudo su -"
    echo "Then run this script again"
    exit 1
fi

# Update system packages
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install python3 python3-pip python3-venv nginx git -y

# Create application directory if it doesn't exist
mkdir -p /root/ElevateAI
cd /root/ElevateAI

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install --upgrade pip
pip install -r requirements-prod.txt

# Create gunicorn log directory
mkdir -p /var/log/gunicorn
chown -R root:root /var/log/gunicorn

# Create systemd service file
tee /etc/systemd/system/elevateai.service > /dev/null <<EOF
[Unit]
Description=ElevateAI Flask Application
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=/root/ElevateAI
Environment="PATH=/root/ElevateAI/venv/bin"
ExecStart=/root/ElevateAI/venv/bin/gunicorn --config gunicorn.conf.py wsgi:application
ExecReload=/bin/kill -s HUP \$MAINPID
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reload
systemctl enable elevateai
systemctl start elevateai

# Check service status
echo "📊 Checking service status..."
systemctl status elevateai --no-pager

# Setup Nginx with optimized configuration
echo "🔧 Setting up optimized Nginx configuration..."

# Copy the optimized Nginx configuration
cp nginx-elevateai.conf /etc/nginx/sites-available/elevateai

# Create necessary directories
mkdir -p /var/www/certbot
mkdir -p /var/log/nginx
mkdir -p /root/ElevateAI/static

# Create robots.txt if it doesn't exist
if [ ! -f /root/ElevateAI/static/robots.txt ]; then
    echo "🤖 Creating robots.txt..."
    tee /root/ElevateAI/static/robots.txt > /dev/null <<EOF
User-agent: *
Allow: /

# Disallow admin areas
Disallow: /init-db
Disallow: /admin/

# Sitemap location
Sitemap: https://www.elevateai.co.in/sitemap.xml
EOF
fi

# Create custom error pages
echo "🚨 Creating custom error pages..."
tee /root/ElevateAI/static/404.html > /dev/null <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Not Found - ElevateAI</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
        h1 { color: #333; }
        p { color: #666; }
        a { color: #007bff; text-decoration: none; }
    </style>
</head>
<body>
    <h1>404 - Page Not Found</h1>
    <p>The page you're looking for doesn't exist.</p>
    <a href="/">← Back to Home</a>
</body>
</html>
EOF

tee /root/ElevateAI/static/50x.html > /dev/null <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Server Error - ElevateAI</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
        h1 { color: #dc3545; }
        p { color: #666; }
        a { color: #007bff; text-decoration: none; }
    </style>
</head>
<body>
    <h1>500 - Server Error</h1>
    <p>Something went wrong on our end. Please try again later.</p>
    <a href="/">← Back to Home</a>
</body>
</html>
EOF

# Set proper permissions
chown -R root:root /root/ElevateAI/static
chmod -R 755 /root/ElevateAI/static

# Enable the site
ln -sf /etc/nginx/sites-available/elevateai /etc/nginx/sites-enabled/

# Remove default site if it exists
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
echo "🧪 Testing Nginx configuration..."
if nginx -t; then
    echo "✅ Nginx configuration test passed!"
    
    # Restart Nginx
    systemctl restart nginx
    systemctl enable nginx
    
    echo "✅ Nginx restarted successfully!"
else
    echo "❌ Nginx configuration test failed!"
    echo "Please check the configuration file for errors."
    exit 1
fi

# Install Certbot for SSL
apt install certbot python3-certbot-nginx -y

echo "✅ Complete deployment finished successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Your website is now running at: http://www.elevateai.co.in"
echo "2. Set up SSL certificate: certbot --nginx -d www.elevateai.co.in -d elevateai.co.in"
echo "3. After SSL setup, your site will be available at: https://www.elevateai.co.in"
echo ""
echo "🔧 Useful commands:"
echo "- Check service status: systemctl status elevateai"
echo "- View application logs: journalctl -u elevateai -f"
echo "- Check Nginx status: systemctl status nginx"
echo "- View Nginx logs: tail -f /var/log/nginx/elevateai_error.log"
echo "- Test configuration: nginx -t"
echo "- Restart services: systemctl restart elevateai && systemctl restart nginx"
echo ""
echo "🌐 Your server IP is: $(curl -s ifconfig.me)"
echo "🎉 ElevateAI is ready to go live!"
