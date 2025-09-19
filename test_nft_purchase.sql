-- Test NFT purchase functionality
-- Run with: sqlite3 backend/desci.db < test_nft_purchase.sql

.print "=== Testing NFT Purchase Functionality ==="

-- Check available NFTs in marketplace
.print ""
.print "=== Available NFTs in Marketplace ==="
SELECT 
    m.id as listing_id,
    n.token_id,
    m.price || ' ' || m.currency as price,
    m.description,
    u.username as seller,
    p.name as project_name,
    m.status
FROM nft_marketplace m
JOIN nfts n ON m.nft_id = n.id
JOIN users u ON m.seller_id = u.id
JOIN projects p ON n.project_id = p.id
WHERE m.status = 'for_sale'
ORDER BY m.price;

-- Test marketplace API data format
.print ""
.print "=== Marketplace API Format Test ==="
SELECT 
    m.id,
    m.nft_id,
    m.price,
    m.currency,
    m.description,
    n.token_id,
    n.contract_address,
    n.metadata_uri,
    u.username as seller_username,
    u.wallet_address as seller_wallet_address,
    p.name as project_name,
    p.visibility as project_visibility
FROM nft_marketplace m
JOIN nfts n ON m.nft_id = n.id
JOIN users u ON m.seller_id = u.id
JOIN projects p ON n.project_id = p.id
WHERE m.status = 'for_sale'
LIMIT 3;

-- Show projects with available NFTs
.print ""
.print "=== Projects with Available NFTs ==="
SELECT DISTINCT
    p.id as project_id,
    p.name as project_name,
    p.visibility,
    COUNT(m.id) as nft_count
FROM projects p
JOIN nfts n ON p.id = n.project_id
JOIN nft_marketplace m ON n.id = m.nft_id
WHERE m.status = 'for_sale'
GROUP BY p.id, p.name, p.visibility
ORDER BY nft_count DESC;

-- Check if users can buy their own NFTs (should be prevented)
.print ""
.print "=== Self-Purchase Prevention Test ==="
SELECT 
    'User ' || u.username || ' owns ' || COUNT(n.id) || ' NFTs and is selling ' || COUNT(m.id) || ' NFTs' as info
FROM users u
LEFT JOIN nfts n ON u.id = n.owner_id
LEFT JOIN nft_marketplace m ON u.id = m.seller_id AND m.status = 'for_sale'
WHERE u.username IN ('dr_alice_ai', 'blockchain_bob', 'climate_charlie', 'biotech_diana')
GROUP BY u.id, u.username;

.print ""
.print "=== Test Complete ===" 