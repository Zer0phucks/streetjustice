#!/bin/bash

# Migration Verification Script
# Compares signature counts between source and destination databases

set -e

echo "🔍 Database Migration Verification"
echo "=================================="
echo ""

# Check for required arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <source_database_url> <destination_database_url>"
    echo ""
    echo "Example:"
    echo "  $0 \"\$DATABASE_URL\" \"postgresql://user:pass@new-host/db\""
    exit 1
fi

SOURCE_URL="$1"
DEST_URL="$2"

echo "📊 Checking source database..."
SOURCE_COUNT=$(psql "$SOURCE_URL" -t -c "SELECT COUNT(*) FROM signatures;" | tr -d ' ')
SOURCE_COMMENTS=$(psql "$SOURCE_URL" -t -c "SELECT COUNT(*) FROM signatures WHERE comment IS NOT NULL AND comment != '';" | tr -d ' ')

echo "   ✅ Source signatures: $SOURCE_COUNT"
echo "   💬 Source comments: $SOURCE_COMMENTS"
echo ""

echo "📊 Checking destination database..."
DEST_COUNT=$(psql "$DEST_URL" -t -c "SELECT COUNT(*) FROM signatures;" | tr -d ' ')
DEST_COMMENTS=$(psql "$DEST_URL" -t -c "SELECT COUNT(*) FROM signatures WHERE comment IS NOT NULL AND comment != '';" | tr -d ' ')

echo "   ✅ Destination signatures: $DEST_COUNT"
echo "   💬 Destination comments: $DEST_COMMENTS"
echo ""

# Compare counts
if [ "$SOURCE_COUNT" -eq "$DEST_COUNT" ]; then
    echo "✅ SUCCESS: Signature counts match!"
else
    echo "⚠️  WARNING: Signature counts differ!"
    echo "   Missing: $((SOURCE_COUNT - DEST_COUNT)) signatures"
    exit 1
fi

if [ "$SOURCE_COMMENTS" -eq "$DEST_COMMENTS" ]; then
    echo "✅ SUCCESS: Comment counts match!"
else
    echo "⚠️  WARNING: Comment counts differ!"
    echo "   Missing: $((SOURCE_COMMENTS - DEST_COMMENTS)) comments"
    exit 1
fi

echo ""
echo "🎉 Migration verification complete!"
echo "   All data successfully migrated."
