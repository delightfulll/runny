import { Router, Response } from "express";
import { v4 as uuidv4 } from "uuid";
import pool from "../db";
import { authenticate, AuthRequest } from "../middleware/auth";
import { CreateActivityBody } from "../types/activity";

const router = Router();

router.use(authenticate);


// GET /api/activities — fetch all activities for the logged-in user
router.get("/", async (req: AuthRequest, res: Response) => {
  try {
    const result = await pool.query(
      "SELECT * FROM activities WHERE user_id = $1 ORDER BY date DESC",
      [req.userId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch activities" });
  }
});


// GET /api/activities/:id — fetch a single activity
router.get("/:id", async (req: AuthRequest, res: Response) => {
  try {
    const result = await pool.query(
      "SELECT * FROM activities WHERE id = $1 AND user_id = $2",
      [req.params.id, req.userId]
    );

    if (result.rows.length === 0) {
      res.status(404).json({ error: "Activity not found" });
      return;
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch activity" });
  }
});

// POST /api/activities — create a new activity
router.post("/", async (req: AuthRequest, res: Response) => {
  const { type, distance, time, date, calories, difficulty } = req.body as CreateActivityBody;

  if (!type || time == null || !date) {
    res.status(400).json({ error: "Missing required fields: type, time, date" });
    return;
  }

  if (type !== "weightlifting" && distance == null) {
    res.status(400).json({ error: "distance is required for running, biking, and walking" });
    return;
  }

  const averagePace = (type === "running" || type === "biking" || type === "walking") && distance ? (time / 60) / distance : null;

  const activityDistance = (type === "weightlifting") ? null : distance;

  try {
    const id = uuidv4();
    const result = await pool.query(
      `INSERT INTO activities (id, user_id, type, distance, time, date, calories, difficulty, average_pace)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING *`,
      [id, req.userId, type, activityDistance, time, date, calories ?? 0, difficulty, averagePace ?? 0]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to create activity" });
  }
});

// DELETE /api/activities/:id — delete an activity
router.delete("/:id", async (req: AuthRequest, res: Response) => {
  try {
    const result = await pool.query(
      "DELETE FROM activities WHERE id = $1 AND user_id = $2 RETURNING id",
      [req.params.id, req.userId]
    );

    if (result.rows.length === 0) {
      res.status(404).json({ error: "Activity not found" });
      return;
    }

    res.json({ deleted: result.rows[0].id });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to delete activity" });
  }
});

export default router;