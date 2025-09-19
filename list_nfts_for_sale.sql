-- List selected NFTs for sale from recently minted ones
-- Run with: sqlite3 backend/desci.db < list_nfts_for_sale.sql

.print "=== Listing Selected NFTs for Sale ==="

-- Show current NFT marketplace status
.print ""
.print "=== Current Marketplace Status ==="
SELECT 'Total listings: ' || COUNT(*) as marketplace_stats FROM nft_marketplace;

-- List some attractive NFTs for sale with competitive pricing
.print ""
.print "=== Adding NFTs to Marketplace ==="

-- High-value public datasets (easier to verify and attract buyers)
INSERT INTO nft_marketplace (nft_id, seller_id, price, currency, description) VALUES
-- Climate Satellite Data NFT (public, high-resolution data)
(15, (SELECT owner_id FROM nfts WHERE id = 15), 2.5, 'ETH', 
 'Premium climate satellite dataset NFT - High-resolution 2024 data perfect for AI/ML climate models'),

-- DeFi Transaction Logs NFT (public, valuable for analytics)
(17, (SELECT owner_id FROM nfts WHERE id = 17), 1.8, 'ETH',
 'Comprehensive DeFi transaction logs NFT - Anonymized data from major protocols, ideal for security analysis'),

-- Global Temperature Records NFT (public, 150 years of data)
(19, (SELECT owner_id FROM nfts WHERE id = 19), 3.2, 'ETH',
 'Historical global temperature records NFT - 150 years of verified climate data for research'),

-- Financial Markets Dataset NFT (public, valuable for trading algorithms)
(23, (SELECT owner_id FROM nfts WHERE id = 23), 2.1, 'ETH',
 'Financial markets dataset NFT - Historical market data perfect for algorithmic trading research');

-- Premium encrypted datasets (higher value due to exclusivity)
INSERT INTO nft_marketplace (nft_id, seller_id, price, currency, description) VALUES
-- Computer Vision Dataset NFT (encrypted, large-scale)
(16, (SELECT owner_id FROM nfts WHERE id = 16), 4.7, 'ETH',
 'Exclusive computer vision dataset NFT - Large-scale encrypted dataset for deep learning applications'),

-- Blockchain Network Metrics NFT (encrypted, performance data)
(18, (SELECT owner_id FROM nfts WHERE id = 18), 3.5, 'ETH',
 'Premium blockchain metrics NFT - Encrypted performance data from multiple networks'),

-- Gene Expression Profiles NFT (encrypted, 10k samples)
(21, (SELECT owner_id FROM nfts WHERE id = 21), 5.8, 'ETH',
 'Rare genomics data NFT - 10,000 encrypted gene expression profiles for biotech research'),

-- Cyber Threat Intelligence NFT (encrypted, security data)
(24, (SELECT owner_id FROM nfts WHERE id = 24), 4.2, 'ETH',
 'Elite cybersecurity NFT - Global threat intelligence data with encryption protection');

-- Complete project NFTs (proven value with completed status)
INSERT INTO nft_marketplace (nft_id, seller_id, price, currency, description) VALUES
-- ML Climate Prediction Model Project NFT
(25, (SELECT owner_id FROM nfts WHERE id = 25), 6.5, 'ETH',
 'Complete AI project NFT - Proven climate prediction model with satellite data integration'),

-- DeFi Security Analysis Project NFT
(26, (SELECT owner_id FROM nfts WHERE id = 26), 5.2, 'ETH',
 'DeFi security project NFT - Comprehensive protocol analysis with transaction data'),

-- Gene Expression Database Project NFT
(28, (SELECT owner_id FROM nfts WHERE id = 28), 7.8, 'ETH',
 'Biotech database project NFT - Complete gene expression database with clinical trial data'),

-- Big Data Analytics Framework Project NFT
(29, (SELECT owner_id FROM nfts WHERE id = 29), 4.9, 'ETH',
 'Data science framework NFT - Scalable analytics platform with financial market integration');

.print "NFTs successfully listed for sale!"

-- Show the marketplace listings
.print ""
.print "=== Current Marketplace Listings ==="
SELECT 
    'Listing ID: ' || m.id || 
    ', NFT: ' || n.token_id || 
    ', Price: ' || m.price || ' ' || m.currency ||
    ', Seller: ' || u.username ||
    ', Project: ' || p.name as listing_info
FROM nft_marketplace m
JOIN nfts n ON m.nft_id = n.id
JOIN users u ON m.seller_id = u.id
JOIN projects pr ON n.project_id = pr.id
WHERE m.status = 'for_sale'
ORDER BY m.price DESC;

-- Show statistics by asset type and price range
.print ""
.print "=== Marketplace Statistics ==="

.print ""
.print "By Asset Type:"
SELECT 
    CASE 
        WHEN n.token_id LIKE 'DATASET_%' THEN 'Dataset NFT'
        WHEN n.token_id LIKE 'PROJECT_%' THEN 'Project NFT'
        ELSE 'Other NFT'
    END as asset_type,
    COUNT(*) as count,
    ROUND(AVG(m.price), 2) as avg_price,
    MIN(m.price) as min_price,
    MAX(m.price) as max_price
FROM nft_marketplace m
JOIN nfts n ON m.nft_id = n.id
WHERE m.status = 'for_sale'
GROUP BY asset_type
ORDER BY avg_price DESC;

.print ""
.print "By Price Range:"
SELECT 
    CASE 
        WHEN m.price < 2.0 THEN 'Budget (< 2 ETH)'
        WHEN m.price < 4.0 THEN 'Mid-tier (2-4 ETH)'
        WHEN m.price < 6.0 THEN 'Premium (4-6 ETH)'
        ELSE 'Elite (6+ ETH)'
    END as price_range,
    COUNT(*) as count,
    ROUND(AVG(m.price), 2) as avg_price
FROM nft_marketplace m
WHERE m.status = 'for_sale'
GROUP BY price_range
ORDER BY avg_price;

.print ""
.print "By Privacy Level (Datasets only):"
SELECT 
    COALESCE(d.privacy_level, 'N/A') as privacy_level,
    COUNT(*) as count,
    ROUND(AVG(m.price), 2) as avg_price
FROM nft_marketplace m
JOIN nfts n ON m.nft_id = n.id
LEFT JOIN datasets d ON n.project_id = d.project_id AND n.token_id LIKE 'DATASET_%'
WHERE m.status = 'for_sale' AND n.token_id LIKE 'DATASET_%'
GROUP BY privacy_level
ORDER BY avg_price DESC;

.print ""
.print "Total marketplace value: "
SELECT ROUND(SUM(price), 2) || ' ETH' as total_value FROM nft_marketplace WHERE status = 'for_sale';

.print ""
.print "=== NFT Marketplace Setup Complete! ===" 