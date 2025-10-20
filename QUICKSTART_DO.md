# 🚀 Quick Start: Deploy to Digital Ocean

**Your data is safe!** Neon database is separate from Vercel, so no data loss.

## Fastest Option: Digital Ocean App Platform (5 minutes)

### Step 1: Backup Database (Safety)
```bash
npm run backup
```

### Step 2: Push to GitHub
```bash
git add .
git commit -m "Add Digital Ocean configuration"
git push origin main
```

### Step 3: Deploy on Digital Ocean
1. Visit: https://cloud.digitalocean.com/apps
2. Click **"Create App"**
3. Select **GitHub** → Choose your repo → Branch: `main`
4. Digital Ocean auto-detects `.do/app.yaml` ✅
5. **Add Environment Variable**:
   - Go to each function (submit, count, comments)
   - Add: `DATABASE_URL` = (copy from your `.env` file)
   - Mark as **"Encrypt"** 🔐
6. Click **"Create Resources"**
7. Wait 3-5 minutes ⏱️

### Step 4: Test Your Site
Digital Ocean provides a URL like:
```
https://streetjustice-petition-xxxxx.ondigitalocean.app
```

Test it:
- ✅ Visit the URL
- ✅ Sign the petition
- ✅ Check signature count
- ✅ View comments

**Done!** Your site is live on Digital Ocean.

---

## Alternative: Run on Droplet ($6/month)

### Quick Commands
```bash
# 1. Create Basic Droplet ($6/month) at:
#    https://cloud.digitalocean.com/droplets

# 2. SSH into droplet
ssh root@YOUR_DROPLET_IP

# 3. Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs nginx

# 4. Clone your repo
cd /var/www
git clone YOUR_REPO_URL streetjustice
cd streetjustice

# 5. Install dependencies
npm install
npm install -g pm2

# 6. Set environment variable
cp .env.example .env
nano .env  # Add your DATABASE_URL

# 7. Start server
pm2 start ecosystem.config.js
pm2 save
pm2 startup

# 8. Configure nginx
cat > /etc/nginx/sites-available/streetjustice << 'EOF'
server {
    listen 80;
    server_name YOUR_IP_OR_DOMAIN;
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

ln -s /etc/nginx/sites-available/streetjustice /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx
```

Visit: `http://YOUR_DROPLET_IP`

---

## Need Help?

Full guide: See `DIGITAL_OCEAN_MIGRATION.md`

**Issues?**
- Database not connecting? → Check DATABASE_URL in environment variables
- Functions failing? → Check Digital Ocean function logs
- CORS errors? → Already configured in code ✅

**Your data is on Neon and completely safe!** 🎉
