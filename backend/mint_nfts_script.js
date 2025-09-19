const Database = require('better-sqlite3');
const path = require('path');
const db = new Database('./backend/desci.db');

// --- Promisify database methods ---
db.runAsync = function (sql, params = []) {
    try {
        const stmt = this.prepare(sql);
        const result = stmt.run(params);
        return Promise.resolve({ lastID: result.lastInsertRowid, changes: result.changes });
    } catch (err) {
        return Promise.reject(err);
    }
};

db.getAsync = function (sql, params = []) {
    try {
        const stmt = this.prepare(sql);
        const row = stmt.get(params);
        return Promise.resolve(row);
    } catch (err) {
        return Promise.reject(err);
    }
};

db.allAsync = function (sql, params = []) {
    try {
        const stmt = this.prepare(sql);
        const rows = stmt.all(params);
        return Promise.resolve(rows);
    } catch (err) {
        return Promise.reject(err);
    }
};

const targetWallet = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5';
const contractAddress = '0x1234567890abcdef1234567890abcdef12345678'; // Mock contract address

async function mintNFTsForUser() {
    try {
        console.log(`Starting NFT minting process for wallet: ${targetWallet}`);
        
        // Get user ID
        const user = await db.getAsync('SELECT id FROM users WHERE wallet_address = ?', [targetWallet]);
        if (!user) {
            console.error('User not found');
            return;
        }
        
        const userId = user.id;
        console.log(`User ID: ${userId}`);
        
        // Mint NFTs for ready datasets
        console.log('\n=== Minting NFTs for Ready Datasets ===');
        const readyDatasets = await db.allAsync(`
            SELECT d.id, d.name, d.privacy_level 
            FROM datasets d 
            JOIN users u ON d.owner_id = u.id 
            WHERE u.wallet_address = ? AND d.status = 'ready'
        `, [targetWallet]);
        
        for (const dataset of readyDatasets) {
            console.log(`Minting NFT for dataset: ${dataset.name} (ID: ${dataset.id})`);
            
            const tokenId = `0x${Date.now().toString(16)}${Math.random().toString(16).substr(2, 8)}`;
            
            // Determine if access should be open (public datasets must be open)
            const isOpen = dataset.privacy_level === 'public';
            
            const metadata = {
                title: dataset.name,
                description: `Dataset NFT for ${dataset.name}`,
                category: 'Research',
                keywords: ['dataset', 'research', 'data'],
                image: `https://via.placeholder.com/400x300/1a1a2e/eee?text=${encodeURIComponent(dataset.name)}`,
                assetType: 'Dataset',
                selectedAsset: dataset.id,
                authors: [{ address: targetWallet, name: 'Researcher' }],
                contentCID: `QmDataset${dataset.id}${Math.random().toString(36).substr(2, 8)}`,
                openAccess: isOpen,
                accessPrice: isOpen ? 0 : 0.1,
                isLimitedEdition: false,
                editionSize: 0,
                status: 'Minted',
                views: 0,
                mintedAt: new Date().toISOString()
            };
            
            await db.runAsync(`
                INSERT INTO nfts (
                    project_id, token_id, contract_address, metadata_uri, owner_id, asset_type, created_at
                ) VALUES (?, ?, ?, ?, ?, ?, datetime('now'))
            `, [dataset.id, tokenId, contractAddress, JSON.stringify(metadata), userId, 'Dataset']);
            
            console.log(`✓ NFT minted for dataset ${dataset.name} with token ID: ${tokenId}`);
        }
        
        // Mint NFTs for completed projects
        console.log('\n=== Minting NFTs for Completed Projects ===');
        const completedProjects = await db.allAsync(`
            SELECT p.id, p.name, p.visibility 
            FROM projects p 
            JOIN users u ON p.owner_id = u.id 
            WHERE u.wallet_address = ? AND p.status = 'Completed'
        `, [targetWallet]);
        
        for (const project of completedProjects) {
            console.log(`Minting NFT for project: ${project.name} (ID: ${project.id})`);
            
            const tokenId = `0x${Date.now().toString(16)}${Math.random().toString(16).substr(2, 8)}`;
            
            // Public projects must have price = 0 (open access)
            const price = project.visibility === 'Public' ? 0 : 0.5;
            
            const metadata = {
                title: project.name,
                description: `Project NFT for ${project.name}`,
                image: `https://via.placeholder.com/400x300/1a1a2e/eee?text=${encodeURIComponent(project.name)}`,
                price: price,
                royalty: 5,
                tags: ['project', 'research', 'completed'],
                views: 0,
                projectId: project.id,
                mintedAt: new Date().toISOString()
            };
            
            await db.runAsync(`
                INSERT INTO nfts (
                    project_id, token_id, contract_address, metadata_uri, owner_id, created_at
                ) VALUES (?, ?, ?, ?, ?, datetime('now'))
            `, [project.id, tokenId, contractAddress, JSON.stringify(metadata), userId]);
            
            console.log(`✓ NFT minted for project ${project.name} with token ID: ${tokenId}`);
        }
        
        // Mint NFTs for published publications
        console.log('\n=== Minting NFTs for Published Publications ===');
        const publishedPublications = await db.allAsync(`
            SELECT p.id, p.title 
            FROM publications p 
            JOIN users u ON p.author_id = u.id 
            WHERE u.wallet_address = ? AND p.status = 'Published'
        `, [targetWallet]);
        
        for (const publication of publishedPublications) {
            console.log(`Minting NFT for publication: ${publication.title} (ID: ${publication.id})`);
            
            const tokenId = `0x${Date.now().toString(16)}${Math.random().toString(16).substr(2, 8)}`;
            
            const metadata = {
                title: publication.title,
                description: `Publication NFT for "${publication.title}"`,
                category: 'Academic',
                keywords: ['publication', 'research', 'academic'],
                image: `https://via.placeholder.com/400x300/1a1a2e/eee?text=${encodeURIComponent(publication.title)}`,
                assetType: 'Publication',
                selectedAsset: publication.id,
                authors: [{ address: targetWallet, name: 'Author' }],
                contentCID: `QmPublication${publication.id}${Math.random().toString(36).substr(2, 8)}`,
                openAccess: true, // Publications are generally open access for NFTs
                accessPrice: 0,
                isLimitedEdition: false,
                editionSize: 0,
                status: 'Minted',
                views: 0,
                mintedAt: new Date().toISOString()
            };
            
            await db.runAsync(`
                INSERT INTO nfts (
                    project_id, token_id, contract_address, metadata_uri, owner_id, asset_type, created_at
                ) VALUES (?, ?, ?, ?, ?, ?, datetime('now'))
            `, [publication.id, tokenId, contractAddress, JSON.stringify(metadata), userId, 'Publication']);
            
            console.log(`✓ NFT minted for publication "${publication.title}" with token ID: ${tokenId}`);
        }
        
        // Summary
        console.log('\n=== Summary ===');
        console.log(`Total datasets processed: ${readyDatasets.length}`);
        console.log(`Total projects processed: ${completedProjects.length}`);
        console.log(`Total publications processed: ${publishedPublications.length}`);
        console.log(`Total NFTs minted: ${readyDatasets.length + completedProjects.length + publishedPublications.length}`);
        
        // Verify NFTs were created
        const nftCount = await db.getAsync('SELECT COUNT(*) as count FROM nfts WHERE owner_id = ?', [userId]);
        console.log(`Total NFTs owned by user: ${nftCount.count}`);
        
    } catch (error) {
        console.error('Error minting NFTs:', error);
    } finally {
        db.close();
    }
}

// Run the script
mintNFTsForUser(); 