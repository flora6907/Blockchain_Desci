-- Create like system for explore cards
-- Run with: sqlite3 backend/desci.db < create_like_system.sql

.print "=== Creating Like System ==="

-- Create likes table
CREATE TABLE IF NOT EXISTS likes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    target_type TEXT NOT NULL, -- 'project', 'dataset', 'publication'
    target_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, target_type, target_id), -- Prevent duplicate likes
    FOREIGN KEY (user_id) REFERENCES users (id)
);

.print "Likes table created successfully!"

-- Add like counts to projects, datasets, and publications tables
-- Check if like_count column exists in projects table
.print ""
.print "=== Adding like_count columns ==="

-- For projects table
PRAGMA table_info(projects);
ALTER TABLE projects ADD COLUMN like_count INTEGER DEFAULT 0;

-- For datasets table  
PRAGMA table_info(datasets);
ALTER TABLE datasets ADD COLUMN like_count INTEGER DEFAULT 0;

-- For publications table
PRAGMA table_info(publications);
ALTER TABLE publications ADD COLUMN like_count INTEGER DEFAULT 0;

.print "Like count columns added successfully!"

-- Create function to update like counts (will be done via triggers or API)
.print ""
.print "=== Creating indexes for performance ==="

CREATE INDEX IF NOT EXISTS idx_likes_user_target ON likes(user_id, target_type, target_id);
CREATE INDEX IF NOT EXISTS idx_likes_target ON likes(target_type, target_id);
CREATE INDEX IF NOT EXISTS idx_likes_created_at ON likes(created_at);

.print "Indexes created successfully!"

-- Add some sample likes for demonstration
.print ""
.print "=== Adding sample likes ==="

INSERT OR IGNORE INTO likes (user_id, target_type, target_id) VALUES
-- Some users like projects
(6, 'project', 4),  -- dr_alice_ai likes ML Climate Prediction Model
(7, 'project', 4),  -- blockchain_bob likes ML Climate Prediction Model
(8, 'project', 6),  -- climate_charlie likes DeFi Security Analysis
(9, 'project', 8),  -- biotech_diana likes Global Temperature Analysis
(6, 'project', 8),  -- dr_alice_ai likes Global Temperature Analysis

-- Some users like datasets
(7, 'dataset', 33), -- blockchain_bob likes Climate Satellite Data 2024
(8, 'dataset', 33), -- climate_charlie likes Climate Satellite Data 2024
(9, 'dataset', 39), -- biotech_diana likes Global Temperature Records
(6, 'dataset', 42), -- dr_alice_ai likes Gene Expression Profiles
(7, 'dataset', 36), -- blockchain_bob likes DeFi Transaction Logs

-- Cross-interest likes
(8, 'dataset', 42), -- climate_charlie likes Gene Expression Profiles
(9, 'dataset', 33), -- biotech_diana likes Climate Satellite Data 2024
(6, 'dataset', 36); -- dr_alice_ai likes DeFi Transaction Logs

.print "Sample likes added successfully!"

-- Update like counts based on existing likes
.print ""
.print "=== Updating like counts ==="

UPDATE projects SET like_count = (
    SELECT COUNT(*) FROM likes 
    WHERE target_type = 'project' AND target_id = projects.id
);

UPDATE datasets SET like_count = (
    SELECT COUNT(*) FROM likes 
    WHERE target_type = 'dataset' AND target_id = datasets.id
);

UPDATE publications SET like_count = (
    SELECT COUNT(*) FROM likes 
    WHERE target_type = 'publication' AND target_id = publications.id
);

.print "Like counts updated successfully!"

-- Show some statistics
.print ""
.print "=== Like Statistics ==="
SELECT 'Total likes: ' || COUNT(*) as stat FROM likes;

SELECT 'Project likes: ' || COUNT(*) as stat FROM likes WHERE target_type = 'project';
SELECT 'Dataset likes: ' || COUNT(*) as stat FROM likes WHERE target_type = 'dataset';
SELECT 'Publication likes: ' || COUNT(*) as stat FROM likes WHERE target_type = 'publication';

.print ""
.print "=== Most liked content ==="
.print "Most liked projects:"
SELECT p.name, p.like_count 
FROM projects p 
WHERE p.like_count > 0 
ORDER BY p.like_count DESC 
LIMIT 5;

.print ""
.print "Most liked datasets:"
SELECT d.name, d.like_count 
FROM datasets d 
WHERE d.like_count > 0 
ORDER BY d.like_count DESC 
LIMIT 5;

.print ""
.print "=== Like System Created Successfully! ===" 