# Quick Start Guide

Get your petition website live in 15 minutes!

## 🚀 5-Step Setup

### 1️⃣ Create Neon Database (5 min)

1. Go to [neon.tech](https://neon.tech) → Sign up with GitHub
2. Create new project (name: `mandela-house-petition`)
3. In SQL Editor, paste and run `neon-schema.sql`
4. Copy your connection string from Dashboard → Connection Details

### 2️⃣ Push to GitHub (3 min)

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/mandela-house-petition.git
git push -u origin main
```

### 3️⃣ Deploy to Vercel (3 min)

1. Go to [vercel.com](https://vercel.com) → Sign up with GitHub
2. Import your repository
3. Add environment variable:
   - Key: `DATABASE_URL`
   - Value: Your Neon connection string
4. Click Deploy

### 4️⃣ Test It (2 min)

1. Click "Visit" to open your live site
2. Sign the petition
3. Verify counter shows "1"
4. See your comment appear

### 5️⃣ Share It (2 min)

Get your live URL from Vercel and share:
- Social media
- Email campaigns
- Community organizations
- Local news

## ✅ You're Live!

Share your petition URL: `https://your-project.vercel.app`

Demand accountability and justice!

## 📚 Need More Details?

See [DEPLOYMENT.md](DEPLOYMENT.md) for complete step-by-step guide.

## 🆘 Troubleshooting

- **Counter not working?** Check Vercel environment variables
- **Form errors?** Verify DATABASE_URL is set correctly
- **Full troubleshooting**: See [DEPLOYMENT.md](DEPLOYMENT.md)

## 📊 View Signatures

Neon Dashboard → SQL Editor:
```sql
SELECT * FROM signatures ORDER BY created_at DESC;
```

## 🔄 Update Your Site

```bash
git add .
git commit -m "Your changes"
git push
# Vercel auto-deploys!
```
