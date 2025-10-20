#!/bin/bash

# Deploy CSS Fix Script
# Run this to push the styling fix to Vercel

echo "🔧 Deploying CSS fix to Vercel..."
echo ""

# Check if git is initialized
if [ ! -d .git ]; then
    echo "❌ Error: Not a git repository"
    echo "Run: git init"
    exit 1
fi

# Add changes
echo "📦 Adding changes..."
git add vercel.json .gitignore STYLING_FIX.md

# Commit
echo "💾 Committing fix..."
git commit -m "Fix CSS loading on Vercel - simplified vercel.json"

# Push
echo "🚀 Pushing to GitHub..."
git push

echo ""
echo "✅ Done! Vercel will automatically redeploy."
echo ""
echo "⏳ Wait ~1 minute for deployment to complete"
echo "🔍 Check your Vercel dashboard to monitor progress"
echo "🌐 Then visit your site - styling should now work!"
echo ""
echo "Test URLs:"
echo "  - https://your-site.vercel.app/ (should be fully styled)"
echo "  - https://your-site.vercel.app/styles.css (should show CSS)"
echo ""
