export type ActivityType = "running" | "biking" | "weightlifting" | "walking";
export type Difficulty = "easy" | "mid" | "hard";

export interface Activity {
  id: string;
  userId: string;
  type: ActivityType;
  distance: number | null; // miles, null for weightlifting
  time: number;            // seconds
  date: string;            // ISO 8601
  calories: number;
  difficulty: Difficulty;
  averagePace: number | null; // min/mile, null for weightlifting
}

export interface CreateActivityBody {
  type: ActivityType;
  distance?: number; // optional, not needed for weightlifting
  time: number;
  date: string;
  calories: number;
  difficulty: Difficulty;
}
