const express = require('express');
const router = express.Router();
const db = require('../database');

// Get user by wallet address
router.get('/wallet/:walletAddress', async (req, res) => {
  const { walletAddress } = req.params;
  
  try {
    const user = await db.getAsync(
      'SELECT * FROM users WHERE wallet_address = ?',
      [walletAddress]
    );

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Don't expose sensitive information in public profile
    const publicUser = {
      id: user.id,
      username: user.username,
      wallet_address: user.wallet_address,
      did: user.did,
      organization: user.organization,
      research_interests: user.research_interests,
      personal_website: user.personal_website,
      orcid_id: user.orcid_id,
      github_username: user.github_username,
      is_academically_verified: user.is_academically_verified,
      created_at: user.created_at
      // Exclude email and other private fields
    };

    res.json(publicUser);
  } catch (error) {
    console.error('Failed to get user by wallet address:', error);
    res.status(500).json({ error: 'Failed to get user' });
  }
});

// Get user by username
router.get('/username/:username', async (req, res) => {
  const { username } = req.params;
  
  try {
    const user = await db.getAsync(
      'SELECT * FROM users WHERE username = ?',
      [username]
    );

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Don't expose sensitive information in public profile
    const publicUser = {
      id: user.id,
      username: user.username,
      wallet_address: user.wallet_address,
      did: user.did,
      organization: user.organization,
      research_interests: user.research_interests,
      personal_website: user.personal_website,
      orcid_id: user.orcid_id,
      github_username: user.github_username,
      is_academically_verified: user.is_academically_verified,
      created_at: user.created_at
      // Exclude email and other private fields
    };

    res.json(publicUser);
  } catch (error) {
    console.error('Failed to get user by username:', error);
    res.status(500).json({ error: 'Failed to get user' });
  }
});

// Get user's public projects
router.get('/:userId/projects', async (req, res) => {
  const { userId } = req.params;
  
  try {
    const projects = await db.allAsync(`
      SELECT p.*, u.username as owner_username
      FROM projects p
      JOIN users u ON p.owner_id = u.id
      WHERE p.owner_id = ? AND p.visibility = 'Public'
      ORDER BY p.updated_at DESC
    `, [userId]);

    res.json(projects);
  } catch (error) {
    console.error('Failed to get user projects:', error);
    res.status(500).json({ error: 'Failed to get user projects' });
  }
});

// Get user dashboard statistics
router.get('/:userId/dashboard-stats', async (req, res) => {
  const { userId } = req.params;
  
  try {
    // Check if user exists
    const user = await db.getAsync('SELECT * FROM users WHERE id = ?', [userId]);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Get projects count (both owned and collaborated)
    const projectsCount = await db.getAsync(`
      SELECT COUNT(DISTINCT p.id) as count
      FROM projects p
      LEFT JOIN project_collaborators pc ON p.id = pc.project_id
      WHERE p.owner_id = ? OR pc.user_id = ?
    `, [userId, userId]);

    // Get active projects count
    const activeProjectsCount = await db.getAsync(`
      SELECT COUNT(DISTINCT p.id) as count
      FROM projects p
      LEFT JOIN project_collaborators pc ON p.id = pc.project_id
      WHERE (p.owner_id = ? OR pc.user_id = ?) AND p.status NOT IN ('Completed', 'Cancelled')
    `, [userId, userId]);

    // Get reviews count for this user
    const reviewsCount = await db.getAsync(`
      SELECT COUNT(*) as count
      FROM reviews
      WHERE reviewer_id = ?
    `, [user.id]);

    // Get citations count for this user (sum of citation_count from all their publications)
    const citationsCount = await db.getAsync(`
      SELECT COALESCE(SUM(citation_count), 0) as count
      FROM publications
      WHERE author_id = ?
    `, [user.id]);

    // Mock reputation score (since there's no reputation calculation yet)
    // In a real implementation, you would calculate based on reviews, citations, contributions, etc.
    const reputationScore = null; // Will show error as requested

    // Get recent activity (last 10 activities)
    const recentActivities = await db.allAsync(`
      SELECT 
        'project_created' as type,
        p.name as title,
        'You created project "' || p.name || '"' as description,
        p.created_at as timestamp
      FROM projects p
      WHERE p.owner_id = ?
      
      UNION ALL
      
      SELECT 
        'project_updated' as type,
        p.name as title,
        'You updated project "' || p.name || '"' as description,
        p.updated_at as timestamp
      FROM projects p
      WHERE p.owner_id = ? AND p.updated_at != p.created_at
      
      UNION ALL
      
      SELECT 
        'dataset_uploaded' as type,
        d.name as title,
        'You uploaded dataset "' || d.name || '"' as description,
        d.created_at as timestamp
      FROM datasets d
      WHERE d.owner_id = ?
      
      ORDER BY timestamp DESC
      LIMIT 10
    `, [userId, userId, userId]);

    const stats = {
      projects: {
        total: projectsCount.count || 0,
        active: activeProjectsCount.count || 0
      },
      reviews: reviewsCount.count,
      citations: citationsCount.count,
      reputation: reputationScore, // null will trigger error display
      recentActivities: recentActivities || []
    };

    res.json(stats);
  } catch (error) {
    console.error('Failed to get user dashboard stats:', error);
    res.status(500).json({ error: 'Failed to get user dashboard stats' });
  }
});

// Get user dashboard statistics by wallet address
router.get('/wallet/:walletAddress/dashboard-stats', async (req, res) => {
  const { walletAddress } = req.params;
  
  try {
    // Get user by wallet address
    const user = await db.getAsync('SELECT * FROM users WHERE wallet_address = ?', [walletAddress]);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Get projects count (both owned and collaborated)
    const projectsCount = await db.getAsync(`
      SELECT COUNT(DISTINCT p.id) as count
      FROM projects p
      LEFT JOIN project_collaborators pc ON p.id = pc.project_id
      WHERE p.owner_id = ? OR pc.user_id = ?
    `, [user.id, user.id]);

    // Get active projects count
    const activeProjectsCount = await db.getAsync(`
      SELECT COUNT(DISTINCT p.id) as count
      FROM projects p
      LEFT JOIN project_collaborators pc ON p.id = pc.project_id
      WHERE (p.owner_id = ? OR pc.user_id = ?) AND p.status NOT IN ('Completed', 'Cancelled')
    `, [user.id, user.id]);

    // Get reviews count for this user
    const reviewsCount = await db.getAsync(`
      SELECT COUNT(*) as count
      FROM reviews
      WHERE reviewer_id = ?
    `, [user.id]);

    // Get citations count for this user (sum of citation_count from all their publications)
    const citationsCount = await db.getAsync(`
      SELECT COALESCE(SUM(citation_count), 0) as count
      FROM publications
      WHERE author_id = ?
    `, [user.id]);

    // Mock reputation score (since there's no reputation calculation yet)
    // In a real implementation, you would calculate based on reviews, citations, contributions, etc.
    const reputationScore = null; // Will show error as requested

    // Get recent activity (last 10 activities)
    const recentActivities = await db.allAsync(`
      SELECT 
        'project_created' as type,
        p.name as title,
        'You created project "' || p.name || '"' as description,
        p.created_at as timestamp
      FROM projects p
      WHERE p.owner_id = ?
      
      UNION ALL
      
      SELECT 
        'project_updated' as type,
        p.name as title,
        'You updated project "' || p.name || '"' as description,
        p.updated_at as timestamp
      FROM projects p
      WHERE p.owner_id = ? AND p.updated_at != p.created_at
      
      UNION ALL
      
      SELECT 
        'dataset_uploaded' as type,
        d.name as title,
        'You uploaded dataset "' || d.name || '"' as description,
        d.created_at as timestamp
      FROM datasets d
      WHERE d.owner_id = ?
      
      ORDER BY timestamp DESC
      LIMIT 10
    `, [user.id, user.id, user.id]);

    const stats = {
      projects: {
        total: projectsCount.count || 0,
        active: activeProjectsCount.count || 0
      },
      reviews: reviewsCount.count,
      citations: citationsCount.count,
      reputation: reputationScore, // null will trigger error display
      recentActivities: recentActivities || []
    };

    res.json(stats);
  } catch (error) {
    console.error('Failed to get user dashboard stats:', error);
    res.status(500).json({ error: 'Failed to get user dashboard stats' });
  }
});

module.exports = router; 