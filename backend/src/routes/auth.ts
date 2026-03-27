import { Router, Request, Response } from "express";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { v4 as uuidv4 } from "uuid";
import pool from "../db";
import { CreateUserBody } from "../types/user";

const router = Router();

// POST /api/auth/register
router.post("/register", async (req: Request, res: Response) => {
  const { name, email, password } = req.body as CreateUserBody;

  if (!name || !email || !password) {
    res.status(400).json({ error: "name, email, and password are required" });
    return;
  }

  try {
    const existing = await pool.query("SELECT id FROM users WHERE email = $1", [email]);
    if (existing.rows.length > 0) {
      res.status(409).json({ error: "Email already in use" });
      return;
    }

    const passwordHash = await bcrypt.hash(password, 12);
    const id = uuidv4();

    const result = await pool.query(
      `INSERT INTO users (id, name, email, password_hash, yesterday_strain, daily_streak, recovery)
       VALUES ($1, $2, $3, $4, 0, 0, 100)
       RETURNING id, name, email`,
      [id, name, email, passwordHash]
    );

    const token = jwt.sign({ userId: id }, process.env.JWT_SECRET!, { expiresIn: "30d" });

    res.status(201).json({ user: result.rows[0], token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Registration failed" });
  }
});

// POST /api/auth/login
router.post("/login", async (req: Request, res: Response) => {
  const { email, password } = req.body;

  if (!email || !password) {
    res.status(400).json({ error: "email and password are required" });
    return;
  }

  try {
    const result = await pool.query("SELECT * FROM users WHERE email = $1", [email]);

    if (result.rows.length === 0) {
      res.status(401).json({ error: "Invalid email or password" });
      return;
    }

    const user = result.rows[0];
    const valid = await bcrypt.compare(password, user.password_hash);

    if (!valid) {
      res.status(401).json({ error: "Invalid email or password" });
      return;
    }

    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET!, { expiresIn: "30d" });

    res.json({ user: { id: user.id, name: user.name, email: user.email }, token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Login failed" });
  }
});


export default router;