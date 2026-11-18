// Extend Express Request with the authenticated user's id.
declare global {
    namespace Express {
        interface Request {
            userId?: string;
        }
    }
}

export {};
