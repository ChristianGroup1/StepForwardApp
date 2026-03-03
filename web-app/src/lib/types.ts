export interface UserModel {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  phoneNumber: string;
  government: string;
  churchName: string;
  isApproved?: boolean;
  frontId?: string | null;
  backId?: string | null;
  favorites?: string[];
}

export interface GameModel {
  id: string;
  name: string;
  coverUrl: string;
  explanation: string;
  isVisible?: boolean;
  laws: string;
  tags: string[];
  target: string;
  tools: string;
  videoLink: string;
}

export interface BrothersModel {
  id: string;
  name: string;
  coverUrl: string;
  phoneNumber: string;
  tags: string[];
  churchName: string;
  government: string;
  city: string;
  preferredMinistries: string[];
}

export interface BookModel {
  id: string;
  name: string;
  url: string;
  coverUrl?: string;
}
