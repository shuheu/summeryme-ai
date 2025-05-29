// src/domain/services/link_service.test.ts
import { LinkService } from '@domain/services/link_service';
import { ILinkRepository } from '@domain/repositories/link_repository';
import { Link } from '@domain/entities/link';
import { randomUUID } from 'crypto';

// Mock ILinkRepository
const mockLinkRepository: jest.Mocked<ILinkRepository> = {
  getAll: jest.fn(),
  save: jest.fn(),
  findById: jest.fn(),
  findByUrl: jest.fn(),
  deleteById: jest.fn(),
  update: jest.fn(),
};

// Reset mocks before each test
beforeEach(() => {
  jest.clearAllMocks();
});

describe('LinkService', () => {
  const linkService = new LinkService(mockLinkRepository);

  describe('addLink', () => {
    it('should add a new link successfully', async () => {
      const url = 'http://example.com';
      const mockSavedLink: Link = { id: randomUUID(), url, createdAt: new Date() };
      mockLinkRepository.findByUrl.mockResolvedValue(null);
      mockLinkRepository.save.mockResolvedValue(mockSavedLink);

      const result = await linkService.addLink(url);

      expect(result).toEqual(mockSavedLink);
      expect(mockLinkRepository.findByUrl).toHaveBeenCalledWith(url);
      expect(mockLinkRepository.save).toHaveBeenCalledWith(expect.objectContaining({ url }));
    });

    it('should throw an error if URL is invalid', async () => {
      await expect(linkService.addLink('invalid-url')).rejects.toThrow('Invalid URL format.');
    });

    it('should throw an error if URL already exists', async () => {
      const url = 'http://exists.com';
      mockLinkRepository.findByUrl.mockResolvedValue({ id: 'some-id', url, createdAt: new Date() });
      await expect(linkService.addLink(url)).rejects.toThrow('This URL has already been saved.');
    });
  });

  describe('getLinkById', () => {
    it('should return a link if found', async () => {
      const id = 'test-id';
      const mockLink: Link = { id, url: 'http://test.com', createdAt: new Date() };
      mockLinkRepository.findById.mockResolvedValue(mockLink);
      
      const result = await linkService.getLinkById(id);
      expect(result).toEqual(mockLink);
      expect(mockLinkRepository.findById).toHaveBeenCalledWith(id);
    });

    it('should return null if link not found', async () => {
      mockLinkRepository.findById.mockResolvedValue(null);
      const result = await linkService.getLinkById('not-found-id');
      expect(result).toBeNull();
    });
  });

  describe('getAllLinks', () => {
    it('should return all links', async () => {
      const mockLinks: Link[] = [
        { id: '1', url: 'http://link1.com', createdAt: new Date() },
        { id: '2', url: 'http://link2.com', createdAt: new Date() },
      ];
      mockLinkRepository.getAll.mockResolvedValue(mockLinks);
      const result = await linkService.getAllLinks();
      expect(result).toEqual(mockLinks);
      expect(mockLinkRepository.getAll).toHaveBeenCalled();
    });
  });

  describe('removeLink', () => {
    it('should remove a link successfully', async () => {
      const id = 'test-remove-id';
      mockLinkRepository.findById.mockResolvedValue({ id, url: 'http://toberemoved.com', createdAt: new Date() });
      mockLinkRepository.deleteById.mockResolvedValue(true);
      
      const result = await linkService.removeLink(id);
      expect(result).toBe(true);
      expect(mockLinkRepository.findById).toHaveBeenCalledWith(id);
      expect(mockLinkRepository.deleteById).toHaveBeenCalledWith(id);
    });

    it('should throw error if link to remove is not found', async () => {
      const id = 'not-found-remove-id';
      mockLinkRepository.findById.mockResolvedValue(null); // Link not found
      await expect(linkService.removeLink(id)).rejects.toThrow('Link with this ID not found.');
      expect(mockLinkRepository.deleteById).not.toHaveBeenCalled();
    });
  });
  
  describe('updateLink', () => {
    const id = 'update-id';
    const oldUrl = 'http://old.com';
    const newUrl = 'http://new.com';
    const existingLink: Link = { id, url: oldUrl, createdAt: new Date() };

    it('should update a link successfully', async () => {
        mockLinkRepository.findById.mockResolvedValue(existingLink);
        mockLinkRepository.findByUrl.mockResolvedValue(null); // New URL doesn't exist elsewhere
        mockLinkRepository.update.mockImplementation(async (link) => link); // Return the updated link

        const result = await linkService.updateLink(id, newUrl);

        expect(result).toEqual({ ...existingLink, url: newUrl });
        expect(mockLinkRepository.findById).toHaveBeenCalledWith(id);
        expect(mockLinkRepository.findByUrl).toHaveBeenCalledWith(newUrl);
        expect(mockLinkRepository.update).toHaveBeenCalledWith({ ...existingLink, url: newUrl });
    });

    it('should throw if new URL is invalid', async () => {
        await expect(linkService.updateLink(id, 'invalid-url')).rejects.toThrow('Invalid URL format for update.');
    });
    
    it('should return null if link to update is not found', async () => {
        mockLinkRepository.findById.mockResolvedValue(null);
        const result = await linkService.updateLink('non-existent-id', newUrl);
        expect(result).toBeNull();
    });

    it('should throw if new URL already exists for another link', async () => {
        mockLinkRepository.findById.mockResolvedValue(existingLink);
        mockLinkRepository.findByUrl.mockResolvedValue({ id: 'other-id', url: newUrl, createdAt: new Date() });
        
        await expect(linkService.updateLink(id, newUrl)).rejects.toThrow('Another link with this URL already exists.');
    });
  });
});
