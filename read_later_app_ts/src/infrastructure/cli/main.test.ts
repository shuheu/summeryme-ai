// src/infrastructure/cli/main.test.ts
import { LinkService } from '@domain/services/link_service';
import { Link } from '@domain/entities/link'; // Import Link for test data

// Mock LinkService
jest.mock('@domain/services/link_service');

// Hold onto the original process.argv
const originalArgv = process.argv;

// Mock console methods
let consoleLogSpy: jest.SpyInstance;
let consoleErrorSpy: jest.SpyInstance;

let runCli: () => Promise<void>; // Type for the imported function
const MockedLinkService = LinkService as jest.MockedClass<typeof LinkService>;

beforeAll(async () => {
  // Set up mock implementations on the prototype
  MockedLinkService.prototype.getAllLinks = jest.fn();
  MockedLinkService.prototype.addLink = jest.fn();
  MockedLinkService.prototype.getLinkById = jest.fn();
  MockedLinkService.prototype.removeLink = jest.fn();
  MockedLinkService.prototype.updateLink = jest.fn();
  
  // Dynamically import runCli from main.ts AFTER mocks are set up
  const cliModule = await import('@infrastructure/cli/main');
  runCli = cliModule.runCli; 
});

beforeEach(() => {
  jest.clearAllMocks();
  consoleLogSpy = jest.spyOn(console, 'log').mockImplementation(() => {});
  consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation(() => {});
  
  // Default mock implementations for LinkService methods
  MockedLinkService.prototype.getAllLinks.mockResolvedValue([]);
  MockedLinkService.prototype.addLink.mockImplementation(async (url: string) => ({ 
    id: 'new-cli-id', 
    url, 
    createdAt: new Date() 
  }));
  MockedLinkService.prototype.getLinkById.mockResolvedValue(null);
  MockedLinkService.prototype.removeLink.mockResolvedValue(true); // Default to successful removal
  MockedLinkService.prototype.updateLink.mockResolvedValue(null); // Default to not found or failed update

  // Base arguments for process.argv
  process.argv = ['node', 'main.js']; 
});

afterEach(() => {
  process.argv = originalArgv; // Restore original argv
  consoleLogSpy.mockRestore();
  consoleErrorSpy.mockRestore();
});

describe('CLI Application (main.ts)', () => {
  const testLink: Link = { id: 'cli-link-1', url: 'http://cli.example.com', createdAt: new Date() };

  it('should show usage if no command is provided', async () => {
    // process.argv is already set to ['node', 'main.js'] in beforeEach
    await runCli(); 
    expect(consoleLogSpy).toHaveBeenCalledWith(expect.stringContaining('Usage:'));
  });

  describe('add command', () => {
    it('should call linkService.addLink with the URL', async () => {
      process.argv.push('add', 'http://test.com');
      MockedLinkService.prototype.addLink.mockResolvedValueOnce(testLink);
      await runCli();
      expect(MockedLinkService.prototype.addLink).toHaveBeenCalledWith('http://test.com');
      expect(consoleLogSpy).toHaveBeenCalledWith(expect.stringContaining(\`Link added successfully! ID: \${testLink.id}\`));
    });
    it('should show error if URL is missing', async () => {
      process.argv.push('add');
      await runCli();
      expect(consoleErrorSpy).toHaveBeenCalledWith(expect.stringContaining('Error: URL is required'));
      expect(consoleLogSpy).toHaveBeenCalledWith(expect.stringContaining('Usage:'));
    });
  });

  describe('list command', () => {
    it('should call linkService.getAllLinks and display them', async () => {
      process.argv.push('list');
      MockedLinkService.prototype.getAllLinks.mockResolvedValueOnce([testLink]);
      await runCli();
      expect(MockedLinkService.prototype.getAllLinks).toHaveBeenCalled();
      expect(consoleLogSpy).toHaveBeenCalledWith(expect.stringContaining(\`- ID: \${testLink.id}, URL: \${testLink.url}\`));
    });
    it('should show "No links saved" if list is empty', async () => {
      process.argv.push('list');
      // Default mock is empty list from beforeEach
      await runCli();
      expect(consoleLogSpy).toHaveBeenCalledWith('No links saved yet.');
    });
  });
  
  describe('remove command', () => {
    it('should call linkService.removeLink with the ID', async () => {
      process.argv.push('remove', 'some-id');
      await runCli();
      expect(MockedLinkService.prototype.removeLink).toHaveBeenCalledWith('some-id');
      expect(consoleLogSpy).toHaveBeenCalledWith('Link with ID "some-id" removed successfully.');
    });
    it('should show error if ID is missing', async () => {
      process.argv.push('remove');
      await runCli();
      expect(consoleErrorSpy).toHaveBeenCalledWith(expect.stringContaining('Error: ID is required'));
    });
    it('should handle errors from service (e.g., link not found)', async () => {
      process.argv.push('remove', 'bad-id');
      MockedLinkService.prototype.removeLink.mockRejectedValueOnce(new Error('Link not found'));
      await runCli();
      expect(consoleErrorSpy).toHaveBeenCalledWith('Operation failed: Link not found');
    });
  });
  
  describe('update command', () => {
    it('should call linkService.updateLink with ID and new URL', async () => {
        process.argv.push('update', 'id-to-update', 'http://newurl.com');
        const updatedLinkData = { ...testLink, id: 'id-to-update', url: 'http://newurl.com'};
        MockedLinkService.prototype.updateLink.mockResolvedValueOnce(updatedLinkData);
        await runCli();
        expect(MockedLinkService.prototype.updateLink).toHaveBeenCalledWith('id-to-update', 'http://newurl.com');
        expect(consoleLogSpy).toHaveBeenCalledWith(expect.stringContaining(\`Link with ID "id-to-update" updated successfully. New URL: http://newurl.com\`));
    });
    it('should show error if ID or URL is missing', async () => {
        process.argv.push('update', 'id-only');
        await runCli();
        expect(consoleErrorSpy).toHaveBeenCalledWith(expect.stringContaining('Error: ID and new URL are required'));
    });
    it('should handle "not found" from service when updateLink returns null', async () => {
        process.argv.push('update', 'non-existent-id', 'http://newurl.com');
        MockedLinkService.prototype.updateLink.mockResolvedValueOnce(null); // Service indicates not found by returning null
        await runCli();
        expect(consoleErrorSpy).toHaveBeenCalledWith(expect.stringContaining('Link with ID "non-existent-id" not found for update.'));
    });
  });

  describe('find command', () => {
    it('should call linkService.getLinkById with the ID', async () => {
        process.argv.push('find', testLink.id);
        MockedLinkService.prototype.getLinkById.mockResolvedValueOnce(testLink);
        await runCli();
        expect(MockedLinkService.prototype.getLinkById).toHaveBeenCalledWith(testLink.id);
        expect(consoleLogSpy).toHaveBeenCalledWith(expect.stringContaining(\`Found Link: ID: \${testLink.id}\`));
    });
    it('should show "not found" if service returns null', async () => {
        process.argv.push('find', 'unknown-id');
        // Default mock is null from beforeEach
        await runCli();
        expect(consoleLogSpy).toHaveBeenCalledWith('Link with ID "unknown-id" not found.');
    });
  });
});
