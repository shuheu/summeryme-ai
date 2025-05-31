// src/infrastructure/persistence/json_link_repository.test.ts
import { JsonLinkRepository } from '@infrastructure/persistence/json_link_repository';
import { Link } from '@domain/entities/link';
import * as fs from 'fs/promises';
import * as path from 'path'; // Import path

// Mock fs/promises
jest.mock('fs/promises');
const mockFs = fs as jest.Mocked<typeof fs>;

// Helper to reset mocks and potentially mock data
const mockDataStore: Link[] = [];
// __dirname in Jest context will be the directory of the test file itself: src/infrastructure/persistence/
const linksFilePathResolved = path.resolve(__dirname, '../../../data/links.json'); 

beforeEach(() => {
  jest.clearAllMocks();
  mockDataStore.length = 0; // Clear the in-memory store

  // Default mock implementations
  // access: Simulate file "existence" based on mockDataStore or specific test setup
  mockFs.access.mockImplementation(async (filePath) => {
    // This simplified mock for 'access' might need adjustment based on how JsonLinkRepository uses it.
    // The repo uses it to check existence before read. If read is mocked to throw ENOENT, access can be simpler.
    if (filePath === linksFilePathResolved) { // Check if it's the correct file path
        // To accurately simulate, we'd need to know if mockDataStore represents an existing file.
        // For now, let's assume if readFile is setup to succeed for this path, access should too.
        // This part is tricky because readLinksFromFile checks access then reads.
        // The mock for readFile is more critical for controlling test flow.
        // If readFile for linksFilePathResolved is mocked to return data, access should resolve.
        // If readFile is mocked to throw ENOENT, access should reject with ENOENT.
        // For simplicity here, let's assume if we intend for a read to succeed, access should resolve.
        // This means tests need to ensure readFile is mocked appropriately for the access check to make sense.
        return Promise.resolve(); // Default to exists, test cases can override if needed
    }
    const error: any = new Error('File not found by access mock');
    error.code = 'ENOENT';
    return Promise.reject(error);
  });

  mockFs.readFile.mockImplementation(async (filePath, options) => {
    if (filePath === linksFilePathResolved) {
      if (mockDataStore.length === 0) { 
         const error: any = new Error('File not found for read or is empty (mock)');
         error.code = 'ENOENT'; 
         throw error;
      }
      return Promise.resolve(JSON.stringify(mockDataStore));
    }
    const error: any = new Error('File not found during read (mock)');
    error.code = 'ENOENT';
    throw error;
  });
  
  mockFs.writeFile.mockImplementation(async (filePath, data) => {
    if (filePath === linksFilePathResolved) {
      const parsedData = JSON.parse(data as string);
      mockDataStore.length = 0; 
      mockDataStore.push(...parsedData);
      // After writing, the file "exists" for subsequent access/read calls in the same test
      mockFs.access.mockResolvedValue(Promise.resolve()); 
      return Promise.resolve();
    }
    throw new Error('Failed to write to mock file');
  });
  
  mockFs.mkdir.mockResolvedValue(undefined); 
});

describe('JsonLinkRepository', () => {
  const repository = new JsonLinkRepository();

  describe('getAll', () => {
    it('should return all links from the file', async () => {
      const date = new Date();
      mockDataStore.push({ id: '1', url: 'http://example1.com', createdAt: date });
      // For this test, ensure readFile returns the current mockDataStore content
      // The beforeEach already sets up readFile to use mockDataStore, so this override might not be needed
      // unless specific behavior for this test is required different from default mock.
      // mockFs.readFile.mockResolvedValueOnce(JSON.stringify(mockDataStore)); // Already handled by default mock if store has data

      const links = await repository.getAll();
      expect(links).toHaveLength(1);
      expect(links[0].url).toBe('http://example1.com');
      expect(links[0].createdAt).toEqual(date); 
      expect(mockFs.readFile).toHaveBeenCalledWith(linksFilePathResolved, 'utf-8');
    });
    
    it('should return an empty array if the file does not exist or is empty', async () => {
       // mockDataStore is empty by default in beforeEach
       // The default readFile mock will throw ENOENT if mockDataStore is empty.
       const links = await repository.getAll();
       expect(links).toEqual([]);
    });
  });

  describe('save', () => {
    it('should save a new link to the file', async () => {
      const newLinkData = { url: 'http://new.com' };
      // save calls readLinksFromFile first. If file is empty/new, it returns [].
      // The default readFile mock handles this (throws ENOENT if mockDataStore is empty, which repo treats as []).
      
      const savedLink = await repository.save(newLinkData);
      
      expect(savedLink.url).toBe(newLinkData.url);
      expect(savedLink.id).toBeDefined();
      expect(savedLink.createdAt).toBeDefined();
      expect(mockFs.writeFile).toHaveBeenCalledWith(linksFilePathResolved, JSON.stringify([savedLink], null, 2));
      expect(mockDataStore).toContainEqual(savedLink);
    });
    
    it('should append to existing links', async () => {
        const initialDate = new Date();
        const existingLink: Link = {id: '1', url: 'http://existing.com', createdAt: initialDate};
        mockDataStore.push(existingLink); // Pre-populate store
        // Default readFile mock will now return [existingLink]

        const newLinkData = {url: 'http://another.com'};
        const savedLink = await repository.save(newLinkData);

        expect(mockDataStore).toHaveLength(2);
        expect(mockDataStore).toContainEqual(existingLink); // Check if existing is still there
        expect(mockDataStore).toContainEqual(savedLink);   // Check if new one is added
        // Order matters for JSON.stringify comparison
        const expectedDataInFile = [existingLink, savedLink];
        expect(mockFs.writeFile).toHaveBeenCalledWith(linksFilePathResolved, JSON.stringify(expectedDataInFile, null, 2));
    });
  });

  describe('findById', () => {
    it('should find a link by ID if it exists', async () => {
      const date = new Date();
      const link: Link = { id: 'find-me', url: 'http://find.com', createdAt: date };
      mockDataStore.push(link);
      // Default readFile mock will return [link]

      const found = await repository.findById('find-me');
      expect(found).toEqual(link);
    });

    it('should return null if link with ID does not exist', async () => {
      // mockDataStore is empty
      const found = await repository.findById('not-gonna-find-me');
      expect(found).toBeNull();
    });
  });
  
  describe('deleteById', () => {
    it('should delete a link by ID and return true', async () => {
        const date1 = new Date();
        const date2 = new Date();
        const link1: Link = {id: '1', url: 'http://link1.com', createdAt: date1};
        const linkToDelete: Link = {id: 'delete-me', url: 'http://delete.com', createdAt: date2};
        mockDataStore.push(link1, linkToDelete);
        // Default readFile mock will return [link1, linkToDelete]

        const result = await repository.deleteById('delete-me');
        expect(result).toBe(true);
        expect(mockDataStore).toEqual([link1]); // Only link1 should remain
        expect(mockFs.writeFile).toHaveBeenCalledWith(linksFilePathResolved, JSON.stringify([link1], null, 2));
    });

    it('should return false if link to delete is not found', async () => {
        // mockDataStore is empty
        const result = await repository.deleteById('no-such-id');
        expect(result).toBe(false);
        expect(mockFs.writeFile).not.toHaveBeenCalled();
    });
  });
  
  describe('update', () => {
    it('should update an existing link and return it', async () => {
        const originalDate = new Date();
        const originalLink: Link = {id: 'update-id', url: 'http://original.com', createdAt: originalDate};
        mockDataStore.push(originalLink);
        // Default readFile mock will return [originalLink]
        
        const updatedLinkData: Link = { ...originalLink, url: 'http://updated.com' };
        // Ensure createdAt is preserved as a Date object if not explicitly changed
        updatedLinkData.createdAt = originalDate; 

        const result = await repository.update(updatedLinkData);

        expect(result).toEqual(updatedLinkData);
        // mockDataStore is updated by the writeFile mock
        expect(mockDataStore).toEqual([updatedLinkData]);
        expect(mockFs.writeFile).toHaveBeenCalledWith(linksFilePathResolved, JSON.stringify([updatedLinkData], null, 2));
    });
    
    it('should return null if link to update is not found', async () => {
        // mockDataStore is empty
        const nonExistentLink: Link = {id: 'non-existent', url: 'http://url.com', createdAt: new Date()};
        const result = await repository.update(nonExistentLink);
        expect(result).toBeNull();
        expect(mockFs.writeFile).not.toHaveBeenCalled();
    });
  });
});
