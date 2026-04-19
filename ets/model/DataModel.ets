export interface User {
  id: string;
  username: string;
  avatar: string;
  phone: string;
  email: string;
  schoolId: string;
  backgroundColor?: string;
}

export enum ItemStatus {
  LOST = 'lost',
  FOUND = 'found',
  CLAIMED = 'claimed',
  RETURNED = 'returned'
}

export enum ItemType {
  LOST = 'lost',
  FOUND = 'found'
}

export interface LostItem {
  id: string;
  title: string;
  description: string;
  type: ItemType;
  status: ItemStatus;
  location: string;
  time: Date;
  contact: string;
  images: string[];
  publisherId: string;
  publisherName: string;
  category: string;
  tags: string[];
  createdAt: Date;
  claimCode?: string;
}

export interface Message {
  id: string;
  title: string;
  content: string;
  itemId: string;
  fromUserId: string;
  toUserId: string;
  type: string;
  isRead: boolean;
  createdAt: Date;
}