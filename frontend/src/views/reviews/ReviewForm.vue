<template>
  <div class="review-form-page">
    <div v-if="isLoading" class="loading-container">
      <n-spin size="large">
        <template #description>Loading review form...</template>
      </n-spin>
    </div>
    
    <div v-else-if="review" class="review-form-content">
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
              <n-tag type="info" size="large">
                <template #icon>
                  <n-icon :component="CreateOutline" />
                </template>
                Review in Progress
              </n-tag>
            </div>
            <h1 class="page-title">Review Paper</h1>
            <p class="page-description">{{ review.paperTitle }}</p>
          </div>
          
          <div class="header-actions">
            <n-button-group>
              <n-button @click="saveDraft" :loading="isSaving">
                <template #icon>
                  <n-icon :component="SaveOutline" />
                </template>
                Save Draft
              </n-button>
              
              <n-button type="primary" @click="submitReview" :loading="isSubmitting">
                <template #icon>
                  <n-icon :component="CheckmarkOutline" />
                </template>
                Submit Review
              </n-button>
            </n-button-group>
          </div>
        </div>
      </div>

      <!-- Review Form -->
      <div class="review-form-container">
        <n-form
          ref="formRef"
          :model="reviewForm"
          :rules="formRules"
          label-placement="top"
          require-mark-placement="right-hanging"
          size="large"
        >
          <div class="form-grid">
            <!-- Left Column -->
            <div class="left-column">
              <!-- Overall Assessment -->
              <n-card title="Overall Assessment" class="form-card">
                <n-form-item label="Overall Rating" path="overallRating">
                  <n-rate 
                    v-model:value="reviewForm.overallRating"
                    :count="5"
                    size="large"
                    :show-text="true"
                    :texts="['Poor', 'Fair', 'Good', 'Very Good', 'Excellent']"
                  />
                </n-form-item>
                
                <n-form-item label="Recommendation" path="recommendation">
                  <n-radio-group v-model:value="reviewForm.recommendation">
                    <n-space direction="vertical">
                      <n-radio value="accept">Accept</n-radio>
                      <n-radio value="minor_revision">Minor Revision</n-radio>
                      <n-radio value="major_revision">Major Revision</n-radio>
                      <n-radio value="reject">Reject</n-radio>
                    </n-space>
                  </n-radio-group>
                </n-form-item>
              </n-card>

              <!-- Detailed Evaluation -->
              <n-card title="Detailed Evaluation" class="form-card">
                <n-form-item label="Originality and Innovation" path="originality">
                  <n-rate 
                    v-model:value="reviewForm.originality"
                    :count="5"
                    :show-text="true"
                    :texts="['Poor', 'Fair', 'Good', 'Very Good', 'Excellent']"
                  />
                </n-form-item>
                
                <n-form-item label="Methodology" path="methodology">
                  <n-rate 
                    v-model:value="reviewForm.methodology"
                    :count="5"
                    :show-text="true"
                    :texts="['Poor', 'Fair', 'Good', 'Very Good', 'Excellent']"
                  />
                </n-form-item>
                
                <n-form-item label="Results and Analysis" path="results">
                  <n-rate 
                    v-model:value="reviewForm.results"
                    :count="5"
                    :show-text="true"
                    :texts="['Poor', 'Fair', 'Good', 'Very Good', 'Excellent']"
                  />
                </n-form-item>
                
                <n-form-item label="Writing Quality" path="writing">
                  <n-rate 
                    v-model:value="reviewForm.writing"
                    :count="5"
                    :show-text="true"
                    :texts="['Poor', 'Fair', 'Good', 'Very Good', 'Excellent']"
                  />
                </n-form-item>
                
                <n-form-item label="Relevance to Field" path="relevance">
                  <n-rate 
                    v-model:value="reviewForm.relevance"
                    :count="5"
                    :show-text="true"
                    :texts="['Poor', 'Fair', 'Good', 'Very Good', 'Excellent']"
                  />
                </n-form-item>
              </n-card>

              <!-- Comments for Authors -->
              <n-card title="Comments for Authors" class="form-card">
                <n-form-item label="Summary" path="summary">
                  <n-input
                    v-model:value="reviewForm.summary"
                    type="textarea"
                    placeholder="Provide a brief summary of the paper and your overall assessment..."
                    :rows="4"
                    :maxlength="1000"
                    show-count
                  />
                </n-form-item>
                
                <n-form-item label="Strengths" path="strengths">
                  <n-input
                    v-model:value="reviewForm.strengths"
                    type="textarea"
                    placeholder="Highlight the main strengths of the paper..."
                    :rows="4"
                    :maxlength="1000"
                    show-count
                  />
                </n-form-item>
                
                <n-form-item label="Weaknesses and Suggestions" path="weaknesses">
                  <n-input
                    v-model:value="reviewForm.weaknesses"
                    type="textarea"
                    placeholder="Identify areas for improvement and provide constructive suggestions..."
                    :rows="4"
                    :maxlength="1000"
                    show-count
                  />
                </n-form-item>
                
                <n-form-item label="Minor Comments" path="minorComments">
                  <n-input
                    v-model:value="reviewForm.minorComments"
                    type="textarea"
                    placeholder="Include any minor comments, typos, or suggestions..."
                    :rows="3"
                    :maxlength="500"
                    show-count
                  />
                </n-form-item>
              </n-card>
            </div>

            <!-- Right Column -->
            <div class="right-column">
              <!-- Paper Information -->
              <n-card title="Paper Information" class="form-card">
                <div class="paper-info">
                  <h3 class="paper-title">{{ review.paperTitle }}</h3>
                  <div class="paper-meta">
                    <p class="authors"><strong>Authors:</strong> {{ review.authors.join(', ') }}</p>
                    <p class="journal"><strong>Journal:</strong> {{ review.journal }}</p>
                    <p class="category"><strong>Category:</strong> {{ review.category }}</p>
                    <p class="deadline"><strong>Deadline:</strong> {{ formatDate(review.deadline) }}</p>
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

              <!-- Review Guidelines -->
              <n-card title="Review Guidelines" class="form-card">
                <div class="guidelines">
                  <div class="guideline-item">
                    <n-icon :component="DocumentTextOutline" class="guideline-icon" />
                    <div class="guideline-content">
                      <h4 class="guideline-title">Be Constructive</h4>
                      <p class="guideline-text">Provide specific, actionable feedback that helps authors improve their work</p>
                    </div>
                  </div>
                  
                  <div class="guideline-item">
                    <n-icon :component="ChatbubbleEllipsesOutline" class="guideline-icon" />
                    <div class="guideline-content">
                      <h4 class="guideline-title">Be Professional</h4>
                      <p class="guideline-text">Maintain a respectful and professional tone throughout your review</p>
                    </div>
                  </div>
                  
                  <div class="guideline-item">
                    <n-icon :component="TimeOutline" class="guideline-icon" />
                    <div class="guideline-content">
                      <h4 class="guideline-title">Be Thorough</h4>
                      <p class="guideline-text">Evaluate all aspects of the paper including methodology, results, and writing</p>
                    </div>
                  </div>
                </div>
              </n-card>

              <!-- Comments for Editor -->
              <n-card title="Comments for Editor" class="form-card">
                <n-form-item label="Confidential Comments" path="editorComments">
                  <n-input
                    v-model:value="reviewForm.editorComments"
                    type="textarea"
                    placeholder="Any confidential comments for the editor (not shared with authors)..."
                    :rows="4"
                    :maxlength="500"
                    show-count
                  />
                </n-form-item>
              </n-card>

              <!-- Review Progress -->
              <n-card title="Review Progress" class="form-card">
                <div class="progress-section">
                  <div class="progress-item">
                    <span class="progress-label">Overall Assessment</span>
                    <n-progress 
                      :percentage="getSectionProgress('overall')"
                      :status="getSectionStatus('overall')"
                      :show-indicator="false"
                      class="progress-bar"
                    />
                  </div>
                  
                  <div class="progress-item">
                    <span class="progress-label">Detailed Evaluation</span>
                    <n-progress 
                      :percentage="getSectionProgress('evaluation')"
                      :status="getSectionStatus('evaluation')"
                      :show-indicator="false"
                      class="progress-bar"
                    />
                  </div>
                  
                  <div class="progress-item">
                    <span class="progress-label">Comments for Authors</span>
                    <n-progress 
                      :percentage="getSectionProgress('comments')"
                      :status="getSectionStatus('comments')"
                      :show-indicator="false"
                      class="progress-bar"
                    />
                  </div>
                  
                  <div class="progress-item">
                    <span class="progress-label">Editor Comments</span>
                    <n-progress 
                      :percentage="getSectionProgress('editor')"
                      :status="getSectionStatus('editor')"
                      :show-indicator="false"
                      class="progress-bar"
                    />
                  </div>
                </div>
              </n-card>
            </div>
          </div>
        </n-form>
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
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { 
  NCard, NButton, NIcon, NSpin, NEmpty, NForm, NFormItem, NInput, NRate,
  NRadioGroup, NRadio, NSpace, NProgress, useMessage
} from 'naive-ui'
import {
  ArrowBackOutline, CreateOutline, SaveOutline, CheckmarkOutline, DownloadOutline,
  DocumentTextOutline, ChatbubbleEllipsesOutline, TimeOutline
} from '@vicons/ionicons5'
import axios from 'axios'
import dayjs from 'dayjs'

const router = useRouter()
const route = useRoute()
const message = useMessage()

// Reactive data
const isLoading = ref(true)
const isSaving = ref(false)
const isSubmitting = ref(false)
const review = ref(null)
const formRef = ref(null)

// Form data
const reviewForm = ref({
  overallRating: 0,
  recommendation: '',
  originality: 0,
  methodology: 0,
  results: 0,
  writing: 0,
  relevance: 0,
  summary: '',
  strengths: '',
  weaknesses: '',
  minorComments: '',
  editorComments: ''
})

// Form validation rules
const formRules = {
  overallRating: [
    { 
      required: true, 
      message: 'Please provide an overall rating', 
      trigger: 'change',
      validator: (rule, value) => {
        if (!value || value === 0) {
          return new Error('Please provide an overall rating')
        }
        return true
      }
    }
  ],
  recommendation: [
    { 
      required: true, 
      message: 'Please select a recommendation', 
      trigger: 'change',
      validator: (rule, value) => {
        if (!value || value === '') {
          return new Error('Please select a recommendation')
        }
        return true
      }
    }
  ],
  summary: [
    { required: true, message: 'Please provide a summary', trigger: 'blur' },
    { min: 50, message: 'Summary must be at least 50 characters', trigger: 'blur' }
  ],
  strengths: [
    { required: true, message: 'Please identify strengths', trigger: 'blur' },
    { min: 30, message: 'Strengths must be at least 30 characters', trigger: 'blur' }
  ],
  weaknesses: [
    { required: true, message: 'Please identify weaknesses and provide suggestions', trigger: 'blur' },
    { min: 30, message: 'Weaknesses must be at least 30 characters', trigger: 'blur' }
  ]
}

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
    status: "In Progress",
    urgency: "High",
    assignedAt: "2024-02-10",
    deadline: "2024-02-25",
    estimatedHours: 8,
    reviewId: "REV-2024-001"
  }
]

// Computed properties
const getSectionProgress = (section) => {
  switch (section) {
    case 'overall':
      return reviewForm.value.overallRating > 0 && reviewForm.value.recommendation ? 100 : 0
    case 'evaluation':
      const evaluationFields = ['originality', 'methodology', 'results', 'writing', 'relevance']
      const completedFields = evaluationFields.filter(field => reviewForm.value[field] > 0).length
      return (completedFields / evaluationFields.length) * 100
    case 'comments':
      const commentFields = ['summary', 'strengths', 'weaknesses']
      const completedComments = commentFields.filter(field => reviewForm.value[field].length > 0).length
      return (completedComments / commentFields.length) * 100
    case 'editor':
      return reviewForm.value.editorComments.length > 0 ? 100 : 0
    default:
      return 0
  }
}

const getSectionStatus = (section) => {
  const progress = getSectionProgress(section)
  if (progress === 100) return 'success'
  if (progress > 0) return 'info'
  return 'default'
}

// Methods
const formatDate = (date) => {
  return dayjs(date).format('MMM DD, YYYY')
}

const goBack = () => {
  router.push(`/reviews/${route.params.review_id}`)
}

const downloadPaper = () => {
  message.success(`Downloading: ${review.value.paperTitle}`)
  // TODO: Implement download
}

const saveDraft = async () => {
  try {
    isSaving.value = true
    
    // Calculate progress based on form completion
    const progress = calculateProgress()
    
    // Prepare the review content
    const reviewContent = {
      overallRating: reviewForm.value.overallRating,
      recommendation: reviewForm.value.recommendation,
      originality: reviewForm.value.originality,
      methodology: reviewForm.value.methodology,
      results: reviewForm.value.results,
      writing: reviewForm.value.writing,
      relevance: reviewForm.value.relevance,
      summary: reviewForm.value.summary,
      strengths: reviewForm.value.strengths,
      weaknesses: reviewForm.value.weaknesses,
      minorComments: reviewForm.value.minorComments,
      editorComments: reviewForm.value.editorComments
    }
    
    // Call backend API to save draft
    const response = await fetch(`http://localhost:3000/api/reviews/${route.params.review_id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        review_content: JSON.stringify(reviewContent),
        progress: progress,
        is_draft_save: true // This will trigger status change from Pending to In Progress
      })
    })
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }
    
    const updatedReview = await response.json()
    console.log('Draft saved successfully:', updatedReview)
    
    message.success('Draft saved successfully')
  } catch (error) {
    console.error('Failed to save draft:', error)
    message.error('Failed to save draft')
  } finally {
    isSaving.value = false
  }
}

// Function to calculate progress based on form completion
const calculateProgress = () => {
  let completedSections = 0
  let totalSections = 4
  
  // Overall Assessment (25%)
  if (reviewForm.value.overallRating > 0 && reviewForm.value.recommendation) {
    completedSections += 1
  }
  
  // Detailed Evaluation (25%)
  const evaluationFields = ['originality', 'methodology', 'results', 'writing', 'relevance']
  const completedEvaluations = evaluationFields.filter(field => reviewForm.value[field] > 0).length
  if (completedEvaluations >= 3) { // At least 3 out of 5 evaluations
    completedSections += 1
  }
  
  // Comments for Authors (25%)
  if (reviewForm.value.summary && reviewForm.value.strengths && reviewForm.value.weaknesses) {
    completedSections += 1
  }
  
  // Editor Comments (25%) - Optional, so we count it as completed if any content exists
  if (reviewForm.value.editorComments || completedSections >= 3) {
    completedSections += 1
  }
  
  return Math.round((completedSections / totalSections) * 100)
}

const submitReview = async () => {
  try {
    // Debug: Log form values before validation
    console.log('Form values before validation:', reviewForm.value)
    console.log('Overall rating value:', reviewForm.value.overallRating, 'Type:', typeof reviewForm.value.overallRating)
    
    await formRef.value?.validate()
    isSubmitting.value = true
    
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 2000))
    
    // Update the review status in the reviews list
    updateReviewsList()
    
    // TODO: Implement actual submit logic
    message.success('Review submitted successfully')
    
    // Navigate back to review details
    router.push(`/reviews/${route.params.review_id}`)
  } catch (error) {
    console.error('Validation failed:', error)
    console.log('Form validation errors:', error)
    message.error('Please complete all required fields')
  } finally {
    isSubmitting.value = false
  }
}

// Watch for form changes to enable auto-save
watch(reviewForm, () => {
  // TODO: Implement auto-save logic
}, { deep: true })

// Watch for overallRating changes specifically
watch(() => reviewForm.value.overallRating, (newValue, oldValue) => {
  console.log('Overall rating changed from', oldValue, 'to', newValue)
}, { immediate: true })

// Function to update the reviews list when a review is submitted
const updateReviewsList = () => {
  try {
    // Get current reviews from localStorage or use default mock data
    const currentReviews = JSON.parse(localStorage.getItem('reviewsData') || JSON.stringify([
      {
        id: 1,
        paperTitle: "Advanced Quantum Cryptography for Secure Communications",
        authors: ["Dr. Alice Johnson", "Prof. Bob Smith", "Dr. Charlie Brown"],
        abstract: "This paper presents novel approaches to quantum cryptography, focusing on enhanced security protocols for next-generation communication systems.",
        keywords: ["Quantum Cryptography", "Security", "Communications", "Protocols", "Quantum Computing"],
        category: "Computer Science",
        journal: "Journal of Quantum Computing",
        status: "Pending",
        urgency: "High",
        assignedAt: "2024-02-10",
        deadline: "2024-02-25",
        estimatedHours: 8,
        reviewId: "REV-2024-001"
      },
      {
        id: 2,
        paperTitle: "Machine Learning Applications in Climate Modeling",
        authors: ["Dr. Emma Wilson", "Prof. David Lee"],
        abstract: "We explore the integration of machine learning techniques with traditional climate modeling approaches to improve prediction accuracy and reduce computational costs.",
        keywords: ["Machine Learning", "Climate Modeling", "Prediction", "Environmental Science", "AI"],
        category: "Environmental Science",
        journal: "Climate Science Review",
        status: "In Progress",
        urgency: "Medium",
        assignedAt: "2024-02-01",
        deadline: "2024-02-28",
        estimatedHours: 12,
        reviewId: "REV-2024-002",
        progress: 60
      },
      {
        id: 3,
        paperTitle: "Blockchain-Based Supply Chain Transparency",
        authors: ["Prof. Sarah Chen", "Dr. Michael Zhang"],
        abstract: "This study examines the implementation of blockchain technology for enhancing transparency and traceability in global supply chain management.",
        keywords: ["Blockchain", "Supply Chain", "Transparency", "Traceability", "Management"],
        category: "Computer Science",
        journal: "Blockchain Technology Review",
        status: "Under Review",
        urgency: "Low",
        assignedAt: "2024-01-20",
        deadline: "2024-03-05",
        estimatedHours: 10,
        reviewId: "REV-2024-003",
        submittedAt: "2024-02-15"
      },
      {
        id: 4,
        paperTitle: "Gene Editing Ethics in Modern Medicine",
        authors: ["Dr. Lisa Garcia", "Prof. James Wilson", "Dr. Anna Lee"],
        abstract: "An ethical analysis of gene editing technologies in medical treatments, examining the moral implications and regulatory frameworks needed for responsible implementation.",
        keywords: ["Gene Editing", "Ethics", "Medicine", "Regulation", "Bioethics"],
        category: "Bioethics",
        journal: "Medical Ethics Quarterly",
        status: "Completed",
        urgency: "Medium",
        assignedAt: "2024-01-15",
        deadline: "2024-02-15",
        estimatedHours: 15,
        reviewId: "REV-2024-004",
        completedAt: "2024-02-10",
        rating: 4.5
      },
      {
        id: 5,
        paperTitle: "Sustainable Energy Storage Solutions",
        authors: ["Dr. Robert Green", "Prof. Maria Rodriguez"],
        abstract: "Investigation of novel materials and technologies for sustainable energy storage, focusing on environmental impact and economic viability.",
        keywords: ["Energy Storage", "Sustainability", "Materials Science", "Environment", "Economics"],
        category: "Environmental Science",
        journal: "Sustainable Energy Journal",
        status: "Revision Requested",
        urgency: "High",
        assignedAt: "2024-01-25",
        deadline: "2024-02-20",
        estimatedHours: 6,
        reviewId: "REV-2024-005",
        revisionRequested: true
      }
    ]))

    // Find and update the current review
    const reviewId = parseInt(route.params.review_id)
    const reviewIndex = currentReviews.findIndex(r => r.id === reviewId)
    
    if (reviewIndex !== -1) {
      // Update the review status and add completion data
      currentReviews[reviewIndex] = {
        ...currentReviews[reviewIndex],
        status: "Completed",
        completedAt: new Date().toISOString().split('T')[0],
        submittedAt: new Date().toISOString().split('T')[0],
        startedAt: currentReviews[reviewIndex].startedAt || new Date().toISOString().split('T')[0],
        rating: reviewForm.value.overallRating,
        recommendation: reviewForm.value.recommendation,
        timeSpent: "8 hours", // Mock time spent
        quality: 5 // Mock quality rating
      }
      
      // Save updated reviews to localStorage
      localStorage.setItem('reviewsData', JSON.stringify(currentReviews))
      localStorage.setItem('updatedReviews', JSON.stringify(currentReviews))
      
      console.log('Updated review status to Completed:', currentReviews[reviewIndex])
    }
  } catch (error) {
    console.error('Failed to update reviews list:', error)
  }
}

// Load review data from backend API
const loadReview = async () => {
  isLoading.value = true
  try {
    const reviewId = route.params.review_id
    console.log('Loading review for form with ID:', reviewId)
    
    // Call backend API to get review details
    const response = await axios.get(`http://localhost:3000/api/reviews/${reviewId}`)
    console.log('Review form response:', response.data)
    
    review.value = response.data
    
    if (!review.value) {
      throw new Error('Review not found')
    }
    
    // Load existing review content if available
    if (review.value.reviewContent) {
      try {
        const existingContent = JSON.parse(review.value.reviewContent)
        console.log('Loading existing review content:', existingContent)
        
        // Populate form with existing data
        reviewForm.value = {
          overallRating: existingContent.overallRating || 0,
          recommendation: existingContent.recommendation || '',
          originality: existingContent.originality || 0,
          methodology: existingContent.methodology || 0,
          results: existingContent.results || 0,
          writing: existingContent.writing || 0,
          relevance: existingContent.relevance || 0,
          summary: existingContent.summary || '',
          strengths: existingContent.strengths || '',
          weaknesses: existingContent.weaknesses || '',
          minorComments: existingContent.minorComments || '',
          editorComments: existingContent.editorComments || ''
        }
        
        console.log('Form populated with existing data:', reviewForm.value)
      } catch (parseError) {
        console.error('Failed to parse existing review content:', parseError)
      }
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
.review-form-page {
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

.review-form-content {
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

.review-form-container {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.form-grid {
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

.form-card {
  background: #161b22;
  border: 1px solid #30363d;
}

.paper-info {
  display: flex;
  flex-direction: column;
  gap: 16px;
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
  gap: 8px;
}

.paper-meta p {
  font-size: 0.875rem;
  color: #8b949e;
  margin: 0;
}

.paper-actions {
  margin-top: 8px;
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

.progress-section {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.progress-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.progress-label {
  font-size: 0.875rem;
  font-weight: 500;
  color: #8b949e;
}

.progress-bar {
  width: 100%;
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

:deep(.n-form-item-label) {
  color: #c9d1d9;
}

:deep(.n-input) {
  background-color: #21262d;
  border-color: #30363d;
}

:deep(.n-input:focus) {
  border-color: #58a6ff;
}

:deep(.n-rate) {
  color: #58a6ff;
}

:deep(.n-radio) {
  color: #c9d1d9;
}

:deep(.n-progress .n-progress-rail) {
  background-color: #30363d;
}

/* Responsive design */
@media (max-width: 1200px) {
  .form-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .review-form-content {
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
