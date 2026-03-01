"use client";

import React, { createContext, useContext, useEffect, useState } from "react";
import {
  User,
  onAuthStateChanged,
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut as firebaseSignOut,
  GoogleAuthProvider,
  signInWithPopup,
  sendPasswordResetEmail,
  deleteUser,
} from "firebase/auth";
import { doc, getDoc, setDoc, updateDoc, deleteDoc, arrayUnion, arrayRemove } from "firebase/firestore";
import { auth, db } from "@/lib/firebase";
import { UserModel } from "@/lib/types";
import { BackendEndpoints } from "@/lib/constants";

interface AuthContextType {
  user: User | null;
  userData: UserModel | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<UserModel>;
  signUp: (email: string, password: string, userData: Omit<UserModel, "id">) => Promise<UserModel>;
  signInWithGoogle: () => Promise<{ user: User; isNewUser: boolean; userData?: UserModel }>;
  completeGoogleSignUp: (userData: UserModel) => Promise<void>;
  logout: () => Promise<void>;
  resetPassword: (email: string) => Promise<void>;
  updateUserProfile: (data: Partial<UserModel>) => Promise<void>;
  deleteAccount: (password?: string) => Promise<void>;
  refreshUserData: () => Promise<void>;
  toggleFavorite: (gameId: string) => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [userData, setUserData] = useState<UserModel | null>(null);
  const [loading, setLoading] = useState(true);

  const fetchUserData = async (uid: string): Promise<UserModel | null> => {
    try {
      const userDoc = await getDoc(doc(db, BackendEndpoints.getUserData, uid));
      if (userDoc.exists()) {
        return { id: uid, ...userDoc.data() } as UserModel;
      }
      return null;
    } catch {
      return null;
    }
  };

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      setUser(firebaseUser);
      if (firebaseUser) {
        const data = await fetchUserData(firebaseUser.uid);
        setUserData(data);
      } else {
        setUserData(null);
      }
      setLoading(false);
    });
    return () => unsubscribe();
  }, []);

  const login = async (email: string, password: string): Promise<UserModel> => {
    const cred = await signInWithEmailAndPassword(auth, email, password);
    const data = await fetchUserData(cred.user.uid);
    if (!data) throw new Error("بيانات المستخدم غير موجودة");
    setUserData(data);
    return data;
  };

  const signUp = async (email: string, password: string, userInfo: Omit<UserModel, "id">): Promise<UserModel> => {
    const cred = await createUserWithEmailAndPassword(auth, email, password);
    const model: UserModel = { id: cred.user.uid, ...userInfo };
    await setDoc(doc(db, BackendEndpoints.addUserData, cred.user.uid), {
      firstName: model.firstName,
      lastName: model.lastName,
      email: model.email,
      phoneNumber: model.phoneNumber,
      government: model.government,
      churchName: model.churchName,
      isApproved: false,
      frontId: model.frontId || null,
      backId: model.backId || null,
      favorites: [],
    });
    setUserData(model);
    return model;
  };

  const signInWithGoogle = async () => {
    const provider = new GoogleAuthProvider();
    const cred = await signInWithPopup(auth, provider);
    const userDoc = await getDoc(doc(db, BackendEndpoints.getUserData, cred.user.uid));
    if (userDoc.exists()) {
      const data = { id: cred.user.uid, ...userDoc.data() } as UserModel;
      setUserData(data);
      return { user: cred.user, isNewUser: false, userData: data };
    }
    return { user: cred.user, isNewUser: true };
  };

  const completeGoogleSignUp = async (model: UserModel) => {
    await setDoc(doc(db, BackendEndpoints.addUserData, model.id), {
      firstName: model.firstName,
      lastName: model.lastName,
      email: model.email,
      phoneNumber: model.phoneNumber,
      government: model.government,
      churchName: model.churchName,
      isApproved: false,
      frontId: model.frontId || null,
      backId: model.backId || null,
      favorites: [],
    });
    setUserData(model);
  };

  const logout = async () => {
    await firebaseSignOut(auth);
    setUser(null);
    setUserData(null);
  };

  const resetPassword = async (email: string) => {
    await sendPasswordResetEmail(auth, email);
  };

  const updateUserProfile = async (data: Partial<UserModel>) => {
    if (!user) throw new Error("يجب تسجيل الدخول أولاً");
    await updateDoc(doc(db, BackendEndpoints.addUserData, user.uid), data);
    const updated = await fetchUserData(user.uid);
    if (updated) setUserData(updated);
  };

  const deleteAccount = async () => {
    if (!user) throw new Error("يجب تسجيل الدخول أولاً");
    await deleteDoc(doc(db, BackendEndpoints.getUserData, user.uid));
    await deleteUser(user);
    setUser(null);
    setUserData(null);
  };

  const refreshUserData = async () => {
    if (user) {
      const data = await fetchUserData(user.uid);
      if (data) setUserData(data);
    }
  };

  const toggleFavorite = async (gameId: string) => {
    if (!user || !userData) return;
    const isFav = userData.favorites?.includes(gameId);
    await updateDoc(doc(db, BackendEndpoints.getUserData, user.uid), {
      favorites: isFav ? arrayRemove(gameId) : arrayUnion(gameId),
    });
    await refreshUserData();
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        userData,
        loading,
        login,
        signUp,
        signInWithGoogle,
        completeGoogleSignUp,
        logout,
        resetPassword,
        updateUserProfile,
        deleteAccount,
        refreshUserData,
        toggleFavorite,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) throw new Error("useAuth must be used within AuthProvider");
  return context;
}
