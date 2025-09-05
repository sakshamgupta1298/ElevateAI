# ElevateAI DigitalOcean Deployment Guide

This guide will help you deploy your ElevateAI website to a DigitalOcean droplet with the domain `www.elevateai.co.in`.

## Prerequisites

1. **DigitalOcean Droplet**: Ubuntu 20.04 or 22.04 LTS
2. **Domain**: `www.elevateai.co.in` pointing to your droplet's IP address
3. **SSH Access**: Root access to your droplet

## Step 1: Prepare Your Local Files

Ensure you have all the necessary files in your project directory:
- `app.py` - Your Flask application
- `wsgi.py` - WSGI entry point
- `gunicorn.conf.py` - Gunicorn configuration
- `requirements-prod.txt` - Production dependencies
- `nginx-elevateai.conf` - Nginx configuration
- `deploy-elevateai.sh` - Deployment script
- `static/` - Static files directory
- `templates/` - HTML templates

## Step 2: Upload Files to Your Droplet

### Option A: Using SCP (Recommended)
```bash
# From your local machine, upload the entire project
scp -r /path/to/your/ElevateIQ root@YOUR_DROPLET_IP:/root/

# Or upload specific files
scp app.py wsgi.py gunicorn.conf.py requirements-prod.txt nginx-elevateai.conf deploy-elevateai.sh root@YOUR_DROPLET_IP:/root/ElevateAI/
scp -r static/ templates/ root@YOUR_DROPLET_IP:/root/ElevateAI/
```

### Option B: Using Git (If your code is in a repository)
```bash
# SSH into your droplet
ssh root@YOUR_DROPLET_IP

# Clone your repository
cd /root
git clone YOUR_REPOSITORY_URL ElevateAI
cd ElevateAI
```

## Step 3: Configure Domain DNS

1. **Point your domain to the droplet**:
   - Add an A record: `www.elevateai.co.in` → `YOUR_DROPLET_IP`
   - Add an A record: `elevateai.co.in` → `YOUR_DROPLET_IP`

2. **Verify DNS propagation**:
   ```bash
   nslookup www.elevateai.co.in
   ```

## Step 4: Deploy the Application

1. **SSH into your droplet**:
   ```bash
   ssh root@YOUR_DROPLET_IP
   ```

2. **Navigate to the project directory**:
   ```bash
   cd /root/ElevateAI
   ```

3. **Make the deployment script executable**:
   ```bash
   chmod +x deploy-elevateai.sh
   ```

4. **Run the deployment script**:
   ```bash
   ./deploy-elevateai.sh
   ```

The script will:
- Update system packages
- Install Python, Nginx, and other dependencies
- Create a virtual environment
- Install Python dependencies
- Set up Gunicorn as a systemd service
- Configure Nginx with your domain
- Create necessary directories and files
- Start all services

## Step 5: Set Up SSL Certificate

After the deployment script completes successfully:

```bash
# Install SSL certificate using Let's Encrypt
certbot --nginx -d www.elevateai.co.in -d elevateai.co.in
```

Follow the prompts to:
- Enter your email address
- Agree to terms of service
- Choose whether to share your email with EFF
- Select redirect option (recommended: redirect HTTP to HTTPS)

## Step 6: Verify Deployment

1. **Check service status**:
   ```bash
   systemctl status elevateai
   systemctl status nginx
   ```

2. **Test your website**:
   - Visit `http://www.elevateai.co.in` (should redirect to HTTPS)
   - Visit `https://www.elevateai.co.in`
   - Test the contact form

3. **Check logs if needed**:
   ```bash
   # Application logs
   journalctl -u elevateai -f
   
   # Nginx logs
   tail -f /var/log/nginx/elevateai_error.log
   tail -f /var/log/nginx/elevateai_access.log
   ```

## Step 7: Configure Firewall (Optional but Recommended)

```bash
# Enable UFW firewall
ufw enable

# Allow SSH
ufw allow ssh

# Allow HTTP and HTTPS
ufw allow 80
ufw allow 443

# Check status
ufw status
```

## Troubleshooting

### Common Issues:

1. **Service won't start**:
   ```bash
   systemctl status elevateai
   journalctl -u elevateai -f
   ```

2. **Nginx configuration errors**:
   ```bash
   nginx -t
   ```

3. **Permission issues**:
   ```bash
   chown -R root:root /root/ElevateAI
   chmod -R 755 /root/ElevateAI
   ```

4. **Port conflicts**:
   ```bash
   netstat -tlnp | grep :3000
   ```

### Useful Commands:

```bash
# Restart services
systemctl restart elevateai
systemctl restart nginx

# Check service status
systemctl status elevateai
systemctl status nginx

# View logs
journalctl -u elevateai -f
tail -f /var/log/nginx/elevateai_error.log

# Test Nginx configuration
nginx -t

# Reload Nginx configuration
systemctl reload nginx
```

## Security Considerations

1. **Keep your system updated**:
   ```bash
   apt update && apt upgrade -y
   ```

2. **Configure fail2ban** (optional):
   ```bash
   apt install fail2ban
   systemctl enable fail2ban
   systemctl start fail2ban
   ```

3. **Regular backups**:
   - Backup your application files
   - Backup your database (if using one)
   - Backup Nginx configuration

## Monitoring

1. **Set up monitoring** (optional):
   ```bash
   # Install htop for system monitoring
   apt install htop
   
   # Monitor system resources
   htop
   ```

2. **Log rotation**:
   The system is configured with log rotation for Nginx and Gunicorn logs.

## Updating Your Application

To update your application:

1. **Upload new files**:
   ```bash
   scp -r /path/to/updated/files root@YOUR_DROPLET_IP:/root/ElevateAI/
   ```

2. **Restart the service**:
   ```bash
   systemctl restart elevateai
   ```

3. **Test the update**:
   ```bash
   systemctl status elevateai
   ```

## Support

If you encounter any issues:

1. Check the logs first
2. Verify all services are running
3. Test the configuration files
4. Ensure DNS is properly configured
5. Check firewall settings

Your ElevateAI website should now be live at `https://www.elevateai.co.in`! 🎉
