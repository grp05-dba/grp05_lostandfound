# Fuse.js matching helper

The repository's API is a native PHP application and does not include Node.js, a JavaScript bundler, or a browser application entry point. Fuse.js is a JavaScript library, so it cannot be executed directly inside the existing PHP service layer.

This branch adds a browser-side helper at `public/js/potentialMatching.js`. A future browser page can import `findPotentialMatches(lostReport, foundItems)` and receive ranked candidates. It uses Fuse.js 7.1.0 from jsDelivr and weights title (60%), description (25%), found location (10%), and category (5%).

The PHP API remains responsible for authoritative database writes. This helper does not write to PostgreSQL and is not a replacement for the server-side potential-match operations. A frontend page must explicitly import and call it when the project adds a browser UI.
