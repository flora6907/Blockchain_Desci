const express = require('express');
const router = express.Router();
const db = require('../database');

// Toggle like (like/unlike) for a project, dataset, or publication
router.post('/toggle', async (req, res) => {
  const { user_wallet_address, target_type, target_id } = req.body;

  try {
    // Get user by wallet address
    const user = await db.getAsync('SELECT id FROM users WHERE wallet_address = ?', [user_wallet_address]);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Check if user already liked this item
    const existingLike = await db.getAsync(
      'SELECT id FROM likes WHERE user_id = ? AND target_type = ? AND target_id = ?',
      [user.id, target_type, target_id]
    );

    let isLiked;
    let likeCount;

    if (existingLike) {
      // Unlike: Remove the like
      await db.runAsync('DELETE FROM likes WHERE id = ?', [existingLike.id]);
      isLiked = false;
    } else {
      // Like: Add the like
      await db.runAsync(
        'INSERT INTO likes (user_id, target_type, target_id) VALUES (?, ?, ?)',
        [user.id, target_type, target_id]
      );
      isLiked = true;
    }

    // Update like count in the target table
    const tableName = target_type === 'project' ? 'projects' : 
                     target_type === 'dataset' ? 'datasets' : 'publications';
    
    const countResult = await db.getAsync(
      `SELECT COUNT(*) as count FROM likes WHERE target_type = ? AND target_id = ?`,
      [target_type, target_id]
    );
    likeCount = countResult.count;

    await db.runAsync(
      `UPDATE ${tableName} SET like_count = ? WHERE id = ?`,
      [likeCount, target_id]
    );

    res.json({
      success: true,
      isLiked: isLiked,
      likeCount: likeCount,
      message: isLiked ? 'Item liked successfully' : 'Item unliked successfully'
    });

  } catch (error) {
    console.error('Failed to toggle like:', error);
    res.status(500).json({ error: 'Failed to toggle like' });
  }
});

// Get like status for multiple items
router.post('/status', async (req, res) => {
  const { user_wallet_address, items } = req.body;
  // items should be an array of { type, id } objects

  try {
    if (!user_wallet_address) {
      // Return like counts without user-specific data
      const results = {};
      for (const item of items) {
        const tableName = item.type === 'project' ? 'projects' : 
                         item.type === 'dataset' ? 'datasets' : 'publications';
        
        const result = await db.getAsync(
          `SELECT like_count FROM ${tableName} WHERE id = ?`,
          [item.id]
        );
        
        results[`${item.type}_${item.id}`] = {
          isLiked: false,
          likeCount: result ? result.like_count || 0 : 0
        };
      }
      return res.json(results);
    }

    // Get user by wallet address
    const user = await db.getAsync('SELECT id FROM users WHERE wallet_address = ?', [user_wallet_address]);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const results = {};
    
    for (const item of items) {
      // Check if user liked this item
      const like = await db.getAsync(
        'SELECT id FROM likes WHERE user_id = ? AND target_type = ? AND target_id = ?',
        [user.id, item.type, item.id]
      );

      // Get like count
      const tableName = item.type === 'project' ? 'projects' : 
                       item.type === 'dataset' ? 'datasets' : 'publications';
      
      const result = await db.getAsync(
        `SELECT like_count FROM ${tableName} WHERE id = ?`,
        [item.id]
      );

      results[`${item.type}_${item.id}`] = {
        isLiked: !!like,
        likeCount: result ? result.like_count || 0 : 0
      };
    }

    res.json(results);

  } catch (error) {
    console.error('Failed to get like status:', error);
    res.status(500).json({ error: 'Failed to get like status' });
  }
});

// Get user's liked items
router.get('/user/:walletAddress', async (req, res) => {
  const { walletAddress } = req.params;
  const { type, limit = 50, offset = 0 } = req.query;

  try {
    // Get user by wallet address
    const user = await db.getAsync('SELECT id FROM users WHERE wallet_address = ?', [walletAddress]);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    let whereClause = 'WHERE l.user_id = ?';
    let params = [user.id];

    if (type) {
      whereClause += ' AND l.target_type = ?';
      params.push(type);
    }

    const likes = await db.allAsync(`
      SELECT 
        l.target_type,
        l.target_id,
        l.created_at,
        CASE 
          WHEN l.target_type = 'project' THEN p.name
          WHEN l.target_type = 'dataset' THEN d.name
          WHEN l.target_type = 'publication' THEN pub.title
        END as name,
        CASE 
          WHEN l.target_type = 'project' THEN p.description
          WHEN l.target_type = 'dataset' THEN d.description
          WHEN l.target_type = 'publication' THEN pub.abstract
        END as description,
        CASE 
          WHEN l.target_type = 'project' THEN u1.username
          WHEN l.target_type = 'dataset' THEN u2.username
          WHEN l.target_type = 'publication' THEN u3.username
        END as owner_username
      FROM likes l
      LEFT JOIN projects p ON l.target_type = 'project' AND l.target_id = p.id
      LEFT JOIN datasets d ON l.target_type = 'dataset' AND l.target_id = d.id
      LEFT JOIN publications pub ON l.target_type = 'publication' AND l.target_id = pub.id
      LEFT JOIN users u1 ON p.owner_id = u1.id
      LEFT JOIN users u2 ON d.owner_id = u2.id
      LEFT JOIN users u3 ON pub.author_id = u3.id
      ${whereClause}
      ORDER BY l.created_at DESC
      LIMIT ? OFFSET ?
    `, [...params, limit, offset]);

    res.json(likes);

  } catch (error) {
    console.error('Failed to get user likes:', error);
    res.status(500).json({ error: 'Failed to get user likes' });
  }
});

// Get trending (most liked) items
router.get('/trending', async (req, res) => {
  const { type, period = '7d', limit = 10 } = req.query;

  try {
    let timeFilter = '';
    if (period === '1d') {
      timeFilter = "AND l.created_at >= datetime('now', '-1 day')";
    } else if (period === '7d') {
      timeFilter = "AND l.created_at >= datetime('now', '-7 days')";
    } else if (period === '30d') {
      timeFilter = "AND l.created_at >= datetime('now', '-30 days')";
    }

    let query;
    if (!type || type === 'all') {
      query = `
        SELECT 
          'project' as type, p.id, p.name, p.description, p.like_count, u.username as owner
        FROM projects p
        JOIN users u ON p.owner_id = u.id
        WHERE p.like_count > 0
        UNION ALL
        SELECT 
          'dataset' as type, d.id, d.name, d.description, d.like_count, u.username as owner
        FROM datasets d
        JOIN users u ON d.owner_id = u.id
        WHERE d.like_count > 0
        UNION ALL
        SELECT 
          'publication' as type, pub.id, pub.title as name, pub.abstract as description, pub.like_count, u.username as owner
        FROM publications pub
        JOIN users u ON pub.author_id = u.id
        WHERE pub.like_count > 0
        ORDER BY like_count DESC
        LIMIT ?
      `;
    } else {
      const tableName = type === 'project' ? 'projects' : 
                       type === 'dataset' ? 'datasets' : 'publications';
      const nameField = type === 'publication' ? 'title' : 'name';
      const descField = type === 'publication' ? 'abstract' : 'description';
      const ownerField = type === 'publication' ? 'author_id' : 'owner_id';

      query = `
        SELECT 
          '${type}' as type, t.id, t.${nameField} as name, t.${descField} as description, 
          t.like_count, u.username as owner
        FROM ${tableName} t
        JOIN users u ON t.${ownerField} = u.id
        WHERE t.like_count > 0
        ORDER BY t.like_count DESC
        LIMIT ?
      `;
    }

    const trending = await db.allAsync(query, [limit]);
    res.json(trending);

  } catch (error) {
    console.error('Failed to get trending items:', error);
    res.status(500).json({ error: 'Failed to get trending items' });
  }
});

module.exports = router; 