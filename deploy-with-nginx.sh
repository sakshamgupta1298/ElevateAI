#!/bin/bash

# Complete ElevateAI Deployment Script with Optimized Nginx Configuration
# This script deploys your Flask app with the custom Nginx configuration

echo "🚀 Starting complete ElevateAI deployment with optimized Nginx..."

# Update system packages
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install python3 python3-pip python3-venv nginx git -y

# Create application directory
sudo mkdir -p /home/elevateai/ElevateAI
sudo chown -R elevateai:elevateai /home/elevateai/ElevateAI

# Navigate to application directory
cd /home/elevateai/ElevateAI

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
User=elevateai
Group=www-data
WorkingDirectory=/home/elevateai/ElevateAI
Environment="PATH=/home/elevateai/ElevateAI/venv/bin"
ExecStart=/home/elevateai/ElevateAI/venv/bin/gunicorn --config gunicorn.conf.py wsgi:application
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

# Setup Nginx with optimized configuration
echo "🔧 Setting up optimized Nginx configuration..."

# Backup existing configuration if it exists
if [ -f /etc/nginx/sites-available/elevateai ]; then
    echo "📋 Backing up existing configuration..."
    sudo cp /etc/nginx/sites-available/elevateai /etc/nginx/sites-available/elevateai.backup.$(date +%Y%m%d_%H%M%S)
fi

# Copy the optimized Nginx configuration
sudo cp nginx-elevateai.conf /etc/nginx/sites-available/elevateai

# Create necessary directories
sudo mkdir -p /var/www/certbot
sudo mkdir -p /var/log/nginx
sudo mkdir -p /home/elevateai/ElevateAI/static

# Create robots.txt if it doesn't exist
if [ ! -f /home/elevateai/ElevateAI/static/robots.txt ]; then
    echo "🤖 Creating robots.txt..."
    sudo tee /home/elevateai/ElevateAI/static/robots.txt > /dev/null <<EOF
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
sudo tee /home/elevateai/ElevateAI/static/404.html > /dev/null <<EOF
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

sudo tee /home/elevateai/ElevateAI/static/50x.html > /dev/null <<EOF
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
sudo chown -R elevateai:www-data /home/elevateai/ElevateAI/static
sudo chmod -R 755 /home/elevateai/ElevateAI/static

# Enable the site
sudo ln -sf /etc/nginx/sites-available/elevateai /etc/nginx/sites-enabled/

# Remove default site if it exists
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
echo "🧪 Testing Nginx configuration..."
if sudo nginx -t; then
    echo "✅ Nginx configuration test passed!"
    
    # Restart Nginx
    sudo systemctl restart nginx
    sudo systemctl enable nginx
    
    echo "✅ Nginx restarted successfully!"
else
    echo "❌ Nginx configuration test failed!"
    echo "Please check the configuration file for errors."
    exit 1
fi

# Install Certbot for SSL
sudo apt install certbot python3-certbot-nginx -y

echo "✅ Complete deployment finished successfully!"
echo ""
echo "📋 Next steps:"
    echo "1. Your website is now running at: http://www.elevateai.co.in (Flask app on port 3000)"
echo "2. Set up SSL certificate: sudo certbot --nginx -d www.elevateai.co.in -d elevateai.co.in"
echo "3. After SSL setup, your site will be available at: https://www.elevateai.co.in"
echo ""
echo "🔧 Useful commands:"
echo "- Check service status: sudo systemctl status elevateai"
echo "- View application logs: sudo journalctl -u elevateai -f"
echo "- Check Nginx status: sudo systemctl status nginx"
echo "- View Nginx logs: sudo tail -f /var/log/nginx/elevateai_error.log"
echo "- Test configuration: sudo nginx -t"
echo "- Restart services: sudo systemctl restart elevateai && sudo systemctl restart nginx"
echo ""
echo "🌐 Your server IP is: $(curl -s ifconfig.me)"
echo "🎉 ElevateAI is ready to go live!"
