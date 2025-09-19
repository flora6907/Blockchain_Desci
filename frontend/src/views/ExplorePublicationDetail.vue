<template>
  <div class="publication-detail-page">
    <div v-if="isLoading" class="loading-container">
      <n-spin size="large">
        <template #description>Loading publication details...</template>
      </n-spin>
    </div>
    
    <div v-else-if="publication" class="publication-content">
      <!-- Publication Header -->
      <div class="publication-header">
        <div class="publication-title-section">
          <h1 class="publication-title">{{ publication.title }}</h1>
          <div class="publication-meta">
            <div class="authors">
              <span v-for="(author, index) in publication.authors" :key="index" class="author">
                {{ typeof author === 'string' ? author : author.name }}{{ index < publication.authors.length - 1 ? ', ' : '' }}
              </span>
            </div>
            <div class="meta-info">
              <span>{{ formatDate(publication.createdAt) }}</span>
              <span v-if="publication.doi">DOI: {{ publication.doi }}</span>
              <span>Category: {{ publication.category }}</span>
            </div>
          </div>
        </div>
        <div class="publication-status-section">
          <n-tag :type="getStatusType(publication.status)" size="large">
            {{ publication.status }}
          </n-tag>
          <div class="publication-actions">
            <n-button @click="downloadPublication">
              <template #icon>
                <n-icon :component="DownloadOutline" />
              </template>
              Download
            </n-button>
            <n-button @click="sharePublication">
              <template #icon>
                <n-icon :component="ShareOutline" />
              </template>
              Share
            </n-button>
                         <n-button @click="citePublication">
               <template #icon>
                 <n-icon :component="DocumentTextOutline" />
               </template>
               Cite
             </n-button>
          </div>
        </div>
      </div>

      <!-- Publication Content Grid -->
      <div class="content-grid">
        <!-- Left Column -->
        <div class="left-column">
          <!-- Abstract -->
          <n-card title="Abstract" class="content-card">
            <p class="abstract-text">{{ publication.abstract }}</p>
          </n-card>

          <!-- Keywords -->
          <n-card title="Keywords" class="content-card">
            <div class="keywords-container">
              <n-tag v-for="keyword in publication.keywords" :key="keyword" size="medium">
                {{ keyword }}
              </n-tag>
            </div>
          </n-card>

          <!-- Author Information -->
          <n-card title="Author Information" class="content-card">
            <div class="author-info">
              <div class="info-item">
                <span class="label">Primary Author:</span>
                <span>{{ getAuthorDisplay() }}</span>
              </div>
              <div v-if="publication.authorUsername" class="info-item">
                <span class="label">Username:</span>
                <span>{{ publication.authorUsername }}</span>
              </div>
            </div>
          </n-card>
        </div>

        <!-- Right Column -->
        <div class="right-column">
          <!-- Publication Statistics -->
          <n-card title="Statistics" class="content-card">
            <n-grid :cols="2" :x-gap="16" :y-gap="16">
              <n-gi>
                <n-statistic label="Views" :value="publication.views || 0" />
              </n-gi>
              <n-gi>
                <n-statistic label="Downloads" :value="publication.downloadCount || 0" />
              </n-gi>
              <n-gi>
                <n-statistic label="Citations" :value="publication.citationCount || 0" />
              </n-gi>
              <n-gi>
                <n-statistic label="Shares" :value="publication.shares || 0" />
              </n-gi>
            </n-grid>
          </n-card>

          <!-- Publication Info -->
          <n-card title="Publication Details" class="content-card">
            <div class="info-list">
              <div class="info-item">
                <span class="label">Status:</span>
                <n-tag :type="getStatusType(publication.status)">{{ publication.status }}</n-tag>
              </div>
              <div v-if="publication.publishedAt" class="info-item">
                <span class="label">Published:</span>
                <span>{{ formatDate(publication.publishedAt) }}</span>
              </div>
              <div v-if="publication.preprintServer" class="info-item">
                <span class="label">Preprint Server:</span>
                <span>{{ publication.preprintServer }}</span>
              </div>
              <div class="info-item">
                <span class="label">Created:</span>
                <span>{{ formatDate(publication.createdAt) }}</span>
              </div>
            </div>
          </n-card>

          <!-- Related Actions -->
          <n-card title="Actions" class="content-card">
            <n-space direction="vertical" size="small">
              <n-button block @click="viewAuthorProfile">
                <template #icon>
                  <n-icon :component="PersonOutline" />
                </template>
                View Author Profile
              </n-button>
              <n-button block @click="findSimilarPublications">
                <template #icon>
                  <n-icon :component="SearchOutline" />
                </template>
                Find Similar Publications
              </n-button>
              <n-button block @click="reportPublication">
                <template #icon>
                  <n-icon :component="FlagOutline" />
                </template>
                Report Issue
              </n-button>
            </n-space>
          </n-card>
        </div>
      </div>
    </div>

    <div v-else class="error-state">
      <n-empty description="Publication not found" size="large">
        <template #extra>
          <n-button @click="goBack">Go Back to Explore</n-button>
        </template>
      </n-empty>
    </div>

    <!-- Citation Modal -->
    <n-modal v-model:show="showCitationModal" preset="card" title="Cite this Publication" style="width: 600px;">
      <div class="citation-content">
        <n-tabs type="line">
          <n-tab-pane name="apa" tab="APA">
            <div class="citation-text">{{ getCitation('apa') }}</div>
          </n-tab-pane>
          <n-tab-pane name="mla" tab="MLA">
            <div class="citation-text">{{ getCitation('mla') }}</div>
          </n-tab-pane>
          <n-tab-pane name="bibtex" tab="BibTeX">
            <div class="citation-text">{{ getCitation('bibtex') }}</div>
          </n-tab-pane>
        </n-tabs>
        <n-button @click="copyCitation" style="margin-top: 16px;">
          Copy Citation
        </n-button>
      </div>
    </n-modal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { 
  NCard, NButton, NTag, NIcon, NSpin, NEmpty, NStatistic, NGrid, NGi, NSpace, NModal, NTabs, NTabPane,
  useMessage
} from 'naive-ui'
import {
  DownloadOutline, ShareOutline, PersonOutline, SearchOutline, FlagOutline, DocumentTextOutline
} from '@vicons/ionicons5'
import dayjs from 'dayjs'

const router = useRouter()
const route = useRoute()
const message = useMessage()

// Reactive data
const isLoading = ref(true)
const publication = ref(null)
const showCitationModal = ref(false)

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

const getAuthorDisplay = () => {
  if (!publication.value || !publication.value.authors || publication.value.authors.length === 0) {
    return 'Unknown'
  }
  const firstAuthor = publication.value.authors[0]
  return typeof firstAuthor === 'string' ? firstAuthor : firstAuthor.name
}

const downloadPublication = () => {
  message.success(`Downloading: ${publication.value.title}`)
  // TODO: Implement download
}

const sharePublication = async () => {
  try {
    await navigator.clipboard.writeText(window.location.href)
    message.success('Publication link copied to clipboard!')
  } catch (error) {
    message.error('Failed to copy link')
  }
}

const citePublication = () => {
  showCitationModal.value = true
}

const viewAuthorProfile = () => {
  if (publication.value.authorWalletAddress) {
    router.push(`/profile/${publication.value.authorWalletAddress}`)
  } else {
    message.warning('Author profile not available')
  }
}

const findSimilarPublications = () => {
  router.push({
    path: '/explore',
    query: { tab: 'publications', category: publication.value.category }
  })
}

const reportPublication = () => {
  message.info('Report functionality not implemented yet')
}

const goBack = () => {
  router.push('/explore?tab=publications')
}

const getCitation = (format) => {
  if (!publication.value) return ''
  
  const title = publication.value.title
  const authors = publication.value.authors.map(a => typeof a === 'string' ? a : a.name).join(', ')
  const year = publication.value.publishedAt ? dayjs(publication.value.publishedAt).format('YYYY') : dayjs(publication.value.createdAt).format('YYYY')
  
  switch (format) {
    case 'apa':
      return `${authors} (${year}). ${title}. ${publication.value.preprintServer || 'DeSci Platform'}. ${publication.value.doi ? `https://doi.org/${publication.value.doi}` : window.location.href}`
    case 'mla':
      return `${authors}. "${title}." ${publication.value.preprintServer || 'DeSci Platform'}, ${year}, ${publication.value.doi ? `https://doi.org/${publication.value.doi}` : window.location.href}.`
    case 'bibtex':
      return `@article{publication${publication.value.id},
  title={${title}},
  author={${authors}},
  year={${year}},
  journal={${publication.value.preprintServer || 'DeSci Platform'}},
  url={${publication.value.doi ? `https://doi.org/${publication.value.doi}` : window.location.href}}
}`
    default:
      return ''
  }
}

const copyCitation = async () => {
  const activeTab = document.querySelector('.n-tab-pane[style*="display: block"] .citation-text')
  if (activeTab) {
    try {
      await navigator.clipboard.writeText(activeTab.textContent)
      message.success('Citation copied to clipboard!')
    } catch (error) {
      message.error('Failed to copy citation')
    }
  }
}

const fetchPublication = async () => {
  try {
    isLoading.value = true
    const publicationId = route.params.publication_id
    
    // Fetch from backend API
    const response = await fetch(`http://localhost:3000/api/publications/${publicationId}`)
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }
    
    const publicationData = await response.json()
    
    // Transform the data to match the expected format
    publication.value = {
      id: publicationData.id,
      title: publicationData.title,
      authors: Array.isArray(publicationData.authors) ? publicationData.authors : [],
      abstract: publicationData.abstract,
      keywords: Array.isArray(publicationData.keywords) ? publicationData.keywords : [],
      category: publicationData.category,
      status: publicationData.status,
      createdAt: publicationData.createdAt,
      publishedAt: publicationData.publishedAt,
      doi: publicationData.doi,
      views: publicationData.views || 0,
      downloadCount: publicationData.downloadCount || 0,
      citationCount: publicationData.citationCount || 0,
      shares: publicationData.shares || 0,
      preprintServer: publicationData.preprintServer,
      authorUsername: publicationData.authorUsername,
      authorWalletAddress: publicationData.authorWalletAddress
    }
  } catch (error) {
    console.error('Failed to fetch publication:', error)
    message.error('Failed to load publication details')
    publication.value = null
  } finally {
    isLoading.value = false
  }
}

onMounted(() => {
  fetchPublication()
})
</script>

<style scoped>
.publication-detail-page {
  padding: 24px;
  max-width: 1400px;
  margin: 0 auto;
}

.loading-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
}

.error-state {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
}

.publication-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 24px;
  margin-bottom: 32px;
  padding: 32px;
  background: #161b22;
  border: 1px solid #30363d;
  border-radius: 12px;
}

.publication-title-section {
  flex: 1;
}

.publication-title {
  font-size: 2.5rem;
  font-weight: 700;
  color: #c9d1d9;
  margin: 0 0 16px 0;
  line-height: 1.2;
}

.publication-meta {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.authors {
  font-size: 1.1rem;
  color: #8b949e;
  line-height: 1.5;
}

.author {
  color: #58a6ff;
}

.meta-info {
  display: flex;
  gap: 16px;
  font-size: 0.875rem;
  color: #8b949e;
}

.meta-info span {
  display: flex;
  align-items: center;
}

.publication-status-section {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 16px;
}

.publication-actions {
  display: flex;
  gap: 8px;
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

.author-info {
  display: flex;
  flex-direction: column;
  gap: 12px;
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

.citation-content {
  padding: 16px 0;
}

.citation-text {
  background: #0d1117;
  border: 1px solid #30363d;
  border-radius: 6px;
  padding: 16px;
  font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
  font-size: 13px;
  line-height: 1.6;
  color: #c9d1d9;
  white-space: pre-wrap;
  word-wrap: break-word;
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
</style> 