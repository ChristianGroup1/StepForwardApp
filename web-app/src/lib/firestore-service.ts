import { collection, getDocs, doc, getDoc, query, where } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { GameModel, BrothersModel, BookModel } from "@/lib/types";
import { BackendEndpoints } from "@/lib/constants";

export async function getGames(): Promise<GameModel[]> {
  const snapshot = await getDocs(collection(db, BackendEndpoints.getGames));
  return snapshot.docs.map((d) => ({ id: d.id, ...d.data() } as GameModel));
}

export async function getGameById(id: string): Promise<GameModel | null> {
  const docRef = doc(db, BackendEndpoints.getGames, id);
  const snap = await getDoc(docRef);
  if (!snap.exists()) return null;
  return { id: snap.id, ...snap.data() } as GameModel;
}

export async function getBrothers(): Promise<BrothersModel[]> {
  const snapshot = await getDocs(collection(db, BackendEndpoints.getBrothers));
  return snapshot.docs.map((d) => ({ id: d.id, ...d.data() } as BrothersModel));
}

export async function getBooks(): Promise<BookModel[]> {
  const snapshot = await getDocs(collection(db, BackendEndpoints.getBooks));
  return snapshot.docs.map((d) => ({ id: d.id, ...d.data() } as BookModel));
}

export async function getUserFavoriteGames(favoriteIds: string[]): Promise<GameModel[]> {
  if (!favoriteIds.length) return [];
  const games: GameModel[] = [];
  // Firestore 'in' queries support max 30 items
  const chunks = [];
  for (let i = 0; i < favoriteIds.length; i += 30) {
    chunks.push(favoriteIds.slice(i, i + 30));
  }
  for (const chunk of chunks) {
    const q = query(collection(db, BackendEndpoints.getGames), where("__name__", "in", chunk));
    const snap = await getDocs(q);
    snap.docs.forEach((d) => games.push({ id: d.id, ...d.data() } as GameModel));
  }
  return games;
}

export async function searchGames(searchText: string): Promise<GameModel[]> {
  const all = await getGames();
  const lower = searchText.toLowerCase();
  return all.filter(
    (g) =>
      g.name.toLowerCase().includes(lower) ||
      g.explanation.toLowerCase().includes(lower) ||
      g.tags.some((t) => t.toLowerCase().includes(lower))
  );
}

export async function searchBrothers(searchText: string): Promise<BrothersModel[]> {
  const all = await getBrothers();
  const lower = searchText.toLowerCase();
  return all.filter(
    (b) =>
      b.name.toLowerCase().includes(lower) ||
      b.churchName.toLowerCase().includes(lower) ||
      b.government.toLowerCase().includes(lower) ||
      b.tags?.some((t) => t.toLowerCase().includes(lower))
  );
}
