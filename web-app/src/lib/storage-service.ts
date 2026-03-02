import { ref, uploadBytes, getDownloadURL } from "firebase/storage";
import { storage } from "@/lib/firebase";

export async function uploadIdImage(file: File, userId: string, side: "front" | "back"): Promise<string> {
  const extension = file.name.split(".").pop() || "jpg";
  const fileName = `${userId}_${side}_${Date.now()}.${extension}`;
  const storageRef = ref(storage, `images/${fileName}`);
  await uploadBytes(storageRef, file);
  const downloadUrl = await getDownloadURL(storageRef);
  return downloadUrl;
}
