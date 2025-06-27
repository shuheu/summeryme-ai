import * as cheerio from 'cheerio';

export async function fetchPageTitle(url: string): Promise<string | null> {
  try {
    const response = await fetch(url, {
      headers: {
        'User-Agent': "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36",
      },
    });

    if (!response.ok) {
      console.error(`Failed to fetch URL: ${url}, status: ${response.status}`);
      return null;
    }

    const html = await response.text();
    const $ = cheerio.load(html);

    // Try multiple selectors for title
    let title = $('meta[property="og:title"]').attr('content') ||
                $('meta[name="twitter:title"]').attr('content') ||
                $('title').text() ||
                $('h1').first().text();

    // Clean up the title
    if (title) {
      title = title.trim().replace(/\s+/g, ' ');
      // Limit title length
      if (title.length > 255) {
        title = title.substring(0, 252) + '...';
      }
      return title;
    }

    return null;
  } catch (error) {
    console.error(`Error fetching page title for URL: ${url}`, error);
    return null;
  }
}