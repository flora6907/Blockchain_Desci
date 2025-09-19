-- Insert Publications for User: 0xE564382Be02b591E8384Ecc9e72c572d94DE20D5
-- This script creates publications with different statuses: Draft, Under Review, Published, Preprint, Revision Required

-- Get the user ID first
-- User should already exist in the database

-- Insert publications with different statuses
INSERT INTO publications (
    title, authors, abstract, keywords, category, status, author_id,
    created_at, published_at, submitted_at, last_modified, doi, 
    citation_count, download_count, views, shares,
    review_deadline, peer_review_id, review_comments, preprint_server,
    is_imported, original_url, publisher, volume, impact_factor, import_notes,
    pdf_path, pdf_file_name, pdf_file_size, pdf_mime_type
) VALUES

-- 1. DRAFT STATUS - Work in Progress
(
    'Advanced Neural Network Architectures for Climate Modeling',
    '["Dr. John Smith", "Prof. Maria Garcia", "Dr. Alex Chen"]',
    'This paper explores novel neural network architectures specifically designed for climate modeling applications. We propose a hybrid CNN-LSTM approach that can capture both spatial and temporal patterns in climate data with unprecedented accuracy.',
    '["neural networks", "climate modeling", "deep learning", "CNN-LSTM", "weather prediction"]',
    'Computer Science',
    'Draft',
    (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
    datetime('now', '-15 days'),
    NULL,
    NULL,
    datetime('now', '-2 days'),
    NULL,
    0, 0, 12, 2,
    NULL, NULL, NULL, NULL,
    FALSE, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL
),

-- 2. UNDER REVIEW STATUS - Submitted to Journal
(
    'Quantum-Enhanced Machine Learning for Drug Discovery',
    '["Dr. John Smith", "Prof. Sarah Johnson", "Dr. Michael Brown"]',
    'We present a novel approach combining quantum computing principles with machine learning algorithms for accelerated drug discovery. Our method demonstrates significant improvements in molecular property prediction and drug-target interaction modeling.',
    '["quantum computing", "machine learning", "drug discovery", "molecular modeling", "quantum ML"]',
    'Computer Science',
    'Under Review',
    (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
    datetime('now', '-45 days'),
    NULL,
    datetime('now', '-30 days'),
    datetime('now', '-5 days'),
    NULL,
    0, 0, 89, 15,
    datetime('now', '+30 days'),
    'JMLR-2024-0892',
    'The reviewers have provided initial feedback. Minor revisions may be needed.',
    NULL,
    FALSE, NULL, 'Journal of Machine Learning Research', NULL, 4.85, NULL,
    'uploads/papers/quantum_ml_drug_discovery.pdf', 'quantum_ml_drug_discovery.pdf', 2458721, 'application/pdf'
),

-- 3. PUBLISHED STATUS - Successfully Published
(
    'Blockchain-Based Secure Data Sharing in Healthcare Systems',
    '["Dr. John Smith", "Prof. Linda Wang", "Dr. Robert Davis"]',
    'This study presents a comprehensive blockchain-based framework for secure and privacy-preserving data sharing in healthcare systems. We demonstrate how smart contracts can automate consent management while maintaining HIPAA compliance.',
    '["blockchain", "healthcare", "data privacy", "smart contracts", "HIPAA", "medical data"]',
    'Computer Science',
    'Published',
    (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
    datetime('now', '-120 days'),
    datetime('now', '-60 days'),
    datetime('now', '-90 days'),
    datetime('now', '-60 days'),
    '10.1109/ACCESS.2024.3389456',
    23, 156, 445, 67,
    NULL, NULL, NULL, NULL,
    FALSE, 'https://ieeexplore.ieee.org/document/10389456', 'IEEE Access', 'Vol. 12, pp. 45678-45692', 3.9, NULL,
    'uploads/papers/blockchain_healthcare_published.pdf', 'blockchain_healthcare_published.pdf', 3245678, 'application/pdf'
),

-- 4. PREPRINT STATUS - Available on Preprint Server
(
    'Federated Learning for Privacy-Preserving IoT Analytics',
    '["Dr. John Smith", "Prof. Emma Thompson", "Dr. James Wilson"]',
    'We propose a federated learning framework specifically designed for IoT environments that ensures privacy preservation while enabling collaborative machine learning across distributed IoT devices. Our approach reduces communication overhead by 60% compared to existing methods.',
    '["federated learning", "IoT", "privacy preservation", "edge computing", "distributed ML"]',
    'Computer Science',
    'Preprint',
    (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
    datetime('now', '-25 days'),
    datetime('now', '-10 days'),
    datetime('now', '-20 days'),
    datetime('now', '-8 days'),
    NULL,
    8, 234, 567, 89,
    NULL, NULL, NULL, 'arXiv',
    FALSE, 'https://arxiv.org/abs/2024.12345', NULL, 'arXiv:2024.12345', NULL, NULL,
    'uploads/papers/federated_iot_preprint.pdf', 'federated_iot_preprint.pdf', 1987654, 'application/pdf'
),

-- 5. REVISION REQUIRED STATUS - Needs Revisions
(
    'Sustainable AI: Energy-Efficient Deep Learning Models',
    '["Dr. John Smith", "Prof. David Lee", "Dr. Sophie Martin"]',
    'This paper addresses the growing concern of energy consumption in deep learning by proposing novel architectures and training techniques that reduce energy usage by up to 40% while maintaining model performance. We evaluate our approaches on multiple benchmarks.',
    '["sustainable AI", "energy efficiency", "green computing", "deep learning", "model optimization"]',
    'Computer Science',
    'Revision Required',
    (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
    datetime('now', '-80 days'),
    NULL,
    datetime('now', '-60 days'),
    datetime('now', '-10 days'),
    NULL,
    0, 0, 78, 12,
    datetime('now', '+45 days'),
    'ICML-2024-1456',
    'The paper shows promising results, but the experimental section needs strengthening. Please provide more detailed comparisons with state-of-the-art methods and include statistical significance tests. The energy measurement methodology also requires clarification.',
    NULL,
    FALSE, NULL, 'International Conference on Machine Learning', NULL, NULL, NULL,
    'uploads/papers/sustainable_ai_revision.pdf', 'sustainable_ai_revision.pdf', 2756432, 'application/pdf'
),

-- 6. PUBLISHED STATUS - Another Published Paper (Different Category)
(
    'CRISPR-Cas9 Gene Editing: Safety Protocols and Ethical Considerations',
    '["Dr. John Smith", "Prof. Rachel Green", "Dr. Thomas Anderson"]',
    'We present comprehensive safety protocols for CRISPR-Cas9 gene editing applications in human therapeutics. This review covers current best practices, risk assessment methodologies, and ethical frameworks for responsible gene editing research.',
    '["CRISPR-Cas9", "gene editing", "bioethics", "safety protocols", "therapeutic applications"]',
    'Biology',
    'Published',
    (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
    datetime('now', '-200 days'),
    datetime('now', '-90 days'),
    datetime('now', '-150 days'),
    datetime('now', '-90 days'),
    '10.1038/s41587-024-2156-8',
    67, 423, 1234, 156,
    NULL, NULL, NULL, NULL,
    FALSE, 'https://www.nature.com/articles/s41587-024-2156-8', 'Nature Biotechnology', 'Vol. 42, Issue 8, pp. 1123-1135', 46.9, NULL,
    'uploads/papers/crispr_safety_published.pdf', 'crispr_safety_published.pdf', 4567890, 'application/pdf'
),

-- 7. DRAFT STATUS - Early Stage Research
(
    'Explainable AI for Medical Diagnosis: A Comparative Study',
    '["Dr. John Smith", "Prof. Angela White", "Dr. Kevin Martinez"]',
    'This ongoing research compares various explainable AI techniques in medical diagnosis applications. We are developing new interpretability methods that can provide clinicians with clear, actionable insights from AI-driven diagnostic tools.',
    '["explainable AI", "medical diagnosis", "interpretability", "clinical decision support", "XAI"]',
    'Medicine',
    'Draft',
    (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
    datetime('now', '-8 days'),
    NULL,
    NULL,
    datetime('now', '-1 days'),
    NULL,
    0, 0, 5, 0,
    NULL, NULL, NULL, NULL,
    FALSE, NULL, NULL, NULL, NULL, 'Early draft - experimental results still being collected',
    NULL, NULL, NULL, NULL
),

-- 8. UNDER REVIEW STATUS - Different Journal
(
    'Renewable Energy Optimization Using Machine Learning',
    '["Dr. John Smith", "Prof. Carlos Rodriguez", "Dr. Lisa Chen"]',
    'We propose a machine learning-based optimization framework for renewable energy systems that can predict energy output and optimize distribution in real-time. Our system demonstrates 25% improvement in energy efficiency across various renewable sources.',
    '["renewable energy", "machine learning", "optimization", "smart grid", "energy efficiency"]',
    'Engineering',
    'Under Review',
    (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5'),
    datetime('now', '-70 days'),
    NULL,
    datetime('now', '-50 days'),
    datetime('now', '-15 days'),
    NULL,
    0, 0, 134, 28,
    datetime('now', '+20 days'),
    'IEEE-TSG-2024-0567',
    'Paper is currently under peer review. Initial reviewer comments are positive.',
    NULL,
    FALSE, NULL, 'IEEE Transactions on Smart Grid', NULL, 10.1, NULL,
    'uploads/papers/renewable_energy_ml.pdf', 'renewable_energy_ml.pdf', 3456789, 'application/pdf'
);

-- Verify insertions
SELECT 'Publications inserted successfully!' as message;
SELECT COUNT(*) as total_publications FROM publications 
WHERE author_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5');

-- Show status distribution
SELECT status, COUNT(*) as count FROM publications 
WHERE author_id = (SELECT id FROM users WHERE wallet_address = '0xE564382Be02b591E8384Ecc9e72c572d94DE20D5')
GROUP BY status
ORDER BY count DESC; 