#!/bin/bash
echo "🔧 Fixing Vercel deployment error..."
git add -A
git commit -m "Fix: Remove vercel.json - let Vercel auto-detect configuration"
git push
echo ""
echo "✅ Changes pushed! Vercel will redeploy automatically."
echo "⏳ Check Vercel dashboard in ~1 minute"
