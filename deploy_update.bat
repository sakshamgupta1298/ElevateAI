@echo off
echo 🚀 ElevateAI Update Deployment Script
echo.
echo 📋 Current local changes to be deployed:
echo - Customers route commented out in app.py
echo - Customers navigation links commented out in base.html
echo - Customers page template exists but is not accessible
echo.

echo 📦 Creating deployment package...
powershell -Command "Compress-Archive -Path 'app.py','templates','static','requirements.txt','requirements-prod.txt','gunicorn.conf.py','wsgi.py' -DestinationPath 'elevateai-update.zip' -Force"

echo ✅ Deployment package created: elevateai-update.zip
echo.
echo 🔧 Next steps to deploy:
echo 1. Upload the package to your server using SCP or SFTP
echo 2. SSH into your server
echo 3. Extract and update the files
echo 4. Restart the service
echo.
echo ⚠️  Make sure to update your server details before deploying!
pause
