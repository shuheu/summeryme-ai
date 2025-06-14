// src/infrastructure/cli/main.ts
import { LinkService } from '@domain/services/link_service'; 
import { JsonLinkRepository } from '@infrastructure/persistence/json_link_repository'; 
// import { Link } from '@domain/entities/link'; 

const linkRepository = new JsonLinkRepository();
const linkService = new LinkService(linkRepository);

function showUsage() {
  console.log(`
Read Later CLI - Onion Architecture Version
Usage: node <path-to-cli-script>.js <command> [arguments]

Commands:
  add <URL>         Saves a new URL.
  list              Displays all saved URLs.
  remove <ID>       Removes a URL by its ID.
  update <ID> <URL> Updates the URL for the given ID.
  find <ID>         Finds and displays a link by its ID. 
  `);
}

// Export runCli for testing
export async function runCli() { 
  // Test will mock process.argv directly
  const args = process.argv.slice(2); 
  const command = args[0];
  const params = args.slice(1);

  if (!command) {
    showUsage();
    return;
  }

  try {
    switch (command) {
      case 'add':
        if (params.length < 1) {
          console.error('Error: URL is required for add command.');
          showUsage();
          return;
        }
        const newLink = await linkService.addLink(params[0]);
        console.log(\`Link added successfully! ID: \${newLink.id}, URL: \${newLink.url}, CreatedAt: \${newLink.createdAt.toISOString()}\`);
        break;

      case 'list':
        const links = await linkService.getAllLinks();
        if (links.length === 0) {
          console.log('No links saved yet.');
        } else {
          console.log('Saved Links:');
          links.forEach(link => {
            console.log(\`- ID: \${link.id}, URL: \${link.url}, Added: \${link.createdAt.toISOString()}\`);
          });
        }
        break;

      case 'remove':
        if (params.length < 1) {
          console.error('Error: ID is required for remove command.');
          showUsage();
          return;
        }
        const idToRemove = params[0];
        await linkService.removeLink(idToRemove); 
        console.log(\`Link with ID "\${idToRemove}" removed successfully.\`);
        break;

      case 'update':
        if (params.length < 2) {
            console.error('Error: ID and new URL are required for update command.');
            showUsage();
            return;
        }
        const idToUpdate = params[0];
        const newUrlForUpdate = params[1];
        const updatedLink = await linkService.updateLink(idToUpdate, newUrlForUpdate);
        if (updatedLink) {
            console.log(\`Link with ID "\${idToUpdate}" updated successfully. New URL: \${updatedLink.url}\`);
        } else {
            console.error(\`Link with ID "\${idToUpdate}" not found for update.\`);
        }
        break;
        
      case 'find':
        if (params.length < 1) {
            console.error('Error: ID is required for find command.');
            showUsage();
            return;
        }
        const idToFind = params[0];
        const foundLink = await linkService.getLinkById(idToFind);
        if (foundLink) {
            console.log(\`Found Link: ID: \${foundLink.id}, URL: \${foundLink.url}, Added: \${foundLink.createdAt.toISOString()}\`);
        } else {
            console.log(\`Link with ID "\${idToFind}" not found.\`);
        }
        break;

      default:
        console.error(\`Error: Unknown command "\${command}".\`);
        showUsage();
    }
  } catch (error: any) {
    console.error(\`Operation failed: \${error.message}\`);
  }
}

// Main execution block
async function main() {
    await runCli();
}

if (require.main === module) {
    main();
}
