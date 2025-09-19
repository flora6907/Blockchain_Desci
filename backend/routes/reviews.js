const express = require('express');
const router = express.Router();
const db = require('../database');

// Get all reviews for a user (by wallet address)
router.get('/user/:walletAddress', async (req, res) => {
  const { walletAddress } = req.params;
  
  try {
    // Get user by wallet address
    const user = await db.getAsync('SELECT id FROM users WHERE wallet_address = ?', [walletAddress]);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Get all reviews assigned to this user
    const reviews = await db.allAsync(`
      SELECT 
        r.*,
        u.username as reviewer_username,
        u.wallet_address as reviewer_wallet_address
      FROM reviews r
      JOIN users u ON r.reviewer_id = u.id
      WHERE r.reviewer_id = ?
      ORDER BY r.deadline ASC, r.created_at DESC
    `, [user.id]);

    // Parse JSON fields and map field names for frontend compatibility
    const formattedReviews = reviews.map(review => ({
      ...review,
      paperTitle: review.paper_title,
      assignedAt: review.assigned_at,
      reviewId: review.review_id,
      estimatedHours: review.estimated_hours,
      completedAt: review.completed_at,
      submittedAt: review.submitted_at,
      reviewContent: review.review_content,
      authors: JSON.parse(review.authors || '[]'),
      keywords: JSON.parse(review.keywords || '[]')
    }));

    res.json(formattedReviews);
  } catch (error) {
    console.error('Failed to get user reviews:', error);
    res.status(500).json({ error: 'Failed to get user reviews' });
  }
});

// Get a specific review by ID
router.get('/:reviewId', async (req, res) => {
  const { reviewId } = req.params;
  
  try {
    const review = await db.getAsync(`
      SELECT 
        r.*,
        u.username as reviewer_username,
        u.wallet_address as reviewer_wallet_address
      FROM reviews r
      JOIN users u ON r.reviewer_id = u.id
      WHERE r.id = ?
    `, [reviewId]);

    if (!review) {
      return res.status(404).json({ error: 'Review not found' });
    }

    // Parse JSON fields and map field names for frontend compatibility
    const formattedReview = {
      ...review,
      paperTitle: review.paper_title,
      assignedAt: review.assigned_at,
      reviewId: review.review_id,
      estimatedHours: review.estimated_hours,
      completedAt: review.completed_at,
      submittedAt: review.submitted_at,
      reviewContent: review.review_content,
      authors: JSON.parse(review.authors || '[]'),
      keywords: JSON.parse(review.keywords || '[]')
    };

    res.json(formattedReview);
  } catch (error) {
    console.error('Failed to get review:', error);
    res.status(500).json({ error: 'Failed to get review' });
  }
});

// Create a new review assignment
router.post('/', async (req, res) => {
  const {
    paper_title,
    authors,
    abstract,
    keywords,
    category,
    journal,
    urgency = 'Medium',
    reviewer_wallet_address,
    deadline,
    estimated_hours = 8
  } = req.body;

  if (!paper_title || !authors || !reviewer_wallet_address) {
    return res.status(400).json({ error: 'Paper title, authors, and reviewer wallet address are required' });
  }

  try {
    // Get reviewer by wallet address
    const reviewer = await db.getAsync('SELECT id FROM users WHERE wallet_address = ?', [reviewer_wallet_address]);
    if (!reviewer) {
      return res.status(404).json({ error: 'Reviewer not found' });
    }

    // Generate unique review ID
    const review_id = `REV-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;

    // Insert review
    const result = await db.runAsync(`
      INSERT INTO reviews (
        paper_title, authors, abstract, keywords, category, journal,
        urgency, reviewer_id, deadline, estimated_hours, review_id,
        created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'), datetime('now'))
    `, [
      paper_title,
      JSON.stringify(authors),
      abstract,
      JSON.stringify(keywords || []),
      category,
      journal,
      urgency,
      reviewer.id,
      deadline,
      estimated_hours,
      review_id
    ]);

    // Get the created review
    const newReview = await db.getAsync(`
      SELECT 
        r.*,
        u.username as reviewer_username,
        u.wallet_address as reviewer_wallet_address
      FROM reviews r
      JOIN users u ON r.reviewer_id = u.id
      WHERE r.id = ?
    `, [result.lastID]);

    // Parse JSON fields
    const formattedReview = {
      ...newReview,
      authors: JSON.parse(newReview.authors || '[]'),
      keywords: JSON.parse(newReview.keywords || '[]')
    };

    res.status(201).json(formattedReview);
  } catch (error) {
    console.error('Failed to create review:', error);
    res.status(500).json({ error: 'Failed to create review' });
  }
});

// Update review status/progress
router.put('/:reviewId', async (req, res) => {
  const { reviewId } = req.params;
  const {
    status,
    progress,
    review_content,
    rating,
    revision_requested,
    is_draft_save
  } = req.body;

  try {
    let updateFields = [];
    let params = [];

    if (status !== undefined) {
      updateFields.push('status = ?');
      params.push(status);
      
      // Set completion timestamp if status is Completed
      if (status === 'Completed') {
        updateFields.push('completed_at = datetime(\'now\')');
      }
      
      // Set started timestamp if status is In Progress and not already set
      if (status === 'In Progress') {
        // Check if startedAt is already set
        const existingReview = await db.getAsync('SELECT started_at FROM reviews WHERE id = ?', [reviewId]);
        if (!existingReview.started_at) {
          updateFields.push('started_at = datetime(\'now\')');
        }
      }
    }

    if (progress !== undefined) {
      updateFields.push('progress = ?');
      params.push(progress);
    }

    if (review_content !== undefined) {
      updateFields.push('review_content = ?');
      params.push(review_content);
    }

    if (rating !== undefined) {
      updateFields.push('rating = ?');
      params.push(rating);
    }

    if (revision_requested !== undefined) {
      updateFields.push('revision_requested = ?');
      params.push(revision_requested);
    }

    // If this is a draft save and status is Pending, change it to In Progress
    if (is_draft_save && !status) {
      const existingReview = await db.getAsync('SELECT status FROM reviews WHERE id = ?', [reviewId]);
      if (existingReview && existingReview.status === 'Pending') {
        updateFields.push('status = ?');
        params.push('In Progress');
        
        // Also set started timestamp
        updateFields.push('started_at = datetime(\'now\')');
      }
    }

    updateFields.push('updated_at = datetime(\'now\')');
    params.push(reviewId);

    const query = `
      UPDATE reviews 
      SET ${updateFields.join(', ')} 
      WHERE id = ?
    `;

    const result = await db.runAsync(query, params);

    if (result.changes === 0) {
      return res.status(404).json({ error: 'Review not found' });
    }

    // Get updated review
    const updatedReview = await db.getAsync(`
      SELECT 
        r.*,
        u.username as reviewer_username,
        u.wallet_address as reviewer_wallet_address
      FROM reviews r
      JOIN users u ON r.reviewer_id = u.id
      WHERE r.id = ?
    `, [reviewId]);

    // Parse JSON fields
    const formattedReview = {
      ...updatedReview,
      paperTitle: updatedReview.paper_title,
      assignedAt: updatedReview.assigned_at,
      reviewId: updatedReview.review_id,
      estimatedHours: updatedReview.estimated_hours,
      completedAt: updatedReview.completed_at,
      submittedAt: updatedReview.submitted_at,
      reviewContent: updatedReview.review_content,
      startedAt: updatedReview.started_at,
      authors: JSON.parse(updatedReview.authors || '[]'),
      keywords: JSON.parse(updatedReview.keywords || '[]')
    };

    res.json(formattedReview);
  } catch (error) {
    console.error('Failed to update review:', error);
    res.status(500).json({ error: 'Failed to update review' });
  }
});

// Start a review (change status from Pending to In Progress)
router.post('/:reviewId/start', async (req, res) => {
  const { reviewId } = req.params;

  try {
    // Check if review exists and is in Pending status
    const review = await db.getAsync('SELECT * FROM reviews WHERE id = ?', [reviewId]);
    
    if (!review) {
      return res.status(404).json({ error: 'Review not found' });
    }
    
    if (review.status !== 'Pending') {
      return res.status(400).json({ error: 'Review is not in pending status' });
    }

    // Update review to In Progress status
    const result = await db.runAsync(`
      UPDATE reviews 
      SET status = 'In Progress', 
          started_at = datetime('now'),
          updated_at = datetime('now')
      WHERE id = ?
    `, [reviewId]);

    if (result.changes === 0) {
      return res.status(404).json({ error: 'Review not found' });
    }

    // Get updated review
    const updatedReview = await db.getAsync(`
      SELECT 
        r.*,
        u.username as reviewer_username,
        u.wallet_address as reviewer_wallet_address
      FROM reviews r
      JOIN users u ON r.reviewer_id = u.id
      WHERE r.id = ?
    `, [reviewId]);

    // Parse JSON fields and map field names
    const formattedReview = {
      ...updatedReview,
      paperTitle: updatedReview.paper_title,
      assignedAt: updatedReview.assigned_at,
      reviewId: updatedReview.review_id,
      estimatedHours: updatedReview.estimated_hours,
      completedAt: updatedReview.completed_at,
      submittedAt: updatedReview.submitted_at,
      reviewContent: updatedReview.review_content,
      startedAt: updatedReview.started_at,
      authors: JSON.parse(updatedReview.authors || '[]'),
      keywords: JSON.parse(updatedReview.keywords || '[]')
    };

    res.json(formattedReview);
  } catch (error) {
    console.error('Failed to start review:', error);
    res.status(500).json({ error: 'Failed to start review' });
  }
});

// Delete a review
router.delete('/:reviewId', async (req, res) => {
  const { reviewId } = req.params;

  try {
    const result = await db.runAsync('DELETE FROM reviews WHERE id = ?', [reviewId]);

    if (result.changes === 0) {
      return res.status(404).json({ error: 'Review not found' });
    }

    res.json({ message: 'Review deleted successfully' });
  } catch (error) {
    console.error('Failed to delete review:', error);
    res.status(500).json({ error: 'Failed to delete review' });
  }
});

module.exports = router; 