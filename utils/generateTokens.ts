import jwt from "jsonwebtoken";

export const createToken = (user: { id: string; role: string }) => {
  const accessTokenSecret = process.env.JWT_ACCESS_SECRET;
  const refreshTokenSecret = process.env.JWT_REFRESH_SECRET;

  if (!accessTokenSecret || !refreshTokenSecret) {
    throw new Error("Missing JWT secrets in .env file"); 
  }

  const accessToken = jwt.sign(
    { id: user.id, role: user.role },
    accessTokenSecret,
    { expiresIn: "15m" }
  );

  const refreshToken = jwt.sign(
    { id: user.id, role: user.role },
    refreshTokenSecret,
    { expiresIn: "7d" }
  );

  return { accessToken, refreshToken };
};