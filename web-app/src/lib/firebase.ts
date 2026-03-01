import { initializeApp, getApps } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";

const firebaseConfig = {
  apiKey: "AIzaSyCkEJrv0IyBNARUfonqM3mJtA3LnXlohsA",
  authDomain: "stepforward-b4fba.firebaseapp.com",
  projectId: "stepforward-b4fba",
  storageBucket: "stepforward-b4fba.firebasestorage.app",
  messagingSenderId: "888953774658",
  appId: "1:888953774658:web:6895d560ad1f5da81a03db",
  measurementId: "G-684JPTCDBE",
};

const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApps()[0];

export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);
export default app;
