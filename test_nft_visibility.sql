-- Test NFT visibility logic for projects and datasets
-- Run with: sqlite3 backend/desci.db < test_nft_visibility.sql

.print "=== Testing NFT Visibility Logic ==="

-- Test 1: Show all projects that should be visible (public + private with NFTs)
.print ""
.print "=== Projects Visible in Explore (Public + Private with NFTs) ==="
SELECT 
  p.id,
  p.name,
  p.visibility,
  p.status,
  u.username as owner,
  COALESCE(
    (SELECT COUNT(*) FROM nfts WHERE project_id = p.id),
    0
  ) as nft_count,
  CASE 
    WHEN EXISTS(SELECT 1 FROM nfts WHERE project_id = p.id) THEN '✅ Has NFT'
    ELSE '❌ No NFT'
  END as nft_status
FROM projects p
JOIN users u ON p.owner_id = u.id
WHERE p.visibility = 'Public' 
   OR (p.visibility = 'Private' AND EXISTS(SELECT 1 FROM nfts WHERE project_id = p.id))
ORDER BY p.visibility, p.name;

-- Test 2: Show all datasets that should be visible  
.print ""
.print "=== Datasets Visible in Explore (Public + Private/Encrypted/ZK with NFTs) ==="
SELECT 
  d.id,
  d.name,
  d.privacy_level,
  d.status,
  u.username as owner,
  CASE 
    WHEN EXISTS(SELECT 1 FROM nfts n WHERE n.project_id = d.project_id AND n.token_id LIKE 'DATASET_%') THEN '✅ Has NFT'
    ELSE '❌ No NFT'
  END as nft_status
FROM datasets d
LEFT JOIN users u ON d.owner_id = u.id
WHERE d.status = 'ready' AND (
  d.privacy_level = 'public' 
  OR (d.privacy_level IN ('private', 'encrypted', 'zk_proof_protected') 
      AND EXISTS(SELECT 1 FROM nfts n WHERE n.project_id = d.project_id AND n.token_id LIKE 'DATASET_%'))
)
ORDER BY d.privacy_level, d.name;

-- Test 3: Compare before and after - show what was hidden before but visible now
.print ""
.print "=== Previously Hidden Private Projects Now Visible Due to NFTs ==="
SELECT 
  p.id,
  p.name,
  p.visibility,
  u.username as owner,
  (SELECT COUNT(*) FROM nfts WHERE project_id = p.id) as nft_count
FROM projects p
JOIN users u ON p.owner_id = u.id
WHERE p.visibility = 'Private' AND EXISTS(SELECT 1 FROM nfts WHERE project_id = p.id);

.print ""
.print "=== Previously Hidden Private/Encrypted/ZK Datasets Now Visible Due to NFTs ==="
SELECT 
  d.id,
  d.name,
  d.privacy_level,
  u.username as owner,
  p.name as project_name
FROM datasets d
LEFT JOIN users u ON d.owner_id = u.id
LEFT JOIN projects p ON d.project_id = p.id
WHERE d.status = 'ready' 
  AND d.privacy_level IN ('private', 'encrypted', 'zk_proof_protected')
  AND EXISTS(SELECT 1 FROM nfts n WHERE n.project_id = d.project_id AND n.token_id LIKE 'DATASET_%');

-- Test 4: Statistics summary
.print ""
.print "=== Visibility Statistics ==="
.print ""
.print "Projects:"
SELECT 
  'Total Public Projects: ' || COUNT(*) as stat
FROM projects WHERE visibility = 'Public';

SELECT 
  'Total Private Projects: ' || COUNT(*) as stat
FROM projects WHERE visibility = 'Private';

SELECT 
  'Private Projects with NFTs (now visible): ' || COUNT(*) as stat
FROM projects 
WHERE visibility = 'Private' AND EXISTS(SELECT 1 FROM nfts WHERE project_id = projects.id);

.print ""
.print "Datasets:"
SELECT 
  'Total Public Datasets: ' || COUNT(*) as stat
FROM datasets WHERE privacy_level = 'public' AND status = 'ready';

SELECT 
  'Total Private Datasets: ' || COUNT(*) as stat
FROM datasets WHERE privacy_level = 'private' AND status = 'ready';

SELECT 
  'Total Encrypted Datasets: ' || COUNT(*) as stat
FROM datasets WHERE privacy_level = 'encrypted' AND status = 'ready';

SELECT 
  'Total ZK-Protected Datasets: ' || COUNT(*) as stat
FROM datasets WHERE privacy_level = 'zk_proof_protected' AND status = 'ready';

SELECT 
  'Private/Encrypted/ZK Datasets with NFTs (now visible): ' || COUNT(*) as stat
FROM datasets d
WHERE d.status = 'ready' 
  AND d.privacy_level IN ('private', 'encrypted', 'zk_proof_protected')
  AND EXISTS(SELECT 1 FROM nfts n WHERE n.project_id = d.project_id AND n.token_id LIKE 'DATASET_%');

.print ""
.print "=== NFT Marketplace Impact ==="
SELECT 
  'NFTs for Private Projects: ' || COUNT(*) as stat
FROM nfts n
JOIN projects p ON n.project_id = p.id
WHERE p.visibility = 'Private';

SELECT 
  'NFTs for Private/Encrypted Datasets: ' || COUNT(*) as stat
FROM nfts n
JOIN datasets d ON n.project_id = d.project_id
WHERE n.token_id LIKE 'DATASET_%' AND d.privacy_level IN ('private', 'encrypted', 'zk_proof_protected');

.print ""
.print "=== Test Complete ===" 