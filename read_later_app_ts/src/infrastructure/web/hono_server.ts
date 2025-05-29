// src/infrastructure/web/hono_server.ts
import { Hono } from 'hono';
import { serve } from '@hono/node-server';
import { LinkService } from '@domain/services/link_service'; 
import { JsonLinkRepository } from '@infrastructure/persistence/json_link_repository'; 
// Potentially add middleware for JSON parsing if not default, logging, cors etc.
// import { cors } from 'hono/cors'
// import { logger } from 'hono/logger'

export const app = new Hono(); // Exported for testing

// Initialize repository and service
// This is where Dependency Injection happens.
// For a larger app, a DI container might be used.
const linkRepository = new JsonLinkRepository();
const linkService = new LinkService(linkRepository);

// Middleware (optional, but good practice)
// app.use('*', logger()) // Example: Hono's built-in logger
// app.use('/links/*', cors()) // Example: CORS for /links routes

// API Routes
app.get('/', (c) => {
  return c.text('Read Later API - Hono Server is Running!');
});

// GET /links - Retrieve all links
app.get('/links', async (c) => {
  try {
    const links = await linkService.getAllLinks();
    return c.json(links);
  } catch (error: any) {
    console.error("Error in GET /links:", error);
    return c.json({ error: 'Failed to retrieve links', details: error.message }, 500);
  }
});

// POST /links - Add a new link
app.post('/links', async (c) => {
  try {
    const { url } = await c.req.json<{ url: string }>();
    if (!url) {
      return c.json({ error: 'URL is required' }, 400);
    }
    const newLink = await linkService.addLink(url);
    return c.json(newLink, 201);
  } catch (error: any) {
    console.error("Error in POST /links:", error);
    if (error.message.includes('Invalid URL') || error.message.includes('already been saved')) {
      return c.json({ error: error.message }, 400); 
    }
    return c.json({ error: 'Failed to add link', details: error.message }, 500);
  }
});

// GET /links/:id - Retrieve a specific link by ID
app.get('/links/:id', async (c) => {
    const { id } = c.req.param();
    try {
        const link = await linkService.getLinkById(id);
        if (!link) {
            return c.json({ error: 'Link not found' }, 404);
        }
        return c.json(link);
    } catch (error: any) {
        console.error(`Error in GET /links/\${id}:`, error);
        return c.json({ error: 'Failed to retrieve link', details: error.message }, 500);
    }
});

// DELETE /links/:id - Remove a link by ID
app.delete('/links/:id', async (c) => {
  const { id } = c.req.param();
  try {
    await linkService.removeLink(id); 
    return c.json({ message: 'Link removed successfully' }, 200); 
  } catch (error: any) {
    console.error(`Error in DELETE /links/\${id}:`, error);
    if (error.message.includes('not found')) { 
         return c.json({ error: error.message }, 404);
    }
    return c.json({ error: 'Failed to remove link', details: error.message }, 500);
  }
});

// PUT /links/:id - Update a link by ID
app.put('/links/:id', async (c) => {
    const { id } = c.req.param();
    try {
        const { url } = await c.req.json<{ url: string }>();
        if (!url) {
            return c.json({ error: 'URL is required for update' }, 400);
        }
        const updatedLink = await linkService.updateLink(id, url);
        if (!updatedLink) {
             return c.json({ error: 'Link not found for update or update failed' }, 404);
        }
        return c.json(updatedLink);
    } catch (error: any) {
        console.error(`Error in PUT /links/\${id}:`, error);
        if (error.message.includes('Invalid URL') || 
            error.message.includes('already exists') || 
            error.message.includes('not found')) {
            return c.json({ error: error.message }, 400); 
        }
        return c.json({ error: 'Failed to update link', details: error.message }, 500);
    }
});

const port = process.env.PORT ? parseInt(process.env.PORT) : 3000;

// Conditional serve for testing (so tests can import app without starting server)
if (process.env.NODE_ENV !== 'test') {
    console.log(`Server is running on port \${port}`);
    serve({
      fetch: app.fetch,
      port: port,
    });
}
