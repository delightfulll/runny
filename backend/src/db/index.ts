import { Pool } from "pg";
import dotenv from "dotenv";



//WHAT IS THIS
dotenv.config();

// No need to check for Unix socket or Cloud SQL. Use a simple false.
const isUnixSocket = false;

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: isUnixSocket ? false : process.env.NODE_ENV === "production" ? { rejectUnauthorized: false } : false,
});

pool.on("error", (err) => {
  console.error("Unexpected database error", err);
  process.exit(-1);
});

export default pool;
