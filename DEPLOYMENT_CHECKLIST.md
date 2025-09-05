# ElevateAI Deployment Checklist

## Pre-Deployment Checklist

### ✅ Files Required
- [x] `app.py` - Flask application
- [x] `wsgi.py` - WSGI entry point
- [x] `gunicorn.conf.py` - Gunicorn configuration
- [x] `requirements-prod.txt` - Production dependencies
- [x] `nginx-elevateai.conf` - Nginx configuration
- [x] `deploy-elevateai.sh` - Deployment script
- [x] `static/` directory with all assets
- [x] `templates/` directory with HTML files

### ✅ Domain Configuration
- [ ] Domain `www.elevateai.co.in` points to droplet IP
- [ ] Domain `elevateai.co.in` points to droplet IP
- [ ] DNS propagation completed (check with `nslookup`)

### ✅ Server Requirements
- [ ] Ubuntu 20.04 or 22.04 LTS droplet
- [ ] Root SSH access
- [ ] At least 1GB RAM
- [ ] At least 25GB storage

## Deployment Steps

### 1. Upload Files
```bash
# Upload entire project
scp -r /path/to/ElevateIQ root@YOUR_DROPLET_IP:/root/
```

### 2. SSH and Deploy
```bash
ssh root@YOUR_DROPLET_IP
cd /root/ElevateAI
chmod +x deploy-elevateai.sh
./deploy-elevateai.sh
```

### 3. SSL Setup
```bash
certbot --nginx -d www.elevateai.co.in -d elevateai.co.in
```

### 4. Verification
- [ ] Website loads at `https://www.elevateai.co.in`
- [ ] Contact form works
- [ ] All pages load correctly
- [ ] SSL certificate is valid

## Post-Deployment

### Security
- [ ] Firewall configured (UFW)
- [ ] SSH key authentication
- [ ] Regular security updates

### Monitoring
- [ ] Service status monitoring
- [ ] Log monitoring setup
- [ ] Backup strategy in place

## Quick Commands Reference

```bash
# Check services
systemctl status elevateai
systemctl status nginx

# Restart services
systemctl restart elevateai
systemctl restart nginx

# View logs
journalctl -u elevateai -f
tail -f /var/log/nginx/elevateai_error.log

# Test configuration
nginx -t
```

## Troubleshooting

### Service Issues
1. Check service status: `systemctl status elevateai`
2. Check logs: `journalctl -u elevateai -f`
3. Restart service: `systemctl restart elevateai`

### Nginx Issues
1. Test config: `nginx -t`
2. Check logs: `tail -f /var/log/nginx/elevateai_error.log`
3. Reload config: `systemctl reload nginx`

### Domain Issues
1. Check DNS: `nslookup www.elevateai.co.in`
2. Verify A records point to correct IP
3. Wait for DNS propagation (up to 48 hours)

## Success Indicators

✅ **Deployment Successful When:**
- Website loads at `https://www.elevateai.co.in`
- All pages render correctly
- Contact form submits successfully
- SSL certificate is valid and auto-renewing
- Services start automatically on reboot
- No errors in logs

🎉 **Your ElevateAI website is live!**
