-- List some paid NFTs for sale to test the purchase functionality

-- Update Genesis NFT (ID: 2) to be listed for sale
UPDATE nfts 
SET metadata_uri = json_patch(
  metadata_uri, 
  '{"status":"Listed","price":0.15,"listingDuration":"1w","listingDescription":"Premium Genesis dataset NFT","listedAt":"' || datetime('now') || '","updatedAt":"' || datetime('now') || '"}'
)
WHERE id = 2;

-- Update Metadata NFT (ID: 4) to be listed for sale  
UPDATE nfts 
SET metadata_uri = json_patch(
  metadata_uri, 
  '{"status":"Listed","price":0.08,"listingDuration":"2w","listingDescription":"Encrypted metadata research NFT","listedAt":"' || datetime('now') || '","updatedAt":"' || datetime('now') || '"}'
)
WHERE id = 4;

-- Update README NFT (ID: 5) to be listed for sale
UPDATE nfts 
SET metadata_uri = json_patch(
  metadata_uri, 
  '{"status":"Listed","price":0.12,"listingDuration":"1w","listingDescription":"ZK-proof protected research documentation","listedAt":"' || datetime('now') || '","updatedAt":"' || datetime('now') || '"}'
)
WHERE id = 5;

-- Show the updated NFTs
.print "=== NFTs now listed for sale ==="
SELECT 
  n.id,
  json_extract(n.metadata_uri, '$.title') as title,
  json_extract(n.metadata_uri, '$.status') as status,
  json_extract(n.metadata_uri, '$.price') as price,
  json_extract(n.metadata_uri, '$.openAccess') as open_access
FROM nfts n 
WHERE n.owner_id = 16 AND json_extract(n.metadata_uri, '$.status') = 'Listed'; 