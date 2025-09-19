const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');

// Storage for PDFs
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const fs = require('fs');
    const uploadDir = path.join(__dirname, '..', 'uploads');
    // Ensure uploads directory exists
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'publication-' + uniqueSuffix + path.extname(file.originalname));
  }
});
const upload = multer({ 
  storage, 
  limits: {
    fileSize: 50 * 1024 * 1024 // 50MB limit
  },
  fileFilter: (req, file, cb) => {
    console.log('Multer fileFilter - file:', file);
    console.log('File mimetype:', file.mimetype);
    console.log('File originalname:', file.originalname);
    
    if (file.mimetype !== 'application/pdf') {
      console.error('Invalid file type:', file.mimetype);
      return cb(new Error('Only PDF files are allowed'));
    }
    console.log('File passed validation');
    cb(null, true);
  }
});

const db = require('../database');

// Test endpoint to verify API is working
router.get('/test', (req, res) => {
  console.log('Test endpoint called');
  res.json({ message: 'Publications API is working', timestamp: new Date().toISOString() });
});

// Get all public publications for explore page
router.get('/explore/public', async (req, res) => {
  try {
    const { limit = 20, offset = 0 } = req.query;
    
    // Get all published publications (only public ones)
    const publications = await db.allAsync(`
      SELECT 
        p.*,
        u.username as author_username,
        u.wallet_address as author_wallet_address
      FROM publications p
      JOIN users u ON p.author_id = u.id
      WHERE p.status IN ('Published', 'Preprint')
      ORDER BY p.created_at DESC
      LIMIT ? OFFSET ?
    `, [parseInt(limit), parseInt(offset)]);

    // Parse JSON fields and format data
    const formattedPublications = publications.map(publication => ({
      id: publication.id,
      title: publication.title,
      authors: JSON.parse(publication.authors || '[]'),
      abstract: publication.abstract,
      keywords: JSON.parse(publication.keywords || '[]'),
      category: publication.category,
      status: publication.status,
      createdAt: publication.created_at,
      publishedAt: publication.published_at,
      submittedAt: publication.submitted_at,
      lastModified: publication.last_modified,
      doi: publication.doi,
      citationCount: publication.citation_count || 0,
      downloadCount: publication.download_count || 0,
      views: publication.views || 0,
      shares: publication.shares || 0,
      reviewDeadline: publication.review_deadline,
      peerReviewId: publication.peer_review_id,
      reviewComments: publication.review_comments,
      preprintServer: publication.preprint_server,
      isImported: publication.is_imported || false,
      originalUrl: publication.original_url,
      publisher: publication.publisher,
      volume: publication.volume,
      impactFactor: publication.impact_factor,
      importNotes: publication.import_notes,
      authorUsername: publication.author_username,
      authorWalletAddress: publication.author_wallet_address
    }));

    res.json(formattedPublications);
  } catch (error) {
    console.error('Failed to get public publications:', error);
    res.status(500).json({ error: 'Failed to get public publications' });
  }
});

// Get all publications for a user (by wallet address)
router.get('/user/:walletAddress', async (req, res) => {
  const { walletAddress } = req.params;
  
  try {
    console.log('🔍 [BACKEND] Fetching publications for wallet:', walletAddress);
    
    // Get user by wallet address
    const user = await db.getAsync('SELECT id FROM users WHERE wallet_address = ?', [walletAddress]);
    if (!user) {
      console.log('❌ [BACKEND] User not found for wallet:', walletAddress);
      return res.status(404).json({ error: 'User not found' });
    }
    
    console.log('✅ [BACKEND] Found user ID:', user.id, 'for wallet:', walletAddress);

    // Get all publications authored by this user
    const publications = await db.allAsync(`
      SELECT 
        p.*,
        u.username as author_username,
        u.wallet_address as author_wallet_address
      FROM publications p
      JOIN users u ON p.author_id = u.id
      WHERE p.author_id = ?
      ORDER BY p.created_at DESC
    `, [user.id]);
    
    console.log(`📚 [BACKEND] Found ${publications.length} publications for user ID ${user.id}`);
    publications.forEach((pub, index) => {
      console.log(`📄 [BACKEND] Publication ${index + 1}:`, {
        title: pub.title,
        author_id: pub.author_id,
        author_wallet: pub.author_wallet_address,
        status: pub.status
      });
    });

    // Parse JSON fields and format data
    const formattedPublications = publications.map(publication => ({
      id: publication.id,
      title: publication.title,
      authors: JSON.parse(publication.authors || '[]'),
      abstract: publication.abstract,
      keywords: JSON.parse(publication.keywords || '[]'),
      category: publication.category,
      status: publication.status,
      createdAt: publication.created_at,
      publishedAt: publication.published_at,
      submittedAt: publication.submitted_at,
      lastModified: publication.last_modified,
      doi: publication.doi,
      citationCount: publication.citation_count || 0,
      downloadCount: publication.download_count || 0,
      views: publication.views || 0,
      shares: publication.shares || 0,
      reviewDeadline: publication.review_deadline,
      peerReviewId: publication.peer_review_id,
      reviewComments: publication.review_comments,
      preprintServer: publication.preprint_server,
      isImported: publication.is_imported || false,
      originalUrl: publication.original_url,
      publisher: publication.publisher,
      volume: publication.volume,
      impactFactor: publication.impact_factor,
      importNotes: publication.import_notes
    }));

    res.json(formattedPublications);
  } catch (error) {
    console.error('Failed to get user publications:', error);
    res.status(500).json({ error: 'Failed to get user publications' });
  }
});

// Get a specific publication by ID
router.get('/:publicationId', async (req, res) => {
  const { publicationId } = req.params;
  
  try {
    const publication = await db.getAsync(`
      SELECT 
        p.*,
        u.username as author_username,
        u.wallet_address as author_wallet_address
      FROM publications p
      JOIN users u ON p.author_id = u.id
      WHERE p.id = ?
    `, [publicationId]);

    if (!publication) {
      return res.status(404).json({ error: 'Publication not found' });
    }

    // Parse JSON fields and format data
    const formattedPublication = {
      id: publication.id,
      title: publication.title,
      authors: JSON.parse(publication.authors || '[]'),
      abstract: publication.abstract,
      keywords: JSON.parse(publication.keywords || '[]'),
      category: publication.category,
      status: publication.status,
      createdAt: publication.created_at,
      publishedAt: publication.published_at,
      submittedAt: publication.submitted_at,
      lastModified: publication.last_modified,
      doi: publication.doi,
      citationCount: publication.citation_count || 0,
      downloadCount: publication.download_count || 0,
      views: publication.views || 0,
      shares: publication.shares || 0,
      reviewDeadline: publication.review_deadline,
      peerReviewId: publication.peer_review_id,
      reviewComments: publication.review_comments,
      preprintServer: publication.preprint_server,
      isImported: publication.is_imported || false,
      originalUrl: publication.original_url,
      publisher: publication.publisher,
      volume: publication.volume,
      impactFactor: publication.impact_factor,
      importNotes: publication.import_notes,
      authorUsername: publication.author_username,
      authorWalletAddress: publication.author_wallet_address
    };

    res.json(formattedPublication);
  } catch (error) {
    console.error('Failed to get publication:', error);
    res.status(500).json({ error: 'Failed to get publication' });
  }
});

// Create a new publication
router.post('/', async (req, res) => {
  console.log('=== CREATE PUBLICATION REQUEST ===');
  console.log('Request body:', JSON.stringify(req.body, null, 2));
  
  const {
    title,
    authors,
    abstract,
    keywords,
    category,
    status = 'Draft',
    author_wallet_address,
    doi,
    peer_review_id,
    review_comments,
    preprint_server,
    published_at,
    citation_count,
    download_count,
    views,
    is_imported,
    original_url,
    publisher,
    volume,
    impact_factor,
    import_notes,
    pdf_path,
    pdf_file_name,
    pdf_file_size,
    pdf_mime_type
  } = req.body;

  if (!title || !authors || !author_wallet_address) {
    console.error('Missing required fields:', { title: !!title, authors: !!authors, author_wallet_address: !!author_wallet_address });
    return res.status(400).json({ error: 'Title, authors, and author wallet address are required' });
  }

  try {
    console.log('Looking up author with wallet address:', author_wallet_address);
    
    // Get author by wallet address
    const author = await db.getAsync('SELECT id FROM users WHERE wallet_address = ?', [author_wallet_address]);
    if (!author) {
      console.error('Author not found for wallet address:', author_wallet_address);
      return res.status(404).json({ error: 'Author not found' });
    }

    console.log('Found author:', author);

    // Prepare values for insertion
    const insertValues = [
      title,
      JSON.stringify(authors),
      abstract,
      JSON.stringify(keywords || []),
      category,
      status,
      author.id,
      doi,
      peer_review_id,
      review_comments,
      preprint_server,
      published_at,
      citation_count || 0,
      download_count || 0,
      views || 0,
      is_imported || false,
      original_url,
      publisher,
      volume,
      impact_factor,
      import_notes,
      pdf_path || null,
      pdf_file_name || null,
      pdf_file_size || null,
      pdf_mime_type || null
    ];

    console.log('Insert values:', insertValues);

    // Insert publication - simplified first
    console.log('Attempting to insert publication...');
    
    // Prepare values with proper type conversion
    const sqlValues = [
      title || null,                              // title - string
      JSON.stringify(authors || []),              // authors - JSON string
      abstract || null,                           // abstract - string
      JSON.stringify(keywords || []),             // keywords - JSON string
      category || null,                           // category - string
      status || 'Draft',                          // status - string
      author.id,                                  // author_id - number
      doi || null,                                // doi - string
      published_at || null,                       // published_at - string (ISO)
      parseInt(citation_count) || 0,              // citation_count - number
      parseInt(download_count) || 0,              // download_count - number
      parseInt(views) || 0,                       // views - number
      is_imported ? 1 : 0,                        // is_imported - number (boolean as int)
      original_url || null,                       // original_url - string
      publisher || null,                          // publisher - string
      volume || null,                             // volume - string
      impact_factor ? parseFloat(impact_factor) : null, // impact_factor - number
      import_notes || null,                       // import_notes - string
      pdf_path || null,                           // pdf_path - string
      pdf_file_name || null,                      // pdf_file_name - string
      pdf_file_size ? parseInt(pdf_file_size) : null, // pdf_file_size - number
      pdf_mime_type || null,                      // pdf_mime_type - string
      preprint_server || null                     // preprint_server - string
    ];

    console.log('SQL values with types:', sqlValues.map((val, i) => ({ index: i, value: val, type: typeof val })));

    const result = await db.runAsync(`
      INSERT INTO publications (
        title, authors, abstract, keywords, category, status, author_id,
        doi, published_at, citation_count, download_count, views,
        is_imported, original_url, publisher, volume, impact_factor, import_notes,
        pdf_path, pdf_file_name, pdf_file_size, pdf_mime_type,
        preprint_server
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, sqlValues);
    
    console.log('Insert successful, result:', result);

    // Get the created publication
    const newPublication = await db.getAsync(`
      SELECT 
        p.*,
        u.username as author_username,
        u.wallet_address as author_wallet_address
      FROM publications p
      JOIN users u ON p.author_id = u.id
      WHERE p.id = ?
    `, [result.lastID]);

    // Format the response
    const formattedPublication = {
      id: newPublication.id,
      title: newPublication.title,
      authors: JSON.parse(newPublication.authors || '[]'),
      abstract: newPublication.abstract,
      keywords: JSON.parse(newPublication.keywords || '[]'),
      category: newPublication.category,
      status: newPublication.status,
      createdAt: newPublication.created_at,
      publishedAt: newPublication.published_at,
      submittedAt: newPublication.submitted_at,
      lastModified: newPublication.last_modified,
      doi: newPublication.doi,
      citationCount: newPublication.citation_count || 0,
      downloadCount: newPublication.download_count || 0,
      views: newPublication.views || 0,
      shares: newPublication.shares || 0,
      reviewDeadline: newPublication.review_deadline,
      peerReviewId: newPublication.peer_review_id,
      reviewComments: newPublication.review_comments,
      preprintServer: newPublication.preprint_server
    };

    res.status(201).json(formattedPublication);
  } catch (error) {
    console.error('=== PUBLICATION CREATION ERROR ===');
    console.error('Error type:', error.constructor.name);
    console.error('Error message:', error.message);
    console.error('Error stack:', error.stack);
    if (error.code) {
      console.error('Error code:', error.code);
    }
    res.status(500).json({ 
      error: 'Failed to create publication', 
      details: error.message,
      code: error.code
    });
  }
});

// Update publication
router.put('/:publicationId', async (req, res) => {
  const { publicationId } = req.params;
  const {
    title,
    authors,
    abstract,
    keywords,
    category,
    status,
    doi,
    peer_review_id,
    review_comments,
    preprint_server,
    published_at,
    submitted_at
  } = req.body;

  try {
    let updateFields = [];
    let params = [];

    if (title !== undefined) {
      updateFields.push('title = ?');
      params.push(title);
    }
    if (authors !== undefined) {
      updateFields.push('authors = ?');
      params.push(JSON.stringify(authors));
    }
    if (abstract !== undefined) {
      updateFields.push('abstract = ?');
      params.push(abstract);
    }
    if (keywords !== undefined) {
      updateFields.push('keywords = ?');
      params.push(JSON.stringify(keywords));
    }
    if (category !== undefined) {
      updateFields.push('category = ?');
      params.push(category);
    }
    if (status !== undefined) {
      updateFields.push('status = ?');
      params.push(status);
    }
    if (doi !== undefined) {
      updateFields.push('doi = ?');
      params.push(doi);
    }
    if (peer_review_id !== undefined) {
      updateFields.push('peer_review_id = ?');
      params.push(peer_review_id);
    }
    if (review_comments !== undefined) {
      updateFields.push('review_comments = ?');
      params.push(review_comments);
    }
    if (preprint_server !== undefined) {
      updateFields.push('preprint_server = ?');
      params.push(preprint_server);
    }
    if (published_at !== undefined) {
      updateFields.push('published_at = ?');
      params.push(published_at);
    }
    if (submitted_at !== undefined) {
      updateFields.push('submitted_at = ?');
      params.push(submitted_at);
    }

    updateFields.push('updated_at = datetime(\'now\')');
    updateFields.push('last_modified = datetime(\'now\')');
    params.push(publicationId);

    const query = `
      UPDATE publications 
      SET ${updateFields.join(', ')} 
      WHERE id = ?
    `;

    const result = await db.runAsync(query, params);

    if (result.changes === 0) {
      return res.status(404).json({ error: 'Publication not found' });
    }

    // Get updated publication
    const updatedPublication = await db.getAsync(`
      SELECT 
        p.*,
        u.username as author_username,
        u.wallet_address as author_wallet_address
      FROM publications p
      JOIN users u ON p.author_id = u.id
      WHERE p.id = ?
    `, [publicationId]);

    // Format the response
    const formattedPublication = {
      id: updatedPublication.id,
      title: updatedPublication.title,
      authors: JSON.parse(updatedPublication.authors || '[]'),
      abstract: updatedPublication.abstract,
      keywords: JSON.parse(updatedPublication.keywords || '[]'),
      category: updatedPublication.category,
      status: updatedPublication.status,
      createdAt: updatedPublication.created_at,
      publishedAt: updatedPublication.published_at,
      submittedAt: updatedPublication.submitted_at,
      lastModified: updatedPublication.last_modified,
      doi: updatedPublication.doi,
      citationCount: updatedPublication.citation_count || 0,
      downloadCount: updatedPublication.download_count || 0,
      views: updatedPublication.views || 0,
      shares: updatedPublication.shares || 0,
      reviewDeadline: updatedPublication.review_deadline,
      peerReviewId: updatedPublication.peer_review_id,
      reviewComments: updatedPublication.review_comments,
      preprintServer: updatedPublication.preprint_server
    };

    res.json(formattedPublication);
  } catch (error) {
    console.error('Failed to update publication:', error);
    res.status(500).json({ error: 'Failed to update publication' });
  }
});

// Delete a publication
router.delete('/:publicationId', async (req, res) => {
  const { publicationId } = req.params;

  try {
    const result = await db.runAsync('DELETE FROM publications WHERE id = ?', [publicationId]);

    if (result.changes === 0) {
      return res.status(404).json({ error: 'Publication not found' });
    }

    res.json({ message: 'Publication deleted successfully' });
  } catch (error) {
    console.error('Failed to delete publication:', error);
    res.status(500).json({ error: 'Failed to delete publication' });
  }
});

// DOI lookup endpoint (optional proxy to avoid CORS issues)
router.get('/doi/:doi', async (req, res) => {
  const { doi } = req.params;
  
  // Validate DOI format
  const doiPattern = /^10\.\d{4,9}\/[-._;()\/:a-zA-Z0-9]+$/;
  if (!doiPattern.test(doi)) {
    return res.status(400).json({ error: 'Invalid DOI format' });
  }
  
  try {
    const fetch = require('node-fetch'); // You may need to install: npm install node-fetch
    
    const response = await fetch(`https://api.crossref.org/works/${doi}`, {
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'DeSci-Platform/1.0 (mailto:contact@desci-platform.org)'
      }
    });
    
    if (!response.ok) {
      if (response.status === 404) {
        return res.status(404).json({ error: 'DOI not found in database' });
      }
      return res.status(response.status).json({ error: `Failed to fetch DOI information: ${response.status}` });
    }
    
    const data = await response.json();
    const work = data.message;
    
    if (!work) {
      return res.status(404).json({ error: 'No publication data found for this DOI' });
    }
    
    // Extract and format the data
    const extractedData = {
      title: work.title && work.title.length > 0 ? work.title[0] : null,
      authors: work.author ? work.author.map(author => {
        if (author.given && author.family) {
          return `${author.given} ${author.family}`;
        } else if (author.name) {
          return author.name;
        } else {
          return author.family || 'Unknown Author';
        }
      }) : [],
      abstract: work.abstract ? work.abstract.replace(/<[^>]*>/g, '') : null,
      publishedDate: null,
      source: work['container-title'] && work['container-title'].length > 0 ? work['container-title'][0] : null,
      publisher: work.publisher || null,
      volume: null,
      keywords: work.subject ? work.subject.slice(0, 10) : [],
      category: null,
      citationCount: work['is-referenced-by-count'] || 0,
      originalUrl: work.URL || null
    };
    
    // Extract publication date
    if (work.published) {
      const pubDate = work.published['date-parts'];
      if (pubDate && pubDate[0] && pubDate[0].length >= 3) {
        const [year, month, day] = pubDate[0];
        extractedData.publishedDate = new Date(year, month - 1, day || 1).toISOString();
      } else if (pubDate && pubDate[0] && pubDate[0].length >= 1) {
        extractedData.publishedDate = new Date(pubDate[0][0], 0, 1).toISOString();
      }
    }
    
    // Extract volume/issue info
    if (work.volume || work.issue || work.page) {
      let volumeInfo = [];
      if (work.volume) volumeInfo.push(`Vol. ${work.volume}`);
      if (work.issue) volumeInfo.push(`Issue ${work.issue}`);
      if (work.page) volumeInfo.push(`pp. ${work.page}`);
      extractedData.volume = volumeInfo.join(', ');
    }
    
    // Determine category based on subject
    if (work.subject && work.subject.length > 0) {
      const subjects = work.subject.map(s => s.toLowerCase());
      if (subjects.some(s => s.includes('computer') || s.includes('software') || s.includes('algorithm'))) {
        extractedData.category = 'Computer Science';
      } else if (subjects.some(s => s.includes('biology') || s.includes('life') || s.includes('genetic'))) {
        extractedData.category = 'Biology';
      } else if (subjects.some(s => s.includes('medicine') || s.includes('medical') || s.includes('health'))) {
        extractedData.category = 'Medicine';
      } else if (subjects.some(s => s.includes('physics') || s.includes('quantum'))) {
        extractedData.category = 'Physics';
      } else if (subjects.some(s => s.includes('chemistry') || s.includes('chemical'))) {
        extractedData.category = 'Chemistry';
      } else if (subjects.some(s => s.includes('environment') || s.includes('climate'))) {
        extractedData.category = 'Environmental Science';
      }
    }
    
    res.json(extractedData);
  } catch (error) {
    console.error('DOI lookup error:', error);
    res.status(500).json({ error: 'Failed to fetch DOI information' });
  }
});

// Upload publication PDF
router.post('/upload', upload.single('pdf'), async (req, res) => {
  try {
    console.log('PDF upload request received');
    console.log('Request file:', req.file);
    console.log('Request body:', req.body);
    
    if (!req.file) {
      console.error('No file in request');
      return res.status(400).json({ error: 'PDF file is required' });
    }
    
    const { filename, path: filePath, mimetype, size, originalname } = req.file;
    
    console.log('File uploaded successfully:', {
      filename,
      filePath,
      mimetype,
      size,
      originalname
    });
    
    res.json({ 
      file_name: filename, 
      file_path: filePath, 
      mime_type: mimetype, 
      file_size: size,
      original_name: originalname
    });
  } catch (err) {
    console.error('Failed to upload publication PDF:', err);
    res.status(500).json({ error: 'Failed to upload PDF', details: err.message });
  }
});

module.exports = router; 