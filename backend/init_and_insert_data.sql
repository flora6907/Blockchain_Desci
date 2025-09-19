-- Initialize database tables and insert test data
-- Run with: sqlite3 desci.db < init_and_insert_data.sql

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    wallet_address TEXT NOT NULL UNIQUE,
    did TEXT UNIQUE,
    username TEXT,
    email TEXT,
    github_username TEXT,
    organization TEXT,
    research_interests TEXT,
    personal_website TEXT,
    orcid_id TEXT,
    is_academically_verified BOOLEAN DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create publications table
CREATE TABLE IF NOT EXISTS publications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    authors TEXT NOT NULL, -- JSON array of author names
    abstract TEXT,
    keywords TEXT, -- JSON array of keywords
    category TEXT,
    status TEXT NOT NULL DEFAULT 'Draft', -- Draft, Under Review, Revision Required, Published, Preprint
    author_id INTEGER NOT NULL, -- User who authored/owns this publication
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    published_at TIMESTAMP,
    submitted_at TIMESTAMP,
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    doi TEXT,
    citation_count INTEGER DEFAULT 0,
    download_count INTEGER DEFAULT 0,
    review_deadline TIMESTAMP,
    peer_review_id TEXT,
    review_comments TEXT,
    preprint_server TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users (id)
);

-- Create reviews table
CREATE TABLE IF NOT EXISTS reviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    paper_title TEXT NOT NULL,
    authors TEXT NOT NULL, -- JSON array of author names
    abstract TEXT,
    keywords TEXT, -- JSON array of keywords
    category TEXT,
    journal TEXT,
    status TEXT NOT NULL DEFAULT 'Pending', -- Pending, In Progress, Under Review, Completed, Revision Requested
    urgency TEXT NOT NULL DEFAULT 'Medium', -- Low, Medium, High
    reviewer_id INTEGER NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deadline TIMESTAMP,
    estimated_hours INTEGER DEFAULT 8,
    review_id TEXT UNIQUE,
    progress INTEGER DEFAULT 0, -- 0-100 percentage
    completed_at TIMESTAMP,
    submitted_at TIMESTAMP,
    rating REAL, -- 1.0-5.0 rating
    review_content TEXT, -- The actual review content
    revision_requested BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reviewer_id) REFERENCES users (id)
);

-- Create citations table
CREATE TABLE IF NOT EXISTS citations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    citing_paper_title TEXT NOT NULL,
    citing_authors TEXT, -- JSON array of author names
    cited_paper_title TEXT NOT NULL,
    cited_authors TEXT, -- JSON array of author names
    citation_context TEXT, -- The context where the citation appears
    citation_type TEXT DEFAULT 'reference', -- reference, mention, comparison
    user_id INTEGER, -- User who owns the cited paper
    publication_id INTEGER, -- Reference to the publication being cited
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (publication_id) REFERENCES publications (id)
);

-- Insert or update the user
INSERT OR REPLACE INTO users (wallet_address, did) 
VALUES ('0xE564382Be02b591E8384Ecc9e72c572d94DE20D5', 'did:ethr:0xE564382Be02b591E8384Ecc9e72c572d94DE20D5');

-- Get the user ID for reference
-- Note: In this script, we'll assume user_id = 1, but you should check the actual ID

-- Insert test publications
INSERT OR REPLACE INTO publications (
  title, authors, abstract, keywords, category, status, author_id,
  created_at, published_at, submitted_at, last_modified, doi, citation_count,
  download_count, review_deadline, peer_review_id, review_comments, preprint_server,
  updated_at
) VALUES 
(
  'Quantum Machine Learning for Drug Discovery: A Comprehensive Survey',
  '["Dr. Sarah Chen", "Prof. Michael Zhang", "Dr. Lisa Wang"]',
  'This paper presents a comprehensive survey of quantum machine learning applications in drug discovery, exploring the potential of quantum algorithms to accelerate pharmaceutical research and development processes.',
  '["Quantum Computing", "Machine Learning", "Drug Discovery", "Pharmaceutical Research", "Quantum Algorithms"]',
  'Computer Science',
  'Published',
  (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
  '2024-01-15T00:00:00.000Z',
  '2024-02-20T00:00:00.000Z',
  NULL,
  '2024-01-15T00:00:00.000Z',
  '10.1000/xyz123',
  45,
  1250,
  NULL,
  NULL,
  NULL,
  NULL,
  datetime('now')
),
(
  'Sustainable Energy Storage Systems: A Machine Learning Approach',
  '["Prof. David Liu", "Dr. Emma Thompson"]',
  'We propose novel machine learning algorithms for optimizing sustainable energy storage systems, focusing on battery management and grid integration for renewable energy sources.',
  '["Energy Storage", "Machine Learning", "Sustainability", "Battery Management", "Grid Integration"]',
  'Environmental Science',
  'Under Review',
  (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
  '2024-01-20T00:00:00.000Z',
  NULL,
  '2024-02-01T00:00:00.000Z',
  '2024-01-20T00:00:00.000Z',
  NULL,
  0,
  0,
  '2024-03-15T00:00:00.000Z',
  'PR-2024-001',
  NULL,
  NULL,
  datetime('now')
),
(
  'Blockchain-Based Healthcare Data Management with Zero-Knowledge Proofs',
  '["Dr. Alex Kim", "Prof. Jennifer Lee", "Dr. Robert Brown"]',
  'This study explores the implementation of blockchain technology with zero-knowledge proofs for secure and private healthcare data management systems.',
  '["Blockchain", "Healthcare", "Zero-Knowledge Proofs", "Data Management", "Privacy"]',
  'Computer Science',
  'Draft',
  (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
  '2024-02-01T00:00:00.000Z',
  NULL,
  NULL,
  '2024-02-15T00:00:00.000Z',
  NULL,
  0,
  0,
  NULL,
  NULL,
  NULL,
  NULL,
  datetime('now')
),
(
  'Gene Therapy Optimization Using Artificial Intelligence',
  '["Dr. Maria Garcia", "Prof. James Wilson"]',
  'An innovative approach to gene therapy optimization leveraging artificial intelligence algorithms to improve treatment efficacy and reduce side effects.',
  '["Gene Therapy", "Artificial Intelligence", "Medical Treatment", "Optimization", "Biotechnology"]',
  'Biotechnology',
  'Revision Required',
  (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
  '2024-01-10T00:00:00.000Z',
  NULL,
  '2024-01-25T00:00:00.000Z',
  '2024-01-10T00:00:00.000Z',
  NULL,
  0,
  0,
  NULL,
  'PR-2024-002',
  'Minor revisions needed in methodology section',
  NULL,
  datetime('now')
),
(
  'Climate Change Impact on Marine Biodiversity: A Deep Learning Analysis',
  '["Dr. Ocean Blue", "Prof. Green Earth"]',
  'Using deep learning techniques to analyze the impact of climate change on marine biodiversity patterns across different oceanic regions.',
  '["Climate Change", "Marine Biology", "Deep Learning", "Biodiversity", "Ocean Science"]',
  'Marine Biology',
  'Preprint',
  (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
  '2024-02-05T00:00:00.000Z',
  '2024-02-10T00:00:00.000Z',
  NULL,
  '2024-02-05T00:00:00.000Z',
  NULL,
  0,
  680,
  NULL,
  NULL,
  NULL,
  'bioRxiv',
  datetime('now')
),
(
  'Decentralized Science Platforms: Architecture and Implementation',
  '["Your Name", "Dr. Collaborator"]',
  'This paper presents a comprehensive architecture for decentralized science platforms, focusing on blockchain integration, peer review mechanisms, and data integrity.',
  '["DeSci", "Blockchain", "Peer Review", "Data Integrity", "Decentralization"]',
  'Computer Science',
  'Published',
  (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
  '2023-11-15T00:00:00.000Z',
  '2023-12-20T00:00:00.000Z',
  NULL,
  '2023-11-15T00:00:00.000Z',
  '10.1000/desci456',
  28,
  890,
  NULL,
  NULL,
  NULL,
  NULL,
  datetime('now')
);

-- Insert test reviews
INSERT OR REPLACE INTO reviews (
  paper_title, authors, abstract, keywords, category, journal,
  status, urgency, reviewer_id, deadline, estimated_hours, review_id,
  progress, created_at, updated_at
) VALUES 
(
  'Blockchain-Based Identity Management for DeSci Platforms',
  '["Dr. Sarah Chen", "Prof. Michael Zhang", "Dr. Lisa Wang"]',
  'This paper explores the implementation of blockchain-based identity management systems specifically designed for decentralized science platforms, focusing on privacy, security, and interoperability.',
  '["Blockchain", "Identity Management", "DeSci", "Privacy", "Security"]',
  'Computer Science',
  'Journal of Blockchain Technology',
  'Pending',
  'High',
  (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
  datetime('now', '+7 days'),
  12,
  'REV-2024-001-TEST',
  0,
  datetime('now'),
  datetime('now')
),
(
  'Zero-Knowledge Proofs for Privacy-Preserving Research Data Sharing',
  '["Prof. Alice Johnson", "Dr. Bob Smith"]',
  'We present a novel approach to research data sharing using zero-knowledge proofs, enabling researchers to verify data integrity and authenticity without exposing sensitive information.',
  '["Zero-Knowledge Proofs", "Privacy", "Data Sharing", "Research", "Cryptography"]',
  'Cryptography',
  'Privacy & Security in Research',
  'In Progress',
  'Medium',
  (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
  datetime('now', '+14 days'),
  15,
  'REV-2024-002-TEST',
  35,
  datetime('now'),
  datetime('now')
),
(
  'Decentralized Peer Review Systems: A Comparative Analysis',
  '["Dr. Emma Wilson", "Prof. David Lee", "Dr. Charlie Brown"]',
  'This study provides a comprehensive comparison of various decentralized peer review systems, analyzing their effectiveness, scalability, and impact on research quality.',
  '["Peer Review", "Decentralization", "Research Quality", "Scalability", "Analysis"]',
  'Research Methodology',
  'Future of Scientific Publishing',
  'Under Review',
  'Low',
  (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
  datetime('now', '+21 days'),
  10,
  'REV-2024-003-TEST',
  80,
  datetime('now'),
  datetime('now')
),
(
  'Smart Contracts for Automated Research Funding Distribution',
  '["Prof. Robert Green", "Dr. Maria Rodriguez"]',
  'Investigation of smart contract implementations for transparent and automated distribution of research funding based on predefined milestones and peer review outcomes.',
  '["Smart Contracts", "Research Funding", "Automation", "Transparency", "Blockchain"]',
  'Financial Technology',
  'Blockchain in Academia',
  'Completed',
  'Medium',
  (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
  datetime('now', '-5 days'),
  8,
  'REV-2024-004-TEST',
  100,
  datetime('now'),
  datetime('now')
),
(
  'Machine Learning Applications in Decentralized Science Platforms',
  '["Dr. Jennifer Kim", "Prof. Alex Thompson"]',
  'This paper explores various machine learning applications that can enhance decentralized science platforms, including automated peer matching, research trend analysis, and quality assessment.',
  '["Machine Learning", "DeSci", "Automation", "Peer Matching", "Quality Assessment"]',
  'Artificial Intelligence',
  'AI in Scientific Research',
  'Revision Requested',
  'High',
  (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
  datetime('now', '+10 days'),
  14,
  'REV-2024-005-TEST',
  60,
  datetime('now'),
  datetime('now')
);

-- Insert test citations that reference specific publications
INSERT OR REPLACE INTO citations (
  citing_paper_title, citing_authors, cited_paper_title, cited_authors,
  citation_context, citation_type, user_id, publication_id, created_at
) VALUES 
(
  'Advanced Cryptographic Protocols in Blockchain Systems',
  '["Dr. John Doe", "Prof. Jane Smith"]',
  'Decentralized Science Platforms: Architecture and Implementation',
  '["Your Name", "Dr. Collaborator"]',
  'The decentralized architecture proposed by [Author] provides a solid foundation for implementing secure cryptographic protocols in blockchain-based research platforms...',
  'reference',
  (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
  (SELECT id FROM publications WHERE title = 'Decentralized Science Platforms: Architecture and Implementation' LIMIT 1),
  datetime('now')
),
(
  'Privacy Technologies in Decentralized Research Networks',
  '["Prof. Alice Cooper", "Dr. Bob Wilson"]',
  'Blockchain-Based Healthcare Data Management with Zero-Knowledge Proofs',
  '["Dr. Alex Kim", "Prof. Jennifer Lee", "Dr. Robert Brown"]',
  'Building upon the privacy framework described in [Author]''s work on healthcare data management, we extend these concepts to broader research networks...',
  'comparison',
  (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
  (SELECT id FROM publications WHERE title = 'Blockchain-Based Healthcare Data Management with Zero-Knowledge Proofs' LIMIT 1),
  datetime('now')
),
(
  'Future of Academic Publishing: Blockchain and AI Integration',
  '["Dr. Mark Johnson", "Prof. Lisa Brown"]',
  'Quantum Machine Learning for Drug Discovery: A Comprehensive Survey',
  '["Dr. Sarah Chen", "Prof. Michael Zhang", "Dr. Lisa Wang"]',
  'The comprehensive survey by [Author] demonstrates the potential of quantum computing in specialized research domains, which aligns with our vision of AI-enhanced academic publishing...',
  'mention',
  (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
  (SELECT id FROM publications WHERE title = 'Quantum Machine Learning for Drug Discovery: A Comprehensive Survey' LIMIT 1),
  datetime('now')
),
(
  'Optimization Algorithms in Biotechnology Applications',
  '["Prof. Sarah Mitchell", "Dr. David Chen"]',
  'Gene Therapy Optimization Using Artificial Intelligence',
  '["Dr. Maria Garcia", "Prof. James Wilson"]',
  'The AI-based optimization approach presented by [Author] serves as a benchmark for our comparative analysis of optimization algorithms in biotechnology...',
  'comparison',
  (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
  (SELECT id FROM publications WHERE title = 'Gene Therapy Optimization Using Artificial Intelligence' LIMIT 1),
  datetime('now')
),
(
  'Environmental Data Analysis with Machine Learning',
  '["Dr. Emma Green", "Prof. Ocean Blue"]',
  'Climate Change Impact on Marine Biodiversity: A Deep Learning Analysis',
  '["Dr. Ocean Blue", "Prof. Green Earth"]',
  'Following the methodology established in [Author]''s marine biodiversity study, we apply similar deep learning techniques to terrestrial environmental data...',
  'reference',
  (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
  (SELECT id FROM publications WHERE title = 'Climate Change Impact on Marine Biodiversity: A Deep Learning Analysis' LIMIT 1),
  datetime('now')
),
(
  'Sustainable Technology Integration in Smart Grids',
  '["Dr. Tech Innovator", "Prof. Grid Master"]',
  'Sustainable Energy Storage Systems: A Machine Learning Approach',
  '["Prof. David Liu", "Dr. Emma Thompson"]',
  'The machine learning framework proposed by [Author] for energy storage optimization provides valuable insights for smart grid integration strategies...',
  'reference',
  (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
  (SELECT id FROM publications WHERE title = 'Sustainable Energy Storage Systems: A Machine Learning Approach' LIMIT 1),
  datetime('now')
);

-- Display results
SELECT 'Data insertion completed!' as message;
SELECT 'Publications inserted:' as result, COUNT(*) as count FROM publications WHERE author_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5')
UNION ALL
SELECT 'Reviews inserted:' as result, COUNT(*) as count FROM reviews WHERE reviewer_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5')
UNION ALL
SELECT 'Citations inserted:' as result, COUNT(*) as count FROM citations WHERE user_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'); 