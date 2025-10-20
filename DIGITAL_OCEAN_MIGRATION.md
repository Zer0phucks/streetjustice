# Digital Ocean Migration Guide

## 🎯 Quick Summary
**Your database data is SAFE** - it's hosted on Neon (separate from Vercel), so you won't lose any signatures or comments during this migration.

## Prerequisites
- Digital Ocean account
- Your Neon database credentials (from `.env` file)
- GitHub repository (optional but recommended)

---

## Option 1: Digital Ocean App Platform (Recommended - Similar to Vercel)

### Step 1: Backup Your Database (Safety Measure)
Even though Neon is separate, always backup before migrations:

```bash
# Install pg_dump if not already installed
# For Ubuntu/Debian:
sudo apt-get install postgresql-client

# Export your database (get DATABASE_URL from .env file)
pg_dump "YOUR_DATABASE_URL" > backup-$(date +%Y%m%d).sql
```

### Step 2: Prepare Your Repository
```bash
# Ensure latest code is committed
git add .
git commit -m "Prepare for Digital Ocean deployment"
git push origin main
```

### Step 3: Deploy to Digital Ocean App Platform

#### Via GitHub (Easiest):
1. Go to https://cloud.digitalocean.com/apps
2. Click **"Create App"**
3. Select **"GitHub"** as source
4. Choose your repository and branch (`main`)
5. Digital Ocean will auto-detect the configuration from `.do/app.yaml`
6. **Set Environment Variables**:
   - Click on each function (submit, count, comments)
   - Add encrypted environment variable:
     - Key: `DATABASE_URL`
     - Value: Your Neon database URL from `.env`
     - Mark as **"Encrypt"**
7. Click **"Next"** → Review settings
8. Click **"Create Resources"**

#### Via doctl CLI:
```bash
# Install doctl
# For Linux:
wget https://github.com/digitalocean/doctl/releases/latest/download/doctl-*-linux-amd64.tar.gz
tar xf doctl-*-linux-amd64.tar.gz
sudo mv doctl /usr/local/bin

# Authenticate
doctl auth init

# Create app from spec
doctl apps create --spec .do/app.yaml

# Set DATABASE_URL secret (get APP_ID from previous command output)
doctl apps update APP_ID --env DATABASE_URL=YOUR_DATABASE_URL
```

### Step 4: Verify Deployment
Once deployed, Digital Ocean will provide a URL like:
`https://streetjustice-petition-xxxxx.ondigitalocean.app`

Test the endpoints:
- **Frontend**: `https://your-app.ondigitalocean.app/`
- **Submit API**: `https://your-app.ondigitalocean.app/api/submit`
- **Count API**: `https://your-app.ondigitalocean.app/api/count`
- **Comments API**: `https://your-app.ondigitalocean.app/api/comments`

---

## Option 2: Digital Ocean Droplet + Docker (More Control)

### Step 1: Create a Droplet
1. Go to https://cloud.digitalocean.com/droplets
2. Click **"Create Droplet"**
3. Choose:
   - **Image**: Ubuntu 22.04 LTS
   - **Plan**: Basic ($6/month is sufficient)
   - **Datacenter**: Closest to your users
4. Add SSH key for access
5. Click **"Create Droplet"**

### Step 2: Set Up the Droplet
```bash
# SSH into your droplet
ssh root@YOUR_DROPLET_IP

# Update system
apt update && apt upgrade -y

# Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Install nginx
apt-get install -y nginx

# Install PM2 for process management
npm install -g pm2
```

### Step 3: Deploy Your Application
```bash
# Clone your repository
cd /var/www
git clone YOUR_REPO_URL streetjustice
cd streetjustice

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
nano .env  # Add your DATABASE_URL

# Set up PM2 ecosystem for serverless functions
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'api-server',
      script: 'server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      }
    }
  ]
};
EOF
```

### Step 4: Create Express Server Wrapper
```bash
# Create server.js to wrap serverless functions
cat > server.js << 'EOF'
import express from 'express';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import dotenv from 'dotenv';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(express.static('.'));

// Import API functions
import submitHandler from './api/submit.js';
import countHandler from './api/count.js';
import commentsHandler from './api/comments.js';

// API routes
app.all('/api/submit', submitHandler);
app.all('/api/count', countHandler);
app.all('/api/comments', commentsHandler);

// Serve index.html for root
app.get('/', (req, res) => {
  res.sendFile(join(__dirname, 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOF

# Update package.json
npm install express dotenv

# Start with PM2
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

### Step 5: Configure Nginx
```bash
cat > /etc/nginx/sites-available/streetjustice << 'EOF'
server {
    listen 80;
    server_name YOUR_DOMAIN_OR_IP;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

# Enable site
ln -s /etc/nginx/sites-available/streetjustice /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

# Test and reload nginx
nginx -t
systemctl reload nginx
```

### Step 6: Set Up SSL (Optional but Recommended)
```bash
# Install Certbot
apt install -y certbot python3-certbot-nginx

# Get SSL certificate (replace with your domain)
certbot --nginx -d yourdomain.com
```

---

## Option 3: Keep Neon + Use Alternative to Vercel

### Netlify (Very Similar to Vercel):
1. Go to https://app.netlify.com
2. Connect GitHub repository
3. Configure:
   - Build command: (leave empty)
   - Publish directory: `/`
   - Functions directory: `api`
4. Add environment variable: `DATABASE_URL`
5. Deploy

### Cloudflare Pages + Workers:
1. Go to https://dash.cloudflare.com
2. Create Pages project from GitHub
3. Deploy Workers for API functions
4. Add DATABASE_URL to environment variables

---

## Database Migration (If Needed)

If you want to move from Neon to Digital Ocean's managed PostgreSQL:

### Step 1: Create Digital Ocean Database
1. Go to https://cloud.digitalocean.com/databases
2. Click **"Create Database Cluster"**
3. Choose:
   - Engine: PostgreSQL
   - Plan: Basic ($15/month minimum)
   - Datacenter: Same as your app
4. Create cluster

### Step 2: Migrate Data
```bash
# Export from Neon
pg_dump "YOUR_NEON_DATABASE_URL" > migration.sql

# Import to Digital Ocean
psql "YOUR_DO_DATABASE_URL" < migration.sql

# Verify migration
psql "YOUR_DO_DATABASE_URL" -c "SELECT COUNT(*) FROM signatures;"
```

### Step 3: Update Environment Variables
Update `DATABASE_URL` in your app to point to the new Digital Ocean database.

---

## Cost Comparison

| Service | Vercel (Current) | DO App Platform | DO Droplet |
|---------|------------------|-----------------|------------|
| Hosting | Free tier | $5-12/month | $6/month |
| Functions | Free tier | Included | Included |
| Database | Neon ($0-19/mo) | Keep Neon | Keep Neon |
| **Total** | ~$0-19/month | ~$5-31/month | ~$6-25/month |

---

## Recommended Approach

**For fastest migration with minimal changes:**
→ Use **Option 1: Digital Ocean App Platform** (most similar to Vercel)

**For maximum control and cost optimization:**
→ Use **Option 2: Digital Ocean Droplet**

**For staying in serverless ecosystem:**
→ Use **Option 3: Netlify** (nearly identical to Vercel)

---

## Quick Start Commands

```bash
# 1. Backup database
pg_dump "$(grep DATABASE_URL .env | cut -d '=' -f2-)" > backup-$(date +%Y%m%d).sql

# 2. Commit and push latest changes
git add .
git commit -m "Prepare for Digital Ocean deployment"
git push origin main

# 3. Deploy to Digital Ocean App Platform (via web UI)
# → Follow Step 3 in Option 1 above
```

---

## Troubleshooting

### Issue: Functions not connecting to database
**Solution**: Verify DATABASE_URL is set correctly in Digital Ocean environment variables and marked as encrypted.

### Issue: CORS errors
**Solution**: Add CORS headers to your API functions:
```javascript
res.setHeader('Access-Control-Allow-Origin', '*');
res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
```

### Issue: Build fails
**Solution**: Ensure Node.js version 18+ is specified in deployment settings.

---

## Support

If you encounter issues:
1. Check Digital Ocean logs: Apps → Your App → Runtime Logs
2. Verify database connection: Test DATABASE_URL with psql
3. Check API responses: Use browser DevTools Network tab

Your data is safe on Neon - you can take your time with this migration!
