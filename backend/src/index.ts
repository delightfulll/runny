import express from "express";
import cors from "cors";
import helmet from "helmet";
import dotenv from "dotenv";

import activitiesRouter from "./routes/activities";
import usersRouter from "./routes/users";
import authRouter from "./routes/auth";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 8080;

app.use(helmet());
app.use(cors());
app.use(express.json());

app.get("/health", (_req, res) => {
  res.json({ message: "OK" });
});

// Routes
app.use("/api/activities", activitiesRouter);
app.use("/api/users", usersRouter);
app.use("/api/auth", authRouter);

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

export default app;
