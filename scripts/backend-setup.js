// Backend API setup with Express.js and PostgreSQL
const express = require("express")
const cors = require("cors")
const admin = require("firebase-admin")
const { Pool } = require("pg")

const app = express()
const port = process.env.PORT || 3000

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert({
    projectId: process.env.FIREBASE_PROJECT_ID,
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, "\n"),
  }),
})

// Database connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === "production" ? { rejectUnauthorized: false } : false,
})

// Middleware
app.use(cors())
app.use(express.json())

// Auth middleware
const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers["authorization"]
  const token = authHeader && authHeader.split(" ")[1]

  if (!token) {
    return res.status(401).json({ error: "Access token required" })
  }

  try {
    const decodedToken = await admin.auth().verifyIdToken(token)
    req.user = decodedToken
    next()
  } catch (error) {
    return res.status(403).json({ error: "Invalid token" })
  }
}

// Routes

// Auth Routes
app.post("/api/auth/register", async (req, res) => {
  try {
    const { email, name, phone, role, address } = req.body

    const result = await pool.query(
      "INSERT INTO users (email, name, phone, role, address, created_at) VALUES ($1, $2, $3, $4, $5, NOW()) RETURNING *",
      [email, name, phone, role, address],
    )

    res.json({ success: true, data: result.rows[0] })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

app.get("/api/users/profile", authenticateToken, async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM users WHERE email = $1", [req.user.email])

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "User not found" })
    }

    res.json({ success: true, data: result.rows[0] })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

// Pickup Routes
app.post("/api/pickups/request", authenticateToken, async (req, res) => {
  try {
    const { fabric_type, estimated_weight, pickup_address, photos, notes } = req.body

    const result = await pool.query(
      `INSERT INTO pickup_requests 
       (tailor_id, fabric_type, estimated_weight, pickup_address, photos, notes, status, created_at) 
       VALUES ($1, $2, $3, $4, $5, $6, 'pending', NOW()) RETURNING *`,
      [req.user.uid, fabric_type, estimated_weight, pickup_address, JSON.stringify(photos), notes],
    )

    res.json({ success: true, data: result.rows[0] })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

app.get("/api/pickups/tailor/:tailorId", authenticateToken, async (req, res) => {
  try {
    const { tailorId } = req.params
    const { page = 1, limit = 10 } = req.query
    const offset = (page - 1) * limit

    const result = await pool.query(
      "SELECT * FROM pickup_requests WHERE tailor_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3",
      [tailorId, limit, offset],
    )

    const countResult = await pool.query("SELECT COUNT(*) FROM pickup_requests WHERE tailor_id = $1", [tailorId])

    res.json({
      success: true,
      data: {
        pickups: result.rows,
        total: Number.parseInt(countResult.rows[0].count),
        page: Number.parseInt(page),
        limit: Number.parseInt(limit),
      },
    })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

app.get("/api/pickups/logistics/:area", authenticateToken, async (req, res) => {
  try {
    const { area } = req.params

    const result = await pool.query(
      `SELECT pr.*, u.name as tailor_name, u.phone as tailor_phone 
       FROM pickup_requests pr 
       JOIN users u ON pr.tailor_id = u.id 
       WHERE pr.status IN ('pending', 'assigned') 
       AND pr.pickup_address ILIKE $1 
       ORDER BY pr.created_at ASC`,
      [`%${area}%`],
    )

    res.json({ success: true, data: result.rows })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

// Product Routes
app.get("/api/products/catalog", async (req, res) => {
  try {
    const { category, page = 1, limit = 20, sort = "created_at" } = req.query
    const offset = (page - 1) * limit

    let query = "SELECT * FROM products WHERE is_active = true"
    const params = []

    if (category && category !== "All") {
      query += " AND category = $1"
      params.push(category)
    }

    query += ` ORDER BY ${sort} DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`
    params.push(limit, offset)

    const result = await pool.query(query, params)

    res.json({ success: true, data: result.rows })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

// Order Routes
app.post("/api/orders/create", authenticateToken, async (req, res) => {
  try {
    const { items, shipping_address, total_amount } = req.body

    // Start transaction
    const client = await pool.connect()

    try {
      await client.query("BEGIN")

      // Create order
      const orderResult = await client.query(
        "INSERT INTO orders (customer_id, total_amount, shipping_address, status, order_date) VALUES ($1, $2, $3, $4, NOW()) RETURNING *",
        [req.user.uid, total_amount, shipping_address, "pending"],
      )

      const orderId = orderResult.rows[0].id

      // Create order items
      for (const item of items) {
        await client.query(
          "INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES ($1, $2, $3, $4)",
          [orderId, item.product_id, item.quantity, item.unit_price],
        )
      }

      await client.query("COMMIT")

      res.json({ success: true, data: orderResult.rows[0] })
    } catch (error) {
      await client.query("ROLLBACK")
      throw error
    } finally {
      client.release()
    }
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

// Volunteer Routes
app.post("/api/volunteers/log-hours", authenticateToken, async (req, res) => {
  try {
    const { task_category, hours_logged, description } = req.body

    const result = await pool.query(
      "INSERT INTO volunteer_hours (volunteer_id, task_category, hours_logged, description, log_date) VALUES ($1, $2, $3, $4, NOW()) RETURNING *",
      [req.user.uid, task_category, hours_logged, description],
    )

    res.json({ success: true, data: result.rows[0] })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

// Start server
app.listen(port, () => {
  console.log(`ReFab API server running on port ${port}`)
})
