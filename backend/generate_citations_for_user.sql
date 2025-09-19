-- Generate citations from new users to the main user's publications
-- Main user: did:ethr:0xE564382Be02b591E8384Ecc9e72c572d94DE20D5

-- First, let's see what publications the main user has
SELECT 'Main user publications:' as info;
SELECT id, title, status, citation_count FROM publications 
WHERE author_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5');

-- Generate citations from various new users to the main user's publications
INSERT OR IGNORE INTO citations (
  citing_paper_title, citing_authors, cited_paper_title, cited_authors,
  citation_context, citation_type, user_id, publication_id, created_at
) VALUES 

-- Citations to "Quantum Machine Learning for Drug Discovery" from main user
(
  'Advanced AI Applications in Pharmaceutical Research',
  '["Dr. Alice Johnson", "Prof. Michael Chen"]',
  'Quantum Machine Learning for Drug Discovery: A Comprehensive Survey',
  '["Dr. Sarah Chen", "Prof. Michael Zhang", "Dr. Lisa Wang"]',
  'The comprehensive survey by [Author] provides an excellent foundation for understanding quantum computing applications in drug discovery, which directly informs our AI-based pharmaceutical research methodology...',
  'reference',
  (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
  (SELECT id FROM publications WHERE title = 'Quantum Machine Learning for Drug Discovery: A Comprehensive Survey' AND author_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5')),
  datetime('now', '-15 days')
),

(
  'Deep Learning Architectures for Medical Image Analysis',
  '["Dr. Alice Johnson", "Prof. Medical Expert"]',
  'Quantum Machine Learning for Drug Discovery: A Comprehensive Survey',
  '["Dr. Sarah Chen", "Prof. Michael Zhang", "Dr. Lisa Wang"]',
  'Building upon the quantum machine learning frameworks described in [Author]''s comprehensive survey, we explore similar approaches for medical imaging applications...',
  'comparison',
  (SELECT id FROM users WHERE username = 'dr_alice_ai'),
  (SELECT id FROM publications WHERE title = 'Quantum Machine Learning for Drug Discovery: A Comprehensive Survey' AND author_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5')),
  datetime('now', '-12 days')
),

(
  'Blockchain-Enhanced Drug Discovery Platforms',
  '["Bob Smith", "Dr. Pharma Block"]',
  'Quantum Machine Learning for Drug Discovery: A Comprehensive Survey',
  '["Dr. Sarah Chen", "Prof. Michael Zhang", "Dr. Lisa Wang"]',
  'The quantum computing approaches outlined by [Author] offer promising directions for integrating with blockchain-based drug discovery platforms, particularly in secure data processing...',
  'reference',
  (SELECT id FROM users WHERE username = 'blockchain_bob'),
  (SELECT id FROM publications WHERE title = 'Quantum Machine Learning for Drug Discovery: A Comprehensive Survey' AND author_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5')),
  datetime('now', '-18 days')
),

-- Citations to "Sustainable Energy Storage Systems" from main user
(
  'Climate-Informed Energy Management Systems',
  '["Charlie Green", "Dr. Climate Energy"]',
  'Sustainable Energy Storage Systems: A Machine Learning Approach',
  '["Prof. David Liu", "Dr. Emma Thompson"]',
  'The machine learning optimization techniques presented by [Author] provide crucial insights for developing climate-adaptive energy storage solutions...',
  'reference',
  (SELECT id FROM users WHERE username = 'climate_charlie'),
  (SELECT id FROM publications WHERE title = 'Sustainable Energy Storage Systems: A Machine Learning Approach' AND author_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5')),
  datetime('now', '-10 days')
),

(
  'Materials Science Approaches to Energy Storage',
  '["Jack Materials", "Prof. Storage Expert"]',
  'Sustainable Energy Storage Systems: A Machine Learning Approach',
  '["Prof. David Liu", "Dr. Emma Thompson"]',
  'Following the methodology established in [Author]''s work on ML-based energy storage optimization, we investigate novel materials for enhanced battery performance...',
  'comparison',
  (SELECT id FROM users WHERE username = 'materials_jack'),
  (SELECT id FROM publications WHERE title = 'Sustainable Energy Storage Systems: A Machine Learning Approach' AND author_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5')),
  datetime('now', '-8 days')
),

-- Citations to "Blockchain-Based Healthcare Data Management" from main user
(
  'Medical Data Security in Digital Healthcare',
  '["Dr. Grace Medical", "Prof. Healthcare Security"]',
  'Blockchain-Based Healthcare Data Management with Zero-Knowledge Proofs',
  '["Dr. Alex Kim", "Prof. Jennifer Lee", "Dr. Robert Brown"]',
  'The zero-knowledge proof implementation described by [Author] represents a significant advancement in healthcare data privacy, which we extend to clinical trial management...',
  'reference',
  (SELECT id FROM users WHERE username = 'dr_grace_med'),
  (SELECT id FROM publications WHERE title = 'Blockchain-Based Healthcare Data Management with Zero-Knowledge Proofs' AND author_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5')),
  datetime('now', '-14 days')
),

(
  'Cybersecurity Frameworks for Healthcare Blockchain',
  '["Henry Security", "Dr. Cyber Health"]',
  'Blockchain-Based Healthcare Data Management with Zero-Knowledge Proofs',
  '["Dr. Alex Kim", "Prof. Jennifer Lee", "Dr. Robert Brown"]',
  'The security architecture proposed in [Author]''s healthcare blockchain framework provides essential foundations for our cybersecurity analysis of medical data systems...',
  'reference',
  (SELECT id FROM users WHERE username = 'security_henry'),
  (SELECT id FROM publications WHERE title = 'Blockchain-Based Healthcare Data Management with Zero-Knowledge Proofs' AND author_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5')),
  datetime('now', '-7 days')
),

-- Citations to "Gene Therapy Optimization" from main user
(
  'AI-Driven Biotechnology Applications',
  '["Diana Bio", "Prof. AI Biotech"]',
  'Gene Therapy Optimization Using Artificial Intelligence',
  '["Dr. Maria Garcia", "Prof. James Wilson"]',
  'The AI optimization strategies detailed by [Author] for gene therapy applications serve as a benchmark for our broader biotechnology AI research initiatives...',
  'comparison',
  (SELECT id FROM users WHERE username = 'biotech_diana'),
  (SELECT id FROM publications WHERE title = 'Gene Therapy Optimization Using Artificial Intelligence' AND author_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5')),
  datetime('now', '-11 days')
),

(
  'Data Science Applications in Medical Research',
  '["Frank Data", "Dr. Medical Analytics"]',
  'Gene Therapy Optimization Using Artificial Intelligence',
  '["Dr. Maria Garcia", "Prof. James Wilson"]',
  'Building upon the data analysis methodologies presented in [Author]''s gene therapy optimization study, we explore broader applications of data science in medical research...',
  'reference',
  (SELECT id FROM users WHERE username = 'data_scientist_frank'),
  (SELECT id FROM publications WHERE title = 'Gene Therapy Optimization Using Artificial Intelligence' AND author_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5')),
  datetime('now', '-6 days')
),

-- Citations to "Climate Change Impact on Marine Biodiversity" from main user
(
  'Marine Ecosystem Modeling and Conservation',
  '["Iris Marine", "Dr. Ocean Conservation"]',
  'Climate Change Impact on Marine Biodiversity: A Deep Learning Analysis',
  '["Dr. Ocean Blue", "Prof. Green Earth"]',
  'The deep learning methodologies described by [Author] for marine biodiversity analysis provide crucial insights for our ecosystem conservation modeling efforts...',
  'reference',
  (SELECT id FROM users WHERE username = 'marine_iris'),
  (SELECT id FROM publications WHERE title = 'Climate Change Impact on Marine Biodiversity: A Deep Learning Analysis' AND author_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5')),
  datetime('now', '-9 days')
),

(
  'Physics-Based Environmental Modeling',
  '["Prof. Edward Einstein", "Dr. Environmental Physics"]',
  'Climate Change Impact on Marine Biodiversity: A Deep Learning Analysis',
  '["Dr. Ocean Blue", "Prof. Green Earth"]',
  'The environmental modeling approaches presented in [Author]''s marine biodiversity study complement our physics-based climate modeling research...',
  'comparison',
  (SELECT id FROM users WHERE username = 'prof_einstein'),
  (SELECT id FROM publications WHERE title = 'Climate Change Impact on Marine Biodiversity: A Deep Learning Analysis' AND author_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5')),
  datetime('now', '-13 days')
),

-- Citations to "Decentralized Science Platforms" from main user
(
  'Blockchain Infrastructure for Scientific Computing',
  '["Bob Smith", "Prof. Scientific Blockchain"]',
  'Decentralized Science Platforms: Architecture and Implementation',
  '["Your Name", "Dr. Collaborator"]',
  'The architectural principles outlined in [Author]''s decentralized science platform design directly inform our blockchain infrastructure development for scientific computing applications...',
  'reference',
  (SELECT id FROM users WHERE username = 'blockchain_bob'),
  (SELECT id FROM publications WHERE title = 'Decentralized Science Platforms: Architecture and Implementation' AND author_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5')),
  datetime('now', '-16 days')
),

(
  'Security Considerations in Decentralized Research Networks',
  '["Henry Security", "Dr. Research Security"]',
  'Decentralized Science Platforms: Architecture and Implementation',
  '["Your Name", "Dr. Collaborator"]',
  'The security framework described by [Author] for decentralized science platforms provides essential foundations for our analysis of research network vulnerabilities...',
  'reference',
  (SELECT id FROM users WHERE username = 'security_henry'),
  (SELECT id FROM publications WHERE title = 'Decentralized Science Platforms: Architecture and Implementation' AND author_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5')),
  datetime('now', '-5 days')
),

(
  'AI Applications in Decentralized Research',
  '["Dr. Alice Johnson", "Prof. Decentralized AI"]',
  'Decentralized Science Platforms: Architecture and Implementation',
  '["Your Name", "Dr. Collaborator"]',
  'The platform architecture presented by [Author] offers promising opportunities for integrating AI applications within decentralized research environments...',
  'comparison',
  (SELECT id FROM users WHERE username = 'dr_alice_ai'),
  (SELECT id FROM publications WHERE title = 'Decentralized Science Platforms: Architecture and Implementation' AND author_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5')),
  datetime('now', '-4 days')
);

-- Update citation counts in publications table
UPDATE publications 
SET citation_count = (
  SELECT COUNT(*) 
  FROM citations 
  WHERE publication_id = publications.id
)
WHERE author_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5');

-- Show results
SELECT 'Citations generation completed!' as message;

SELECT 'Citations added per publication:' as info;
SELECT 
  p.title,
  p.citation_count,
  COUNT(c.id) as actual_citations
FROM publications p
LEFT JOIN citations c ON p.id = c.publication_id
WHERE p.author_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5')
GROUP BY p.id, p.title, p.citation_count
ORDER BY p.citation_count DESC;

SELECT 'Total citations added:' as summary, COUNT(*) as count 
FROM citations 
WHERE publication_id IN (
  SELECT id FROM publications 
  WHERE author_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5')
);

-- Show some sample citations
SELECT 'Sample citations:' as sample_info;
SELECT 
  c.citing_paper_title,
  c.cited_paper_title,
  c.citation_type,
  u.username as citing_user,
  c.created_at
FROM citations c
JOIN users u ON c.user_id = u.id
WHERE c.publication_id IN (
  SELECT id FROM publications 
  WHERE author_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5')
)
ORDER BY c.created_at DESC
LIMIT 5; 