# ElevateAI Deployment Guide for DigitalOcean

This guide will help you deploy your ElevateAI website to a DigitalOcean droplet with your domain `www.elevateai.co.in`.

## Prerequisites

- DigitalOcean account
- Domain `www.elevateai.co.in` registered
- SSH access to your local machine
- Basic knowledge of command line

## Step 1: Create DigitalOcean Droplet

1. **Log into DigitalOcean** and create a new droplet:
   - **Image**: Ubuntu 22.04 LTS
   - **Size**: Basic plan, $6/month (1GB RAM, 1 vCPU)
   - **Region**: Choose closest to your target audience
   - **Authentication**: SSH Key (recommended)
   - **Hostname**: `elevateai-server`

2. **Note your droplet's IP address** - you'll need this for DNS configuration.

## Step 2: Initial Server Setup

SSH into your droplet:
```bash
ssh root@YOUR_DROPLET_IP
```

Run these commands to secure your server:
```bash
# Update system
apt update && apt upgrade -y

# Create a non-root user (replace 'yourusername' with your preferred username)
adduser yourusername
usermod -aG sudo yourusername

# Set up SSH key for the new user
mkdir -p /home/yourusername/.ssh
cp /root/.ssh/authorized_keys /home/yourusername/.ssh/
chown -R yourusername:yourusername /home/yourusername/.ssh
chmod 700 /home/yourusername/.ssh
chmod 600 /home/yourusername/.ssh/authorized_keys

# Configure firewall
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable
```

## Step 3: Deploy Your Application

### Option A: Automated Upload (Recommended)

From your local machine, run:
```bash
chmod +x upload_to_server.sh
./upload_to_server.sh YOUR_DROPLET_IP yourusername
```

### Option B: Manual Upload

1. **Create deployment package**:
```bash
tar -czf elevateai-deploy.tar.gz \
    --exclude='venv' \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='.git' \
    --exclude='instance' \
    --exclude='*.log' \
    app.py templates/ static/ requirements.txt requirements-prod.txt gunicorn.conf.py wsgi.py deploy_to_digitalocean.sh
```

2. **Upload to server**:
```bash
scp elevateai-deploy.tar.gz yourusername@YOUR_DROPLET_IP:/tmp/
```

3. **SSH into server and deploy**:
```bash
ssh yourusername@YOUR_DROPLET_IP
cd /var/www/elevateai
tar -xzf /tmp/elevateai-deploy.tar.gz
chmod +x deploy_to_digitalocean.sh
./deploy_to_digitalocean.sh
```

## Step 4: Configure Domain DNS

1. **Log into your domain registrar** (where you bought elevateai.co.in)

2. **Configure DNS records**:
   - **A Record**: `@` → `YOUR_DROPLET_IP`
   - **A Record**: `www` → `YOUR_DROPLET_IP`
   - **CNAME Record**: `elevateai.co.in` → `www.elevateai.co.in` (optional)

3. **Wait for DNS propagation** (5-30 minutes)

## Step 5: Set Up SSL Certificate

Once DNS is propagated, run on your server:
```bash
sudo certbot --nginx -d www.elevateai.co.in -d elevateai.co.in
```

Follow the prompts to:
- Enter your email address
- Agree to terms of service
- Choose whether to share your email with EFF
- Select redirect option (recommended: redirect HTTP to HTTPS)

## Step 6: Test Your Deployment

1. **Check service status**:
```bash
sudo systemctl status elevateai
sudo systemctl status nginx
```

2. **View logs if needed**:
```bash
sudo journalctl -u elevateai -f
sudo tail -f /var/log/nginx/error.log
```

3. **Test your website**:
   - Visit `http://www.elevateai.co.in` (should redirect to HTTPS)
   - Visit `https://www.elevateai.co.in`
   - Test all pages: Home, About, Services, Contact
   - Test contact form functionality

## Useful Commands

### Service Management
```bash
# Restart application
sudo systemctl restart elevateai

# Check application status
sudo systemctl status elevateai

# View application logs
sudo journalctl -u elevateai -f

# Restart Nginx
sudo systemctl restart nginx
```

### SSL Certificate Management
```bash
# Test certificate renewal
sudo certbot renew --dry-run

# Renew certificates manually
sudo certbot renew

# Check certificate status
sudo certbot certificates
```

### Database Management
```bash
# Initialize database (if needed)
curl https://www.elevateai.co.in/init-db

# Check database file
ls -la /var/www/elevateai/instance/
```

## Troubleshooting

### Common Issues

1. **Service won't start**:
   - Check logs: `sudo journalctl -u elevateai -f`
   - Verify file permissions: `ls -la /var/www/elevateai/`
   - Check Python path: `which python3`

2. **Nginx errors**:
   - Test configuration: `sudo nginx -t`
   - Check error logs: `sudo tail -f /var/log/nginx/error.log`

3. **SSL issues**:
   - Verify DNS propagation: `nslookup www.elevateai.co.in`
   - Check firewall: `sudo ufw status`

4. **Database issues**:
   - Check file permissions: `ls -la /var/www/elevateai/instance/`
   - Reinitialize database: Visit `/init-db` endpoint

### Performance Optimization

1. **Enable Gzip compression** (already configured in Nginx)
2. **Set up log rotation**:
```bash
sudo tee /etc/logrotate.d/elevateai > /dev/null <<EOF
/var/log/gunicorn/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 $USER $USER
    postrotate
        systemctl reload elevateai
    endscript
}
EOF
```

3. **Monitor server resources**:
```bash
# Install monitoring tools
sudo apt install htop iotop nethogs -y

# Check disk usage
df -h

# Check memory usage
free -h
```

## Security Considerations

1. **Keep system updated**:
```bash
sudo apt update && sudo apt upgrade -y
```

2. **Configure automatic security updates**:
```bash
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure -plow unattended-upgrades
```

3. **Set up fail2ban** (optional):
```bash
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

## Backup Strategy

1. **Database backup**:
```bash
# Create backup script
sudo tee /usr/local/bin/backup-elevateai.sh > /dev/null <<EOF
#!/bin/bash
DATE=\$(date +%Y%m%d_%H%M%S)
cp /var/www/elevateai/instance/elevateiq.db /var/backups/elevateiq_\$DATE.db
find /var/backups -name "elevateiq_*.db" -mtime +7 -delete
EOF

sudo chmod +x /usr/local/bin/backup-elevateai.sh

# Add to crontab for daily backups
echo "0 2 * * * /usr/local/bin/backup-elevateai.sh" | sudo crontab -
```

## Cost Optimization

- **Droplet size**: Start with $6/month, scale up if needed
- **Domain**: Use free DNS services if your registrar charges extra
- **SSL**: Let's Encrypt is free
- **Monitoring**: Use DigitalOcean's built-in monitoring

## Support

If you encounter issues:
1. Check the logs first
2. Verify all steps were completed
3. Test each component individually
4. Consider scaling up droplet size if performance is poor

Your ElevateAI website should now be live at `https://www.elevateai.co.in`! 🎉
