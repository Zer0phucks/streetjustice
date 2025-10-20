import { neon } from '@neondatabase/serverless';

export default async function handler(req, res) {
  // Only allow GET requests
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    // Connect to Neon database
    const sql = neon(process.env.DATABASE_URL);

    // Get signature count
    const result = await sql`
      SELECT COUNT(*) as count FROM signatures
    `;

    return res.status(200).json({
      success: true,
      count: parseInt(result[0].count)
    });

  } catch (error) {
    console.error('Error getting signature count:', error);
    return res.status(500).json({
      success: false,
      count: 0,
      error: 'Failed to get signature count'
    });
  }
}
