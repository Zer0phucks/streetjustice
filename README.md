# Mandela House Petition Website

A website documenting injustices at Mandela House (Project Homekey) in Oakland, California, with an integrated petition system.

## Features

- **Petition System**: Sign and track petition signatures in real-time
- **Signature Counter**: Live counter showing total petition support
- **Comment Display**: Public comments from petition signers
- **Auto-refresh**: Automatic updates every 30 seconds
- **Responsive Design**: Mobile-friendly layout
- **Neon Database**: Serverless Postgres database for petition data
- **Vercel Serverless Functions**: API endpoints for data operations

## Tech Stack

- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **Backend**: Vercel Serverless Functions (Node.js)
- **Database**: Neon (Serverless Postgres)
- **Deployment**: Vercel
- **Package**: @neondatabase/serverless

## Setup Instructions

### 1. Neon Database Setup

1. Create a free account at [Neon](https://neon.tech)
2. Create a new project
3. In the SQL Editor, run the entire `neon-schema.sql` file
4. Copy your database connection string:
   - Go to Dashboard → Connection Details
   - Copy the connection string (starts with `postgresql://`)

### 2. Local Development

1. Clone this repository
2. Create a `.env` file in the project root:

```bash
DATABASE_URL=your_neon_connection_string_here
```

3. Install dependencies:

```bash
npm install
```

4. Run locally with Vercel CLI:

```bash
npm install -g vercel
vercel dev
```

5. Open `http://localhost:3000` in your browser

### 3. Deploy to Vercel

#### Option A: Deploy via GitHub (Recommended)

1. Push your code to GitHub:

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin YOUR_GITHUB_REPO_URL
git push -u origin main
```

2. Go to [Vercel](https://vercel.com)
3. Click "New Project" → Import your GitHub repository
4. Add environment variable:
   - Key: `DATABASE_URL`
   - Value: Your Neon connection string
5. Click "Deploy"

#### Option B: Deploy via Vercel CLI

1. Install Vercel CLI:

```bash
npm i -g vercel
```

2. Deploy:

```bash
vercel
```

3. Add environment variable:

```bash
vercel env add DATABASE_URL
```

4. Paste your Neon connection string when prompted

5. Redeploy:

```bash
vercel --prod
```

## File Structure

```
streetjustice/
├── api/
│   ├── submit.js          # API endpoint to submit signatures
│   ├── count.js           # API endpoint to get signature count
│   └── comments.js        # API endpoint to get public comments
├── index.html             # Main website HTML
├── styles.css             # All styling
├── neon-schema.sql        # Database schema for Neon
├── package.json           # Node.js dependencies
├── vercel.json            # Vercel deployment configuration
├── .env.example           # Environment variables template
├── .gitignore             # Git ignore configuration
├── README.md              # This file
├── DEPLOYMENT.md          # Detailed deployment guide
├── QUICKSTART.md          # Quick start guide
├── THEN.jpg               # Before image
└── NOW.png                # After image
```

## API Endpoints

### POST /api/submit
Submit a new petition signature

**Request Body:**
```json
{
  "firstName": "string",
  "lastName": "string",
  "email": "string",
  "city": "string",
  "state": "string",
  "zip": "string",
  "comment": "string (optional)",
  "publicDisplay": "boolean"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "created_at": "2025-10-20T12:00:00Z"
  }
}
```

### GET /api/count
Get total signature count

**Response:**
```json
{
  "success": true,
  "count": 1234
}
```

### GET /api/comments?limit=12
Get public comments

**Query Parameters:**
- `limit` (optional): Number of comments to return (default: 12)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "first_name": "John",
      "last_name": "Doe",
      "city": "Oakland",
      "state": "CA",
      "comment": "This matters because...",
      "created_at": "2025-10-20T12:00:00Z"
    }
  ]
}
```

## Features Breakdown

### Petition Form
- Collects: First name, last name, email, city, state, ZIP, optional comment
- Checkbox for public display consent
- Form validation
- Loading state during submission

### Signature Counter
- Real-time count display
- Updates every 30 seconds
- Pulse animation on updates
- Comma-separated formatting (1,234)

### Comment Display
- Shows up to 12 recent comments
- Only displays if public_display = true and comment exists
- Shows first name and last initial for privacy
- Location display (City, State)
- Responsive grid layout

### Auto-refresh
- Counter and comments update every 30 seconds
- No manual refresh needed

## Security Features

- **XSS Protection**: All user input is escaped before display
- **SQL Injection Protection**: Parameterized queries via Neon client
- **Email Privacy**: Emails are never displayed publicly
- **Name Privacy**: Only first name + last initial shown
- **HTTPS**: Enforced by Vercel
- **Environment Variables**: Database credentials stored securely in Vercel

## Monitoring

### View Signatures in Neon

1. Go to your Neon project dashboard
2. Click "SQL Editor"
3. Run query:

```sql
SELECT * FROM signatures ORDER BY created_at DESC;
```

### Export Data

```sql
-- Export all signatures
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

Then click "Download CSV" in Neon SQL Editor.

### Statistics

```sql
-- Total signatures
SELECT COUNT(*) FROM signatures;

-- Signatures by state
SELECT state, COUNT(*) as count
FROM signatures
GROUP BY state
ORDER BY count DESC;

-- Signatures with comments
SELECT COUNT(*) FROM signatures
WHERE comment IS NOT NULL AND comment != '';
```

## Troubleshooting

### Counter shows 0
- Check browser console for errors
- Verify Vercel environment variable `DATABASE_URL` is set
- Test API endpoint: `https://your-site.vercel.app/api/count`

### Form submission fails
- Check browser console for errors
- Verify API is responding: `https://your-site.vercel.app/api/submit`
- Check Vercel function logs for errors

### Comments not displaying
- Verify comments exist with `public_display = true`
- Test API endpoint: `https://your-site.vercel.app/api/comments`
- Check browser console for errors

### Database connection errors
- Verify `DATABASE_URL` in Vercel environment variables
- Test connection in Neon dashboard
- Check Neon project is not paused

## Environment Variables

Set these in Vercel:

- `DATABASE_URL`: Your Neon Postgres connection string

Format:
```
postgresql://username:password@host.neon.tech/database?sslmode=require
```

## Customization

### Change Colors
Edit CSS variables in `styles.css`:
```css
:root {
    --primary-color: #c41e3a;  /* Main red color */
    --secondary-color: #1a1a1a; /* Dark color */
    --accent-color: #ff6b35;    /* Accent */
    --warning: #f39c12;         /* Yellow/warning */
}
```

### Change Number of Displayed Comments
In `index.html`, modify the fetch call:
```javascript
await fetch(`${API_BASE}/api/comments?limit=20`); // Show 20 instead of 12
```

### Change Auto-refresh Interval
In `index.html`, modify the setInterval:
```javascript
setInterval(async () => {
    await updateSignatureCount();
    await loadComments();
}, 60000); // 60 seconds instead of 30
```

## Development

### Run locally
```bash
vercel dev
```

### Test API endpoints
```bash
# Test count
curl http://localhost:3000/api/count

# Test comments
curl http://localhost:3000/api/comments?limit=5

# Test submit
curl -X POST http://localhost:3000/api/submit \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Test","lastName":"User","email":"test@example.com","city":"Oakland","state":"CA","zip":"94612","comment":"Test comment","publicDisplay":true}'
```

## Performance

- **Serverless Functions**: Auto-scaling, pay per request
- **Neon Database**: Auto-scaling, auto-suspend when idle
- **CDN**: Static assets cached globally via Vercel
- **Optimized Queries**: Indexed columns for fast lookups

## Cost

With free tiers:
- **Vercel**: 100GB bandwidth, unlimited serverless function invocations
- **Neon**: 3GB storage, 200 hours compute per month
- **Total**: $0/month for moderate traffic

## Support

For issues or questions:
1. Check browser console for errors
2. Review Vercel function logs
3. Test API endpoints directly
4. Verify Neon database connection

## License

This project is dedicated to demanding accountability and justice for Mandela House residents.
