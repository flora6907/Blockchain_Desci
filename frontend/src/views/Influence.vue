<template>
  <div class="influence-page">
    <!-- Header Section -->
    <div class="page-header">
      <h1>🎯 Influence Ranking</h1>
      <p>Track and analyze your scientific influence across the DeSci ecosystem</p>
    </div>

    <!-- User Basic Info Card -->
    <n-card class="user-info-card" title="🔍 User Profile">
      <div class="user-info-content">
        <div class="user-address">
          <n-tag type="info" size="large">
            <template #icon>
              <n-icon :component="WalletOutline" />
            </template>
            {{ userAddress || 'Not Connected' }}
          </n-tag>
        </div>
        
        <div class="user-status">
          <div class="status-item">
            <span class="label">Status:</span>
            <n-tag :type="getStatusType(userStatus)" round>
              <template #icon>
                <n-icon :component="getStatusIcon(userStatus)" />
              </template>
              {{ userStatus }}
            </n-tag>
          </div>
          
          <div class="status-item">
            <span class="label">Network:</span>
            <n-tag type="warning" round>
              <template #icon>
                <n-icon :component="GlobeOutline" />
              </template>
              {{ networkName }}
            </n-tag>
          </div>
          
          <div class="status-item">
            <span class="label">Last Update:</span>
            <span class="timestamp">{{ formatDate(lastUpdateTime) }}</span>
          </div>
        </div>

        <div class="update-section">
          <n-button 
            type="primary" 
            size="large"
            :loading="isUpdating"
            @click="updateInfluence"
          >
            <template #icon>
              <n-icon :component="RefreshOutline" />
            </template>
            Update My Influence
          </n-button>
        </div>
      </div>
    </n-card>

    <!-- Total Influence Overview -->
    <n-card class="total-influence-card" title="📊 Total Influence Score">
      <div class="influence-overview">
        <div class="score-display">
          <div class="main-score">
            <span class="score-number">{{ totalInfluence.toLocaleString() }}</span>
            <span class="score-label">Total Influence</span>
          </div>
          
          <div class="rank-info" v-if="userRank">
            <n-tag type="success" size="large">
              <template #icon>
                <n-icon :component="TrophyOutline" />
              </template>
              Rank #{{ userRank }}
            </n-tag>
          </div>
        </div>

        <div class="weights-display">
          <h3>Current Weights (Total: 10,000)</h3>
          <div class="weights-grid">
            <div v-for="(weight, key) in weights" :key="key" class="weight-item">
              <div class="weight-label">{{ getWeightLabel(key) }}</div>
              <div class="weight-value">{{ weight.toLocaleString() }}</div>
              <div class="weight-percentage">{{ (weight / 100).toFixed(1) }}%</div>
            </div>
          </div>
        </div>

        <!-- Formula Explanation -->
        <n-collapse class="formula-section">
          <n-collapse-item title="💡 Calculation Formula" name="formula">
            <div class="formula-content">
              <div class="formula-equation">
                <code>
                  Total = (pub × {{ weights.publication }} + rev × {{ weights.review }} + 
                  data × {{ weights.data }} + collab × {{ weights.collaboration }} + 
                  gov × {{ weights.governance }}) ÷ 10,000
                </code>
              </div>
              
              <div class="current-calculation">
                <h4>Your Current Calculation:</h4>
                <div class="calc-breakdown">
                  <div v-for="(score, key) in scores" :key="key" class="calc-item">
                    <span class="calc-label">{{ getWeightLabel(key) }}:</span>
                    <span class="calc-value">{{ score }} × {{ weights[key] }} = {{ (score * weights[key]).toLocaleString() }}</span>
                  </div>
                  <div class="calc-total">
                    <strong>Total: {{ totalCalculated.toLocaleString() }} ÷ 10,000 = {{ totalInfluence.toLocaleString() }}</strong>
                  </div>
                </div>
              </div>
            </div>
          </n-collapse-item>
        </n-collapse>
      </div>
    </n-card>

    <!-- Detailed Breakdown -->
    <div class="breakdown-sections">
      <!-- Publication Score -->
      <n-card class="section-card" title="📚 Publication Impact">
        <div class="section-content">
          <div class="section-header">
            <div class="score-summary">
              <span class="section-score">{{ scores.publication }}</span>
              <span class="section-label">Publication Score</span>
            </div>
          </div>
          
          <div class="publications-list" v-if="userPublications.length > 0">
            <div v-for="pub in userPublications" :key="pub.tokenId" class="publication-item">
              <div class="pub-header">
                <h4>{{ pub.title }}</h4>
                <n-tag type="info" size="small">Token ID: {{ pub.tokenId }}</n-tag>
              </div>
              
              <div class="pub-calculation">
                <div class="calc-detail">
                  <span>Type Weight × Impact Multiplier:</span>
                  <span>{{ pub.typeWeight }} × {{ pub.impactMultiplier }} = {{ pub.baseScore }}</span>
                </div>
                <div class="calc-detail">
                  <span>Citation Bonus:</span>
                  <span>+{{ pub.citationBonus }}</span>
                </div>
                <div class="calc-detail">
                  <span>Download Bonus:</span>
                  <span>+{{ pub.downloadBonus }}</span>
                </div>
                <div class="calc-detail">
                  <span>Time Decay:</span>
                  <span>× {{ pub.timeDecay }}</span>
                </div>
                <div class="calc-total">
                  <strong>Final Score: {{ pub.finalScore }}</strong>
                </div>
              </div>
            </div>
          </div>
          
          <n-empty v-else description="No publications found" />
        </div>
      </n-card>

      <!-- Review Score -->
      <n-card class="section-card" title="🔍 Review Contribution">
        <div class="section-content">
          <div class="section-header">
            <div class="score-summary">
              <span class="section-score">{{ scores.review }}</span>
              <span class="section-label">Review Score</span>
            </div>
          </div>
          
          <div class="review-stats">
            <div class="stat-item">
              <span class="stat-label">Total Reviews:</span>
              <span class="stat-value">{{ reviewStats.totalReviews }}</span>
            </div>
            <div class="stat-item">
              <span class="stat-label">Average Quality:</span>
              <span class="stat-value">{{ reviewStats.averageQuality.toFixed(2) }}</span>
            </div>
            <div class="stat-item">
              <span class="stat-label">Quality Bonus:</span>
              <span class="stat-value">+{{ reviewStats.qualityBonus }}</span>
            </div>
          </div>
          
          <div class="review-explanation">
            <p>
              <strong>Calculation:</strong> Each review score × target research influence × 0.1, 
              plus frequency bonus based on review count.
            </p>
          </div>
        </div>
      </n-card>

      <!-- Data Contribution Score -->
      <n-card class="section-card" title="💾 Data Contribution">
        <div class="section-content">
          <div class="section-header">
            <div class="score-summary">
              <span class="section-score">{{ scores.data }}</span>
              <span class="section-label">Data Score</span>
            </div>
          </div>
          
          <div class="datasets-list" v-if="userDatasets.length > 0">
            <div v-for="dataset in userDatasets" :key="dataset.id" class="dataset-item">
              <div class="dataset-header">
                <h4>{{ dataset.name }}</h4>
                <n-tag :type="getQualityType(dataset.quality)" size="small">
                  {{ dataset.quality }}
                </n-tag>
              </div>
              
              <div class="dataset-calculation">
                <div class="calc-detail">
                  <span>Quality Score:</span>
                  <span>{{ dataset.qualityScore }} × 20 = {{ dataset.qualityScore * 20 }}</span>
                </div>
                <div class="calc-detail">
                  <span>Downloads:</span>
                  <span>{{ dataset.downloads }} × 5 = {{ dataset.downloads * 5 }}</span>
                </div>
                <div class="calc-detail">
                  <span>Citations:</span>
                  <span>{{ dataset.citations }} × 10 = {{ dataset.citations * 10 }}</span>
                </div>
                <div class="calc-detail">
                  <span>Size Bonus:</span>
                  <span>log2({{ dataset.sizeKB }}KB) × 2 = {{ dataset.sizeBonus }}</span>
                </div>
                <div class="calc-total">
                  <strong>Dataset Score: {{ dataset.totalScore }}</strong>
                </div>
              </div>
            </div>
          </div>
          
          <div class="data-explanation">
            <p>
              <strong>Formula:</strong> Quality×20 + Downloads×5 + Citations×10 + log2(Size/KB)×2
            </p>
          </div>
        </div>
      </n-card>

      <!-- Collaboration Score -->
      <n-card class="section-card" title="🤝 Collaboration">
        <div class="section-content">
          <div class="section-header">
            <div class="score-summary">
              <span class="section-score">{{ scores.collaboration }}</span>
              <span class="section-label">Collaboration Score</span>
            </div>
          </div>
          
          <div class="collaboration-stats">
            <div class="stat-item">
              <span class="stat-label">Collaborative Works:</span>
              <span class="stat-value">{{ collaborationStats.totalWorks }}</span>
            </div>
            <div class="stat-item">
              <span class="stat-label">Base Bonus:</span>
              <span class="stat-value">{{ collaborationStats.totalWorks }} × 10 = {{ collaborationStats.baseBonus }}</span>
            </div>
            <div class="stat-item">
              <span class="stat-label">Team Bonus:</span>
              <span class="stat-value">+10% = {{ collaborationStats.teamBonus }}</span>
            </div>
          </div>
          
          <div class="collaboration-explanation">
            <p>
              <strong>Calculation:</strong> Each collaborative work adds +10 points, 
              with an additional 10% team bonus.
            </p>
          </div>
        </div>
      </n-card>

      <!-- Governance Score -->
      <n-card class="section-card" title="🏛️ Governance Participation">
        <div class="section-content">
          <div class="section-header">
            <div class="score-summary">
              <span class="section-score">{{ scores.governance }}</span>
              <span class="section-label">Governance Score</span>
            </div>
          </div>
          
          <div class="governance-info">
            <div class="role-display">
              <span class="role-label">Current Role:</span>
              <n-tag :type="getRoleType(userRole)" size="large">
                <template #icon>
                  <n-icon :component="ShieldCheckmarkOutline" />
                </template>
                {{ userRole }}
              </n-tag>
            </div>
            
            <div class="governance-breakdown">
              <div class="score-item">
                <span class="item-label">Base Score:</span>
                <span class="item-value">50</span>
              </div>
              <div class="score-item" v-if="userRole !== 'User'">
                <span class="item-label">Role Bonus:</span>
                <span class="item-value">+50</span>
              </div>
            </div>
          </div>
          
          <div class="governance-explanation">
            <p>
              <strong>Scoring:</strong> Base 50 points for all users. 
              Reviewers and Institutions receive additional 50 points (total 100).
            </p>
          </div>
        </div>
      </n-card>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useMessage } from 'naive-ui';
import axios from 'axios';
import {
  WalletOutline, RefreshOutline, TrophyOutline, GlobeOutline,
  ShieldCheckmarkOutline, CheckmarkCircleOutline, CloseCircleOutline,
  TimeOutline
} from '@vicons/ionicons5';

const message = useMessage();

// Reactive data
const userAddress = ref('');
const userStatus = ref('Verified');
const networkName = ref('Ethereum Mainnet');
const lastUpdateTime = ref(new Date());
const isUpdating = ref(false);
const userRank = ref(null);

// Weights from smart contract (should sum to 10000)
const weights = ref({
  publication: 3000,
  review: 2000,
  data: 2500,
  collaboration: 1500,
  governance: 1000
});

// Individual scores
const scores = ref({
  publication: 0,
  review: 0,
  data: 0,
  collaboration: 0,
  governance: 50
});

// Detailed data
const userPublications = ref([]);
const userDatasets = ref([]);
const reviewStats = ref({
  totalReviews: 0,
  averageQuality: 0,
  qualityBonus: 0
});
const collaborationStats = ref({
  totalWorks: 0,
  baseBonus: 0,
  teamBonus: 0
});
const userRole = ref('User');

// Computed values
const totalInfluence = computed(() => {
  return Math.floor(
    (scores.value.publication * weights.value.publication +
     scores.value.review * weights.value.review +
     scores.value.data * weights.value.data +
     scores.value.collaboration * weights.value.collaboration +
     scores.value.governance * weights.value.governance) / 10000
  );
});

const totalCalculated = computed(() => {
  return scores.value.publication * weights.value.publication +
         scores.value.review * weights.value.review +
         scores.value.data * weights.value.data +
         scores.value.collaboration * weights.value.collaboration +
         scores.value.governance * weights.value.governance;
});

// Methods
const loadCurrentUser = () => {
  const user = JSON.parse(localStorage.getItem('currentUser') || '{}');
  if (user.wallet_address) {
    userAddress.value = user.wallet_address;
  }
};

const updateInfluence = async () => {
  if (!userAddress.value) {
    message.warning('Please connect your wallet first');
    return;
  }

  isUpdating.value = true;
  try {
    // Simulate smart contract call
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    // Refresh all data
    await loadInfluenceData();
    
    lastUpdateTime.value = new Date();
    message.success('Influence updated successfully!');
  } catch (error) {
    console.error('Failed to update influence:', error);
    message.error('Failed to update influence');
  } finally {
    isUpdating.value = false;
  }
};

const loadInfluenceData = async () => {
  try {
    // Load mock data - in real implementation, this would call smart contracts
    loadMockData();
  } catch (error) {
    console.error('Failed to load influence data:', error);
    message.error('Failed to load influence data');
  }
};

const loadMockData = () => {
  // Mock publication data
  userPublications.value = [
    {
      tokenId: 'NFT_123',
      title: 'Machine Learning for Climate Prediction',
      typeWeight: 100,
      impactMultiplier: 1.5,
      baseScore: 150,
      citationBonus: 25,
      downloadBonus: 15,
      timeDecay: 0.9,
      finalScore: 171
    },
    {
      tokenId: 'NFT_124',
      title: 'Blockchain in Scientific Publishing',
      typeWeight: 80,
      impactMultiplier: 1.2,
      baseScore: 96,
      citationBonus: 10,
      downloadBonus: 8,
      timeDecay: 0.95,
      finalScore: 108
    }
  ];

  // Mock dataset data
  userDatasets.value = [
    {
      id: 1,
      name: 'Climate Satellite Data 2024',
      quality: 'High',
      qualityScore: 5,
      downloads: 150,
      citations: 8,
      sizeKB: 1024000,
      sizeBonus: 40,
      totalScore: 830
    },
    {
      id: 2,
      name: 'Gene Expression Profiles',
      quality: 'Medium',
      qualityScore: 3,
      downloads: 75,
      citations: 3,
      sizeKB: 512000,
      sizeBonus: 38,
      totalScore: 473
    }
  ];

  // Calculate scores
  scores.value.publication = userPublications.value.reduce((sum, pub) => sum + pub.finalScore, 0);
  scores.value.data = userDatasets.value.reduce((sum, dataset) => sum + dataset.totalScore, 0);
  
  // Mock other scores
  reviewStats.value = {
    totalReviews: 12,
    averageQuality: 4.2,
    qualityBonus: 50
  };
  scores.value.review = 420;

  collaborationStats.value = {
    totalWorks: 5,
    baseBonus: 50,
    teamBonus: 5
  };
  scores.value.collaboration = 55;

  userRole.value = 'Reviewer';
  scores.value.governance = 100;
  
  userRank.value = 156;
};

// Helper methods
const getWeightLabel = (key) => {
  const labels = {
    publication: 'Publication',
    review: 'Review',
    data: 'Data',
    collaboration: 'Collaboration',
    governance: 'Governance'
  };
  return labels[key] || key;
};

const getStatusType = (status) => {
  switch (status) {
    case 'Verified': return 'success';
    case 'Pending': return 'warning';
    case 'Rejected': return 'error';
    default: return 'default';
  }
};

const getStatusIcon = (status) => {
  switch (status) {
    case 'Verified': return CheckmarkCircleOutline;
    case 'Pending': return TimeOutline;
    case 'Rejected': return CloseCircleOutline;
    default: return TimeOutline;
  }
};

const getQualityType = (quality) => {
  switch (quality) {
    case 'High': return 'success';
    case 'Medium': return 'warning';
    case 'Low': return 'error';
    default: return 'default';
  }
};

const getRoleType = (role) => {
  switch (role) {
    case 'Institution': return 'success';
    case 'Reviewer': return 'info';
    case 'User': return 'default';
    default: return 'default';
  }
};

const formatDate = (date) => {
  return new Date(date).toLocaleString();
};

// Lifecycle
onMounted(async () => {
  loadCurrentUser();
  await loadInfluenceData();
});
</script>

<style scoped>
.influence-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.page-header {
  text-align: center;
  margin-bottom: 1rem;
}

.page-header h1 {
  font-size: 2.5rem;
  margin-bottom: 0.5rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.page-header p {
  color: #6b7280;
  font-size: 1.1rem;
}

/* User Info Card */
.user-info-card {
  border: 2px solid #e5e7eb;
}

.user-info-content {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.user-address {
  display: flex;
  justify-content: center;
}

.user-status {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  justify-content: center;
}

.status-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.label {
  font-weight: 600;
  color: #374151;
}

.timestamp {
  color: #6b7280;
}

.update-section {
  display: flex;
  justify-content: center;
}

/* Total Influence Card */
.total-influence-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.total-influence-card :deep(.n-card__header) {
  color: white;
}

.influence-overview {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.score-display {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.main-score {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.score-number {
  font-size: 3rem;
  font-weight: bold;
  line-height: 1;
}

.score-label {
  font-size: 1.1rem;
  opacity: 0.9;
  margin-top: 0.5rem;
}

.weights-display h3 {
  color: white;
  margin-bottom: 1rem;
}

.weights-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
  gap: 1rem;
}

.weight-item {
  background: rgba(255, 255, 255, 0.1);
  padding: 1rem;
  border-radius: 8px;
  text-align: center;
}

.weight-label {
  font-size: 0.875rem;
  opacity: 0.9;
  margin-bottom: 0.5rem;
}

.weight-value {
  font-size: 1.25rem;
  font-weight: bold;
  margin-bottom: 0.25rem;
}

.weight-percentage {
  font-size: 0.875rem;
  opacity: 0.8;
}

.formula-section {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 8px;
}

.formula-content {
  padding: 1rem;
}

.formula-equation {
  background: rgba(0, 0, 0, 0.2);
  padding: 1rem;
  border-radius: 4px;
  margin-bottom: 1rem;
}

.formula-equation code {
  color: #fbbf24;
  font-size: 0.9rem;
  line-height: 1.5;
}

.current-calculation h4 {
  margin-bottom: 0.75rem;
}

.calc-breakdown {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.calc-item {
  display: flex;
  justify-content: space-between;
  padding: 0.5rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 4px;
}

.calc-total {
  padding: 0.75rem;
  background: rgba(255, 255, 255, 0.15);
  border-radius: 4px;
  margin-top: 0.5rem;
}

/* Breakdown Sections */
.breakdown-sections {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 2rem;
}

.section-card {
  height: fit-content;
}

.section-content {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 1rem;
  border-bottom: 1px solid #e5e7eb;
}

.score-summary {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.section-score {
  font-size: 2rem;
  font-weight: bold;
  color: #1f6feb;
}

.section-label {
  color: #6b7280;
  margin-top: 0.25rem;
}

/* Publication Items */
.publication-item, .dataset-item {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  padding: 1rem;
  margin-bottom: 1rem;
}

.pub-header, .dataset-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1rem;
}

.pub-header h4, .dataset-header h4 {
  margin: 0;
  color: #1f2937;
  flex: 1;
  margin-right: 1rem;
}

.pub-calculation, .dataset-calculation {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.calc-detail {
  display: flex;
  justify-content: space-between;
  padding: 0.5rem;
  background: white;
  border-radius: 4px;
  font-size: 0.875rem;
}

.calc-total {
  padding: 0.75rem;
  background: #1f6feb;
  color: white;
  border-radius: 4px;
  font-weight: bold;
  text-align: center;
}

/* Stats and Info */
.review-stats, .collaboration-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 1rem;
}

.stat-item, .score-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  text-align: center;
  padding: 0.75rem;
  background: #f8fafc;
  border-radius: 6px;
}

.stat-label, .item-label {
  font-size: 0.875rem;
  color: #6b7280;
}

.stat-value, .item-value {
  font-size: 1.25rem;
  font-weight: bold;
  color: #1f2937;
}

.governance-info {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.role-display {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.role-label {
  font-weight: 600;
  color: #374151;
}

.governance-breakdown {
  display: flex;
  gap: 1rem;
}

/* Explanations */
.review-explanation, .data-explanation, .collaboration-explanation, .governance-explanation {
  padding: 1rem;
  background: #eff6ff;
  border-left: 4px solid #3b82f6;
  border-radius: 4px;
}

.review-explanation p, .data-explanation p, .collaboration-explanation p, .governance-explanation p {
  margin: 0;
  color: #1e40af;
  font-size: 0.9rem;
}

/* Responsive Design */
@media (max-width: 768px) {
  .influence-page {
    padding: 1rem;
  }
  
  .breakdown-sections {
    grid-template-columns: 1fr;
  }
  
  .score-display {
    flex-direction: column;
    gap: 1rem;
  }
  
  .user-status {
    flex-direction: column;
    align-items: center;
  }
}</style> 