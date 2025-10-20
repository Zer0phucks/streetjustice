import { neon } from '@neondatabase/serverless';

export default async function handler(req, res) {
  // Only allow POST requests
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const {
      firstName,
      lastName,
      email,
      city,
      state,
      zip,
      comment,
      publicDisplay
    } = req.body;

    // Validate required fields
    if (!firstName || !lastName || !email || !city || !state || !zip) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Connect to Neon database
    const sql = neon(process.env.DATABASE_URL);

    // Insert signature
    const result = await sql`
      INSERT INTO signatures (
        first_name,
        last_name,
        email,
        city,
        state,
        zip,
        comment,
        public_display
      ) VALUES (
        ${firstName},
        ${lastName},
        ${email},
        ${city},
        ${state},
        ${zip},
        ${comment || null},
        ${publicDisplay !== false}
      )
      RETURNING id, created_at
    `;

    return res.status(200).json({
      success: true,
      data: result[0]
    });

  } catch (error) {
    console.error('Error submitting signature:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to submit signature'
    });
  }
}
