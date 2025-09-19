<template>
  <div class="review-detail-page">
    <div v-if="isLoading" class="loading-container">
      <n-spin size="large">
        <template #description>Loading review details...</template>
      </n-spin>
    </div>
    
    <div v-else-if="review" class="review-detail-content">
      <!-- Page Header -->
      <div class="page-header">
        <div class="header-content">
          <div class="header-navigation">
            <n-button text @click="goBack" class="back-btn">
              <template #icon>
                <n-icon :component="ArrowBackOutline" />
              </template>
              Back to Reviews
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
            <h1 class="page-title">Review Assignment</h1>
            <p class="page-description">Review ID: {{ review.reviewId }}</p>
          </div>
          
          <div class="header-actions">
            <n-button-group>
              <n-button 
                v-if="review.status === 'Pending'"
                type="primary"
                @click="startReview"
              >
                <template #icon>
                  <n-icon :component="PlayOutline" />
                </template>
                Start Review
              </n-button>
              
              <n-button 
                v-else-if="review.status === 'In Progress'"
                type="primary"
                @click="continueReview"
              >
                <template #icon>
                  <n-icon :component="CreateOutline" />
                </template>
                Continue Review
              </n-button>
              
              <n-button 
                v-else
                @click="viewReviewForm"
              >
                <template #icon>
                  <n-icon :component="EyeOutline" />
                </template>
                View Review
              </n-button>
              
              <n-button @click="downloadPaper">
                <template #icon>
                  <n-icon :component="DownloadOutline" />
                </template>
                Download Paper
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
            <!-- Paper Information -->
            <n-card title="Paper Information" class="content-card">
              <div class="paper-info">
                <h2 class="paper-title">{{ review.paperTitle }}</h2>
                
                <div class="paper-meta">
                  <div class="meta-section">
                    <h4 class="meta-title">Authors</h4>
                    <div class="authors-list">
                      <span v-for="(author, index) in review.authors" :key="index" class="author">
                        {{ author }}{{ index < review.authors.length - 1 ? ', ' : '' }}
                      </span>
                    </div>
                  </div>
                  
                  <div class="meta-section">
                    <h4 class="meta-title">Journal</h4>
                    <p class="meta-value">{{ review.journal }}</p>
                  </div>
                  
                  <div class="meta-section">
                    <h4 class="meta-title">Category</h4>
                    <n-tag size="medium">{{ review.category }}</n-tag>
                  </div>
                  
                  <div class="meta-section">
                    <h4 class="meta-title">Keywords</h4>
                    <div class="keywords-list">
                      <n-tag 
                        v-for="keyword in review.keywords" 
                        :key="keyword" 
                        size="small"
                        class="keyword-tag"
                      >
                        {{ keyword }}
                      </n-tag>
                    </div>
                  </div>
                </div>
              </div>
            </n-card>

            <!-- Abstract -->
            <n-card title="Abstract" class="content-card">
              <p class="abstract-text">{{ review.abstract }}</p>
            </n-card>

            <!-- Review Timeline -->
            <n-card title="Review Timeline" class="content-card">
              <div class="timeline">
                <div class="timeline-item" :class="{ active: review.status !== 'Pending' }">
                  <div class="timeline-marker">
                    <n-icon :component="CheckmarkCircleOutline" />
                  </div>
                  <div class="timeline-content">
                    <h4 class="timeline-title">Assignment Received</h4>
                    <p class="timeline-date">{{ formatDate(review.assignedAt) }}</p>
                  </div>
                </div>
                
                <div class="timeline-item" :class="{ active: review.status === 'In Progress' || review.status === 'Under Review' || review.status === 'Completed' }">
                  <div class="timeline-marker">
                    <n-icon :component="CreateOutline" />
                  </div>
                  <div class="timeline-content">
                    <h4 class="timeline-title">Review Started</h4>
                    <p class="timeline-date" v-if="review.startedAt">{{ formatDate(review.startedAt) }}</p>
                    <p class="timeline-date" v-else>Not started yet</p>
                  </div>
                </div>
                
                <div class="timeline-item" :class="{ active: review.status === 'Under Review' || review.status === 'Completed' }">
                  <div class="timeline-marker">
                    <n-icon :component="DocumentTextOutline" />
                  </div>
                  <div class="timeline-content">
                    <h4 class="timeline-title">Review Submitted</h4>
                    <p class="timeline-date" v-if="review.submittedAt">{{ formatDate(review.submittedAt) }}</p>
                    <p class="timeline-date" v-else>Not submitted yet</p>
                  </div>
                </div>
                
                <div class="timeline-item" :class="{ active: review.status === 'Completed' }">
                  <div class="timeline-marker">
                    <n-icon :component="CheckmarkCircleOutline" />
                  </div>
                  <div class="timeline-content">
                    <h4 class="timeline-title">Review Completed</h4>
                    <p class="timeline-date" v-if="review.completedAt">{{ formatDate(review.completedAt) }}</p>
                    <p class="timeline-date" v-else>Not completed yet</p>
                  </div>
                </div>
              </div>
            </n-card>
          </div>

          <!-- Right Column -->
          <div class="right-column">
            <!-- Review Status -->
            <n-card title="Review Status" class="content-card">
              <div class="status-info">
                <div class="status-item">
                  <span class="status-label">Current Status:</span>
                  <n-tag :type="getStatusType(review.status)" size="medium">
                    {{ review.status }}
                  </n-tag>
                </div>
                
                <div class="status-item">
                  <span class="status-label">Urgency:</span>
                  <n-tag :type="getUrgencyType(review.urgency)" size="medium">
                    {{ review.urgency }}
                  </n-tag>
                </div>
                
                <div class="status-item">
                  <span class="status-label">Deadline:</span>
                  <span class="status-value">{{ formatDate(review.deadline) }}</span>
                  <span :class="getDaysLeftClass(review.deadline, review.status)" class="days-left">
                    ({{ getDaysLeft(review.deadline, review.status) }})
                  </span>
                </div>
                
                <div class="status-item">
                  <span class="status-label">Estimated Time:</span>
                  <span class="status-value">{{ review.estimatedHours }} hours</span>
                </div>
              </div>
            </n-card>

            <!-- Progress -->
            <n-card title="Progress" class="content-card">
              <div class="progress-section">
                <div class="progress-info">
                  <span class="progress-label">{{ getProgressLabel(review.status) }}</span>
                  <n-progress 
                    :percentage="getProgressPercentage(review.status, review.progress)"
                    :status="getProgressStatus(review.status)"
                    :show-indicator="true"
                    class="progress-bar"
                  />
                </div>
                
                <div class="progress-details">
                  <p class="progress-text" v-if="review.progress !== null && review.progress !== undefined">
                    Current progress: {{ review.progress }}%
                  </p>
                  <p class="progress-text" v-if="review.status === 'In Progress' && review.startedAt">
                    Started: {{ formatDate(review.startedAt) }}
                  </p>
                </div>
              </div>
            </n-card>

            <!-- Review Guidelines -->
            <n-card title="Review Guidelines" class="content-card">
              <div class="guidelines">
                <div class="guideline-item">
                  <n-icon :component="DocumentTextOutline" class="guideline-icon" />
                  <div class="guideline-content">
                    <h4 class="guideline-title">Review Criteria</h4>
                    <p class="guideline-text">Evaluate originality, methodology, results, and writing quality</p>
                  </div>
                </div>
                
                <div class="guideline-item">
                  <n-icon :component="TimeOutline" class="guideline-icon" />
                  <div class="guideline-content">
                    <h4 class="guideline-title">Time Management</h4>
                    <p class="guideline-text">Allocate sufficient time for thorough evaluation</p>
                  </div>
                </div>
                
                <div class="guideline-item">
                  <n-icon :component="ChatbubbleEllipsesOutline" class="guideline-icon" />
                  <div class="guideline-content">
                    <h4 class="guideline-title">Constructive Feedback</h4>
                    <p class="guideline-text">Provide detailed, constructive comments for authors</p>
                  </div>
                </div>
              </div>
            </n-card>

            <!-- Quick Actions -->
            <n-card title="Quick Actions" class="content-card">
              <div class="quick-actions">
                <n-button block @click="contactEditor">
                  <template #icon>
                    <n-icon :component="ChatbubbleEllipsesOutline" />
                  </template>
                  Contact Editor
                </n-button>
                
                <n-button block @click="requestExtension" v-if="review.status !== 'Completed'">
                  <template #icon>
                    <n-icon :component="TimeOutline" />
                  </template>
                  Request Extension
                </n-button>
                
                <n-button block @click="declineReview" v-if="review.status === 'Pending'">
                  <template #icon>
                    <n-icon :component="CloseOutline" />
                  </template>
                  Decline Review
                </n-button>
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
  NCard, NButton, NIcon, NSpin, NEmpty, NTag, NProgress, NButtonGroup,
  useMessage
} from 'naive-ui'
import {
  ArrowBackOutline, PlayOutline, CreateOutline, EyeOutline, DownloadOutline,
  CheckmarkCircleOutline, DocumentTextOutline, TimeOutline, ChatbubbleEllipsesOutline,
  CloseOutline, PauseOutline, CheckmarkOutline, AlertCircleOutline
} from '@vicons/ionicons5'
import axios from 'axios'
import dayjs from 'dayjs'

const router = useRouter()
const route = useRoute()
const message = useMessage()

// Reactive data
const isLoading = ref(true)
const review = ref(null)

// Mock review data
const mockReviews = [
  {
    id: 1,
    paperTitle: "Advanced Quantum Cryptography for Secure Communications",
    authors: ["Dr. Alice Johnson", "Prof. Bob Smith", "Dr. Charlie Brown"],
    abstract: "This paper presents novel approaches to quantum cryptography, focusing on enhanced security protocols for next-generation communication systems. The research introduces innovative quantum key distribution methods that significantly improve upon existing protocols while maintaining practical implementation feasibility.",
    keywords: ["Quantum Cryptography", "Security", "Communications", "Protocols", "Quantum Computing"],
    category: "Computer Science",
    journal: "Journal of Quantum Computing",
    status: "In Progress",
    urgency: "High",
    assignedAt: "2024-02-10",
    deadline: "2024-02-25",
    estimatedHours: 8,
    reviewId: "REV-2024-001",
    startedAt: "2024-02-12",
    progress: 60
  },
  {
    id: 2,
    paperTitle: "Machine Learning Applications in Climate Modeling",
    authors: ["Dr. Emma Wilson", "Prof. David Lee"],
    abstract: "We explore the integration of machine learning techniques with traditional climate modeling approaches to improve prediction accuracy and reduce computational costs.",
    keywords: ["Machine Learning", "Climate Modeling", "Prediction", "Environmental Science", "AI"],
    category: "Environmental Science",
    journal: "Climate Science Review",
    status: "Under Review",
    urgency: "Medium",
    assignedAt: "2024-02-01",
    deadline: "2024-02-28",
    estimatedHours: 12,
    reviewId: "REV-2024-002",
    startedAt: "2024-02-05",
    submittedAt: "2024-02-15",
    progress: 100
  },
  {
    id: 3,
    paperTitle: "Blockchain-Based Supply Chain Transparency",
    authors: ["Prof. Sarah Chen", "Dr. Michael Zhang"],
    abstract: "This study examines the implementation of blockchain technology for enhancing transparency and traceability in global supply chain management.",
    keywords: ["Blockchain", "Supply Chain", "Transparency", "Traceability", "Management"],
    category: "Computer Science",
    journal: "Blockchain Technology Review",
    status: "Completed",
    urgency: "Low",
    assignedAt: "2024-01-20",
    deadline: "2024-03-05",
    estimatedHours: 10,
    reviewId: "REV-2024-003",
    startedAt: "2024-01-25",
    submittedAt: "2024-02-15",
    completedAt: "2024-02-20",
    progress: 100,
    rating: 4.5
  }
]

// Methods
const formatDate = (date) => {
  return dayjs(date).format('MMM DD, YYYY')
}

const getDaysLeft = (deadline, status = null) => {
  // If completed, don't show overdue
  if (status === 'Completed') return 'Completed'
  
  const days = dayjs(deadline).diff(dayjs(), 'day')
  if (days < 0) return 'Overdue'
  if (days === 0) return 'Due today'
  if (days === 1) return '1 day left'
  return `${days} days left`
}

const getDaysLeftClass = (deadline, status = null) => {
  // If completed, use success class
  if (status === 'Completed') return 'completed'
  
  const days = dayjs(deadline).diff(dayjs(), 'day')
  if (days < 0) return 'overdue'
  if (days <= 2) return 'urgent'
  if (days <= 7) return 'warning'
  return 'normal'
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

const getUrgencyType = (urgency) => {
  switch (urgency) {
    case 'High': return 'error'
    case 'Medium': return 'warning'
    case 'Low': return 'info'
    default: return 'default'
  }
}

const getProgressLabel = (status) => {
  switch (status) {
    case 'Pending': return 'Not Started'
    case 'In Progress': return 'In Progress'
    case 'Under Review': return 'Under Review'
    case 'Completed': return 'Completed'
    case 'Revision Requested': return 'Revision Requested'
    default: return status
  }
}

const getProgressPercentage = (status, progress) => {
  if (status === 'Pending') return 0
  if (status === 'In Progress') return progress || 0
  if (status === 'Under Review') return 80
  if (status === 'Completed') return 100
  if (status === 'Revision Requested') return 30
  return 0
}

const getProgressStatus = (status) => {
  switch (status) {
    case 'Completed': return 'success'
    case 'Revision Requested': return 'error'
    case 'Under Review': return 'warning'
    default: return 'info'
  }
}

const goBack = () => {
  router.push('/reviews')
}

const startReview = () => {
  router.push(`/reviews/${route.params.review_id}/review`)
}

const continueReview = () => {
  router.push(`/reviews/${route.params.review_id}/review`)
}

const viewReviewForm = () => {
  router.push(`/reviews/${route.params.review_id}/details`)
}

const downloadPaper = () => {
  message.success(`Downloading: ${review.value.paperTitle}`)
  // TODO: Implement download
}

const contactEditor = () => {
  message.info('Opening contact editor dialog')
  // TODO: Implement contact editor
}

const requestExtension = () => {
  message.info('Opening extension request dialog')
  // TODO: Implement extension request
}

const declineReview = () => {
  message.warning('Declining review assignment')
  // TODO: Implement decline logic
}

// Load review data from backend API
const loadReview = async () => {
  isLoading.value = true
  try {
    const reviewId = route.params.review_id
    console.log('Loading review with ID:', reviewId)
    
    // Call backend API to get review details
    const response = await axios.get(`http://localhost:3000/api/reviews/${reviewId}`)
    console.log('Review response:', response.data)
    
    review.value = response.data
    
    if (!review.value) {
      throw new Error('Review not found')
    }
  } catch (error) {
    console.error('Failed to load review:', error)
    console.error('Error details:', {
      message: error.message,
      response: error.response?.data,
      status: error.response?.status
    })
    
    // Fallback to mock data for development
    const reviewId = parseInt(route.params.review_id)
    review.value = mockReviews.find(r => r.id === reviewId)
    
    if (!review.value) {
      if (error.code === 'ECONNREFUSED' || error.message.includes('Network Error')) {
        message.error('Cannot connect to server. Using mock data for demo.')
      } else {
        message.error(`Failed to load review data: ${error.message}`)
      }
    }
  } finally {
    isLoading.value = false
  }
}

// Lifecycle
onMounted(async () => {
  await loadReview()
})
</script>

<style scoped>
.review-detail-page {
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

.review-detail-content {
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

.paper-info {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.paper-title {
  font-size: 1.5rem;
  font-weight: 600;
  color: #c9d1d9;
  margin: 0;
  line-height: 1.4;
}

.paper-meta {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.meta-section {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.meta-title {
  font-size: 0.875rem;
  font-weight: 600;
  color: #8b949e;
  margin: 0;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.meta-value {
  font-size: 0.95rem;
  color: #c9d1d9;
  margin: 0;
}

.authors-list {
  font-size: 0.95rem;
  color: #c9d1d9;
  line-height: 1.5;
}

.keywords-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.keyword-tag {
  font-size: 0.75rem;
}

.abstract-text {
  font-size: 0.95rem;
  line-height: 1.7;
  color: #c9d1d9;
  margin: 0;
  text-align: justify;
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
  opacity: 0.5;
  transition: opacity 0.3s ease;
}

.timeline-item.active {
  opacity: 1;
}

.timeline-marker {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #30363d;
  color: #8b949e;
  flex-shrink: 0;
  transition: all 0.3s ease;
}

.timeline-item.active .timeline-marker {
  background: #58a6ff;
  color: #ffffff;
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

.status-info {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.status-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.status-label {
  font-size: 0.875rem;
  font-weight: 600;
  color: #8b949e;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.status-value {
  font-size: 0.95rem;
  color: #c9d1d9;
}

.days-left {
  font-weight: 500;
  margin-left: 8px;
}

.days-left.overdue {
  color: #f85149;
}

.days-left.urgent {
  color: #ff8c42;
}

.days-left.completed {
  color: #4ade80;
}

.days-left.warning {
  color: #f0d000;
}

.days-left.normal {
  color: #7c3aed;
}

.progress-section {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.progress-info {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.progress-label {
  font-size: 0.875rem;
  font-weight: 600;
  color: #8b949e;
}

.progress-bar {
  width: 100%;
}

.progress-details {
  padding-top: 8px;
  border-top: 1px solid #30363d;
}

.progress-text {
  font-size: 0.875rem;
  color: #8b949e;
  margin: 0;
}

.guidelines {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.guideline-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
}

.guideline-icon {
  font-size: 20px;
  color: #58a6ff;
  flex-shrink: 0;
  margin-top: 2px;
}

.guideline-content {
  flex: 1;
}

.guideline-title {
  font-size: 0.875rem;
  font-weight: 600;
  color: #c9d1d9;
  margin: 0 0 4px 0;
}

.guideline-text {
  font-size: 0.8rem;
  color: #8b949e;
  margin: 0;
  line-height: 1.5;
}

.quick-actions {
  display: flex;
  flex-direction: column;
  gap: 12px;
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

:deep(.n-progress .n-progress-rail) {
  background-color: #30363d;
}

/* Responsive design */
@media (max-width: 1200px) {
  .content-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .review-detail-content {
    padding: 16px;
  }
  
  .header-actions {
    justify-content: stretch;
  }
  
  .header-actions .n-button-group {
    width: 100%;
  }
}
</style>
