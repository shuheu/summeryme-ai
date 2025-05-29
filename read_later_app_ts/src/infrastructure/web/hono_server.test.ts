// src/infrastructure/web/hono_server.test.ts
import { Hono } from 'hono'; // Hono type, not the instance
import { LinkService } from '@domain/services/link_service';
import { Link } from '@domain/entities/link';

// Mock LinkService: This will mock the entire module.
// The actual LinkService class will be replaced by a Jest mock constructor.
jest.mock('@domain/services/link_service');
    
// Dynamically import app after mocks are set up
let app: Hono; // Type for the Hono app

// Get a reference to the mock constructor and its prototype for setting up mock methods
const MockedLinkService = LinkService as jest.MockedClass<typeof LinkService>;
    
// Test data
const testLink1: Link = { id: '1', url: 'http://test1.com', createdAt: new Date() };
const testLink2: Link = { id: '2', url: 'http://test2.com', createdAt: new Date() };

beforeAll(async () => {
    // Set up mock implementations on the prototype of the mocked LinkService.
    // These will be used by any instance created from the mocked LinkService.
    MockedLinkService.prototype.getAllLinks = jest.fn();
    MockedLinkService.prototype.addLink = jest.fn();
    MockedLinkService.prototype.getLinkById = jest.fn();
    MockedLinkService.prototype.removeLink = jest.fn();
    MockedLinkService.prototype.updateLink = jest.fn();
    
    // Import the app from hono_server AFTER mocks are established.
    // The hono_server.ts file will use the mocked version of LinkService when it
    // instantiates `const linkService = new LinkService(linkRepository);`
    const serverModule = await import('@infrastructure/web/hono_server');
    app = serverModule.app; 
});

beforeEach(() => {
  // Clear mock function calls (history) but not their implementations.
  // Implementations are reset below to ensure a consistent state for each test.
  jest.clearAllMocks(); 
  
  // Reset to default mock implementations for each test
  MockedLinkService.prototype.getAllLinks.mockResolvedValue([
    { ...testLink1, createdAt: new Date(testLink1.createdAt) }, // Ensure fresh Date objects
    { ...testLink2, createdAt: new Date(testLink2.createdAt) },
  ]);
  MockedLinkService.prototype.addLink.mockImplementation(async (url) => ({ 
    id: 'new-id', 
    url, 
    createdAt: new Date() 
  }));
  MockedLinkService.prototype.getLinkById.mockImplementation(async (id) => (
    id === testLink1.id ? { ...testLink1, createdAt: new Date(testLink1.createdAt) } : null
  ));
  MockedLinkService.prototype.removeLink.mockResolvedValue(true); // Default to successful removal
  MockedLinkService.prototype.updateLink.mockImplementation(async (id, url) => (
    id === testLink1.id ? { ...testLink1, url, createdAt: new Date(testLink1.createdAt) } : null
  ));
});

describe('Hono API (hono_server.ts)', () => {
  describe('GET /links', () => {
    it('should return all links', async () => {
      const res = await app.request('/links');
      expect(res.status).toBe(200);
      // Dates are stringified in JSON responses
      expect(await res.json()).toEqual([
        { ...testLink1, createdAt: testLink1.createdAt.toISOString() }, 
        { ...testLink2, createdAt: testLink2.createdAt.toISOString() },
      ]);
      expect(MockedLinkService.prototype.getAllLinks).toHaveBeenCalled();
    });
  });

  describe('POST /links', () => {
    it('should add a new link', async () => {
      const newUrl = 'http://newlink.com';
      const req = new Request('http://localhost/links', { // Base URL doesn't matter for app.fetch
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ url: newUrl }),
      });
      const res = await app.fetch(req);
      expect(res.status).toBe(201);
      const responseBody = await res.json();
      expect(responseBody.url).toBe(newUrl);
      expect(MockedLinkService.prototype.addLink).toHaveBeenCalledWith(newUrl);
    });
    
    it('should return 400 if URL is missing', async () => {
        const req = new Request('http://localhost/links', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({}), // Missing URL
        });
        const res = await app.fetch(req);
        expect(res.status).toBe(400);
        expect(await res.json()).toEqual({ error: 'URL is required' });
    });

    it('should return 400 if link service throws known error (e.g. duplicate)', async () => {
        MockedLinkService.prototype.addLink.mockRejectedValueOnce(new Error('This URL has already been saved.'));
        const req = new Request('http://localhost/links', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ url: 'http://duplicate.com' }),
        });
        const res = await app.fetch(req);
        expect(res.status).toBe(400);
        expect(await res.json()).toEqual({ error: 'This URL has already been saved.' });
    });
  });
  
  describe('GET /links/:id', () => {
    it('should return a link by ID', async () => {
      const res = await app.request(`/links/\${testLink1.id}`);
      expect(res.status).toBe(200);
      expect(await res.json()).toEqual({ ...testLink1, createdAt: testLink1.createdAt.toISOString() });
      expect(MockedLinkService.prototype.getLinkById).toHaveBeenCalledWith(testLink1.id);
    });

    it('should return 404 if link not found', async () => {
      MockedLinkService.prototype.getLinkById.mockResolvedValueOnce(null);
      const res = await app.request('/links/unknown-id');
      expect(res.status).toBe(404);
      expect(await res.json()).toEqual({ error: 'Link not found' });
    });
  });

  describe('DELETE /links/:id', () => {
    it('should delete a link by ID', async () => {
      const res = await app.request(`/links/\${testLink1.id}`, { method: 'DELETE' });
      expect(res.status).toBe(200); 
      expect(await res.json()).toEqual({ message: 'Link removed successfully' });
      expect(MockedLinkService.prototype.removeLink).toHaveBeenCalledWith(testLink1.id);
    });
    
    it('should return 404 if link to delete is not found', async () => {
        MockedLinkService.prototype.removeLink.mockRejectedValueOnce(new Error('Link with this ID not found.'));
        const res = await app.request('/links/unknown-id', { method: 'DELETE' });
        expect(res.status).toBe(404);
        expect(await res.json()).toEqual({ error: 'Link with this ID not found.' });
    });
  });
  
  describe('PUT /links/:id', () => {
    it('should update a link by ID', async () => {
        const updatedUrl = 'http://updatedurl.com';
        const req = new Request(`http://localhost/links/\${testLink1.id}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ url: updatedUrl }),
        });
        const res = await app.fetch(req); // Use app.fetch for requests with body
        expect(res.status).toBe(200);
        const responseBody = await res.json();
        expect(responseBody.url).toBe(updatedUrl);
        expect(MockedLinkService.prototype.updateLink).toHaveBeenCalledWith(testLink1.id, updatedUrl);
    });

    it('should return 404 if link to update is not found', async () => {
        MockedLinkService.prototype.updateLink.mockResolvedValueOnce(null); // Simulate service returning null for not found
         const req = new Request(`http://localhost/links/unknown-id`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ url: 'http://someurl.com' }),
        });
        const res = await app.fetch(req);
        expect(res.status).toBe(404);
        expect(await res.json()).toEqual({ error: 'Link not found for update or update failed' });
    });
    
    it('should return 400 if URL is missing for update', async () => {
        const req = new Request(`http://localhost/links/\${testLink1.id}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({}), // Missing URL
        });
        const res = await app.fetch(req);
        expect(res.status).toBe(400);
        expect(await res.json()).toEqual({ error: 'URL is required for update' });
    });
  });
});
