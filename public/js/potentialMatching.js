import Fuse from 'https://cdn.jsdelivr.net/npm/fuse.js@7.1.0/dist/fuse.mjs';

/**
 * Find found items that may match a lost report.
 * This helper is intended for a browser-based client; the PHP API continues
 * to own persistence and server-side matching.
 */
export function findPotentialMatches(lostReport, foundItems, options = {}) {
    if (!lostReport || !Array.isArray(foundItems)) {
        throw new TypeError('A lost report and an array of found items are required.');
    }

    const fuse = new Fuse(foundItems, {
        includeScore: true,
        threshold: options.threshold ?? 0.45,
        ignoreLocation: true,
        minMatchCharLength: 2,
        keys: [
            { name: 'title', weight: 0.6 },
            { name: 'description', weight: 0.25 },
            { name: 'location_found', weight: 0.1 },
            { name: 'category_id', weight: 0.05 },
        ],
    });

    const query = [
        lostReport.title,
        lostReport.description,
        lostReport.location_lost,
        lostReport.category_id,
    ].filter(value => value !== null && value !== undefined && String(value).trim() !== '').join(' ');

    if (!query) return [];

    return fuse.search(query).map(({ item, score }) => ({
        item,
        score: 1 - (score ?? 1),
    }));
}
