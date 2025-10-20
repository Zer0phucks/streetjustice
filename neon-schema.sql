-- Mandela House Petition Database Schema for Neon
-- Run this SQL in your Neon SQL Editor or via psql

-- Create signatures table
CREATE TABLE IF NOT EXISTS signatures (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  city VARCHAR(255) NOT NULL,
  state VARCHAR(100) NOT NULL,
  zip VARCHAR(20) NOT NULL,
  comment TEXT,
  public_display BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_signatures_created_at ON signatures(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_signatures_public_display ON signatures(public_display);
CREATE INDEX IF NOT EXISTS idx_signatures_comment ON signatures(comment) WHERE comment IS NOT NULL AND comment != '';

-- Create a view for public comments
CREATE OR REPLACE VIEW public_comments AS
SELECT
  first_name,
  last_name,
  city,
  state,
  comment,
  created_at
FROM signatures
WHERE public_display = true
  AND comment IS NOT NULL
  AND comment != ''
ORDER BY created_at DESC;
