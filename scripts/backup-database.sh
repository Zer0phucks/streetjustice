#!/bin/bash

# Database Backup Script for Neon PostgreSQL
# This creates a backup of your petition signatures

set -e  # Exit on error

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep DATABASE_URL | xargs)
else
    echo "❌ Error: .env file not found"
    exit 1
fi

# Check if DATABASE_URL is set
if [ -z "$DATABASE_URL" ]; then
    echo "❌ Error: DATABASE_URL not found in .env"
    exit 1
fi

# Create backup directory
BACKUP_DIR="backups"
mkdir -p $BACKUP_DIR

# Generate backup filename with timestamp
BACKUP_FILE="$BACKUP_DIR/petition-backup-$(date +%Y%m%d-%H%M%S).sql"

echo "🔄 Starting database backup..."
echo "📁 Backup location: $BACKUP_FILE"

# Check if pg_dump is installed
if ! command -v pg_dump &> /dev/null; then
    echo "❌ Error: pg_dump not found. Install PostgreSQL client:"
    echo "   Ubuntu/Debian: sudo apt-get install postgresql-client"
    echo "   macOS: brew install postgresql"
    exit 1
fi

# Perform backup
if pg_dump "$DATABASE_URL" > "$BACKUP_FILE"; then
    echo "✅ Backup completed successfully!"
    echo "📊 Backup size: $(du -h $BACKUP_FILE | cut -f1)"

    # Get signature count
    SIGNATURE_COUNT=$(psql "$DATABASE_URL" -t -c "SELECT COUNT(*) FROM signatures;" 2>/dev/null || echo "unknown")
    echo "📝 Total signatures backed up: $SIGNATURE_COUNT"

    # Compress backup
    echo "🗜️  Compressing backup..."
    gzip "$BACKUP_FILE"
    echo "✅ Compressed backup: ${BACKUP_FILE}.gz"
    echo "📊 Compressed size: $(du -h ${BACKUP_FILE}.gz | cut -f1)"
else
    echo "❌ Backup failed!"
    exit 1
fi

echo ""
echo "🎉 Backup complete!"
echo "📂 Location: ${BACKUP_FILE}.gz"
echo ""
echo "To restore this backup:"
echo "  gunzip ${BACKUP_FILE}.gz"
echo "  psql \"YOUR_NEW_DATABASE_URL\" < $BACKUP_FILE"
