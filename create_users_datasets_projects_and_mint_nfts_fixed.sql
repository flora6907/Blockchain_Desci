-- Create datasets, projects and mint NFTs for existing users
-- Run with: sqlite3 backend/desci.db < create_users_datasets_projects_and_mint_nfts_fixed.sql

.print "=== Creating Datasets, Projects and Minting NFTs for Existing Users ==="

-- Show existing users to work with
.print ""
.print "=== Existing Users ==="
SELECT 'User ID: ' || id || ', Wallet: ' || wallet_address || ', Username: ' || COALESCE(username, 'N/A') as user_info 
FROM users WHERE username IS NOT NULL;

-- Create projects for existing users with different statuses
.print ""
.print "=== Creating Projects with Different Statuses ==="

INSERT INTO projects (name, description, visibility, status, category, owner_id, start_date) VALUES
-- Projects by dr_alice_ai (User 6)
('ML Climate Prediction Model', 'Machine learning model for climate prediction using satellite data', 'Public', 'Completed', 'AI/ML', 
 (SELECT id FROM users WHERE username = 'dr_alice_ai'), '2024-01-15'),
 
('AI Research Platform', 'Advanced AI research platform for neural networks', 'Private', 'In Progress', 'AI/ML',
 (SELECT id FROM users WHERE username = 'dr_alice_ai'), '2024-03-01'),

-- Projects by blockchain_bob (User 7)
('DeFi Security Analysis', 'Comprehensive security analysis of DeFi protocols', 'Public', 'Completed', 'Blockchain',
 (SELECT id FROM users WHERE username = 'blockchain_bob'), '2024-02-10'),
 
('Smart Contract Audit Tool', 'Automated smart contract vulnerability detection', 'Private', 'Planning', 'Security',
 (SELECT id FROM users WHERE username = 'blockchain_bob'), '2024-04-01'),

-- Projects by climate_charlie (User 8)
('Global Temperature Analysis', 'Analysis of global temperature trends over the past century', 'Public', 'Completed', 'Climate Science',
 (SELECT id FROM users WHERE username = 'climate_charlie'), '2024-01-20'),
 
('Ocean Current Modeling', 'Advanced modeling of ocean current patterns', 'Public', 'In Progress', 'Environmental Science',
 (SELECT id FROM users WHERE username = 'climate_charlie'), '2024-03-15'),

-- Projects by biotech_diana (User 9)
('Gene Expression Database', 'Comprehensive database of gene expression patterns', 'Private', 'Completed', 'Biotechnology',
 (SELECT id FROM users WHERE username = 'biotech_diana'), '2024-02-05'),
 
('Drug Discovery Pipeline', 'AI-powered drug discovery and development pipeline', 'Private', 'Testing', 'Medical Research',
 (SELECT id FROM users WHERE username = 'biotech_diana'), '2024-03-20'),

-- Projects by data_scientist_frank (User 11)
('Big Data Analytics Framework', 'Scalable framework for big data analytics', 'Public', 'Completed', 'Data Science',
 (SELECT id FROM users WHERE username = 'data_scientist_frank'), '2024-01-10'),

-- Projects by security_henry (User 13)
('Cybersecurity Threat Detection', 'AI-powered cybersecurity threat detection system', 'Private', 'Completed', 'Security',
 (SELECT id FROM users WHERE username = 'security_henry'), '2024-02-15');

.print "Projects created successfully!"

-- Show created projects
.print ""
.print "=== Created Projects ==="
SELECT 'Project ID: ' || p.id || ', Name: ' || p.name || ', Status: ' || p.status || ', Owner: ' || u.username as project_info
FROM projects p 
JOIN users u ON p.owner_id = u.id 
WHERE u.username IN ('dr_alice_ai', 'blockchain_bob', 'climate_charlie', 'biotech_diana', 'data_scientist_frank', 'security_henry')
ORDER BY p.id;

-- Create datasets with different statuses and privacy levels
.print ""
.print "=== Creating Datasets with Different Statuses and Privacy Levels ==="

INSERT INTO datasets (name, description, owner_id, project_id, privacy_level, status, category, tags, file_name, file_size, file_type) VALUES
-- Alice's datasets (AI Researcher)
('Climate Satellite Data 2024', 'High-resolution satellite imagery for climate analysis', 
 (SELECT id FROM users WHERE username = 'dr_alice_ai'),
 (SELECT id FROM projects WHERE name = 'ML Climate Prediction Model' AND owner_id = (SELECT id FROM users WHERE username = 'dr_alice_ai')),
 'public', 'ready', 'Climate Data', '["satellite", "climate", "2024", "high-resolution"]',
 'climate_satellite_2024.csv', 15728640, 'text/csv'),

('Neural Network Training Data', 'Training dataset for neural network models',
 (SELECT id FROM users WHERE username = 'dr_alice_ai'),
 (SELECT id FROM projects WHERE name = 'AI Research Platform' AND owner_id = (SELECT id FROM users WHERE username = 'dr_alice_ai')),
 'private', 'processing', 'AI Data', '["neural-networks", "training", "ai"]',
 'nn_training_data.pkl', 89123456, 'application/octet-stream'),

('Computer Vision Dataset', 'Large-scale computer vision dataset',
 (SELECT id FROM users WHERE username = 'dr_alice_ai'),
 (SELECT id FROM projects WHERE name = 'AI Research Platform' AND owner_id = (SELECT id FROM users WHERE username = 'dr_alice_ai')),
 'encrypted', 'ready', 'Computer Vision', '["computer-vision", "image-recognition", "deep-learning"]',
 'cv_dataset.h5', 134217728, 'application/x-hdf'),

-- Bob's datasets (Blockchain)
('DeFi Transaction Logs', 'Anonymized transaction logs from major DeFi protocols',
 (SELECT id FROM users WHERE username = 'blockchain_bob'),
 (SELECT id FROM projects WHERE name = 'DeFi Security Analysis' AND owner_id = (SELECT id FROM users WHERE username = 'blockchain_bob')),
 'public', 'ready', 'Blockchain Data', '["defi", "transactions", "anonymized", "protocols"]',
 'defi_transactions.csv', 52428800, 'text/csv'),

('Smart Contract Vulnerabilities', 'Database of known smart contract vulnerabilities',
 (SELECT id FROM users WHERE username = 'blockchain_bob'),
 (SELECT id FROM projects WHERE name = 'Smart Contract Audit Tool' AND owner_id = (SELECT id FROM users WHERE username = 'blockchain_bob')),
 'private', 'failed', 'Security Data', '["smart-contracts", "vulnerabilities", "security"]',
 'vulnerabilities.json', 3145728, 'application/json'),

('Blockchain Network Metrics', 'Performance metrics from various blockchain networks',
 (SELECT id FROM users WHERE username = 'blockchain_bob'),
 (SELECT id FROM projects WHERE name = 'DeFi Security Analysis' AND owner_id = (SELECT id FROM users WHERE username = 'blockchain_bob')),
 'encrypted', 'ready', 'Performance Data', '["blockchain", "metrics", "performance", "networks"]',
 'network_metrics.csv', 18874368, 'text/csv'),

-- Charlie's datasets (Climate)
('Global Temperature Records', '150 years of global temperature measurements',
 (SELECT id FROM users WHERE username = 'climate_charlie'),
 (SELECT id FROM projects WHERE name = 'Global Temperature Analysis' AND owner_id = (SELECT id FROM users WHERE username = 'climate_charlie')),
 'public', 'ready', 'Climate Data', '["temperature", "global", "historical", "150-years"]',
 'global_temp_records.csv', 41943040, 'text/csv'),

('Ocean Current Measurements', 'Real-time ocean current data from buoy network',
 (SELECT id FROM users WHERE username = 'climate_charlie'),
 (SELECT id FROM projects WHERE name = 'Ocean Current Modeling' AND owner_id = (SELECT id FROM users WHERE username = 'climate_charlie')),
 'public', 'processing', 'Oceanographic Data', '["ocean", "currents", "buoys", "real-time"]',
 'ocean_currents.nc', 78643200, 'application/x-netcdf'),

('Arctic Ice Coverage', 'Satellite data of Arctic ice coverage over 50 years',
 (SELECT id FROM users WHERE username = 'climate_charlie'),
 (SELECT id FROM projects WHERE name = 'Global Temperature Analysis' AND owner_id = (SELECT id FROM users WHERE username = 'climate_charlie')),
 'private', 'ready', 'Climate Data', '["arctic", "ice", "satellite", "50-years"]',
 'arctic_ice_coverage.tiff', 134217728, 'image/tiff'),

-- Diana's datasets (Biotech)
('Gene Expression Profiles', 'Comprehensive gene expression data from 10,000 samples',
 (SELECT id FROM users WHERE username = 'biotech_diana'),
 (SELECT id FROM projects WHERE name = 'Gene Expression Database' AND owner_id = (SELECT id FROM users WHERE username = 'biotech_diana')),
 'encrypted', 'ready', 'Genomics Data', '["gene-expression", "profiles", "10k-samples", "comprehensive"]',
 'gene_expression.h5', 268435456, 'application/x-hdf'),

('Drug Compound Library', 'Chemical structures and properties of pharmaceutical compounds',
 (SELECT id FROM users WHERE username = 'biotech_diana'),
 (SELECT id FROM projects WHERE name = 'Drug Discovery Pipeline' AND owner_id = (SELECT id FROM users WHERE username = 'biotech_diana')),
 'private', 'processing', 'Chemical Data', '["drugs", "compounds", "chemical", "pharmaceutical"]',
 'compound_library.sdf', 62914560, 'chemical/x-mdl-sdfile'),

('Clinical Trial Results', 'Anonymized results from Phase II clinical trials',
 (SELECT id FROM users WHERE username = 'biotech_diana'),
 (SELECT id FROM projects WHERE name = 'Gene Expression Database' AND owner_id = (SELECT id FROM users WHERE username = 'biotech_diana')),
 'encrypted', 'ready', 'Medical Data', '["clinical-trials", "phase-2", "anonymized", "results"]',
 'clinical_results.csv', 31457280, 'text/csv'),

-- Frank's datasets (Data Science)
('Financial Markets Dataset', 'Historical financial market data for analysis',
 (SELECT id FROM users WHERE username = 'data_scientist_frank'),
 (SELECT id FROM projects WHERE name = 'Big Data Analytics Framework' AND owner_id = (SELECT id FROM users WHERE username = 'data_scientist_frank')),
 'public', 'ready', 'Financial Data', '["finance", "markets", "historical", "trading"]',
 'financial_markets.csv', 98304000, 'text/csv'),

-- Henry's datasets (Security)
('Cyber Threat Intelligence', 'Global cybersecurity threat intelligence data',
 (SELECT id FROM users WHERE username = 'security_henry'),
 (SELECT id FROM projects WHERE name = 'Cybersecurity Threat Detection' AND owner_id = (SELECT id FROM users WHERE username = 'security_henry')),
 'encrypted', 'ready', 'Security Data', '["cybersecurity", "threats", "intelligence", "global"]',
 'threat_intel.enc', 45678912, 'application/octet-stream');

.print "Datasets created successfully!"

-- Show created datasets
.print ""
.print "=== Created Datasets ==="
SELECT 'Dataset ID: ' || d.id || ', Name: ' || d.name || ', Status: ' || d.status || ', Privacy: ' || d.privacy_level || ', Owner: ' || u.username as dataset_info
FROM datasets d 
JOIN users u ON d.owner_id = u.id 
WHERE u.username IN ('dr_alice_ai', 'blockchain_bob', 'climate_charlie', 'biotech_diana', 'data_scientist_frank', 'security_henry')
ORDER BY d.id;

-- Now let's identify and mint NFTs for ready datasets and completed projects
.print ""
.print "=== Identifying Assets Eligible for NFT Minting ==="

.print ""
.print "Ready Datasets:"
SELECT 'Dataset ID: ' || d.id || ', Name: ' || d.name || ', Privacy: ' || d.privacy_level || ', Owner: ' || u.username as ready_datasets
FROM datasets d 
JOIN users u ON d.owner_id = u.id 
WHERE d.status = 'ready' AND u.username IN ('dr_alice_ai', 'blockchain_bob', 'climate_charlie', 'biotech_diana', 'data_scientist_frank', 'security_henry');

.print ""
.print "Completed Projects:"
SELECT 'Project ID: ' || p.id || ', Name: ' || p.name || ', Status: ' || p.status || ', Owner: ' || u.username as completed_projects
FROM projects p 
JOIN users u ON p.owner_id = u.id 
WHERE p.status = 'Completed' AND u.username IN ('dr_alice_ai', 'blockchain_bob', 'climate_charlie', 'biotech_diana', 'data_scientist_frank', 'security_henry');

-- Mint NFTs for ready datasets and completed projects
.print ""
.print "=== Minting NFTs for Eligible Assets ==="

-- Mint NFTs for ready datasets
.print ""
.print "Minting NFTs for Ready Datasets..."

-- Alice's ready datasets
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
WHERE d.status = 'ready' AND u.username = 'dr_alice_ai';

-- Bob's ready datasets  
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
WHERE d.status = 'ready' AND u.username = 'blockchain_bob';

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

-- Frank's ready datasets
INSERT INTO nfts (project_id, token_id, contract_address, metadata_uri, owner_id, created_at)
SELECT 
    d.project_id,
    'DATASET_' || d.id || '_' || strftime('%s', 'now'),
    '0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc',
    'https://ipfs.io/ipfs/QmDataset' || d.id || 'Hash',
    d.owner_id,
    datetime('now')
FROM datasets d 
JOIN users u ON d.owner_id = u.id 
WHERE d.status = 'ready' AND u.username = 'data_scientist_frank';

-- Henry's ready datasets
INSERT INTO nfts (project_id, token_id, contract_address, metadata_uri, owner_id, created_at)
SELECT 
    d.project_id,
    'DATASET_' || d.id || '_' || strftime('%s', 'now'),
    '0x14dC79964da2C08b23698B3D3cc7Ca32193d9955',
    'https://ipfs.io/ipfs/QmDataset' || d.id || 'Hash',
    d.owner_id,
    datetime('now')
FROM datasets d 
JOIN users u ON d.owner_id = u.id 
WHERE d.status = 'ready' AND u.username = 'security_henry';

.print "NFTs minted for ready datasets!"

-- Mint NFTs for completed projects
.print ""
.print "Minting NFTs for Completed Projects..."

-- Alice's completed projects
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
WHERE p.status = 'Completed' AND u.username = 'dr_alice_ai';

-- Bob's completed projects
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
WHERE p.status = 'Completed' AND u.username = 'blockchain_bob';

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

-- Frank's completed projects
INSERT INTO nfts (project_id, token_id, contract_address, metadata_uri, owner_id, created_at)
SELECT 
    p.id,
    'PROJECT_' || p.id || '_' || strftime('%s', 'now'),
    '0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc',
    'https://ipfs.io/ipfs/QmProject' || p.id || 'Hash',
    p.owner_id,
    datetime('now')
FROM projects p 
JOIN users u ON p.owner_id = u.id 
WHERE p.status = 'Completed' AND u.username = 'data_scientist_frank';

-- Henry's completed projects
INSERT INTO nfts (project_id, token_id, contract_address, metadata_uri, owner_id, created_at)
SELECT 
    p.id,
    'PROJECT_' || p.id || '_' || strftime('%s', 'now'),
    '0x14dC79964da2C08b23698B3D3cc7Ca32193d9955',
    'https://ipfs.io/ipfs/QmProject' || p.id || 'Hash',
    p.owner_id,
    datetime('now')
FROM projects p 
JOIN users u ON p.owner_id = u.id 
WHERE p.status = 'Completed' AND u.username = 'security_henry';

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
WHERE u.username IN ('dr_alice_ai', 'blockchain_bob', 'climate_charlie', 'biotech_diana', 'data_scientist_frank', 'security_henry')
ORDER BY n.id;

.print ""
.print "=== Final Statistics ==="
SELECT 'Total Users: ' || COUNT(*) as stats FROM users;
SELECT 'Total Projects: ' || COUNT(*) as stats FROM projects;
SELECT 'Total Datasets: ' || COUNT(*) as stats FROM datasets;
SELECT 'Total NFTs: ' || COUNT(*) as stats FROM nfts;
SELECT 'Ready Datasets: ' || COUNT(*) as stats FROM datasets WHERE status = 'ready';
SELECT 'Completed Projects: ' || COUNT(*) as stats FROM projects WHERE status = 'Completed';

-- Show breakdown by user
.print ""
.print "=== NFT Distribution by User ==="
SELECT 
    u.username as user,
    COUNT(n.id) as nft_count,
    COUNT(CASE WHEN n.token_id LIKE 'DATASET_%' THEN 1 END) as dataset_nfts,
    COUNT(CASE WHEN n.token_id LIKE 'PROJECT_%' THEN 1 END) as project_nfts
FROM users u
LEFT JOIN nfts n ON u.id = n.owner_id
WHERE u.username IN ('dr_alice_ai', 'blockchain_bob', 'climate_charlie', 'biotech_diana', 'data_scientist_frank', 'security_henry')
GROUP BY u.username, u.id
ORDER BY nft_count DESC;

.print ""
.print "=== Database Operations Completed Successfully! ===" 