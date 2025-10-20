# Deployment Guide: Mandela House Petition Website

Complete step-by-step guide to deploy the petition website to Vercel with Neon database.

## Prerequisites

- GitHub account (free)
- Neon account (free)
- Vercel account (free)

## Step 1: Set Up Neon Database

### 1.1 Create Neon Project

1. Go to [https://neon.tech](https://neon.tech)
2. Click "Sign up" and sign in with GitHub
3. Click "Create a project"
4. Fill in project details:
   - **Project name**: `mandela-house-petition`
   - **Region**: Choose closest to your audience (US West recommended for Oakland)
   - **Postgres version**: Leave as default (16)
5. Click "Create project"

### 1.2 Create Database Schema

1. In your Neon project dashboard, click "SQL Editor"
2. Open `neon-schema.sql` from this repository
3. Copy the entire contents
4. Paste into the Neon SQL Editor
5. Click "Run" (or press Ctrl/Cmd + Enter)
6. Verify success: You should see "Success" message

### 1.3 Get Your Connection String

1. In Neon dashboard, find "Connection Details" section
2. Make sure "Pooled connection" is selected
3. Copy the connection string (looks like this):
   ```
   postgresql://username:password@ep-cool-name-12345.us-west-2.aws.neon.tech/neondb?sslmode=require
   ```
4. Save this somewhere safe - you'll need it next

### 1.4 Test Your Database

1. In SQL Editor, run this query:
```sql
SELECT * FROM signatures;
```
2. Should return empty result (0 rows) - this is correct!
3. The table exists and is ready to use

## Step 2: Push to GitHub

### 2.1 Create Repository

1. Go to [https://github.com](https://github.com)
2. Click the "+" icon (top right) → "New repository"
3. Name it: `mandela-house-petition`
4. Keep it Public (or Private if preferred)
5. Do NOT initialize with README, .gitignore, or license
6. Click "Create repository"

### 2.2 Push Your Code

Open terminal/command prompt in your project folder and run:

```bash

git init
git add .
git commit -m "Initial commit: Mandela House petition with Neon"
git remote add origin https://github.com/Zer0phucks/streetjustice.git
git branch -M main
git push -u origin main
```

### 2.3 Verify

1. Refresh your GitHub repository page
2. You should see all your files including:
   - `api/` folder with submit.js, count.js, comments.js
   - `index.html`, `styles.css`
   - `package.json`, `vercel.json`
   - `neon-schema.sql`

## Step 3: Deploy to Vercel

### 3.1 Connect Vercel to GitHub

1. Go to [https://vercel.com](https://vercel.com)
2. Click "Sign Up" → "Continue with GitHub"
3. Authorize Vercel to access your GitHub account

### 3.2 Import Your Project

1. On Vercel dashboard, click "Add New..." → "Project"
2. Find your `mandela-house-petition` repository
3. Click "Import"

### 3.3 Configure Project

1. **Project Name**: Leave as `mandela-house-petition` or customize
2. **Framework Preset**: Leave as default (Vercel will auto-detect)
3. **Root Directory**: Leave as `./`
4. **Build Settings**: Leave all defaults

### 3.4 Add Environment Variable

**IMPORTANT**: Before deploying, add your database connection string:

1. Click "Environment Variables" section (expand if collapsed)
2. Add variable:
   - **Key**: `DATABASE_URL`
   - **Value**: Paste your Neon connection string from Step 1.3
   - **Environment**: Leave all three checked (Production, Preview, Development)
3. Click "Add"

### 3.5 Deploy

1. Click "Deploy" button
2. Wait for deployment (~1-2 minutes)
3. You'll see a success screen with confetti!
4. Click "Visit" to see your live website

### 3.6 Test Your Live Site

1. Click "Visit" to open your deployed website
2. Scroll to the petition section
3. Fill out and submit the petition form
4. Verify:
   - Success message appears
   - Counter updates to show "1"
   - Your comment appears in the "Voices of Support" section
5. Open a new browser tab and visit your site again
6. Counter should still show "1" (data persists!)

## Step 4: Verify Database

### 4.1 Check Data in Neon

1. Go back to Neon dashboard
2. Open SQL Editor
3. Run query:
```sql
SELECT * FROM signatures ORDER BY created_at DESC LIMIT 10;
```
4. You should see your test signature!

## Step 5: Post-Deployment

### 5.1 Custom Domain (Optional)

If you have a custom domain:

1. In Vercel project settings, click "Domains"
2. Click "Add"
3. Enter your domain (e.g., `justiceformandela.org`)
4. Follow DNS setup instructions provided by Vercel
5. Wait for DNS propagation (~24 hours max, usually faster)

### 5.2 Monitor Your Petition

**View Signatures:**
1. Neon Dashboard → SQL Editor
2. Run: `SELECT COUNT(*) FROM signatures;`
3. See total signature count

**Export Signatures:**
```sql
SELECT
  first_name,
  last_name,
  email,
  city,
  state,
  comment,
  created_at
FROM signatures
ORDER BY created_at DESC;
```
Then click "Download" → "CSV"

**Statistics:**
```sql
-- Signatures by state
SELECT state, COUNT(*) as count
FROM signatures
GROUP BY state
ORDER BY count DESC;

-- Comments count
SELECT COUNT(*) FROM signatures
WHERE comment IS NOT NULL AND comment != '';
```

### 5.3 Monitor Function Performance

1. Vercel Dashboard → Your Project → Analytics
2. View:
   - Total requests
   - Function invocations
   - Response times
   - Error rates

### 5.4 Share Your Website

Your petition is now live! Share the URL:
- Social media platforms
- Email campaigns
- Local news outlets
- Community organizations
- City council meetings
- Resident groups

**Example URL**: `https://mandela-house-petition.vercel.app`

## Troubleshooting

### Problem: "DATABASE_URL is not defined" error

**Solution:**
1. Go to Vercel → Your Project → Settings → Environment Variables
2. Add `DATABASE_URL` with your Neon connection string
3. Redeploy: Deployments → ... menu → Redeploy

### Problem: Counter shows 0 but signatures exist

**Solution:**
1. Open browser console (F12)
2. Check for errors
3. Test API directly: `https://your-site.vercel.app/api/count`
4. If you see CORS errors, they should resolve after a few minutes

### Problem: Form submission fails

**Solution:**
1. Check browser console for errors
2. Test API: `https://your-site.vercel.app/api/submit` (should show 405 Method Not Allowed - that's correct for GET)
3. Check Vercel function logs:
   - Vercel Dashboard → Your Project → Logs
   - Look for errors in `/api/submit` function
4. Verify DATABASE_URL is set correctly

### Problem: Comments not showing

**Solution:**
1. Verify signatures have `public_display = true` in database
2. Check comments are not empty:
```sql
SELECT * FROM signatures
WHERE public_display = true AND comment IS NOT NULL AND comment != '';
```
3. Test API: `https://your-site.vercel.app/api/comments`

### Problem: Database connection errors

**Solution:**
1. Verify connection string format:
   ```
   postgresql://user:pass@host.neon.tech/db?sslmode=require
   ```
2. Check Neon project is active (not paused)
3. Test connection in Neon SQL Editor
4. Make sure `?sslmode=require` is at the end

### Problem: Vercel build fails

**Solution:**
1. Check build logs in Vercel deployment details
2. Verify `package.json` exists with @neondatabase/serverless dependency
3. Make sure all API files are in `/api` folder
4. Try manual redeploy

## Updating Your Site

When you make changes:

```bash
# Make your changes to files

# Stage changes
git add .

# Commit with descriptive message
git commit -m "Description of changes"

# Push to GitHub
git push

# Vercel automatically redeploys!
```

Changes appear on your live site in ~1 minute.

## Advanced Configuration

### Enable Email Notifications

Add a webhook in Neon to get notified of new signatures:

1. Create a service like Zapier or Make.com workflow
2. Trigger: Neon webhook on INSERT to signatures table
3. Action: Send email notification

### Rate Limiting

To prevent spam, add rate limiting to your API:

1. Install `@upstash/ratelimit`:
```bash
npm install @upstash/ratelimit @upstash/redis
```

2. Add to each API function:
```javascript
import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '1 h'),
});
```

3. Set up Upstash Redis (free tier available)
4. Add environment variables in Vercel

### Analytics

Enable Vercel Analytics:

1. Vercel Dashboard → Your Project → Analytics
2. Enable Web Analytics (free)
3. View traffic, page views, performance metrics

### Custom Error Pages

Create `pages/404.html` and `pages/500.html` for custom error pages.

## Security Best Practices

✅ **Do:**
- Keep DATABASE_URL in Vercel environment variables (never commit to Git)
- Monitor signature submissions for spam/abuse
- Regularly backup database (Neon has automatic backups)
- Use HTTPS (Vercel enforces this automatically)

❌ **Don't:**
- Commit `.env` file to Git (it's in `.gitignore`)
- Share your DATABASE_URL publicly
- Disable SSL mode in connection string
- Expose database credentials in frontend code

## Database Maintenance

### Backup Database

Neon automatically backs up your database, but you can also export:

```sql
-- Export all data
SELECT * FROM signatures;
```

Download as CSV from Neon SQL Editor.

### Delete Spam Entries

```sql
-- Delete specific signature
DELETE FROM signatures WHERE id = 123;

-- Delete by email pattern
DELETE FROM signatures WHERE email LIKE '%spam%';
```

### View Database Size

```sql
SELECT
  pg_size_pretty(pg_database_size(current_database())) as size;
```

## Performance Optimization

### Database Indexing

Already included in `neon-schema.sql`:
- Index on `created_at` for fast sorting
- Index on `public_display` for comment queries
- Index on non-empty comments

### Function Cold Starts

Vercel serverless functions may have cold starts. To minimize:
- Functions automatically warm after first use
- Consider Vercel Pro for lower cold start times
- Neon keeps connections pooled for faster queries

## Scaling

### If You Get Lots of Traffic

**Neon Scaling (automatically handled):**
- Auto-scales compute based on demand
- Supports up to 10,000 concurrent connections
- No downtime during scaling

**Vercel Scaling (automatically handled):**
- Functions auto-scale to handle traffic
- CDN caches static assets globally
- No configuration needed

**Free Tier Limits:**
- Neon: 3GB storage, 200 hours compute/month
- Vercel: 100GB bandwidth, unlimited functions
- Upgrade if you exceed (both have affordable paid plans)

## Next Steps

1. ✅ Website is live and accepting signatures
2. ✅ Share petition URL widely
3. ✅ Monitor signature count in Neon
4. ✅ Export signatures periodically
5. ✅ Deliver signatures to Oakland officials
6. ✅ Update website with progress
7. ✅ Amplify resident voices

## Support Resources

- **Neon Docs**: [https://neon.tech/docs](https://neon.tech/docs)
- **Vercel Docs**: [https://vercel.com/docs](https://vercel.com/docs)
- **Neon Discord**: Community support
- **Vercel Community**: GitHub discussions

## Quick Reference Commands

```bash
# Test locally
vercel dev

# Deploy to production
vercel --prod

# View logs
vercel logs

# Add environment variable
vercel env add DATABASE_URL

# Remove old deployment
vercel remove [deployment-url]
```

---

**You're now live!** Every signature brings justice closer for Mandela House residents.

**Your petition URL**: `https://your-project-name.vercel.app`

Share it and demand accountability! 🎯
