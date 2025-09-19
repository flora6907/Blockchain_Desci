<template>
  <div class="paper-preview-page">
    <div v-if="isLoading" class="loading-container">
      <n-spin size="large">
        <template #description>Loading paper preview...</template>
      </n-spin>
    </div>
    
    <div v-else-if="paper" class="paper-preview-content">
      <!-- Preview Header -->
      <div class="preview-header">
        <div class="header-content">
          <div class="preview-badge">
            <n-tag type="info" size="large">
              <template #icon>
                <n-icon :component="EyeOutline" />
              </template>
              Preview Mode
            </n-tag>
          </div>
          <h1 class="page-title">Paper Preview</h1>
          <p class="page-description">Review your paper as it will appear when published</p>
        </div>
        <div class="header-actions">
          <n-button @click="goBack">
            <template #icon>
              <n-icon :component="ArrowBackOutline" />
            </template>
            Back to Edit
          </n-button>
          <n-button type="primary" @click="proceedToPublish">
            <template #icon>
              <n-icon :component="CheckmarkOutline" />
            </template>
            Proceed to Publish
          </n-button>
        </div>
      </div>

      <!-- Paper Content -->
      <div class="paper-content">
        <!-- Paper Header -->
        <div class="paper-header">
          <div class="paper-title-section">
            <h1 class="paper-title">{{ paper.title }}</h1>
            <div class="paper-meta">
              <div class="authors">
                <span v-for="(author, index) in paper.authors" :key="index" class="author">
                  {{ author.name }}{{ author.affiliation ? ` (${author.affiliation})` : '' }}{{ index < paper.authors.length - 1 ? ', ' : '' }}
                </span>
              </div>
              <div class="meta-info">
                <span>{{ formatDate(paper.createdAt) }}</span>
                <span v-if="paper.doi">DOI: {{ paper.doi }}</span>
                <span>Category: {{ paper.category }}</span>
              </div>
            </div>
          </div>
          <div class="paper-status-section">
            <n-tag :type="getStatusType(paper.status)" size="large">
              {{ paper.status }}
            </n-tag>
          </div>
        </div>

        <!-- Paper Content Grid -->
        <div class="content-grid">
          <!-- Left Column -->
          <div class="left-column">
            <!-- Abstract -->
            <n-card title="Abstract" class="content-card">
              <p class="abstract-text">{{ paper.abstract }}</p>
            </n-card>

            <!-- Keywords -->
            <n-card title="Keywords" class="content-card">
              <div class="keywords-container">
                <n-tag v-for="keyword in paper.keywords" :key="keyword" size="medium">
                  {{ keyword }}
                </n-tag>
              </div>
            </n-card>

            <!-- Funding Information -->
            <n-card v-if="paper.funding" title="Funding Information" class="content-card">
              <p class="funding-text">{{ paper.funding }}</p>
            </n-card>

            <!-- Paper Content Preview -->
            <n-card title="Paper Content" class="content-card">
              <div class="paper-content-preview">
                <div class="content-section">
                  <h3>1. Introduction</h3>
                  <p>This section provides an overview of the research topic and establishes the context for the study. The introduction outlines the problem statement, research objectives, and the significance of the work.</p>
                </div>
                <div class="content-section">
                  <h3>2. Related Work</h3>
                  <p>A comprehensive review of existing literature and related research in the field. This section positions the current work within the broader research landscape and identifies gaps that this study addresses.</p>
                </div>
                <div class="content-section">
                  <h3>3. Methodology</h3>
                  <p>Detailed description of the research methodology, including data collection methods, experimental design, and analytical approaches used in the study.</p>
                </div>
                <div class="content-section">
                  <h3>4. Results</h3>
                  <p>Presentation and analysis of the research findings, including statistical results, experimental outcomes, and key discoveries.</p>
                </div>
                <div class="content-section">
                  <h3>5. Discussion</h3>
                  <p>Interpretation of the results, discussion of implications, limitations of the study, and suggestions for future research directions.</p>
                </div>
                <div class="content-section">
                  <h3>6. Conclusion</h3>
                  <p>Summary of the main findings, contributions to the field, and final remarks on the significance of the research.</p>
                </div>
              </div>
            </n-card>
          </div>

          <!-- Right Column -->
          <div class="right-column">
            <!-- Paper Statistics -->
            <n-card title="Statistics" class="content-card">
              <n-grid :cols="2" :x-gap="16" :y-gap="16">
                <n-gi>
                  <n-statistic label="Views" :value="paper.views || 0" />
                </n-gi>
                <n-gi>
                  <n-statistic label="Downloads" :value="paper.downloads || 0" />
                </n-gi>
                <n-gi>
                  <n-statistic label="Citations" :value="paper.citations || 0" />
                </n-gi>
                <n-gi>
                  <n-statistic label="Shares" :value="paper.shares || 0" />
                </n-gi>
              </n-grid>
            </n-card>

            <!-- Publication Info -->
            <n-card title="Publication Details" class="content-card">
              <div class="info-list">
                <div class="info-item">
                  <span class="label">Status:</span>
                  <n-tag :type="getStatusType(paper.status)">{{ paper.status }}</n-tag>
                </div>
                <div v-if="paper.venue" class="info-item">
                  <span class="label">Venue:</span>
                  <span>{{ paper.venue }}</span>
                </div>
                <div v-if="paper.publishedAt" class="info-item">
                  <span class="label">Published:</span>
                  <span>{{ formatDate(paper.publishedAt) }}</span>
                </div>
                <div class="info-item">
                  <span class="label">License:</span>
                  <span>{{ getLicenseName(paper.license) }}</span>
                </div>
                <div v-if="paper.peerReviewId" class="info-item">
                  <span class="label">Review ID:</span>
                  <span>{{ paper.peerReviewId }}</span>
                </div>
              </div>
            </n-card>

            <!-- Preview Actions -->
            <n-card title="Preview Actions" class="content-card">
              <n-space direction="vertical" size="small">
                <n-button block @click="downloadPreview">
                  <template #icon>
                    <n-icon :component="DownloadOutline" />
                  </template>
                  Download Preview
                </n-button>
                <n-button block @click="sharePreview">
                  <template #icon>
                    <n-icon :component="ShareOutline" />
                  </template>
                  Share Preview
                </n-button>
                <n-button block @click="printPreview">
                  <template #icon>
                    <n-icon :component="PrintOutline" />
                  </template>
                  Print Preview
                </n-button>
              </n-space>
            </n-card>

            <!-- Publishing Checklist -->
            <n-card title="Publishing Checklist" class="content-card">
              <div class="checklist">
                <div class="checklist-item" :class="{ completed: paper.title }">
                  <n-icon :component="paper.title ? CheckmarkCircleOutline : CloseCircleOutline" />
                  <span>Title and Abstract</span>
                </div>
                <div class="checklist-item" :class="{ completed: paper.authors?.length > 0 }">
                  <n-icon :component="paper.authors?.length > 0 ? CheckmarkCircleOutline : CloseCircleOutline" />
                  <span>Authors and Affiliations</span>
                </div>
                <div class="checklist-item" :class="{ completed: paper.keywords?.length > 0 }">
                  <n-icon :component="paper.keywords?.length > 0 ? CheckmarkCircleOutline : CloseCircleOutline" />
                  <span>Keywords</span>
                </div>
                <div class="checklist-item" :class="{ completed: paper.category }">
                  <n-icon :component="paper.category ? CheckmarkCircleOutline : CloseCircleOutline" />
                  <span>Category</span>
                </div>
                <div class="checklist-item" :class="{ completed: paper.license }">
                  <n-icon :component="paper.license ? CheckmarkCircleOutline : CloseCircleOutline" />
                  <span>License Selection</span>
                </div>
              </div>
            </n-card>
          </div>
        </div>
      </div>
    </div>

    <div v-else class="error-state">
      <n-empty description="Paper not found" size="large">
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
  NCard, NButton, NTag, NIcon, NSpin, NEmpty, NStatistic, NGrid, NGi, NSpace,
  useMessage
} from 'naive-ui'
import {
  EyeOutline, ArrowBackOutline, CheckmarkOutline, DownloadOutline, ShareOutline,
  PrintOutline, CheckmarkCircleOutline, CloseCircleOutline
} from '@vicons/ionicons5'
import dayjs from 'dayjs'

const router = useRouter()
const route = useRoute()
const message = useMessage()

// Reactive data
const isLoading = ref(true)
const paper = ref(null)

// Mock paper data (would be fetched from API)
const mockPaper = {
  id: 1,
  title: "Quantum Machine Learning for Drug Discovery: A Comprehensive Survey",
  authors: [
    { name: "Dr. Sarah Chen", affiliation: "MIT", email: "s.chen@mit.edu" },
    { name: "Prof. Michael Zhang", affiliation: "Stanford University", email: "m.zhang@stanford.edu" },
    { name: "Dr. Lisa Wang", affiliation: "Google Research", email: "l.wang@google.com" }
  ],
  abstract: "This paper presents a comprehensive survey of quantum machine learning applications in drug discovery, exploring the potential of quantum algorithms to accelerate pharmaceutical research and development processes. We examine current approaches, challenges, and future directions in the intersection of quantum computing and computational biology. Our analysis reveals significant opportunities for quantum advantage in molecular simulation, drug-target interaction prediction, and optimization of pharmaceutical compounds. The survey covers both theoretical foundations and practical implementations, providing insights for researchers working at the intersection of quantum computing and pharmaceutical sciences.",
  keywords: ["Quantum Computing", "Machine Learning", "Drug Discovery", "Pharmaceutical Research", "Quantum Algorithms", "Molecular Simulation", "Computational Biology"],
  category: "Computer Science",
  status: "Draft",
  createdAt: "2024-01-15",
  publishedAt: null,
  venue: null,
  doi: null,
  license: "cc-by",
  funding: "This research was supported by NSF Grant No. 12345678 and NIH Grant No. R01-987654321.",
  views: 0,
  downloads: 0,
  citations: 0,
  shares: 0,
  peerReviewId: null
}

// Methods
const formatDate = (date) => {
  return dayjs(date).format('MMMM DD, YYYY')
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

const getLicenseName = (license) => {
  const licenses = {
    'cc-by': 'CC BY 4.0',
    'cc-by-sa': 'CC BY-SA 4.0',
    'cc-by-nc': 'CC BY-NC 4.0',
    'all-rights-reserved': 'All Rights Reserved'
  }
  return licenses[license] || license
}

const goBack = () => {
  router.push(`/papers/${route.params.paper_id}/edit`)
}

const proceedToPublish = () => {
  router.push(`/papers/${route.params.paper_id}/publish`)
}

const downloadPreview = () => {
  message.success('Downloading paper preview...')
  // TODO: Implement preview download
}

const sharePreview = async () => {
  try {
    const url = window.location.href
    await navigator.clipboard.writeText(url)
    message.success('Preview link copied to clipboard')
  } catch (error) {
    message.error('Failed to copy link')
  }
}

const printPreview = () => {
  window.print()
}

// Lifecycle
onMounted(async () => {
  try {
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000))
    paper.value = mockPaper
  } catch (error) {
    console.error('Failed to load paper:', error)
    message.error('Failed to load paper data')
  } finally {
    isLoading.value = false
  }
})
</script>

<style scoped>
.paper-preview-page {
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

.paper-preview-content {
  max-width: 1400px;
  margin: 0 auto;
  padding: 24px;
}

.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 32px;
  padding-bottom: 24px;
  border-bottom: 1px solid #30363d;
}

.header-content {
  flex: 1;
}

.preview-badge {
  margin-bottom: 12px;
}

.page-title {
  font-size: 2.5rem;
  font-weight: 700;
  color: #c9d1d9;
  margin: 0 0 8px 0;
}

.page-description {
  font-size: 1.1rem;
  color: #8b949e;
  margin: 0;
}

.header-actions {
  display: flex;
  gap: 12px;
  align-items: center;
}

.paper-content {
  display: flex;
  flex-direction: column;
  gap: 32px;
}

.paper-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 24px;
  padding: 24px;
  background: #161b22;
  border: 1px solid #30363d;
  border-radius: 8px;
}

.paper-title-section {
  flex: 1;
}

.paper-title {
  font-size: 2rem;
  font-weight: 700;
  color: #c9d1d9;
  margin: 0 0 16px 0;
  line-height: 1.3;
}

.paper-meta {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.authors {
  font-size: 1.1rem;
  color: #c9d1d9;
  line-height: 1.5;
}

.author {
  font-weight: 500;
}

.meta-info {
  display: flex;
  gap: 16px;
  font-size: 0.9rem;
  color: #8b949e;
}

.paper-status-section {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 12px;
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

.abstract-text {
  font-size: 1rem;
  line-height: 1.7;
  color: #c9d1d9;
  margin: 0;
  text-align: justify;
}

.keywords-container {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.funding-text {
  font-size: 0.95rem;
  line-height: 1.6;
  color: #c9d1d9;
  margin: 0;
}

.paper-content-preview {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.content-section h3 {
  font-size: 1.2rem;
  font-weight: 600;
  color: #c9d1d9;
  margin: 0 0 12px 0;
  padding-bottom: 8px;
  border-bottom: 1px solid #30363d;
}

.content-section p {
  font-size: 0.95rem;
  line-height: 1.6;
  color: #8b949e;
  margin: 0;
  text-align: justify;
}

.info-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
}

.info-item .label {
  font-weight: 500;
  color: #8b949e;
  min-width: 80px;
}

.checklist {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.checklist-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.9rem;
  color: #8b949e;
}

.checklist-item.completed {
  color: #3fb950;
}

.checklist-item .n-icon {
  font-size: 16px;
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

:deep(.n-statistic .n-statistic-value) {
  color: #c9d1d9;
}

:deep(.n-statistic .n-statistic-label) {
  color: #8b949e;
}

:deep(.n-tag) {
  border-color: #30363d;
}

/* Print styles */
@media print {
  .preview-header,
  .header-actions,
  .right-column {
    display: none;
  }
  
  .content-grid {
    grid-template-columns: 1fr;
  }
  
  .paper-preview-page {
    background: white;
    color: black;
  }
  
  .paper-header,
  .content-card {
    background: white;
    border: 1px solid #ccc;
  }
}
</style>