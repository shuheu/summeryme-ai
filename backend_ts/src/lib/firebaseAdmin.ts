import { getApps, initializeApp, applicationDefault } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';

const app =
  getApps().length > 0
    ? getApps()[0]
    : initializeApp({ credential: applicationDefault() });

export const firebaseAuth = getAuth(app);
