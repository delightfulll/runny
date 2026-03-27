export interface User {
  id: string;
  name: string;
  email: string;
  yesterdayStrain: number;
  dailyStreak: number;
  recovery: number;
  createdAt: string;
}

export interface CreateUserBody {
  name: string;
  email: string;
  password: string;
}
