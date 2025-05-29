// src/infrastructure/persistence/json_link_repository.ts
import * as fs from 'fs/promises';
import * as path from 'path';
import { Link } from '@domain/entities/link'; // Updated path
import { ILinkRepository } from '@domain/repositories/link_repository'; // Updated path
import { randomUUID } from 'crypto'; 

const linksFilePath = path.resolve(__dirname, '../../../data/links.json'); 

export class JsonLinkRepository implements ILinkRepository {
  private async readLinksFromFile(): Promise<Link[]> {
    try {
      await fs.access(linksFilePath); 
      const data = await fs.readFile(linksFilePath, 'utf-8');
      if (data.trim() === '') {
        return []; 
      }
      return JSON.parse(data).map((link: any) => ({
        ...link,
        createdAt: new Date(link.createdAt),
      }));
    } catch (error: any) {
      if (error.code === 'ENOENT') { 
        return []; 
      }
      console.error('Error reading links file:', error);
      throw new Error('Could not read links data.');
    }
  }

  private async writeLinksToFile(links: Link[]): Promise<void> {
    try {
      const directory = path.dirname(linksFilePath);
      await fs.mkdir(directory, { recursive: true }); 
      await fs.writeFile(linksFilePath, JSON.stringify(links, null, 2));
    } catch (error) {
      console.error('Error writing links file:', error);
      throw new Error('Could not save links data.');
    }
  }

  async getAll(): Promise<Link[]> {
    return this.readLinksFromFile();
  }

  async save(linkData: Omit<Link, 'id' | 'createdAt'> & { id?: string, createdAt?: Date }): Promise<Link> {
    const links = await this.readLinksFromFile();
    const newLink: Link = {
      id: linkData.id || randomUUID(), 
      url: linkData.url,
      createdAt: linkData.createdAt || new Date(),
    };
    
    if (linkData.id && links.some(l => l.id === linkData.id)) {
        throw new Error(`Link with ID ${linkData.id} already exists.`);
    }

    links.push(newLink);
    await this.writeLinksToFile(links);
    return newLink;
  }

  async findById(id: string): Promise<Link | null> {
    const links = await this.readLinksFromFile();
    return links.find(link => link.id === id) || null;
  }

  async findByUrl(url: string): Promise<Link | null> {
    const links = await this.readLinksFromFile();
    return links.find(link => link.url === url) || null;
  }

  async deleteById(id: string): Promise<boolean> {
    let links = await this.readLinksFromFile();
    const initialLength = links.length;
    links = links.filter(link => link.id !== id);
    if (links.length < initialLength) {
      await this.writeLinksToFile(links);
      return true;
    }
    return false;
  }
  
  async update(linkToUpdate: Link): Promise<Link | null> {
    const links = await this.readLinksFromFile();
    const index = links.findIndex(l => l.id === linkToUpdate.id);
    if (index === -1) {
      return null; 
    }
    
    links[index] = {
        ...linkToUpdate,
        createdAt: new Date(linkToUpdate.createdAt) 
    };
    await this.writeLinksToFile(links);
    return links[index];
  }
}
