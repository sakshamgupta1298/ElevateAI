#!/bin/bash

# ElevateAI Monitoring Script
echo "🔍 ElevateAI System Status Check"
echo "================================"

# Check if services are running
echo "📊 Service Status:"
sudo systemctl is-active elevateai && echo "✅ ElevateAI: Running" || echo "❌ ElevateAI: Not Running"
sudo systemctl is-active nginx && echo "✅ Nginx: Running" || echo "❌ Nginx: Not Running"

# Check disk usage
echo -e "\n💾 Disk Usage:"
df -h /var/www/elevateai

# Check memory usage
echo -e "\n🧠 Memory Usage:"
free -h

# Check recent logs
echo -e "\n📝 Recent ElevateAI Logs:"
sudo journalctl -u elevateai --lines=10 --no-pager

echo -e "\n🌐 Website Status:"
curl -I http://localhost:5000 2>/dev/null | head -1 || echo "❌ Website not responding"
