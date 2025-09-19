<template>
  <div class="review-details-page">
    <div v-if="isLoading" class="loading-container">
      <n-spin size="large">
        <template #description>Loading review details...</template>
      </n-spin>
    </div>
    
    <div v-else-if="review" class="review-details-content">
      <!-- Page Header -->
      <div class="page-header">
        <div class="header-content">
          <div class="header-navigation">
            <n-button text @click="goBack" class="back-btn">
              <template #icon>
                <n-icon :component="ArrowBackOutline" />
              </template>
              Back to Review Details
            </n-button>
          </div>
          
          <div class="header-main">
            <div class="review-badge">
              <n-tag :type="getStatusType(review.status)" size="large">
                <template #icon>
                  <n-icon :component="getStatusIcon(review.status)" />
                </template>
                {{ review.status }}
              </n-tag>
            </div>
            <h1 class="page-title">Review Details</h1>
            <p class="page-description">{{ review.paperTitle }}</p>
          </div>
          
          <div class="header-actions">
            <n-button-group>
              <n-button @click="downloadReview">
                <template #icon>
                  <n-icon :component="DownloadOutline" />
                </template>
                Download Review
              </n-button>
              
              <n-button @click="shareReview" v-if="review.status === 'Completed'">
                <template #icon>
                  <n-icon :component="ShareOutline" />
                </template>
                Share Review
              </n-button>
            </n-button-group>
          </div>
        </div>
      </div>

      <!-- Review Content -->
      <div class="review-content">
        <div class="content-grid">
          <!-- Left Column -->
          <div class="left-column">
            <!-- Review Summary -->
            <n-card title="Review Summary" class="content-card">
              <div class="review-summary">
                <div class="summary-header">
                  <div class="overall-rating">
                    <h3 class="rating-title">Overall Rating</h3>
                    <div class="rating-display">
                      <n-rate 
                        :value="reviewData.overallRating"
                        :count="5"
                        size="large"
                        readonly
                        :show-text="true"
                        :texts="['Poor', 'Fair', 'Good', 'Very Good', 'Excellent']"
                      />
                    </div>
                  </div>
                  
                  <div class="recommendation">
                    <h3 class="recommendation-title">Recommendation</h3>
                    <n-tag 
                      :type="getRecommendationType(reviewData.recommendation)" 
                      size="large"
                      class="recommendation-tag"
                    >
                      {{ getRecommendationText(reviewData.recommendation) }}
                    </n-tag>
                  </div>
                </div>
                
                <div class="summary-text">
                  <h4 class="summary-label">Summary</h4>
                  <p class="summary-content">{{ reviewData.summary }}</p>
                </div>
              </div>
            </n-card>

            <!-- Detailed Evaluation -->
            <n-card title="Detailed Evaluation" class="content-card">
              <div class="evaluation-grid">
                <div class="evaluation-item">
                  <span class="evaluation-label">Originality and Innovation</span>
                  <div class="evaluation-rating">
                    <n-rate :value="reviewData.originality" :count="5" readonly />
                    <span class="rating-text">{{ getRatingText(reviewData.originality) }}</span>
                  </div>
                </div>
                
                <div class="evaluation-item">
                  <span class="evaluation-label">Methodology</span>
                  <div class="evaluation-rating">
                    <n-rate :value="reviewData.methodology" :count="5" readonly />
                    <span class="rating-text">{{ getRatingText(reviewData.methodology) }}</span>
                  </div>
                </div>
                
                <div class="evaluation-item">
                  <span class="evaluation-label">Results and Analysis</span>
                  <div class="evaluation-rating">
                    <n-rate :value="reviewData.results" :count="5" readonly />
                    <span class="rating-text">{{ getRatingText(reviewData.results) }}</span>
                  </div>
                </div>
                
                <div class="evaluation-item">
                  <span class="evaluation-label">Writing Quality</span>
                  <div class="evaluation-rating">
                    <n-rate :value="reviewData.writing" :count="5" readonly />
                    <span class="rating-text">{{ getRatingText(reviewData.writing) }}</span>
                  </div>
                </div>
                
                <div class="evaluation-item">
                  <span class="evaluation-label">Relevance to Field</span>
                  <div class="evaluation-rating">
                    <n-rate :value="reviewData.relevance" :count="5" readonly />
                    <span class="rating-text">{{ getRatingText(reviewData.relevance) }}</span>
                  </div>
                </div>
              </div>
            </n-card>

            <!-- Comments for Authors -->
            <n-card title="Comments for Authors" class="content-card">
              <div class="comments-section">
                <div class="comment-item">
                  <h4 class="comment-title">Strengths</h4>
                  <div class="comment-content">
                    <p>{{ reviewData.strengths }}</p>
                  </div>
                </div>
                
                <div class="comment-item">
                  <h4 class="comment-title">Areas for Improvement</h4>
                  <div class="comment-content">
                    <p>{{ reviewData.weaknesses }}</p>
                  </div>
                </div>
                
                <div class="comment-item" v-if="reviewData.minorComments">
                  <h4 class="comment-title">Minor Comments</h4>
                  <div class="comment-content">
                    <p>{{ reviewData.minorComments }}</p>
                  </div>
                </div>
              </div>
            </n-card>
          </div>

          <!-- Right Column -->
          <div class="right-column">
            <!-- Paper Information -->
            <n-card title="Paper Information" class="content-card">
              <div class="paper-info">
                <h3 class="paper-title">{{ review.paperTitle }}</h3>
                <div class="paper-meta">
                  <div class="meta-item">
                    <span class="meta-label">Authors:</span>
                    <span class="meta-value">{{ review.authors.join(', ') }}</span>
                  </div>
                  <div class="meta-item">
                    <span class="meta-label">Journal:</span>
                    <span class="meta-value">{{ review.journal }}</span>
                  </div>
                  <div class="meta-item">
                    <span class="meta-label">Category:</span>
                    <span class="meta-value">{{ review.category }}</span>
                  </div>
                  <div class="meta-item">
                    <span class="meta-label">Review ID:</span>
                    <span class="meta-value">{{ review.reviewId }}</span>
                  </div>
                </div>
                
                <div class="paper-actions">
                  <n-button block @click="downloadPaper">
                    <template #icon>
                      <n-icon :component="DownloadOutline" />
                    </template>
                    Download Paper
                  </n-button>
                </div>
              </div>
            </n-card>

            <!-- Review Timeline -->
            <n-card title="Review Timeline" class="content-card">
              <div class="timeline">
                <div class="timeline-item completed">
                  <div class="timeline-marker">
                    <n-icon :component="CheckmarkCircleOutline" />
                  </div>
                  <div class="timeline-content">
                    <h4 class="timeline-title">Assignment Received</h4>
                    <p class="timeline-date">{{ formatDate(review.assignedAt) }}</p>
                  </div>
                </div>
                
                <div class="timeline-item completed">
                  <div class="timeline-marker">
                    <n-icon :component="CreateOutline" />
                  </div>
                  <div class="timeline-content">
                    <h4 class="timeline-title">Review Started</h4>
                    <p class="timeline-date">{{ formatDate(review.startedAt) }}</p>
                  </div>
                </div>
                
                <div class="timeline-item completed">
                  <div class="timeline-marker">
                    <n-icon :component="DocumentTextOutline" />
                  </div>
                  <div class="timeline-content">
                    <h4 class="timeline-title">Review Submitted</h4>
                    <p class="timeline-date">{{ formatDate(review.submittedAt) }}</p>
                  </div>
                </div>
                
                <div class="timeline-item completed">
                  <div class="timeline-marker">
                    <n-icon :component="CheckmarkCircleOutline" />
                  </div>
                  <div class="timeline-content">
                    <h4 class="timeline-title">Review Completed</h4>
                    <p class="timeline-date">{{ formatDate(review.completedAt) }}</p>
                  </div>
                </div>
              </div>
            </n-card>

            <!-- Review Statistics -->
            <n-card title="Review Statistics" class="content-card">
              <div class="statistics">
                <div class="stat-item">
                  <span class="stat-label">Time Spent</span>
                  <span class="stat-value">{{ review.timeSpent || '8 hours' }}</span>
                </div>
                
                <div class="stat-item">
                  <span class="stat-label">Word Count</span>
                  <span class="stat-value">{{ getWordCount() }} words</span>
                </div>
                
                <div class="stat-item">
                  <span class="stat-label">Review Quality</span>
                  <span class="stat-value">
                    <n-rate :value="review.quality || 5" :count="5" readonly size="small" />
                  </span>
                </div>
              </div>
            </n-card>

            <!-- Editor Comments (if available) -->
            <n-card title="Editor Feedback" class="content-card" v-if="reviewData.editorComments">
              <div class="editor-comments">
                <p class="editor-comments-text">{{ reviewData.editorComments }}</p>
              </div>
            </n-card>
          </div>
        </div>
      </div>
    </div>

    <div v-else class="error-state">
      <n-empty description="Review not found" size="large">
        <template #extra>
          <n-button @click="goBack">Go Back</n-button>
        </template>
      </n-empty>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { 
  NCard, NButton, NIcon, NSpin, NEmpty, NTag, NRate, NButtonGroup,
  useMessage
} from 'naive-ui'
import {
  ArrowBackOutline, DownloadOutline, ShareOutline, CheckmarkCircleOutline,
  CreateOutline, DocumentTextOutline, CheckmarkOutline, PauseOutline,
  AlertCircleOutline, CloseOutline
} from '@vicons/ionicons5'
import dayjs from 'dayjs'

const router = useRouter()
const route = useRoute()
const message = useMessage()

// Reactive data
const isLoading = ref(true)
const review = ref(null)
const reviewData = ref({
  overallRating: 4,
  recommendation: 'minor_revision',
  originality: 4,
  methodology: 3,
  results: 4,
  writing: 3,
  relevance: 5,
  summary: 'This paper presents a novel approach to quantum cryptography with significant potential for practical applications. The methodology is sound and the results are promising, though there are some areas that could benefit from additional clarification and refinement.',
  strengths: 'The paper introduces innovative quantum key distribution methods that show clear improvements over existing protocols. The experimental validation is thorough and the theoretical foundation is solid. The writing is generally clear and the figures are well-designed.',
  weaknesses: 'The computational complexity analysis could be more detailed. Some of the security assumptions need further justification. The comparison with existing methods could be more comprehensive. The paper would benefit from additional discussion of practical implementation challenges.',
  minorComments: 'There are a few typos on pages 3 and 7. Figure 2 could be improved with better labeling. The reference list is comprehensive but could include more recent work from 2023.',
  editorComments: 'Thank you for the thorough review. The reviewer has provided excellent feedback that will help improve the paper significantly.'
})

// Mock review data
const mockReviews = [
  {
    id: 1,
    paperTitle: "Advanced Quantum Cryptography for Secure Communications",
    authors: ["Dr. Alice Johnson", "Prof. Bob Smith", "Dr. Charlie Brown"],
    abstract: "This paper presents novel approaches to quantum cryptography, focusing on enhanced security protocols for next-generation communication systems.",
    keywords: ["Quantum Cryptography", "Security", "Communications", "Protocols", "Quantum Computing"],
    category: "Computer Science",
    journal: "Journal of Quantum Computing",
    status: "Completed",
    urgency: "High",
    assignedAt: "2024-02-10",
    deadline: "2024-02-25",
    estimatedHours: 8,
    reviewId: "REV-2024-001",
    startedAt: "2024-02-12",
    submittedAt: "2024-02-20",
    completedAt: "2024-02-22",
    timeSpent: "8 hours",
    quality: 5
  }
]

// Methods
const formatDate = (date) => {
  return dayjs(date).format('MMM DD, YYYY')
}

const getStatusType = (status) => {
  switch (status) {
    case 'Completed': return 'success'
    case 'In Progress': return 'info'
    case 'Under Review': return 'warning'
    case 'Pending': return 'default'
    case 'Revision Requested': return 'error'
    default: return 'default'
  }
}

const getStatusIcon = (status) => {
  switch (status) {
    case 'Completed': return CheckmarkOutline
    case 'In Progress': return CreateOutline
    case 'Under Review': return PauseOutline
    case 'Pending': return AlertCircleOutline
    case 'Revision Requested': return CloseOutline
    default: return AlertCircleOutline
  }
}

const getRecommendationType = (recommendation) => {
  switch (recommendation) {
    case 'accept': return 'success'
    case 'minor_revision': return 'warning'
    case 'major_revision': return 'error'
    case 'reject': return 'error'
    default: return 'default'
  }
}

const getRecommendationText = (recommendation) => {
  switch (recommendation) {
    case 'accept': return 'Accept'
    case 'minor_revision': return 'Minor Revision'
    case 'major_revision': return 'Major Revision'
    case 'reject': return 'Reject'
    default: return recommendation
  }
}

const getRatingText = (rating) => {
  const texts = ['Poor', 'Fair', 'Good', 'Very Good', 'Excellent']
  return texts[rating - 1] || 'Not rated'
}

const getWordCount = () => {
  const text = reviewData.value.summary + ' ' + reviewData.value.strengths + ' ' + reviewData.value.weaknesses
  return text.split(/\s+/).filter(word => word.length > 0).length
}

const goBack = () => {
  router.push(`/reviews/${route.params.review_id}`)
}

const downloadPaper = () => {
  message.success(`Downloading: ${review.value.paperTitle}`)
  // TODO: Implement download
}

const downloadReview = () => {
  message.success('Downloading review report')
  // TODO: Implement download
}

const shareReview = () => {
  message.info('Opening share dialog')
  // TODO: Implement share functionality
}

// Lifecycle
onMounted(async () => {
  try {
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    const reviewId = parseInt(route.params.review_id)
    
    // First try to get from localStorage (updated data)
    const savedReviews = localStorage.getItem('reviewsData')
    if (savedReviews) {
      try {
        const parsedReviews = JSON.parse(savedReviews)
        review.value = parsedReviews.find(r => r.id === reviewId)
      } catch (error) {
        console.error('Failed to parse saved reviews:', error)
      }
    }
    
    // Fallback to mock data if not found in localStorage
    if (!review.value) {
      review.value = mockReviews.find(r => r.id === reviewId)
    }
    
    if (!review.value) {
      throw new Error('Review not found')
    }
    
    // TODO: Load actual review data from API
  } catch (error) {
    console.error('Failed to load review:', error)
    message.error('Failed to load review data')
  } finally {
    isLoading.value = false
  }
})
</script>

<style scoped>
.review-details-page {
  min-height: 100vh;
  background: #0d1117;
  color: #c9d1d9;
}

.loading-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
}

.review-details-content {
  max-width: 1400px;
  margin: 0 auto;
  padding: 24px;
}

.page-header {
  margin-bottom: 32px;
}

.header-content {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.header-navigation {
  display: flex;
  align-items: center;
}

.header-main {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.review-badge {
  align-self: flex-start;
}

.page-title {
  font-size: 2.5rem;
  font-weight: 700;
  color: #c9d1d9;
  margin: 0;
}

.page-description {
  font-size: 1.1rem;
  color: #8b949e;
  margin: 0;
}

.header-actions {
  display: flex;
  justify-content: flex-end;
}

.review-content {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.content-grid {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 32px;
}

.left-column {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.right-column {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.content-card {
  background: #161b22;
  border: 1px solid #30363d;
}

.review-summary {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.summary-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 32px;
}

.overall-rating {
  flex: 1;
}

.rating-title {
  font-size: 1.1rem;
  font-weight: 600;
  color: #c9d1d9;
  margin: 0 0 12px 0;
}

.rating-display {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.recommendation {
  flex: 1;
}

.recommendation-title {
  font-size: 1.1rem;
  font-weight: 600;
  color: #c9d1d9;
  margin: 0 0 12px 0;
}

.recommendation-tag {
  font-size: 1rem;
  font-weight: 600;
}

.summary-text {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.summary-label {
  font-size: 1rem;
  font-weight: 600;
  color: #c9d1d9;
  margin: 0;
}

.summary-content {
  font-size: 0.95rem;
  line-height: 1.7;
  color: #c9d1d9;
  margin: 0;
  text-align: justify;
}

.evaluation-grid {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.evaluation-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
}

.evaluation-label {
  font-size: 0.95rem;
  font-weight: 500;
  color: #c9d1d9;
  flex: 1;
}

.evaluation-rating {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-shrink: 0;
}

.rating-text {
  font-size: 0.875rem;
  color: #8b949e;
  min-width: 80px;
}

.comments-section {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.comment-item {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.comment-title {
  font-size: 1rem;
  font-weight: 600;
  color: #c9d1d9;
  margin: 0;
}

.comment-content {
  background: #21262d;
  border: 1px solid #30363d;
  border-radius: 8px;
  padding: 16px;
}

.comment-content p {
  font-size: 0.95rem;
  line-height: 1.7;
  color: #c9d1d9;
  margin: 0;
  text-align: justify;
}

.paper-info {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.paper-title {
  font-size: 1.1rem;
  font-weight: 600;
  color: #c9d1d9;
  margin: 0;
  line-height: 1.4;
}

.paper-meta {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.meta-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.meta-label {
  font-size: 0.875rem;
  font-weight: 600;
  color: #8b949e;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.meta-value {
  font-size: 0.95rem;
  color: #c9d1d9;
}

.paper-actions {
  margin-top: 8px;
}

.timeline {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.timeline-item {
  display: flex;
  align-items: flex-start;
  gap: 16px;
}

.timeline-item.completed {
  opacity: 1;
}

.timeline-marker {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #58a6ff;
  color: #ffffff;
  flex-shrink: 0;
}

.timeline-content {
  flex: 1;
}

.timeline-title {
  font-size: 0.95rem;
  font-weight: 600;
  color: #c9d1d9;
  margin: 0 0 4px 0;
}

.timeline-date {
  font-size: 0.875rem;
  color: #8b949e;
  margin: 0;
}

.statistics {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.stat-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
}

.stat-label {
  font-size: 0.875rem;
  font-weight: 500;
  color: #8b949e;
}

.stat-value {
  font-size: 0.95rem;
  font-weight: 600;
  color: #c9d1d9;
}

.editor-comments {
  background: #21262d;
  border: 1px solid #30363d;
  border-radius: 8px;
  padding: 16px;
}

.editor-comments-text {
  font-size: 0.95rem;
  line-height: 1.7;
  color: #c9d1d9;
  margin: 0;
  text-align: justify;
}

.error-state {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
}

/* Dark theme adjustments */
:deep(.n-card) {
  background-color: #161b22;
  border-color: #30363d;
}

:deep(.n-tag) {
  border-color: #30363d;
}

:deep(.n-rate) {
  color: #58a6ff;
}

/* Responsive design */
@media (max-width: 1200px) {
  .content-grid {
    grid-template-columns: 1fr;
  }
  
  .summary-header {
    flex-direction: column;
    gap: 20px;
  }
}

@media (max-width: 768px) {
  .review-details-content {
    padding: 16px;
  }
  
  .header-actions {
    justify-content: stretch;
  }
  
  .header-actions .n-button-group {
    width: 100%;
  }
  
  .evaluation-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
}
</style>
