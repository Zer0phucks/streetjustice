import { neon } from '@neondatabase/serverless';

export default async function handler(req, res) {
  // Only allow GET requests
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const limit = parseInt(req.query.limit) || 12;

    // Connect to Neon database
    const sql = neon(process.env.DATABASE_URL);

    // Get public comments
    const result = await sql`
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
      ORDER BY created_at DESC
      LIMIT ${limit}
    `;

    return res.status(200).json({
      success: true,
      data: result
    });

  } catch (error) {
    console.error('Error getting comments:', error);
    return res.status(500).json({
      success: false,
      data: [],
      error: 'Failed to get comments'
    });
  }
}
