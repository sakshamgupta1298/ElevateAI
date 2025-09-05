#!/bin/bash

# Nginx Setup Script for ElevateAI
# This script configures Nginx with the optimized configuration

echo "🔧 Setting up Nginx configuration for ElevateAI..."

# Backup existing configuration if it exists
if [ -f /etc/nginx/sites-available/elevateai ]; then
    echo "📋 Backing up existing configuration..."
    sudo cp /etc/nginx/sites-available/elevateai /etc/nginx/sites-available/elevateai.backup.$(date +%Y%m%d_%H%M%S)
fi

# Copy the new configuration
echo "📝 Installing new Nginx configuration..."
sudo cp nginx-elevateai.conf /etc/nginx/sites-available/elevateai

# Create necessary directories
echo "📁 Creating necessary directories..."
sudo mkdir -p /var/www/certbot
sudo mkdir -p /var/log/nginx
sudo mkdir -p /home/elevateai/ElevateAI/static

# Create robots.txt if it doesn't exist
if [ ! -f /home/elevateai/ElevateAI/static/robots.txt ]; then
    echo "🤖 Creating robots.txt..."
    sudo tee /home/elevateai/ElevateAI/static/robots.txt > /dev/null <<EOF
User-agent: *
Allow: /

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
echo "🔐 Setting proper permissions..."
sudo chown -R elevateai:www-data /home/elevateai/ElevateAI/static
sudo chmod -R 755 /home/elevateai/ElevateAI/static

# Enable the site
echo "🔗 Enabling the site..."
sudo ln -sf /etc/nginx/sites-available/elevateai /etc/nginx/sites-enabled/

# Remove default site if it exists
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
echo "🧪 Testing Nginx configuration..."
if sudo nginx -t; then
    echo "✅ Nginx configuration test passed!"
    
    # Reload Nginx
    echo "🔄 Reloading Nginx..."
    sudo systemctl reload nginx
    
    echo "✅ Nginx configuration updated successfully!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Make sure your Flask application is running on port 3000"
    echo "2. Set up SSL certificate: sudo certbot --nginx -d www.elevateai.co.in -d elevateai.co.in"
    echo "3. Test your website: curl -I http://www.elevateai.co.in"
    echo ""
    echo "🔧 Useful commands:"
    echo "- Check Nginx status: sudo systemctl status nginx"
    echo "- View Nginx logs: sudo tail -f /var/log/nginx/elevateai_error.log"
    echo "- Test configuration: sudo nginx -t"
    echo "- Reload Nginx: sudo systemctl reload nginx"
else
    echo "❌ Nginx configuration test failed!"
    echo "Please check the configuration file for errors."
    exit 1
fi
