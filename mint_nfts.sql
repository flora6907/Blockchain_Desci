-- Mint NFTs for user with wallet address 0xE564382Be02b591E8384Ecc9e72c572d94DE20D5
-- This script will mint NFTs for ready datasets, completed projects, and published publications

-- First, let's get the user ID
.print "=== Starting NFT minting process ==="
.print "Target wallet: 0xE564382Be02b591E8384Ecc9e72c572d94DE20D5"

-- Show user info
.print ""
.print "=== User Information ==="
SELECT 'User ID: ' || id as info FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5';

-- Show eligible assets
.print ""
.print "=== Eligible Assets ==="
.print "Ready Datasets:"
SELECT '- Dataset ID ' || d.id || ': ' || d.name || ' (' || d.privacy_level || ')' as datasets
FROM datasets d 
JOIN users u ON d.owner_id = u.id 
WHERE u.wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5' AND d.status = 'ready';

.print ""
.print "Completed Projects:"
SELECT '- Project ID ' || p.id || ': ' || p.name || ' (' || p.visibility || ')' as projects
FROM projects p 
JOIN users u ON p.owner_id = u.id 
WHERE u.wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5' AND p.status = 'Completed';

.print ""
.print "Published Publications:"
SELECT '- Publication ID ' || p.id || ': ' || p.title as publications
FROM publications p 
JOIN users u ON p.author_id = u.id 
WHERE u.wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5' AND p.status = 'Published';

-- Mint NFTs for ready datasets
.print ""
.print "=== Minting NFTs for Ready Datasets ==="

-- Dataset 25: Genesis (private)
INSERT INTO nfts (
    project_id, 
    token_id, 
    contract_address, 
    metadata_uri, 
    owner_id, 
    asset_type, 
    created_at
) VALUES (
    25,
    '0x' || hex(random()) || hex(random()),
    '0x1234567890abcdef1234567890abcdef12345678',
    '{"title":"Genesis","description":"Dataset NFT for Genesis","category":"Research","keywords":["dataset","research","data"],"image":"https://via.placeholder.com/400x300/1a1a2e/eee?text=Genesis","assetType":"Dataset","selectedAsset":25,"authors":[{"address":"0xE564382Be02b591E8384Ecc9e72c572d94DE20D5","name":"Researcher"}],"contentCID":"QmDataset25abc123","openAccess":false,"accessPrice":0.1,"isLimitedEdition":false,"editionSize":0,"status":"Minted","views":0,"mintedAt":"' || datetime('now') || '"}',
    16,
    'Dataset',
    datetime('now')
);

-- Dataset 28: Simple Test (public) - must be open access
INSERT INTO nfts (
    project_id, 
    token_id, 
    contract_address, 
    metadata_uri, 
    owner_id, 
    asset_type, 
    created_at
) VALUES (
    28,
    '0x' || hex(random()) || hex(random()),
    '0x1234567890abcdef1234567890abcdef12345678',
    '{"title":"Simple Test","description":"Dataset NFT for Simple Test","category":"Research","keywords":["dataset","research","data"],"image":"https://via.placeholder.com/400x300/1a1a2e/eee?text=Simple%20Test","assetType":"Dataset","selectedAsset":28,"authors":[{"address":"0xE564382Be02b591E8384Ecc9e72c572d94DE20D5","name":"Researcher"}],"contentCID":"QmDataset28def456","openAccess":true,"accessPrice":0,"isLimitedEdition":false,"editionSize":0,"status":"Minted","views":0,"mintedAt":"' || datetime('now') || '"}',
    16,
    'Dataset',
    datetime('now')
);

-- Dataset 30: Metadata (encrypted)
INSERT INTO nfts (
    project_id, 
    token_id, 
    contract_address, 
    metadata_uri, 
    owner_id, 
    asset_type, 
    created_at
) VALUES (
    30,
    '0x' || hex(random()) || hex(random()),
    '0x1234567890abcdef1234567890abcdef12345678',
    '{"title":"Metadata","description":"Dataset NFT for Metadata","category":"Research","keywords":["dataset","research","data"],"image":"https://via.placeholder.com/400x300/1a1a2e/eee?text=Metadata","assetType":"Dataset","selectedAsset":30,"authors":[{"address":"0xE564382Be02b591E8384Ecc9e72c572d94DE20D5","name":"Researcher"}],"contentCID":"QmDataset30ghi789","openAccess":false,"accessPrice":0.1,"isLimitedEdition":false,"editionSize":0,"status":"Minted","views":0,"mintedAt":"' || datetime('now') || '"}',
    16,
    'Dataset',
    datetime('now')
);

-- Dataset 31: README (zk_proof_protected)
INSERT INTO nfts (
    project_id, 
    token_id, 
    contract_address, 
    metadata_uri, 
    owner_id, 
    asset_type, 
    created_at
) VALUES (
    31,
    '0x' || hex(random()) || hex(random()),
    '0x1234567890abcdef1234567890abcdef12345678',
    '{"title":"README","description":"Dataset NFT for README","category":"Research","keywords":["dataset","research","data"],"image":"https://via.placeholder.com/400x300/1a1a2e/eee?text=README","assetType":"Dataset","selectedAsset":31,"authors":[{"address":"0xE564382Be02b591E8384Ecc9e72c572d94DE20D5","name":"Researcher"}],"contentCID":"QmDataset31jkl012","openAccess":false,"accessPrice":0.1,"isLimitedEdition":false,"editionSize":0,"status":"Minted","views":0,"mintedAt":"' || datetime('now') || '"}',
    16,
    'Dataset',
    datetime('now')
);

-- Dataset 32: Simple Test (zk_proof_protected)
INSERT INTO nfts (
    project_id, 
    token_id, 
    contract_address, 
    metadata_uri, 
    owner_id, 
    asset_type, 
    created_at
) VALUES (
    32,
    '0x' || hex(random()) || hex(random()),
    '0x1234567890abcdef1234567890abcdef12345678',
    '{"title":"Simple Test (ZK)","description":"Dataset NFT for Simple Test (ZK Protected)","category":"Research","keywords":["dataset","research","data"],"image":"https://via.placeholder.com/400x300/1a1a2e/eee?text=Simple%20Test%20ZK","assetType":"Dataset","selectedAsset":32,"authors":[{"address":"0xE564382Be02b591E8384Ecc9e72c572d94DE20D5","name":"Researcher"}],"contentCID":"QmDataset32mno345","openAccess":false,"accessPrice":0.1,"isLimitedEdition":false,"editionSize":0,"status":"Minted","views":0,"mintedAt":"' || datetime('now') || '"}',
    16,
    'Dataset',
    datetime('now')
);

-- Mint NFTs for completed projects
.print ""
.print "=== Minting NFTs for Completed Projects ==="

-- Project 3: test-proj (Public) - must be open access (price = 0)
INSERT INTO nfts (
    project_id, 
    token_id, 
    contract_address, 
    metadata_uri, 
    owner_id, 
    created_at
) VALUES (
    3,
    '0x' || hex(random()) || hex(random()),
    '0x1234567890abcdef1234567890abcdef12345678',
    '{"title":"test-proj","description":"Project NFT for test-proj","image":"https://via.placeholder.com/400x300/1a1a2e/eee?text=test-proj","price":0,"royalty":5,"tags":["project","research","completed"],"views":0,"projectId":3,"mintedAt":"' || datetime('now') || '"}',
    16,
    datetime('now')
);

-- Mint NFTs for published publications
.print ""
.print "=== Minting NFTs for Published Publications ==="

-- Publication 12: Quantum Machine Learning for Drug Discovery: A Comprehensive Survey
INSERT INTO nfts (
    project_id, 
    token_id, 
    contract_address, 
    metadata_uri, 
    owner_id, 
    asset_type, 
    created_at
) VALUES (
    12,
    '0x' || hex(random()) || hex(random()),
    '0x1234567890abcdef1234567890abcdef12345678',
    '{"title":"Quantum Machine Learning for Drug Discovery: A Comprehensive Survey","description":"Publication NFT for Quantum Machine Learning for Drug Discovery: A Comprehensive Survey","category":"Academic","keywords":["publication","research","academic"],"image":"https://via.placeholder.com/400x300/1a1a2e/eee?text=Quantum%20ML","assetType":"Publication","selectedAsset":12,"authors":[{"address":"0xE564382Be02b591E8384Ecc9e72c572d94DE20D5","name":"Author"}],"contentCID":"QmPublication12abc","openAccess":true,"accessPrice":0,"isLimitedEdition":false,"editionSize":0,"status":"Minted","views":0,"mintedAt":"' || datetime('now') || '"}',
    16,
    'Publication',
    datetime('now')
);

-- Publication 17: Decentralized Science Platforms: Architecture and Implementation
INSERT INTO nfts (
    project_id, 
    token_id, 
    contract_address, 
    metadata_uri, 
    owner_id, 
    asset_type, 
    created_at
) VALUES (
    17,
    '0x' || hex(random()) || hex(random()),
    '0x1234567890abcdef1234567890abcdef12345678',
    '{"title":"Decentralized Science Platforms: Architecture and Implementation","description":"Publication NFT for Decentralized Science Platforms: Architecture and Implementation","category":"Academic","keywords":["publication","research","academic"],"image":"https://via.placeholder.com/400x300/1a1a2e/eee?text=DeSci%20Platforms","assetType":"Publication","selectedAsset":17,"authors":[{"address":"0xE564382Be02b591E8384Ecc9e72c572d94DE20D5","name":"Author"}],"contentCID":"QmPublication17def","openAccess":true,"accessPrice":0,"isLimitedEdition":false,"editionSize":0,"status":"Minted","views":0,"mintedAt":"' || datetime('now') || '"}',
    16,
    'Publication',
    datetime('now')
);

-- Publication 23: Zero knowledge proofs of identity
INSERT INTO nfts (
    project_id, 
    token_id, 
    contract_address, 
    metadata_uri, 
    owner_id, 
    asset_type, 
    created_at
) VALUES (
    23,
    '0x' || hex(random()) || hex(random()),
    '0x1234567890abcdef1234567890abcdef12345678',
    '{"title":"Zero knowledge proofs of identity","description":"Publication NFT for Zero knowledge proofs of identity","category":"Academic","keywords":["publication","research","academic"],"image":"https://via.placeholder.com/400x300/1a1a2e/eee?text=ZK%20Proofs","assetType":"Publication","selectedAsset":23,"authors":[{"address":"0xE564382Be02b591E8384Ecc9e72c572d94DE20D5","name":"Author"}],"contentCID":"QmPublication23ghi","openAccess":true,"accessPrice":0,"isLimitedEdition":false,"editionSize":0,"status":"Minted","views":0,"mintedAt":"' || datetime('now') || '"}',
    16,
    'Publication',
    datetime('now')
);

-- Publication 26: Blockchain-Based Secure Data Sharing in Healthcare Systems
INSERT INTO nfts (
    project_id, 
    token_id, 
    contract_address, 
    metadata_uri, 
    owner_id, 
    asset_type, 
    created_at
) VALUES (
    26,
    '0x' || hex(random()) || hex(random()),
    '0x1234567890abcdef1234567890abcdef12345678',
    '{"title":"Blockchain-Based Secure Data Sharing in Healthcare Systems","description":"Publication NFT for Blockchain-Based Secure Data Sharing in Healthcare Systems","category":"Academic","keywords":["publication","research","academic"],"image":"https://via.placeholder.com/400x300/1a1a2e/eee?text=Blockchain%20Healthcare","assetType":"Publication","selectedAsset":26,"authors":[{"address":"0xE564382Be02b591E8384Ecc9e72c572d94DE20D5","name":"Author"}],"contentCID":"QmPublication26jkl","openAccess":true,"accessPrice":0,"isLimitedEdition":false,"editionSize":0,"status":"Minted","views":0,"mintedAt":"' || datetime('now') || '"}',
    16,
    'Publication',
    datetime('now')
);

-- Publication 29: CRISPR-Cas9 Gene Editing: Safety Protocols and Ethical Considerations
INSERT INTO nfts (
    project_id, 
    token_id, 
    contract_address, 
    metadata_uri, 
    owner_id, 
    asset_type, 
    created_at
) VALUES (
    29,
    '0x' || hex(random()) || hex(random()),
    '0x1234567890abcdef1234567890abcdef12345678',
    '{"title":"CRISPR-Cas9 Gene Editing: Safety Protocols and Ethical Considerations","description":"Publication NFT for CRISPR-Cas9 Gene Editing: Safety Protocols and Ethical Considerations","category":"Academic","keywords":["publication","research","academic"],"image":"https://via.placeholder.com/400x300/1a1a2e/eee?text=CRISPR%20Safety","assetType":"Publication","selectedAsset":29,"authors":[{"address":"0xE564382Be02b591E8384Ecc9e72c572d94DE20D5","name":"Author"}],"contentCID":"QmPublication29mno","openAccess":true,"accessPrice":0,"isLimitedEdition":false,"editionSize":0,"status":"Minted","views":0,"mintedAt":"' || datetime('now') || '"}',
    16,
    'Publication',
    datetime('now')
);

-- Publication 34: Blockchain-Based Secure Data Sharing in Healthcare Systems (duplicate)
INSERT INTO nfts (
    project_id, 
    token_id, 
    contract_address, 
    metadata_uri, 
    owner_id, 
    asset_type, 
    created_at
) VALUES (
    34,
    '0x' || hex(random()) || hex(random()),
    '0x1234567890abcdef1234567890abcdef12345678',
    '{"title":"Blockchain-Based Secure Data Sharing in Healthcare Systems (v2)","description":"Publication NFT for Blockchain-Based Secure Data Sharing in Healthcare Systems (v2)","category":"Academic","keywords":["publication","research","academic"],"image":"https://via.placeholder.com/400x300/1a1a2e/eee?text=Blockchain%20Healthcare%20v2","assetType":"Publication","selectedAsset":34,"authors":[{"address":"0xE564382Be02b591E8384Ecc9e72c572d94DE20D5","name":"Author"}],"contentCID":"QmPublication34pqr","openAccess":true,"accessPrice":0,"isLimitedEdition":false,"editionSize":0,"status":"Minted","views":0,"mintedAt":"' || datetime('now') || '"}',
    16,
    'Publication',
    datetime('now')
);

-- Publication 37: CRISPR-Cas9 Gene Editing: Safety Protocols and Ethical Considerations (duplicate)
INSERT INTO nfts (
    project_id, 
    token_id, 
    contract_address, 
    metadata_uri, 
    owner_id, 
    asset_type, 
    created_at
) VALUES (
    37,
    '0x' || hex(random()) || hex(random()),
    '0x1234567890abcdef1234567890abcdef12345678',
    '{"title":"CRISPR-Cas9 Gene Editing: Safety Protocols and Ethical Considerations (v2)","description":"Publication NFT for CRISPR-Cas9 Gene Editing: Safety Protocols and Ethical Considerations (v2)","category":"Academic","keywords":["publication","research","academic"],"image":"https://via.placeholder.com/400x300/1a1a2e/eee?text=CRISPR%20Safety%20v2","assetType":"Publication","selectedAsset":37,"authors":[{"address":"0xE564382Be02b591E8384Ecc9e72c572d94DE20D5","name":"Author"}],"contentCID":"QmPublication37stu","openAccess":true,"accessPrice":0,"isLimitedEdition":false,"editionSize":0,"status":"Minted","views":0,"mintedAt":"' || datetime('now') || '"}',
    16,
    'Publication',
    datetime('now')
);

-- Show summary
.print ""
.print "=== Minting Summary ==="
.print "Total NFTs minted for user:"
SELECT COUNT(*) || ' NFTs' as total FROM nfts WHERE owner_id = 16;

.print ""
.print "NFTs by type:"
SELECT 
    COALESCE(asset_type, 'Project') as type,
    COUNT(*) as count
FROM nfts 
WHERE owner_id = 16 
GROUP BY asset_type;

.print ""
.print "=== All NFTs for user 0xE564382Be02b591E8384Ecc9e72c572d94DE20D5 ==="
SELECT 
    n.id as nft_id,
    n.token_id,
    COALESCE(n.asset_type, 'Project') as type,
    n.project_id as asset_id,
    substr(n.metadata_uri, 10, 50) || '...' as metadata_preview
FROM nfts n
WHERE n.owner_id = 16
ORDER BY n.created_at DESC; 