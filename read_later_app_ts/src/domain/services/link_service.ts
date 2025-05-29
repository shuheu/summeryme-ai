// src/domain/services/link_service.ts
import { Link } from '@domain/entities/link'; // Updated path
import { ILinkRepository } from '@domain/repositories/link_repository'; // Updated path
import { randomUUID } from 'crypto'; 

export class LinkService {
  constructor(private linkRepository: ILinkRepository) {}

  async addLink(url: string): Promise<Link> {
    if (!this.isValidUrl(url)) {
      throw new Error('Invalid URL format.');
    }

    const existingLink = await this.linkRepository.findByUrl(url);
    if (existingLink) {
      throw new Error('This URL has already been saved.');
    }

    const newLink: Link = {
      id: randomUUID(),
      url,
      createdAt: new Date(),
    };
    return this.linkRepository.save(newLink);
  }

  async getLinkById(id: string): Promise<Link | null> {
    return this.linkRepository.findById(id);
  }

  async getAllLinks(): Promise<Link[]> {
    return this.linkRepository.getAll();
  }

  async removeLink(id: string): Promise<boolean> {
    const linkExists = await this.linkRepository.findById(id);
    if (!linkExists) {
        throw new Error('Link with this ID not found.');
    }
    return this.linkRepository.deleteById(id);
  }
  
  async updateLink(id: string, newUrl: string): Promise<Link | null> {
    if (!this.isValidUrl(newUrl)) {
      throw new Error('Invalid URL format for update.');
    }
    const linkToUpdate = await this.linkRepository.findById(id);
    if (!linkToUpdate) {
      return null; 
    }
    
    const existingLinkWithNewUrl = await this.linkRepository.findByUrl(newUrl);
    if (existingLinkWithNewUrl && existingLinkWithNewUrl.id !== id) {
        throw new Error('Another link with this URL already exists.');
    }

    const updatedLink = { ...linkToUpdate, url: newUrl };
    return this.linkRepository.update(updatedLink);
  }

  private isValidUrl(urlString: string): boolean {
    try {
      new URL(urlString);
      return true;
    } catch (error) {
      return false;
    }
  }
}
