-- Update some publications to Published status for testing
-- This ensures they will show up in the Explore page

UPDATE publications 
SET status = 'Published', 
    published_at = datetime('now')
WHERE status IN ('Draft', 'Under Review', 'Revision Required');

-- Show updated publications
SELECT 'Updated publications to Published status:' as message;
SELECT id, title, status, published_at, author_id FROM publications WHERE status = 'Published'; 