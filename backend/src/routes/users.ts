import { Router, Response } from "express";
import pool from "../db";
import { authenticate, AuthRequest } from "../middleware/auth";

const router = Router();

router.use(authenticate);

// GET /api/users/me — get the logged-in user's profile
router.get("/me", async (req: AuthRequest, res: Response) => {
  try {
    const result = await pool.query(
      "SELECT id, name, email, yesterday_strain, daily_streak, recovery, created_at FROM users WHERE id = $1",
      [req.userId]
    );
  
    if (result.rows.length === 0) {
      res.status(404).json({ error: "User not found" });
      return;
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch user" });
  }
});

// PATCH /api/users/me — update user profile fields
router.patch("/me", async (req: AuthRequest, res: Response) => {
  const { name, yesterdayStrain, dailyStreak, recovery } = req.body;

  try {
    const result = await pool.query(
      `UPDATE users
       SET name = COALESCE($1, name),
           yesterday_strain = COALESCE($2, yesterday_strain),
           daily_streak = COALESCE($3, daily_streak),
           recovery = COALESCE($4, recovery)
       WHERE id = $5
       RETURNING id, name, email, yesterday_strain, daily_streak, recovery`,
      [name, yesterdayStrain, dailyStreak, recovery, req.userId]
    );

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to update user" });
  }
});

export default router;
