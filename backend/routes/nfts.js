const express = require('express');
const router = express.Router();
const db = require('../database');
const multer = require('multer');
const path = require('path');

// Multer configuration for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, path.join(__dirname, '..', 'uploads'));
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});
const upload = multer({ storage: storage });

// Get all NFTs for a user
router.get('/user/:walletAddress', async (req, res) => {
  const { walletAddress } = req.params;
  
  try {
    // Get user by wallet address
    const user = await db.getAsync('SELECT id FROM users WHERE wallet_address = ?', [walletAddress]);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Get all NFTs owned by this user
    const nfts = await db.allAsync(`
      SELECT 
        n.*,
        u.username as owner_username,
        u.wallet_address as owner_wallet_address
      FROM nfts n
      JOIN users u ON n.owner_id = u.id
      WHERE n.owner_id = ?
      ORDER BY n.created_at DESC
    `, [user.id]);

    // Format response
    const formattedNFTs = nfts.map(nft => {
      return {
        id: nft.id,
        tokenId: nft.token_id,
        contractAddress: nft.contract_address,
        metadataUri: nft.metadata_uri,
        assetType: nft.asset_type,
        projectId: nft.project_id,
        owner: {
          id: nft.owner_id,
          username: nft.owner_username,
          walletAddress: nft.owner_wallet_address
        },
        mintedAt: nft.created_at
      };
    });

    res.json(formattedNFTs);
  } catch (error) {
    console.error('Failed to get user NFTs:', error);
    res.status(500).json({ error: 'Failed to get user NFTs' });
  }
});

// Get marketplace NFTs for a specific project/dataset
router.get('/marketplace/project/:projectId', async (req, res) => {
  const { projectId } = req.params;
  
  try {
    const marketplaceNFTs = await db.allAsync(`
      SELECT 
        m.*,
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
      WHERE n.project_id = ? AND m.status = 'for_sale'
      ORDER BY m.price ASC
    `, [projectId]);

    res.json(marketplaceNFTs);
  } catch (error) {
    console.error('Failed to get marketplace NFTs for project:', error);
    res.status(500).json({ error: 'Failed to get marketplace NFTs' });
  }
});

// Get specific NFT by ID
router.get('/:nftId', async (req, res) => {
  const { nftId } = req.params;
  
  try {
    const nft = await db.getAsync(`
      SELECT 
        n.*,
        u.username as owner_username,
        u.wallet_address as owner_wallet_address
      FROM nfts n
      JOIN users u ON n.owner_id = u.id
      WHERE n.id = ?
    `, [nftId]);

    if (!nft) {
      return res.status(404).json({ error: 'NFT not found' });
    }

    const nftData = {
      id: nft.id,
      tokenId: nft.token_id,
      contractAddress: nft.contract_address,
      metadataUri: nft.metadata_uri,
      assetType: nft.asset_type,
      projectId: nft.project_id,
      owner: {
        id: nft.owner_id,
        username: nft.owner_username,
        walletAddress: nft.owner_wallet_address
      },
      mintedAt: nft.created_at,
      // Extract metadata fields
      ...metadata
    };

    res.json(nftData);
  } catch (error) {
    console.error('Failed to get NFT:', error);
    res.status(500).json({ error: 'Failed to get NFT' });
  }
});

// Mint new NFT
router.post('/mint', upload.single('coverImage'), async (req, res) => {
  const {
    assetType,
    selectedAsset,
    title,
    category,
    keywords,
    description,
    previewImageCID,
    authors,
    contentCID,
    openAccess,
    accessPrice,
    isLimitedEdition,
    editionSize,
    coverImageCID
  } = req.body;

  if (!assetType || !selectedAsset || !title || !description || !contentCID) {
    return res.status(400).json({ 
      error: 'Asset type, selected asset, title, description, and content CID are required' 
    });
  }

  try {
    // Parse authors array
    let parsedAuthors = [];
    try {
      parsedAuthors = typeof authors === 'string' ? JSON.parse(authors) : authors;
    } catch (error) {
      return res.status(400).json({ error: 'Invalid authors format' });
    }

    if (!parsedAuthors || parsedAuthors.length === 0) {
      return res.status(400).json({ error: 'At least one author is required' });
    }

    // Get the first author as the owner
    const ownerWallet = parsedAuthors[0].address;
    const user = await db.getAsync('SELECT id FROM users WHERE wallet_address = ?', [ownerWallet]);
    
    if (!user) {
      return res.status(404).json({ error: 'Owner not found' });
    }

    // Verify asset exists and belongs to the user
    let assetExists = false;
    let assetData = null;
    switch (assetType) {
      case 'Dataset':
        const dataset = await db.getAsync(
          'SELECT d.* FROM datasets d JOIN users u ON d.owner_id = u.id WHERE d.id = ? AND u.wallet_address = ?',
          [selectedAsset, ownerWallet]
        );
        assetExists = !!dataset;
        assetData = dataset;
        
        // If dataset is public, enforce that access must be open (not restricted)
        if (dataset && dataset.privacy_level === 'public' && (openAccess === 'false' || openAccess === false)) {
          return res.status(400).json({ 
            error: 'Public datasets must have open access when minting NFTs. Cannot set restricted access for public datasets.' 
          });
        }
        break;
      case 'Project':
        const project = await db.getAsync(
          'SELECT p.* FROM projects p JOIN users u ON p.owner_id = u.id WHERE p.id = ? AND u.wallet_address = ?',
          [selectedAsset, ownerWallet]
        );
        assetExists = !!project;
        assetData = project;
        
        // If project is public, enforce that access must be open (not restricted)
        if (project && project.visibility === 'Public' && (openAccess === 'false' || openAccess === false)) {
          return res.status(400).json({ 
            error: 'Public projects must have open access when minting NFTs. Cannot set restricted access for public projects.' 
          });
        }
        break;
      case 'Publication':
        const publication = await db.getAsync(
          'SELECT p.* FROM publications p JOIN users u ON p.author_id = u.id WHERE p.id = ? AND u.wallet_address = ?',
          [selectedAsset, ownerWallet]
        );
        assetExists = !!publication;
        assetData = publication;
        break;
    }

    if (!assetExists) {
      return res.status(404).json({ error: 'Asset not found or not owned by user' });
    }

    // Generate mock token ID and contract address
    const tokenId = `0x${Date.now().toString(16)}${Math.random().toString(16).substr(2, 8)}`;
    const contractAddress = '0x1234567890abcdef1234567890abcdef12345678';

    // Handle cover image
    let coverImage = coverImageCID;
    if (req.file) {
      // In a real implementation, you would upload to IPFS
      coverImage = `ipfs://Qm${Math.random().toString(36).substr(2, 44)}`;
    }

    // Create metadata
    const metadata = {
      title,
      description,
      category,
      keywords: typeof keywords === 'string' ? JSON.parse(keywords) : keywords,
      image: coverImage || previewImageCID || `https://via.placeholder.com/400x300/1a1a2e/eee?text=${encodeURIComponent(title)}`,
      assetType,
      selectedAsset: parseInt(selectedAsset),
      authors: parsedAuthors,
      contentCID,
      openAccess: openAccess === 'true' || openAccess === true,
      accessPrice: parseFloat(accessPrice) || 0,
      isLimitedEdition: isLimitedEdition === 'true' || isLimitedEdition === true,
      editionSize: parseInt(editionSize) || 0,
      status: 'Minted',
      views: 0,
      mintedAt: new Date().toISOString()
    };

    // Insert NFT record
    const result = await db.runAsync(`
      INSERT INTO nfts (
        project_id, token_id, contract_address, metadata_uri, owner_id, asset_type, created_at
      ) VALUES (?, ?, ?, ?, ?, ?, datetime('now'))
    `, [selectedAsset, tokenId, contractAddress, JSON.stringify(metadata), user.id, assetType]);

    // Get the created NFT with owner info
    const newNFT = await db.getAsync(`
      SELECT 
        n.*,
        u.username as owner_username,
        u.wallet_address as owner_wallet_address
      FROM nfts n
      JOIN users u ON n.owner_id = u.id
      WHERE n.id = ?
    `, [result.lastID]);

    const nftData = {
      id: newNFT.id,
      tokenId: newNFT.token_id,
      contractAddress: newNFT.contract_address,
      assetType: newNFT.asset_type,
      projectId: newNFT.project_id,
      owner: {
        id: newNFT.owner_id,
        username: newNFT.owner_username,
        walletAddress: newNFT.owner_wallet_address
      },
      mintedAt: newNFT.created_at,
      ...metadata
    };

    res.status(201).json({
      message: 'Asset successfully minted as NFT',
      nft: nftData
    });

  } catch (error) {
    console.error('Failed to mint NFT:', error);
    res.status(500).json({ error: 'Failed to mint NFT' });
  }
});

// List NFT for sale
router.post('/:nftId/list', async (req, res) => {
  const { nftId } = req.params;
  const { price, duration, royalty, description, walletAddress } = req.body;

  if (!price || !duration || !walletAddress) {
    return res.status(400).json({ 
      error: 'Price, duration, and wallet address are required' 
    });
  }

  try {
    // Verify user owns the NFT
    const nft = await db.getAsync(`
      SELECT n.*, u.wallet_address 
      FROM nfts n 
      JOIN users u ON n.owner_id = u.id 
      WHERE n.id = ?
    `, [nftId]);

    if (!nft) {
      return res.status(404).json({ error: 'NFT not found' });
    }

    if (nft.wallet_address !== walletAddress) {
      return res.status(403).json({ error: 'You do not own this NFT' });
    }

    // All minted NFTs can be listed for sale (skip metadata checks since we use IPFS URLs)
    // Update metadata with listing info
    const updatedMetadata = {
      metadataUri: nft.metadata_uri,
      status: 'Listed',
      price: parseFloat(price),
      royalty: parseFloat(royalty || 2.5),
      listingDuration: duration,
      listingDescription: description,
      listedAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    // NFT metadata_uri stays as IPFS URL, no need to update
    
    res.json({
      message: 'NFT listed for sale successfully',
      nft: {
        id: nft.id,
        metadataUri: nft.metadata_uri,
        status: 'Listed',
        price: parseFloat(price)
      }
    });

  } catch (error) {
    console.error('Failed to list NFT:', error);
    res.status(500).json({ error: 'Failed to list NFT' });
  }
});

// Update NFT view count
router.post('/:nftId/view', async (req, res) => {
  const { nftId } = req.params;

  try {
    const nft = await db.getAsync('SELECT * FROM nfts WHERE id = ?', [nftId]);
    
    if (!nft) {
      return res.status(404).json({ error: 'NFT not found' });
    }

    // Skip metadata parsing and view count update for IPFS URLs
    // Just log the view
    console.log(`NFT ${nftId} viewed`);

    // No need to update metadata_uri for IPFS URLs
    res.json({ success: true, message: 'View logged' });

  } catch (error) {
    console.error('Failed to update view count:', error);
    res.status(500).json({ error: 'Failed to update view count' });
  }
});

// Get all NFTs (marketplace view)
router.get('/', async (req, res) => {
  try {
    const { status, category, assetType, search, limit = 50, offset = 0 } = req.query;

    let query = `
      SELECT 
        n.*,
        u.username as owner_username,
        u.wallet_address as owner_wallet_address
      FROM nfts n
      JOIN users u ON n.owner_id = u.id
      WHERE 1=1
    `;
    const params = [];

    // Add filters
    if (assetType) {
      query += ' AND n.asset_type = ?';
      params.push(assetType);
    }

    // Add ordering and pagination
    query += ' ORDER BY n.created_at DESC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), parseInt(offset));

    const nfts = await db.allAsync(query, params);

    // Format response
    const formattedNFTs = nfts.map(nft => {
      return {
        id: nft.id,
        tokenId: nft.token_id,
        contractAddress: nft.contract_address,
        metadataUri: nft.metadata_uri,
        assetType: nft.asset_type,
        projectId: nft.project_id,
        owner: {
          id: nft.owner_id,
          username: nft.owner_username,
          walletAddress: nft.owner_wallet_address
        },
        mintedAt: nft.created_at
      };
    });

    // Apply metadata-based filters
    let filteredNFTs = formattedNFTs;

    if (status) {
      filteredNFTs = filteredNFTs.filter(nft => nft.status === status);
    }

    if (category) {
      filteredNFTs = filteredNFTs.filter(nft => nft.category === category);
    }

    if (search) {
      const searchLower = search.toLowerCase();
      filteredNFTs = filteredNFTs.filter(nft => 
        nft.title?.toLowerCase().includes(searchLower) ||
        nft.description?.toLowerCase().includes(searchLower) ||
        nft.category?.toLowerCase().includes(searchLower)
      );
    }

    res.json(filteredNFTs);
  } catch (error) {
    console.error('Failed to get NFTs:', error);
    res.status(500).json({ error: 'Failed to get NFTs' });
  }
});

// Purchase NFT from marketplace
router.post('/marketplace/purchase', async (req, res) => {
  const { marketplace_id, buyer_wallet_address } = req.body;
  
  try {
    // Get buyer user
    const buyer = await db.getAsync('SELECT id FROM users WHERE wallet_address = ?', [buyer_wallet_address]);
    if (!buyer) {
      return res.status(404).json({ error: 'Buyer not found' });
    }

    // Get marketplace listing
    const listing = await db.getAsync(`
      SELECT 
        m.*,
        n.id as nft_id,
        n.owner_id as current_owner_id,
        u.username as seller_username
      FROM nft_marketplace m
      JOIN nfts n ON m.nft_id = n.id
      JOIN users u ON m.seller_id = u.id
      WHERE m.id = ? AND m.status = 'for_sale'
    `, [marketplace_id]);

    if (!listing) {
      return res.status(404).json({ error: 'NFT listing not found or not available for sale' });
    }

    // Check if buyer is not the seller
    if (listing.seller_id === buyer.id) {
      return res.status(400).json({ error: 'Cannot buy your own NFT' });
    }

    // Start transaction (simulate blockchain purchase)
    await db.runAsync('BEGIN TRANSACTION');

    try {
      // Update NFT ownership
      await db.runAsync(
        'UPDATE nfts SET owner_id = ? WHERE id = ?',
        [buyer.id, listing.nft_id]
      );

      // Update marketplace listing
      await db.runAsync(
        'UPDATE nft_marketplace SET status = ?, sale_date = datetime(\'now\'), buyer_id = ? WHERE id = ?',
        ['sold', buyer.id, marketplace_id]
      );

      // Commit transaction
      await db.runAsync('COMMIT');

      res.json({
        success: true,
        message: `Successfully purchased NFT for ${listing.price} ${listing.currency}`,
        transaction: {
          nft_id: listing.nft_id,
          price: listing.price,
          currency: listing.currency,
          seller: listing.seller_username,
          buyer_id: buyer.id
        }
      });

    } catch (error) {
      await db.runAsync('ROLLBACK');
      throw error;
    }

  } catch (error) {
    console.error('Failed to purchase NFT:', error);
    res.status(500).json({ error: 'Failed to purchase NFT' });
  }
});

module.exports = router; 