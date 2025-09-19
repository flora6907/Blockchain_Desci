-- Create additional users, datasets, projects and mint NFTs for ready/completed assets
-- Run with: sqlite3 backend/desci.db < create_users_datasets_projects_and_mint_nfts.sql

.print "=== Creating Additional Users, Datasets, Projects and Minting NFTs ==="

-- First, let's check existing users
.print ""
.print "=== Existing Users ==="
SELECT 'User ID: ' || id || ', Wallet: ' || wallet_address || ', Username: ' || COALESCE(username, 'N/A') as user_info 
FROM users;

-- Create additional users if they don't exist
.print ""
.print "=== Creating Additional Users ==="

INSERT OR IGNORE INTO users (wallet_address, did, username, email, organization, research_interests, personal_website, github_username) VALUES
-- User 2: Data Scientist
(
  '0x1234567890123456789012345678901234567890',
  'did:ethr:0x1234567890123456789012345678901234567890',
  'data_scientist_bob',
  'bob.data@university.edu',
  'MIT Data Science Lab',
  '["Data Science", "Machine Learning", "Statistics", "Big Data"]',
  'https://bob-data-science.com',
  'bob-data-scientist'
),

-- User 3: Blockchain Researcher
(
  '0xABCDEF1234567890ABCDEF1234567890ABCDEF12',
  'did:ethr:0xABCDEF1234567890ABCDEF1234567890ABCDEF12',
  'blockchain_alice',
  'alice.blockchain@tech.edu',
  'Stanford Blockchain Research',
  '["Blockchain", "Cryptography", "DeFi", "Smart Contracts"]',
  'https://alice-blockchain.stanford.edu',
  'alice-blockchain-researcher'
),

-- User 4: Climate Data Analyst
(
  '0x9876543210987654321098765432109876543210',
  'did:ethr:0x9876543210987654321098765432109876543210',
  'climate_charlie',
  'charlie.climate@research.org',
  'Climate Research Institute',
  '["Climate Science", "Environmental Data", "Weather Modeling", "Sustainability"]',
  'https://charlie-climate-research.org',
  'charlie-climate-data'
),

-- User 5: Biotech Researcher
(
  '0xFEDCBA0987654321FEDCBA0987654321FEDCBA09',
  'did:ethr:0xFEDCBA0987654321FEDCBA0987654321FEDCBA09',
  'biotech_diana',
  'diana.bio@medical.edu',
  'Harvard Medical School',
  '["Biotechnology", "Genomics", "Medical Research", "Drug Discovery"]',
  'https://diana-biotech.harvard.edu',
  'diana-biotech-researcher'
);

.print "Additional users created successfully!"

-- Show all users now
.print ""
.print "=== All Users After Creation ==="
SELECT 'User ID: ' || id || ', Wallet: ' || wallet_address || ', Username: ' || COALESCE(username, 'N/A') as user_info 
FROM users ORDER BY id;

-- Create projects for these users with different statuses
.print ""
.print "=== Creating Projects with Different Statuses ==="

INSERT INTO projects (name, description, visibility, status, category, owner_id, start_date) VALUES
-- Projects by Bob (User 2)
('ML Climate Prediction Model', 'Machine learning model for climate prediction using satellite data', 'Public', 'Completed', 'AI/ML', 
 (SELECT id FROM users WHERE username = 'data_scientist_bob'), '2024-01-15'),
 
('Data Visualization Dashboard', 'Interactive dashboard for environmental data visualization', 'Private', 'In Progress', 'Data Analysis',
 (SELECT id FROM users WHERE username = 'data_scientist_bob'), '2024-03-01'),

-- Projects by Alice (User 3)
('DeFi Security Analysis', 'Comprehensive security analysis of DeFi protocols', 'Public', 'Completed', 'Blockchain',
 (SELECT id FROM users WHERE username = 'blockchain_alice'), '2024-02-10'),
 
('Smart Contract Audit Tool', 'Automated smart contract vulnerability detection', 'Private', 'Planning', 'Security',
 (SELECT id FROM users WHERE username = 'blockchain_alice'), '2024-04-01'),

-- Projects by Charlie (User 4)
('Global Temperature Analysis', 'Analysis of global temperature trends over the past century', 'Public', 'Completed', 'Climate Science',
 (SELECT id FROM users WHERE username = 'climate_charlie'), '2024-01-20'),
 
('Ocean Current Modeling', 'Advanced modeling of ocean current patterns', 'Public', 'In Progress', 'Environmental Science',
 (SELECT id FROM users WHERE username = 'climate_charlie'), '2024-03-15'),

-- Projects by Diana (User 5)
('Gene Expression Database', 'Comprehensive database of gene expression patterns', 'Private', 'Completed', 'Biotechnology',
 (SELECT id FROM users WHERE username = 'biotech_diana'), '2024-02-05'),
 
('Drug Discovery Pipeline', 'AI-powered drug discovery and development pipeline', 'Private', 'Testing', 'Medical Research',
 (SELECT id FROM users WHERE username = 'biotech_diana'), '2024-03-20');

.print "Projects created successfully!"

-- Show created projects
.print ""
.print "=== Created Projects ==="
SELECT 'Project ID: ' || p.id || ', Name: ' || p.name || ', Status: ' || p.status || ', Owner: ' || u.username as project_info
FROM projects p 
JOIN users u ON p.owner_id = u.id 
WHERE u.username IN ('data_scientist_bob', 'blockchain_alice', 'climate_charlie', 'biotech_diana')
ORDER BY p.id;

-- Create datasets with different statuses and privacy levels
.print ""
.print "=== Creating Datasets with Different Statuses and Privacy Levels ==="

INSERT INTO datasets (name, description, owner_id, project_id, privacy_level, status, category, tags, file_name, file_size, file_type) VALUES
-- Bob's datasets
('Climate Satellite Data 2024', 'High-resolution satellite imagery for climate analysis', 
 (SELECT id FROM users WHERE username = 'data_scientist_bob'),
 (SELECT id FROM projects WHERE name = 'ML Climate Prediction Model'),
 'public', 'ready', 'Climate Data', '["satellite", "climate", "2024", "high-resolution"]',
 'climate_satellite_2024.csv', 15728640, 'text/csv'),

('Temperature Sensor Network', 'Real-time temperature data from global sensor network',
 (SELECT id FROM users WHERE username = 'data_scientist_bob'),
 (SELECT id FROM projects WHERE name = 'Data Visualization Dashboard'),
 'private', 'processing', 'Environmental Data', '["temperature", "sensors", "real-time"]',
 'temp_sensor_data.json', 8912345, 'application/json'),

('Weather Pattern Analysis', 'Processed weather pattern data for ML training',
 (SELECT id FROM users WHERE username = 'data_scientist_bob'),
 (SELECT id FROM projects WHERE name = 'ML Climate Prediction Model'),
 'encrypted', 'ready', 'Weather Data', '["weather", "patterns", "ml", "training"]',
 'weather_patterns.pkl', 25165824, 'application/octet-stream'),

-- Alice's datasets
('DeFi Transaction Logs', 'Anonymized transaction logs from major DeFi protocols',
 (SELECT id FROM users WHERE username = 'blockchain_alice'),
 (SELECT id FROM projects WHERE name = 'DeFi Security Analysis'),
 'public', 'ready', 'Blockchain Data', '["defi", "transactions", "anonymized", "protocols"]',
 'defi_transactions.csv', 52428800, 'text/csv'),

('Smart Contract Vulnerabilities', 'Database of known smart contract vulnerabilities',
 (SELECT id FROM users WHERE username = 'blockchain_alice'),
 (SELECT id FROM projects WHERE name = 'Smart Contract Audit Tool'),
 'private', 'failed', 'Security Data', '["smart-contracts", "vulnerabilities", "security"]',
 'vulnerabilities.json', 3145728, 'application/json'),

('Blockchain Network Metrics', 'Performance metrics from various blockchain networks',
 (SELECT id FROM users WHERE username = 'blockchain_alice'),
 (SELECT id FROM projects WHERE name = 'DeFi Security Analysis'),
 'encrypted', 'ready', 'Performance Data', '["blockchain", "metrics", "performance", "networks"]',
 'network_metrics.csv', 18874368, 'text/csv'),

-- Charlie's datasets
('Global Temperature Records', '150 years of global temperature measurements',
 (SELECT id FROM users WHERE username = 'climate_charlie'),
 (SELECT id FROM projects WHERE name = 'Global Temperature Analysis'),
 'public', 'ready', 'Climate Data', '["temperature", "global", "historical", "150-years"]',
 'global_temp_records.csv', 41943040, 'text/csv'),

('Ocean Current Measurements', 'Real-time ocean current data from buoy network',
 (SELECT id FROM users WHERE username = 'climate_charlie'),
 (SELECT id FROM projects WHERE name = 'Ocean Current Modeling'),
 'public', 'processing', 'Oceanographic Data', '["ocean", "currents", "buoys", "real-time"]',
 'ocean_currents.nc', 78643200, 'application/x-netcdf'),

('Arctic Ice Coverage', 'Satellite data of Arctic ice coverage over 50 years',
 (SELECT id FROM users WHERE username = 'climate_charlie'),
 (SELECT id FROM projects WHERE name = 'Global Temperature Analysis'),
 'private', 'ready', 'Climate Data', '["arctic", "ice", "satellite", "50-years"]',
 'arctic_ice_coverage.tiff', 134217728, 'image/tiff'),

-- Diana's datasets
('Gene Expression Profiles', 'Comprehensive gene expression data from 10,000 samples',
 (SELECT id FROM users WHERE username = 'biotech_diana'),
 (SELECT id FROM projects WHERE name = 'Gene Expression Database'),
 'encrypted', 'ready', 'Genomics Data', '["gene-expression", "profiles", "10k-samples", "comprehensive"]',
 'gene_expression.h5', 268435456, 'application/x-hdf'),

('Drug Compound Library', 'Chemical structures and properties of pharmaceutical compounds',
 (SELECT id FROM users WHERE username = 'biotech_diana'),
 (SELECT id FROM projects WHERE name = 'Drug Discovery Pipeline'),
 'private', 'processing', 'Chemical Data', '["drugs", "compounds", "chemical", "pharmaceutical"]',
 'compound_library.sdf', 62914560, 'chemical/x-mdl-sdfile'),

('Clinical Trial Results', 'Anonymized results from Phase II clinical trials',
 (SELECT id FROM users WHERE username = 'biotech_diana'),
 (SELECT id FROM projects WHERE name = 'Gene Expression Database'),
 'encrypted', 'ready', 'Medical Data', '["clinical-trials", "phase-2", "anonymized", "results"]',
 'clinical_results.csv', 31457280, 'text/csv');

.print "Datasets created successfully!"

-- Show created datasets
.print ""
.print "=== Created Datasets ==="
SELECT 'Dataset ID: ' || d.id || ', Name: ' || d.name || ', Status: ' || d.status || ', Privacy: ' || d.privacy_level || ', Owner: ' || u.username as dataset_info
FROM datasets d 
JOIN users u ON d.owner_id = u.id 
WHERE u.username IN ('data_scientist_bob', 'blockchain_alice', 'climate_charlie', 'biotech_diana')
ORDER BY d.id;

-- Now let's identify and mint NFTs for ready datasets and completed projects
.print ""
.print "=== Identifying Assets Eligible for NFT Minting ==="

.print ""
.print "Ready Datasets:"
SELECT 'Dataset ID: ' || d.id || ', Name: ' || d.name || ', Privacy: ' || d.privacy_level || ', Owner: ' || u.username as ready_datasets
FROM datasets d 
JOIN users u ON d.owner_id = u.id 
WHERE d.status = 'ready' AND u.username IN ('data_scientist_bob', 'blockchain_alice', 'climate_charlie', 'biotech_diana');

.print ""
.print "Completed Projects:"
SELECT 'Project ID: ' || p.id || ', Name: ' || p.name || ', Status: ' || p.status || ', Owner: ' || u.username as completed_projects
FROM projects p 
JOIN users u ON p.owner_id = u.id 
WHERE p.status = 'Completed' AND u.username IN ('data_scientist_bob', 'blockchain_alice', 'climate_charlie', 'biotech_diana');

-- Check if NFTs table has asset_type column, if not we'll work with existing structure
.print ""
.print "=== Minting NFTs for Eligible Assets ==="

-- Mint NFTs for ready datasets
.print ""
.print "Minting NFTs for Ready Datasets..."

-- Bob's ready datasets
INSERT INTO nfts (project_id, token_id, contract_address, metadata_uri, owner_id, created_at) 
SELECT 
    d.project_id,
    'DATASET_' || d.id || '_' || strftime('%s', 'now'),
    '0x742d35Cc6634C0532925a3b8D4f25177F9E5C4B8',
    'https://ipfs.io/ipfs/QmDataset' || d.id || 'Hash',
    d.owner_id,
    datetime('now')
FROM datasets d 
JOIN users u ON d.owner_id = u.id 
WHERE d.status = 'ready' AND u.username = 'data_scientist_bob';

-- Alice's ready datasets  
INSERT INTO nfts (project_id, token_id, contract_address, metadata_uri, owner_id, created_at)
SELECT 
    d.project_id,
    'DATASET_' || d.id || '_' || strftime('%s', 'now'),
    '0x8ba1f109551bD432803012645Hac136c5b3F5F99',
    'https://ipfs.io/ipfs/QmDataset' || d.id || 'Hash',
    d.owner_id,
    datetime('now')
FROM datasets d 
JOIN users u ON d.owner_id = u.id 
WHERE d.status = 'ready' AND u.username = 'blockchain_alice';

-- Charlie's ready datasets
INSERT INTO nfts (project_id, token_id, contract_address, metadata_uri, owner_id, created_at)
SELECT 
    d.project_id,
    'DATASET_' || d.id || '_' || strftime('%s', 'now'),
    '0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC',
    'https://ipfs.io/ipfs/QmDataset' || d.id || 'Hash',
    d.owner_id,
    datetime('now')
FROM datasets d 
JOIN users u ON d.owner_id = u.id 
WHERE d.status = 'ready' AND u.username = 'climate_charlie';

-- Diana's ready datasets
INSERT INTO nfts (project_id, token_id, contract_address, metadata_uri, owner_id, created_at)
SELECT 
    d.project_id,
    'DATASET_' || d.id || '_' || strftime('%s', 'now'),
    '0x90F79bf6EB2c4f870365E785982E1f101E93b906',
    'https://ipfs.io/ipfs/QmDataset' || d.id || 'Hash',
    d.owner_id,
    datetime('now')
FROM datasets d 
JOIN users u ON d.owner_id = u.id 
WHERE d.status = 'ready' AND u.username = 'biotech_diana';

.print "NFTs minted for ready datasets!"

-- Mint NFTs for completed projects
.print ""
.print "Minting NFTs for Completed Projects..."

-- Bob's completed projects
INSERT INTO nfts (project_id, token_id, contract_address, metadata_uri, owner_id, created_at)
SELECT 
    p.id,
    'PROJECT_' || p.id || '_' || strftime('%s', 'now'),
    '0x742d35Cc6634C0532925a3b8D4f25177F9E5C4B8',
    'https://ipfs.io/ipfs/QmProject' || p.id || 'Hash',
    p.owner_id,
    datetime('now')
FROM projects p 
JOIN users u ON p.owner_id = u.id 
WHERE p.status = 'Completed' AND u.username = 'data_scientist_bob';

-- Alice's completed projects
INSERT INTO nfts (project_id, token_id, contract_address, metadata_uri, owner_id, created_at)
SELECT 
    p.id,
    'PROJECT_' || p.id || '_' || strftime('%s', 'now'),
    '0x8ba1f109551bD432803012645Hac136c5b3F5F99',
    'https://ipfs.io/ipfs/QmProject' || p.id || 'Hash',
    p.owner_id,
    datetime('now')
FROM projects p 
JOIN users u ON p.owner_id = u.id 
WHERE p.status = 'Completed' AND u.username = 'blockchain_alice';

-- Charlie's completed projects
INSERT INTO nfts (project_id, token_id, contract_address, metadata_uri, owner_id, created_at)
SELECT 
    p.id,
    'PROJECT_' || p.id || '_' || strftime('%s', 'now'),
    '0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC',
    'https://ipfs.io/ipfs/QmProject' || p.id || 'Hash',
    p.owner_id,
    datetime('now')
FROM projects p 
JOIN users u ON p.owner_id = u.id 
WHERE p.status = 'Completed' AND u.username = 'climate_charlie';

-- Diana's completed projects
INSERT INTO nfts (project_id, token_id, contract_address, metadata_uri, owner_id, created_at)
SELECT 
    p.id,
    'PROJECT_' || p.id || '_' || strftime('%s', 'now'),
    '0x90F79bf6EB2c4f870365E785982E1f101E93b906',
    'https://ipfs.io/ipfs/QmProject' || p.id || 'Hash',
    p.owner_id,
    datetime('now')
FROM projects p 
JOIN users u ON p.owner_id = u.id 
WHERE p.status = 'Completed' AND u.username = 'biotech_diana';

.print "NFTs minted for completed projects!"

-- Show summary of minted NFTs
.print ""
.print "=== Summary of Minted NFTs ==="
SELECT 
    'NFT ID: ' || n.id || 
    ', Token: ' || n.token_id || 
    ', Project: ' || p.name || 
    ', Owner: ' || u.username as nft_summary
FROM nfts n 
JOIN projects p ON n.project_id = p.id 
JOIN users u ON n.owner_id = u.id 
WHERE u.username IN ('data_scientist_bob', 'blockchain_alice', 'climate_charlie', 'biotech_diana')
ORDER BY n.id;

.print ""
.print "=== Final Statistics ==="
SELECT 'Total Users: ' || COUNT(*) as stats FROM users;
SELECT 'Total Projects: ' || COUNT(*) as stats FROM projects;
SELECT 'Total Datasets: ' || COUNT(*) as stats FROM datasets;
SELECT 'Total NFTs: ' || COUNT(*) as stats FROM nfts;
SELECT 'Ready Datasets: ' || COUNT(*) as stats FROM datasets WHERE status = 'ready';
SELECT 'Completed Projects: ' || COUNT(*) as stats FROM projects WHERE status = 'Completed';

.print ""
.print "=== Database Operations Completed Successfully! === 