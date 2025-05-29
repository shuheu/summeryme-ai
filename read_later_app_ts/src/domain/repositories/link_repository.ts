// src/domain/repositories/link_repository.ts
import { Link } from '@domain/entities/link'; // Updated path

export interface ILinkRepository {
  getAll(): Promise<Link[]>;
  save(link: Omit<Link, 'id' | 'createdAt'> & { id?: string }): Promise<Link>; 
  findById(id: string): Promise<Link | null>;
  findByUrl(url: string): Promise<Link | null>; 
  deleteById(id: string): Promise<boolean>; 
  update(link: Link): Promise<Link | null>; 
}
