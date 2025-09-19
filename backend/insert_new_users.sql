-- Insert new users with proper wallet address formats
-- Run with: sqlite3 desci.db < insert_new_users.sql

-- Insert multiple test users with different profiles
INSERT OR IGNORE INTO users (wallet_address, did, username, email, organization, research_interests, personal_website, github_username) VALUES
-- User 1: AI Researcher
(
  '0x742d35Cc6634C0532925a3b8D4f25177F9E5C4B8',
  'did:ethr:0x742d35Cc6634C0532925a3b8D4f25177F9E5C4B8',
  'dr_alice_ai',
  'alice.johnson@stanford.edu',
  'Stanford University',
  '["Artificial Intelligence", "Machine Learning", "Neural Networks", "Computer Vision"]',
  'https://alice-ai-research.com',
  'alice-johnson-ai'
),

-- User 2: Blockchain Developer
(
  '0x8ba1f109551bD432803012645Hac136c5b3F5F99',
  'did:ethr:0x8ba1f109551bD432803012645Hac136c5b3F5F99',
  'blockchain_bob',
  'bob.smith@mit.edu',
  'MIT Blockchain Lab',
  '["Blockchain", "Smart Contracts", "DeFi", "Cryptocurrency", "Web3"]',
  'https://bobsmith-blockchain.io',
  'bob-smith-blockchain'
),

-- User 3: Climate Scientist
(
  '0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC',
  'did:ethr:0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC',
  'climate_charlie',
  'charlie.green@caltech.edu',
  'Caltech Climate Research',
  '["Climate Science", "Environmental Modeling", "Data Analysis", "Sustainability"]',
  'https://charlie-climate.org',
  'charlie-green-climate'
),

-- User 4: Biotech Researcher
(
  '0x90F79bf6EB2c4f870365E785982E1f101E93b906',
  'did:ethr:0x90F79bf6EB2c4f870365E785982E1f101E93b906',
  'biotech_diana',
  'diana.bio@harvard.edu',
  'Harvard Medical School',
  '["Biotechnology", "Gene Therapy", "Molecular Biology", "Bioinformatics"]',
  'https://diana-biotech.harvard.edu',
  'diana-bio-research'
),

-- User 5: Physics Professor
(
  '0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65',
  'did:ethr:0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65',
  'prof_einstein',
  'edward.physics@princeton.edu',
  'Princeton University',
  '["Quantum Physics", "Theoretical Physics", "Particle Physics", "Cosmology"]',
  'https://edward-physics.princeton.edu',
  'prof-edward-physics'
),

-- User 6: Data Scientist
(
  '0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc',
  'did:ethr:0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc',
  'data_scientist_frank',
  'frank.data@berkeley.edu',
  'UC Berkeley Data Science',
  '["Data Science", "Statistics", "Big Data", "Analytics", "Visualization"]',
  'https://frank-datascience.berkeley.edu',
  'frank-data-berkeley'
),

-- User 7: Medical Researcher
(
  '0x976EA74026E726554dB657fA54763abd0C3a0aa9',
  'did:ethr:0x976EA74026E726554dB657fA54763abd0C3a0aa9',
  'dr_grace_med',
  'grace.medical@mayo.edu',
  'Mayo Clinic Research',
  '["Medical Research", "Clinical Trials", "Pharmacology", "Healthcare Innovation"]',
  'https://grace-medical.mayo.edu',
  'dr-grace-medical'
),

-- User 8: Computer Security Expert
(
  '0x14dC79964da2C08b23698B3D3cc7Ca32193d9955',
  'did:ethr:0x14dC79964da2C08b23698B3D3cc7Ca32193d9955',
  'security_henry',
  'henry.security@cmu.edu',
  'Carnegie Mellon Cybersecurity',
  '["Cybersecurity", "Cryptography", "Network Security", "Privacy Protection"]',
  'https://henry-security.cmu.edu',
  'henry-cybersec'
),

-- User 9: Marine Biologist
(
  '0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f',
  'did:ethr:0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f',
  'marine_iris',
  'iris.ocean@scripps.edu',
  'Scripps Institution of Oceanography',
  '["Marine Biology", "Ocean Science", "Marine Ecology", "Conservation Biology"]',
  'https://iris-marine.scripps.edu',
  'iris-marine-bio'
),

-- User 10: Materials Scientist
(
  '0xa0Ee7A142d267C1f36714E4a8F75612F20a79720',
  'did:ethr:0xa0Ee7A142d267C1f36714E4a8F75612F20a79720',
  'materials_jack',
  'jack.materials@northwestern.edu',
  'Northwestern Materials Science',
  '["Materials Science", "Nanotechnology", "Advanced Materials", "Engineering"]',
  'https://jack-materials.northwestern.edu',
  'jack-materials-nw'
);

-- Add some publications for these new users
INSERT OR IGNORE INTO publications (
  title, authors, abstract, keywords, category, status, author_id,
  created_at, published_at, doi, citation_count, download_count, updated_at
) VALUES 
-- Publication from Alice (AI Researcher)
(
  'Deep Learning Architectures for Medical Image Analysis',
  '["Dr. Alice Johnson", "Prof. Michael Chen"]',
  'This paper presents novel deep learning architectures specifically designed for medical image analysis, achieving state-of-the-art performance in diagnostic accuracy.',
  '["Deep Learning", "Medical Imaging", "Computer Vision", "Healthcare AI"]',
  'Computer Science',
  'Published',
  (SELECT id FROM users WHERE username = 'dr_alice_ai'),
  '2024-01-10T00:00:00.000Z',
  '2024-02-15T00:00:00.000Z',
  '10.1000/ai-medical-2024',
  23,
  456,
  datetime('now')
),

-- Publication from Bob (Blockchain Developer)
(
  'Scalable Smart Contract Architecture for DeFi Applications',
  '["Bob Smith", "Dr. Sarah Wilson"]',
  'We propose a novel smart contract architecture that significantly improves scalability and reduces gas costs for decentralized finance applications.',
  '["Blockchain", "Smart Contracts", "DeFi", "Scalability", "Ethereum"]',
  'Computer Science',
  'Under Review',
  (SELECT id FROM users WHERE username = 'blockchain_bob'),
  '2024-02-01T00:00:00.000Z',
  NULL,
  NULL,
  0,
  0,
  datetime('now')
),

-- Publication from Charlie (Climate Scientist)
(
  'Machine Learning Models for Climate Change Prediction',
  '["Charlie Green", "Dr. Emma Davis", "Prof. Tom Wilson"]',
  'This study develops advanced machine learning models for long-term climate change prediction, incorporating multiple environmental factors and feedback loops.',
  '["Climate Science", "Machine Learning", "Environmental Modeling", "Prediction"]',
  'Environmental Science',
  'Published',
  (SELECT id FROM users WHERE username = 'climate_charlie'),
  '2023-12-15T00:00:00.000Z',
  '2024-01-20T00:00:00.000Z',
  '10.1000/climate-ml-2024',
  18,
  234,
  datetime('now')
),

-- Publication from Diana (Biotech Researcher)
(
  'CRISPR-Cas9 Optimization for Therapeutic Gene Editing',
  '["Diana Bio", "Prof. Robert Johnson", "Dr. Lisa Chen"]',
  'We present optimized CRISPR-Cas9 protocols for therapeutic gene editing applications, demonstrating improved efficiency and reduced off-target effects.',
  '["CRISPR", "Gene Editing", "Biotechnology", "Therapeutics", "Molecular Biology"]',
  'Biotechnology',
  'Published',
  (SELECT id FROM users WHERE username = 'biotech_diana'),
  '2024-01-05T00:00:00.000Z',
  '2024-02-10T00:00:00.000Z',
  '10.1000/crispr-2024',
  31,
  567,
  datetime('now')
),

-- Publication from Edward (Physics Professor)
(
  'Quantum Entanglement in Many-Body Systems',
  '["Prof. Edward Einstein", "Dr. Marie Curie", "Prof. Niels Bohr"]',
  'This theoretical work explores quantum entanglement phenomena in complex many-body systems, providing new insights into quantum phase transitions.',
  '["Quantum Physics", "Entanglement", "Many-Body Systems", "Theoretical Physics"]',
  'Physics',
  'Published',
  (SELECT id FROM users WHERE username = 'prof_einstein'),
  '2023-11-20T00:00:00.000Z',
  '2024-01-15T00:00:00.000Z',
  '10.1000/quantum-entanglement-2024',
  42,
  789,
  datetime('now')
);

-- Add some reviews assigned to these users
INSERT OR IGNORE INTO reviews (
  paper_title, authors, abstract, keywords, category, journal,
  status, urgency, reviewer_id, deadline, estimated_hours, review_id,
  progress, created_at, updated_at
) VALUES 
-- Review assigned to Alice
(
  'Advanced Neural Network Architectures for Natural Language Processing',
  '["Dr. John Smith", "Prof. Jane Doe"]',
  'This paper proposes new neural network architectures for improved natural language understanding and generation.',
  '["Neural Networks", "NLP", "Deep Learning", "Language Models"]',
  'Computer Science',
  'Journal of AI Research',
  'Pending',
  'High',
  (SELECT id FROM users WHERE username = 'dr_alice_ai'),
  datetime('now', '+10 days'),
  8,
  'REV-AI-2024-001',
  0,
  datetime('now'),
  datetime('now')
),

-- Review assigned to Bob
(
  'Cross-Chain Interoperability Protocols for Blockchain Networks',
  '["Prof. Alice Cooper", "Dr. Bob Johnson"]',
  'This study presents novel protocols for enabling seamless interoperability between different blockchain networks.',
  '["Blockchain", "Interoperability", "Cross-Chain", "Protocols"]',
  'Computer Science',
  'Blockchain Technology Journal',
  'In Progress',
  'Medium',
  (SELECT id FROM users WHERE username = 'blockchain_bob'),
  datetime('now', '+15 days'),
  12,
  'REV-BLOCKCHAIN-2024-001',
  40,
  datetime('now'),
  datetime('now')
),

-- Review assigned to Charlie
(
  'Impact of Ocean Acidification on Marine Ecosystems',
  '["Dr. Ocean Blue", "Prof. Sea Green"]',
  'This research examines the long-term effects of ocean acidification on marine biodiversity and ecosystem stability.',
  '["Ocean Acidification", "Marine Ecosystems", "Climate Change", "Biodiversity"]',
  'Environmental Science',
  'Marine Environmental Research',
  'Completed',
  'Low',
  (SELECT id FROM users WHERE username = 'climate_charlie'),
  datetime('now', '-5 days'),
  10,
  'REV-CLIMATE-2024-001',
  100,
  datetime('now'),
  datetime('now')
);

-- Add some citations referencing the new publications
INSERT OR IGNORE INTO citations (
  citing_paper_title, citing_authors, cited_paper_title, cited_authors,
  citation_context, citation_type, user_id, publication_id, created_at
) VALUES 
(
  'Applications of AI in Modern Healthcare Systems',
  '["Dr. Health Expert", "Prof. Medical AI"]',
  'Deep Learning Architectures for Medical Image Analysis',
  '["Dr. Alice Johnson", "Prof. Michael Chen"]',
  'The deep learning architecture proposed by [Author] has shown remarkable success in medical image analysis, particularly in diagnostic applications...',
  'reference',
  (SELECT id FROM users WHERE username = 'dr_alice_ai'),
  (SELECT id FROM publications WHERE title = 'Deep Learning Architectures for Medical Image Analysis'),
  datetime('now')
),

(
  'Future of Decentralized Finance: Technical Challenges and Solutions',
  '["Prof. DeFi Expert", "Dr. Crypto Researcher"]',
  'Scalable Smart Contract Architecture for DeFi Applications',
  '["Bob Smith", "Dr. Sarah Wilson"]',
  'Building upon the scalability solutions presented in [Author]''s work, we explore additional optimization strategies for DeFi protocols...',
  'comparison',
  (SELECT id FROM users WHERE username = 'blockchain_bob'),
  (SELECT id FROM publications WHERE title = 'Scalable Smart Contract Architecture for DeFi Applications'),
  datetime('now')
),

(
  'Advances in Environmental Data Science',
  '["Dr. Data Environment", "Prof. Green Analytics"]',
  'Machine Learning Models for Climate Change Prediction',
  '["Charlie Green", "Dr. Emma Davis", "Prof. Tom Wilson"]',
  'The predictive modeling approach described by [Author] provides a solid foundation for environmental data analysis applications...',
  'reference',
  (SELECT id FROM users WHERE username = 'climate_charlie'),
  (SELECT id FROM publications WHERE title = 'Machine Learning Models for Climate Change Prediction'),
  datetime('now')
);

-- Display results
SELECT 'New users insertion completed!' as message;

SELECT 'Users inserted:' as result, COUNT(*) as count FROM users WHERE username IN (
  'dr_alice_ai', 'blockchain_bob', 'climate_charlie', 'biotech_diana', 'prof_einstein',
  'data_scientist_frank', 'dr_grace_med', 'security_henry', 'marine_iris', 'materials_jack'
)
UNION ALL
SELECT 'Publications inserted:' as result, COUNT(*) as count FROM publications WHERE author_id IN (
  SELECT id FROM users WHERE username IN (
    'dr_alice_ai', 'blockchain_bob', 'climate_charlie', 'biotech_diana', 'prof_einstein'
  )
)
UNION ALL
SELECT 'Reviews inserted:' as result, COUNT(*) as count FROM reviews WHERE reviewer_id IN (
  SELECT id FROM users WHERE username IN (
    'dr_alice_ai', 'blockchain_bob', 'climate_charlie'
  )
)
UNION ALL
SELECT 'Citations inserted:' as result, COUNT(*) as count FROM citations WHERE user_id IN (
  SELECT id FROM users WHERE username IN (
    'dr_alice_ai', 'blockchain_bob', 'climate_charlie'
  )
);

-- Show some sample data
SELECT 'Sample Users:' as info;
SELECT username, wallet_address, organization, research_interests FROM users 
WHERE username IN ('dr_alice_ai', 'blockchain_bob', 'climate_charlie') 
LIMIT 3; 