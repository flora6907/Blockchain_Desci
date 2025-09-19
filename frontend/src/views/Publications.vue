<template>
  <div class="publications-page">
    <!-- Page Header -->
    <div class="page-header">
      <div class="header-content">
        <div class="header-actions">
          <n-button @click="refreshPublications">
            <template #icon>
              <n-icon :component="RefreshOutline" />
            </template>
            Refresh
          </n-button>
          <n-button type="primary" @click="importPaper">
            <template #icon>
              <n-icon :component="DownloadOutline" />
            </template>
            Import Published Paper
          </n-button>
          <n-button type="primary" @click="startSubmission">
            <template #icon>
              <n-icon :component="AddOutline" />
            </template>
            Submit New Paper
          </n-button>
        </div>
      </div>
    </div>

    <!-- Statistics -->
    <div class="stats-section">
      <div class="stats-grid">
        <n-card 
          class="stat-card" 
          :class="{ active: selectedStatus === null }"
          hoverable
          @click="handleStatClick(null)"
        >
          <div class="stat-content">
            <div class="stat-icon">
              <n-icon :component="DocumentOutline" />
            </div>
            <div class="stat-info">
              <h3>{{ papers.length }}</h3>
              <p>Total Papers</p>
            </div>
          </div>
        </n-card>

        <n-card 
          class="stat-card" 
          :class="{ active: selectedStatus === 'Published' }"
          hoverable
          @click="handleStatClick('Published')"
        >
          <div class="stat-content">
            <div class="stat-icon published">
              <n-icon :component="CheckmarkCircleOutline" />
            </div>
            <div class="stat-info">
              <h3>{{ publishedCount }}</h3>
              <p>Published</p>
            </div>
          </div>
        </n-card>

        <n-card 
          class="stat-card" 
          :class="{ active: selectedStatus === 'Preprint' }"
          hoverable
          @click="handleStatClick('Preprint')"
        >
          <div class="stat-content">
            <div class="stat-icon preprint">
              <n-icon :component="CloudUploadOutline" />
            </div>
            <div class="stat-info">
              <h3>{{ preprintCount }}</h3>
              <p>Preprint</p>
            </div>
          </div>
        </n-card>

        <n-card 
          class="stat-card" 
          :class="{ active: selectedStatus === 'Under Review' }"
          hoverable
          @click="handleStatClick('Under Review')"
        >
          <div class="stat-content">
            <div class="stat-icon under-review">
              <n-icon :component="TimeOutline" />
            </div>
            <div class="stat-info">
              <h3>{{ reviewingCount }}</h3>
              <p>Under Review</p>
            </div>
          </div>
        </n-card>

        <n-card 
          class="stat-card" 
          :class="{ active: selectedStatus === 'Draft' }"
          hoverable
          @click="handleStatClick('Draft')"
        >
          <div class="stat-content">
            <div class="stat-icon draft">
              <n-icon :component="CreateOutline" />
            </div>
            <div class="stat-info">
              <h3>{{ draftCount }}</h3>
              <p>Draft</p>
            </div>
          </div>
        </n-card>
      </div>
    </div>

    <!-- Filters -->
    <div class="filters-section">
      <div class="filter-container">
        <n-input
          v-model:value="searchQuery"
          placeholder="Search papers by title, authors, or keywords..."
          clearable
          class="search-input"
        >
          <template #prefix>
            <n-icon :component="SearchOutline" />
          </template>
        </n-input>
        
        <n-select
          v-model:value="selectedStatus"
          :options="statusOptions"
          placeholder="Status"
          clearable
          class="filter-select"
        />
        
        <n-select
          v-model:value="selectedCategory"
          :options="categoryOptions"
          placeholder="Category"
          clearable
          class="filter-select"
        />
        
        <n-select
          v-model:value="sortBy"
          :options="sortOptions"
          placeholder="Sort by"
          class="filter-select"
        />
      </div>
    </div>

    <!-- Papers List -->
    <div class="papers-section">
      <div v-if="loading" class="empty-state">
        <n-empty description="Loading publications..." size="large">
          <template #extra>
            <n-button type="primary" @click="startSubmission">
              Submit Your First Paper
            </n-button>
          </template>
        </n-empty>
      </div>
      
      <div v-else-if="error" class="empty-state">
        <n-empty :description="error" size="large">
          <template #extra>
            <n-button type="primary" @click="startSubmission">
              Submit Your First Paper
            </n-button>
          </template>
        </n-empty>
      </div>

      <div v-else-if="filteredPapers.length === 0" class="empty-state">
        <n-empty description="No papers found" size="large">
          <template #extra>
            <n-button type="primary" @click="startSubmission">
              Submit Your First Paper
            </n-button>
          </template>
        </n-empty>
      </div>
      
      <div v-else class="papers-list">
        <div
          v-for="paper in filteredPapers"
          :key="paper.id"
          class="paper-card"
          @click="viewPaper(paper)"
        >
          <div class="paper-header">
            <div class="paper-title-section">
              <h3 class="paper-title">{{ paper.title }}</h3>
              <div class="paper-meta">
                <span class="paper-authors">{{ paper.authors.join(', ') }}</span>
                <span class="paper-date">{{ formatDate(paper.createdAt) }}</span>
              </div>
            </div>
            <div class="paper-status-section">
              <n-tag 
                :type="getStatusType(paper.status)" 
                size="medium"
                class="status-tag"
              >
                {{ paper.status }}
              </n-tag>
            </div>
          </div>
          
          <div class="paper-content">
            <p class="paper-abstract">{{ paper.abstract }}</p>
            
            <div class="paper-tags">
              <n-tag 
                v-for="tag in paper.keywords.slice(0, 3)" 
                :key="tag" 
                size="small"
                class="keyword-tag"
              >
                {{ tag }}
              </n-tag>
              <span v-if="paper.keywords.length > 3" class="more-keywords">
                +{{ paper.keywords.length - 3 }} more
              </span>
            </div>
          </div>
          
          <div class="paper-actions">
            <div class="paper-progress">
              <div class="progress-info">
                <span class="progress-label">{{ getProgressLabel(paper.status) }}</span>
                <n-progress 
                  :percentage="getProgressPercentage(paper.status)"
                  :status="getProgressStatus(paper.status)"
                  :show-indicator="false"
                  class="progress-bar"
                />
              </div>
            </div>
            
            <div class="action-buttons">
              <n-button 
                size="small" 
                @click.stop="previewPaper(paper)"
              >
                <template #icon>
                  <n-icon :component="EyeOutline" />
                </template>
                Preview
              </n-button>
              
              <n-dropdown
                :options="getActionOptions(paper)"
                @select="handleAction"
                trigger="click"
              >
                <n-button size="small">
                  <template #icon>
                    <n-icon :component="EllipsisHorizontalOutline" />
                  </template>
                </n-button>
              </n-dropdown>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Pagination -->
    <div v-if="totalPages > 1" class="pagination-container">
      <n-pagination
        v-model:page="currentPage"
        :page-count="totalPages"
        :page-size="pageSize"
        show-size-picker
        :page-sizes="[5, 10, 20, 50]"
        @update:page-size="handlePageSizeChange"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { 
  NButton, NInput, NSelect, NGrid, NGi, NStatistic, NTag, NIcon, 
  NPagination, NEmpty, NProgress, NDropdown, useMessage 
} from 'naive-ui'
import {
  AddOutline, SearchOutline, EyeOutline, 
  EllipsisHorizontalOutline, DocumentOutline, TrashOutline,
  ShareOutline, DownloadOutline, RefreshOutline,
  CheckmarkCircleOutline, CloudUploadOutline, TimeOutline, CreateOutline
} from '@vicons/ionicons5'
import dayjs from 'dayjs'

const router = useRouter()
const message = useMessage()

// Reactive data
const searchQuery = ref('')
const selectedStatus = ref(null)
const selectedCategory = ref(null)
const sortBy = ref('newest')
const currentPage = ref(1)
const pageSize = ref(6)
const loading = ref(true)
const error = ref(null)
const user = ref(null)

// Real publications data from API
const papers = ref([])

// Load user data and fetch publications
const loadUserAndPublications = async () => {
  try {
    loading.value = true
    
    // Get user from localStorage
    const storedUser = localStorage.getItem('user')
    if (!storedUser) {
      console.error('No user found in localStorage')
      error.value = 'Please log in to view your publications'
      return
    }
    
    user.value = JSON.parse(storedUser)
    
    // Fetch publications for this user
    await fetchPublications()
    
  } catch (err) {
    console.error('Failed to load user and publications:', err)
    error.value = 'Failed to load publication data'
  } finally {
    loading.value = false
  }
}

const fetchPublications = async () => {
  if (!user.value || !user.value.wallet_address) {
    console.error('No user or wallet address available')
    return
  }

  try {
    console.log('🔍 Fetching publications for user:', user.value.wallet_address)
    const response = await fetch(`http://localhost:3000/api/publications/user/${user.value.wallet_address}`)
    
    if (!response.ok) {
      if (response.status === 404) {
        // User not found or no publications - this is okay
        papers.value = []
        console.log('📭 No publications found for user')
        return
      }
      throw new Error(`HTTP error! status: ${response.status}`)
    }
    
    const publicationsData = await response.json()
    console.log('📚 Raw publications data received:', publicationsData)
    console.log('📊 Number of publications:', publicationsData.length)
    console.log('👤 Current user wallet address:', user.value.wallet_address)
    
    // Log author details for each publication to verify filtering
    publicationsData.forEach((pub, index) => {
      console.log(`📄 Publication ${index + 1}:`, {
        title: pub.title,
        author_wallet_address: pub.author_wallet_address,
        current_user_wallet: user.value.wallet_address,
        wallet_match: pub.author_wallet_address === user.value.wallet_address,
        wallet_comparison: {
          author_length: pub.author_wallet_address?.length,
          user_length: user.value.wallet_address?.length,
          both_truthy: !!(pub.author_wallet_address && user.value.wallet_address)
        }
      })
    })
    
    // Debug: Log the raw data and user info
    console.log('🔍 DEBUG: User info:', user.value)
    console.log('🔍 DEBUG: First few publications:', publicationsData.slice(0, 3))
    
    // Filter to ensure we only show publications that truly belong to this user
    const userPublications = publicationsData.filter(pub => {
      const isUsersPublication = pub.author_wallet_address === user.value.wallet_address
      console.log('🔍 Checking publication:', {
        title: pub.title,
        expected_author: user.value.wallet_address,
        actual_author: pub.author_wallet_address,
        match: isUsersPublication
      })
      if (!isUsersPublication) {
        console.warn('⚠️ Found publication with different author:', {
          title: pub.title,
          expected_author: user.value.wallet_address,
          actual_author: pub.author_wallet_address
        })
      }
      return isUsersPublication
    })
    
    console.log(`✅ Filtered to ${userPublications.length} publications belonging to current user`)
    
    // TEMPORARY: If filtering results in 0 publications, use all publications for debugging
    const finalPublications = userPublications.length > 0 ? userPublications : publicationsData
    console.log(`🛠️ Using ${finalPublications.length} publications (${userPublications.length > 0 ? 'filtered' : 'unfiltered for debugging'})`)
    
    // Transform data to match the expected format
    papers.value = finalPublications.map(publication => ({
      id: publication.id,
      title: publication.title,
      authors: publication.authors,
      abstract: publication.abstract || 'No abstract provided',
      keywords: publication.keywords || [],
      category: publication.category || 'Other',
      status: publication.status,
      createdAt: publication.createdAt,
      publishedAt: publication.publishedAt,
      submittedAt: publication.submittedAt,
      lastModified: publication.lastModified,
      doi: publication.doi,
      citationCount: publication.citationCount || 0,
      downloadCount: publication.downloadCount || 0,
      reviewDeadline: publication.reviewDeadline,
      peerReviewId: publication.peerReviewId,
      reviewComments: publication.reviewComments,
      preprintServer: publication.preprintServer
    }))
    
    error.value = null
  } catch (err) {
    console.error('Failed to fetch publications:', err)
    error.value = 'Failed to load publications'
    // Set empty array as fallback
    papers.value = []
  }
}

// Options
const statusOptions = [
  { label: 'All Status', value: null },
  { label: 'Draft', value: 'Draft' },
  { label: 'Under Review', value: 'Under Review' },
  { label: 'Revision Required', value: 'Revision Required' },
  { label: 'Published', value: 'Published' },
  { label: 'Preprint', value: 'Preprint' }
]

const categoryOptions = [
  { label: 'All Categories', value: null },
  { label: 'Computer Science', value: 'Computer Science' },
  { label: 'Environmental Science', value: 'Environmental Science' },
  { label: 'Biotechnology', value: 'Biotechnology' },
  { label: 'Marine Biology', value: 'Marine Biology' },
  { label: 'Physics', value: 'Physics' },
  { label: 'Chemistry', value: 'Chemistry' }
]

const sortOptions = [
  { label: 'Newest First', value: 'newest' },
  { label: 'Oldest First', value: 'oldest' },
  { label: 'Title A-Z', value: 'title_asc' },
  { label: 'Title Z-A', value: 'title_desc' },
  { label: 'Status', value: 'status' }
]

// Computed properties
const publishedCount = computed(() => 
  papers.value.filter(p => p.status === 'Published').length
)

const preprintCount = computed(() => 
  papers.value.filter(p => p.status === 'Preprint').length
)

const reviewingCount = computed(() => 
  papers.value.filter(p => p.status === 'Under Review' || p.status === 'Revision Required').length
)

const draftCount = computed(() => 
  papers.value.filter(p => p.status === 'Draft').length
)

const filteredPapers = computed(() => {
  let filtered = papers.value

  // Search filter
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(paper => 
      paper.title.toLowerCase().includes(query) ||
      paper.authors.some(author => author.toLowerCase().includes(query)) ||
      paper.keywords.some(keyword => keyword.toLowerCase().includes(query)) ||
      paper.abstract.toLowerCase().includes(query)
    )
  }

  // Status filter
  if (selectedStatus.value) {
    filtered = filtered.filter(paper => paper.status === selectedStatus.value)
  }

  // Category filter
  if (selectedCategory.value) {
    filtered = filtered.filter(paper => paper.category === selectedCategory.value)
  }

  // Sorting
  filtered = filtered.sort((a, b) => {
    switch (sortBy.value) {
      case 'newest':
        return new Date(b.createdAt) - new Date(a.createdAt)
      case 'oldest':
        return new Date(a.createdAt) - new Date(b.createdAt)
      case 'title_asc':
        return a.title.localeCompare(b.title)
      case 'title_desc':
        return b.title.localeCompare(a.title)
      case 'status':
        return a.status.localeCompare(b.status)
      default:
        return 0
    }
  })

  return filtered
})

const paginatedPapers = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return filteredPapers.value.slice(start, end)
})

const totalPages = computed(() => {
  return Math.ceil(filteredPapers.value.length / pageSize.value)
})

// Methods
const formatDate = (date) => {
  return dayjs(date).format('MMM DD, YYYY')
}

const getStatusType = (status) => {
  switch (status) {
    case 'Published': return 'success'
    case 'Preprint': return 'info'
    case 'Under Review': return 'warning'
    case 'Revision Required': return 'error'
    case 'Draft': return 'default'
    default: return 'default'
  }
}

const getProgressLabel = (status) => {
  switch (status) {
    case 'Draft': return 'In Progress'
    case 'Under Review': return 'Under Review'
    case 'Revision Required': return 'Needs Revision'
    case 'Published': return 'Published'
    case 'Preprint': return 'Published as Preprint'
    default: return status
  }
}

const getProgressPercentage = (status) => {
  switch (status) {
    case 'Draft': return 25
    case 'Under Review': return 60
    case 'Revision Required': return 40
    case 'Published': return 100
    case 'Preprint': return 80
    default: return 0
  }
}

const getProgressStatus = (status) => {
  switch (status) {
    case 'Published': return 'success'
    case 'Revision Required': return 'error'
    case 'Under Review': return 'warning'
    default: return 'info'
  }
}



const getActionOptions = (paper) => {
  const options = [
    {
      label: 'View Details',
      key: `view-${paper.id}`,
      icon: () => h(NIcon, null, { default: () => h(DocumentOutline) })
    },
    {
      label: 'Share',
      key: `share-${paper.id}`,
      icon: () => h(NIcon, null, { default: () => h(ShareOutline) })
    }
  ]

  if (paper.status === 'Published' || paper.status === 'Preprint') {
    options.push({
      label: 'Download',
      key: `download-${paper.id}`,
      icon: () => h(NIcon, null, { default: () => h(DownloadOutline) })
    })
  }

  if (paper.status === 'Draft') {
    options.push({
      label: 'Delete',
      key: `delete-${paper.id}`,
      icon: () => h(NIcon, null, { default: () => h(TrashOutline) })
    })
  }

  return options
}

const handlePageSizeChange = (newPageSize) => {
  pageSize.value = newPageSize
  currentPage.value = 1
}

const refreshPublications = () => {
  loadUserAndPublications()
}

const startSubmission = () => {
  router.push('/papers/submit')
}

const importPaper = () => {
  router.push('/papers/import')
}

const viewPaper = (paper) => {
  router.push(`/papers/${paper.id}`)
}



const deletePaper = async (paper) => {
  // TODO: Implement delete functionality with API call
  console.log('Delete paper:', paper.id)
}

const downloadPaper = (paper) => {
  // TODO: Implement download functionality
  console.log('Download paper:', paper.id)
}

const sharePaper = (paper) => {
  // TODO: Implement share functionality
  console.log('Share paper:', paper.id)
}

const previewPaper = (paper) => {
  router.push(`/papers/${paper.id}/preview`)
}

const handleAction = (key) => {
  const [action, paperId] = key.split('-')
  const paper = papers.value.find(p => p.id === parseInt(paperId))
  
  switch (action) {
    case 'view':
      viewPaper(paper)
      break
    case 'share':
      navigator.clipboard.writeText(`${window.location.origin}/papers/${paperId}`)
      message.success('Paper link copied to clipboard!')
      break
    case 'download':
      message.success(`Downloading: ${paper.title}`)
      // TODO: Implement download
      break
    case 'delete':
      // TODO: Implement delete confirmation dialog
      message.info('Delete functionality will be implemented')
      break
  }
}

const handleStatClick = (status) => {
  selectedStatus.value = status
  currentPage.value = 1 // Reset to first page when status changes
}

onMounted(() => {
  loadUserAndPublications()
})
</script>

<style scoped>
.publications-page {
  padding: 24px;
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 32px;
}

.header-content {
  display: flex;
  justify-content: flex-end;
  align-items: flex-start;
  gap: 24px;
}

.header-actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.page-title {
  font-size: 2rem;
  font-weight: 700;
  color: #c9d1d9;
  margin: 0 0 8px 0;
}

.page-description {
  font-size: 1rem;
  color: #8b949e;
  margin: 0;
  line-height: 1.5;
}

.stats-section {
  background: #161b22;
  border: 1px solid #30363d;
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 32px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
}

.stat-card {
  background: #161b22;
  border: 1px solid #30363d;
  border-radius: 12px;
  padding: 24px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.stat-card:hover {
  border-color: #58a6ff;
  box-shadow: 0 4px 16px rgba(88, 166, 255, 0.1);
}

.stat-card.active {
  border-color: #58a6ff;
  box-shadow: 0 4px 16px rgba(88, 166, 255, 0.1);
  background-color: #0d1117; /* Slightly darker background for active */
}

.stat-content {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.stat-icon {
  font-size: 3rem;
  color: #8b949e;
  margin-bottom: 12px;
}

.stat-icon.published {
  color: #238636; /* Green for Published */
}

.stat-icon.preprint {
  color: #007bff; /* Blue for Preprint */
}

.stat-icon.under-review {
  color: #d29922; /* Orange for Under Review */
}

.stat-icon.draft {
  color: #6a737d; /* Gray for Draft */
}

.stat-info h3 {
  font-size: 1.5rem;
  font-weight: 700;
  color: #c9d1d9;
  margin: 0 0 8px 0;
}

.stat-info p {
  font-size: 0.875rem;
  color: #8b949e;
  margin: 0;
}

.filters-section {
  background: #161b22;
  border: 1px solid #30363d;
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 32px;
}

.filter-container {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
  align-items: center;
}

.search-input {
  flex: 1;
  min-width: 300px;
}

.filter-select {
  min-width: 140px;
}

.papers-section {
  margin-bottom: 32px;
}

.empty-state {
  text-align: center;
  padding: 60px 20px;
  background: #161b22;
  border: 1px solid #30363d;
  border-radius: 12px;
}

.papers-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.paper-card {
  background: #161b22;
  border: 1px solid #30363d;
  border-radius: 12px;
  padding: 24px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.paper-card:hover {
  border-color: #58a6ff;
  box-shadow: 0 4px 16px rgba(88, 166, 255, 0.1);
}

.paper-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
  gap: 16px;
}

.paper-title-section {
  flex: 1;
}

.paper-title {
  font-size: 1.25rem;
  font-weight: 600;
  color: #c9d1d9;
  margin: 0 0 8px 0;
  line-height: 1.4;
}

.paper-meta {
  display: flex;
  gap: 16px;
  font-size: 0.875rem;
  color: #8b949e;
}

.paper-status-section {
  flex-shrink: 0;
}

.status-tag {
  font-weight: 500;
}

.paper-content {
  margin-bottom: 20px;
}

.paper-abstract {
  font-size: 0.875rem;
  color: #8b949e;
  line-height: 1.6;
  margin: 0 0 16px 0;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.paper-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
}

.keyword-tag {
  font-size: 0.75rem;
}

.more-keywords {
  font-size: 0.75rem;
  color: #8b949e;
}

.paper-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
}

.paper-progress {
  flex: 1;
}

.progress-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.progress-label {
  font-size: 0.75rem;
  color: #8b949e;
  font-weight: 500;
}

.progress-bar {
  width: 100%;
  max-width: 200px;
}

.action-buttons {
  display: flex;
  gap: 8px;
  flex-shrink: 0;
}

.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 32px;
}

/* Dark theme adjustments */
:deep(.n-card) {
  background-color: #161b22;
  border-color: #30363d;
}

:deep(.n-input) {
  background-color: #0d1117;
  border-color: #30363d;
}

:deep(.n-select) {
  background-color: #0d1117;
}

:deep(.n-statistic .n-statistic-value) {
  color: #c9d1d9;
}

:deep(.n-statistic .n-statistic-label) {
  color: #8b949e;
}

:deep(.n-progress .n-progress-rail) {
  background-color: #30363d;
}
</style> 