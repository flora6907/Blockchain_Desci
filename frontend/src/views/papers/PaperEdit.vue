<template>
  <div class="paper-edit-page">
    <div v-if="isLoading" class="loading-container">
      <n-spin size="large">
        <template #description>Loading paper data...</template>
      </n-spin>
    </div>
    
    <div v-else-if="paper" class="paper-edit-content">
      <!-- Edit Header -->
      <div class="edit-header">
        <div class="header-content">
          <div class="edit-badge">
            <n-tag type="warning" size="large">
              <template #icon>
                <n-icon :component="CreateOutline" />
              </template>
              Edit Mode
            </n-tag>
          </div>
          <h1 class="page-title">Edit Paper</h1>
          <p class="page-description">Modify your paper information and metadata</p>
        </div>
        <div class="header-actions">
          <n-button @click="goBack">
            <template #icon>
              <n-icon :component="ArrowBackOutline" />
            </template>
            Cancel
          </n-button>
          <n-button @click="previewPaper">
            <template #icon>
              <n-icon :component="EyeOutline" />
            </template>
            Preview
          </n-button>
          <n-button type="primary" @click="saveChanges" :loading="isSaving">
            <template #icon>
              <n-icon :component="CheckmarkOutline" />
            </template>
            Save Changes
          </n-button>
        </div>
      </div>

      <!-- Edit Form -->
      <div class="edit-form-container">
        <n-form
          ref="formRef"
          :model="editForm"
          :rules="formRules"
          label-placement="top"
          require-mark-placement="right-hanging"
          size="large"
        >
          <div class="form-grid">
            <!-- Left Column -->
            <div class="left-column">
              <!-- Basic Information -->
              <n-card title="Basic Information" class="form-card">
                <n-form-item label="Paper Title" path="title">
                  <n-input
                    v-model:value="editForm.title"
                    placeholder="Enter paper title"
                    :maxlength="200"
                    show-count
                  />
                </n-form-item>

                <n-form-item label="Abstract" path="abstract">
                  <n-input
                    v-model:value="editForm.abstract"
                    type="textarea"
                    placeholder="Enter paper abstract"
                    :rows="6"
                    :maxlength="2000"
                    show-count
                  />
                </n-form-item>

                <n-form-item label="Category" path="category">
                  <n-select
                    v-model:value="editForm.category"
                    placeholder="Select category"
                    :options="categoryOptions"
                    filterable
                  />
                </n-form-item>

                <n-form-item label="Keywords" path="keywords">
                  <n-dynamic-tags
                    v-model:value="editForm.keywords"
                    placeholder="Add keywords"
                    :max="10"
                  />
                </n-form-item>
              </n-card>

              <!-- Authors Section -->
              <n-card title="Authors" class="form-card">
                <div class="authors-section">
                  <div v-for="(author, index) in editForm.authors" :key="index" class="author-item">
                    <n-grid :cols="3" :x-gap="12" :y-gap="12">
                      <n-gi>
                        <n-form-item :label="`Author ${index + 1} Name`" :path="`authors.${index}.name`">
                          <n-input
                            v-model:value="author.name"
                            placeholder="Full name"
                          />
                        </n-form-item>
                      </n-gi>
                      <n-gi>
                        <n-form-item :label="`Affiliation`" :path="`authors.${index}.affiliation`">
                          <n-input
                            v-model:value="author.affiliation"
                            placeholder="Institution/Organization"
                          />
                        </n-form-item>
                      </n-gi>
                      <n-gi>
                        <n-form-item :label="`Email`" :path="`authors.${index}.email`">
                          <n-input
                            v-model:value="author.email"
                            placeholder="email@example.com"
                            type="email"
                          />
                        </n-form-item>
                      </n-gi>
                    </n-grid>
                    <div class="author-actions">
                      <n-button
                        v-if="editForm.authors.length > 1"
                        size="small"
                        type="error"
                        @click="removeAuthor(index)"
                      >
                        <template #icon>
                          <n-icon :component="TrashOutline" />
                        </template>
                        Remove
                      </n-button>
                    </div>
                  </div>
                  <n-button @click="addAuthor" type="dashed" block>
                    <template #icon>
                      <n-icon :component="AddOutline" />
                    </template>
                    Add Author
                  </n-button>
                </div>
              </n-card>

              <!-- Publication Details -->
              <n-card title="Publication Details" class="form-card">
                <n-form-item label="Publication Venue" path="venue">
                  <n-input
                    v-model:value="editForm.venue"
                    placeholder="Journal, Conference, or Publisher"
                  />
                </n-form-item>

                <n-form-item label="DOI" path="doi">
                  <n-input
                    v-model:value="editForm.doi"
                    placeholder="10.1000/182"
                  />
                </n-form-item>

                <n-form-item label="Publication Date" path="publishedAt">
                  <n-date-picker
                    v-model:value="editForm.publishedAt"
                    type="date"
                    placeholder="Select publication date"
                    clearable
                  />
                </n-form-item>

                <n-form-item label="License" path="license">
                  <n-select
                    v-model:value="editForm.license"
                    placeholder="Select license"
                    :options="licenseOptions"
                  />
                </n-form-item>
              </n-card>
            </div>

            <!-- Right Column -->
            <div class="right-column">
              <!-- File Upload -->
              <n-card title="Paper File" class="form-card">
                <div class="file-upload-section">
                  <n-upload
                    ref="uploadRef"
                    :file-list="fileList"
                    :max="1"
                    accept=".pdf,.doc,.docx"
                    :on-change="handleFileChange"
                    :on-remove="handleFileRemove"
                    :custom-request="handleCustomRequest"
                    directory-dnd
                    drag
                    class="upload-area"
                  >
                    <n-upload-dragger>
                      <n-icon size="48" :component="CloudUploadOutline" class="upload-icon" />
                      <n-text style="font-size: 16px">
                        Click or drag paper file to upload
                      </n-text>
                      <n-text depth="3" style="font-size: 14px">
                        Supports PDF, DOC, DOCX files
                      </n-text>
                    </n-upload-dragger>
                  </n-upload>
                </div>
              </n-card>

              <!-- Funding Information -->
              <n-card title="Funding Information" class="form-card">
                <n-form-item label="Funding Details" path="funding">
                  <n-input
                    v-model:value="editForm.funding"
                    type="textarea"
                    placeholder="Enter funding information (grants, sponsors, etc.)"
                    :rows="4"
                    :maxlength="1000"
                    show-count
                  />
                </n-form-item>
              </n-card>

              <!-- Paper Status -->
              <n-card title="Paper Status" class="form-card">
                <n-form-item label="Current Status" path="status">
                  <n-select
                    v-model:value="editForm.status"
                    placeholder="Select status"
                    :options="statusOptions"
                    :disabled="!canChangeStatus"
                  />
                </n-form-item>
                <div v-if="!canChangeStatus" class="status-note">
                  <n-alert type="info" show-icon>
                    Status can only be changed by administrators or reviewers
                  </n-alert>
                </div>
              </n-card>

              <!-- Additional Metadata -->
              <n-card title="Additional Metadata" class="form-card">
                <n-form-item label="Peer Review ID" path="peerReviewId">
                  <n-input
                    v-model:value="editForm.peerReviewId"
                    placeholder="Review ID (if applicable)"
                    :disabled="true"
                  />
                </n-form-item>

                <n-form-item label="Created Date" path="createdAt">
                  <n-date-picker
                    v-model:value="editForm.createdAt"
                    type="date"
                    placeholder="Creation date"
                    :disabled="true"
                  />
                </n-form-item>
              </n-card>

              <!-- Edit Actions -->
              <n-card title="Actions" class="form-card">
                <n-space direction="vertical" size="small">
                  <n-button block @click="resetForm">
                    <template #icon>
                      <n-icon :component="RefreshOutline" />
                    </template>
                    Reset to Original
                  </n-button>
                  <n-button block @click="duplicatePaper">
                    <template #icon>
                      <n-icon :component="CopyOutline" />
                    </template>
                    Duplicate Paper
                  </n-button>
                  <n-button block @click="exportMetadata">
                    <template #icon>
                      <n-icon :component="DownloadOutline" />
                    </template>
                    Export Metadata
                  </n-button>
                </n-space>
              </n-card>
            </div>
          </div>
        </n-form>
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
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { 
  NCard, NButton, NIcon, NSpin, NEmpty, NForm, NFormItem, NInput, NSelect,
  NDatePicker, NDynamicTags, NUpload, NUploadDragger, NText, NGrid, NGi,
  NAlert, NSpace, NTag, useMessage
} from 'naive-ui'
import {
  CreateOutline, ArrowBackOutline, EyeOutline, CheckmarkOutline, AddOutline,
  TrashOutline, CloudUploadOutline, RefreshOutline, CopyOutline, DownloadOutline
} from '@vicons/ionicons5'
import dayjs from 'dayjs'

const router = useRouter()
const route = useRoute()
const message = useMessage()

// Reactive data
const isLoading = ref(true)
const isSaving = ref(false)
const paper = ref(null)
const formRef = ref(null)
const uploadRef = ref(null)
const fileList = ref([])

// Form data
const editForm = ref({
  title: '',
  abstract: '',
  category: '',
  keywords: [],
  authors: [
    { name: '', affiliation: '', email: '' }
  ],
  venue: '',
  doi: '',
  publishedAt: null,
  license: 'cc-by',
  funding: '',
  status: 'Draft',
  peerReviewId: null,
  createdAt: null
})

// Original form data for reset functionality
const originalForm = ref({})

// Form options
const categoryOptions = [
  { label: 'Computer Science', value: 'Computer Science' },
  { label: 'Mathematics', value: 'Mathematics' },
  { label: 'Physics', value: 'Physics' },
  { label: 'Chemistry', value: 'Chemistry' },
  { label: 'Biology', value: 'Biology' },
  { label: 'Medicine', value: 'Medicine' },
  { label: 'Engineering', value: 'Engineering' },
  { label: 'Economics', value: 'Economics' },
  { label: 'Psychology', value: 'Psychology' },
  { label: 'Other', value: 'Other' }
]

const licenseOptions = [
  { label: 'CC BY 4.0', value: 'cc-by' },
  { label: 'CC BY-SA 4.0', value: 'cc-by-sa' },
  { label: 'CC BY-NC 4.0', value: 'cc-by-nc' },
  { label: 'All Rights Reserved', value: 'all-rights-reserved' }
]

const statusOptions = [
  { label: 'Draft', value: 'Draft' },
  { label: 'Under Review', value: 'Under Review' },
  { label: 'Revision Required', value: 'Revision Required' },
  { label: 'Preprint', value: 'Preprint' },
  { label: 'Published', value: 'Published' }
]

// Form validation rules
const formRules = {
  title: [
    { required: true, message: 'Please enter paper title', trigger: 'blur' },
    { min: 10, max: 200, message: 'Title must be between 10 and 200 characters', trigger: 'blur' }
  ],
  abstract: [
    { required: true, message: 'Please enter abstract', trigger: 'blur' },
    { min: 100, max: 2000, message: 'Abstract must be between 100 and 2000 characters', trigger: 'blur' }
  ],
  category: [
    { required: true, message: 'Please select category', trigger: 'change' }
  ],
  keywords: [
    { required: true, type: 'array', min: 3, message: 'Please add at least 3 keywords', trigger: 'change' }
  ],
  authors: [
    { required: true, type: 'array', min: 1, message: 'Please add at least one author', trigger: 'change' }
  ],
  license: [
    { required: true, message: 'Please select license', trigger: 'change' }
  ]
}

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

// Computed properties
const canChangeStatus = computed(() => {
  return ['Draft', 'Preprint'].includes(editForm.value.status)
})

// Methods
const formatDate = (date) => {
  return dayjs(date).format('YYYY-MM-DD')
}

const parseDate = (dateString) => {
  return dayjs(dateString).valueOf()
}

const addAuthor = () => {
  editForm.value.authors.push({ name: '', affiliation: '', email: '' })
}

const removeAuthor = (index) => {
  editForm.value.authors.splice(index, 1)
}

const handleFileChange = (options) => {
  fileList.value = options.fileList
}

const handleFileRemove = () => {
  fileList.value = []
}

const handleCustomRequest = (options) => {
  // Simulate file upload
  setTimeout(() => {
    options.onSuccess()
    message.success('File uploaded successfully')
  }, 1000)
}

const goBack = () => {
  router.back()
}

const previewPaper = () => {
  router.push(`/papers/${route.params.paper_id}/preview`)
}

const saveChanges = async () => {
  try {
    await formRef.value?.validate()
    isSaving.value = true
    
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1500))
    
    // Update original form data
    originalForm.value = { ...editForm.value }
    
    message.success('Paper updated successfully')
    
    // Optionally navigate back or to preview
    // router.push(`/papers/${route.params.paper_id}`)
    
  } catch (error) {
    console.error('Validation failed:', error)
    message.error('Please fix the form errors before saving')
  } finally {
    isSaving.value = false
  }
}

const resetForm = () => {
  editForm.value = { ...originalForm.value }
  message.info('Form reset to original values')
}

const duplicatePaper = () => {
  message.info('Duplicating paper...')
  // TODO: Implement paper duplication
}

const exportMetadata = () => {
  const metadata = {
    title: editForm.value.title,
    authors: editForm.value.authors,
    abstract: editForm.value.abstract,
    keywords: editForm.value.keywords,
    category: editForm.value.category,
    venue: editForm.value.venue,
    doi: editForm.value.doi,
    license: editForm.value.license,
    funding: editForm.value.funding,
    exportedAt: new Date().toISOString()
  }
  
  const blob = new Blob([JSON.stringify(metadata, null, 2)], { type: 'application/json' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = `${editForm.value.title.replace(/\s+/g, '-')}-metadata.json`
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  URL.revokeObjectURL(url)
  
  message.success('Metadata exported successfully')
}

// Watch for form changes to enable save button
const hasChanges = computed(() => {
  return JSON.stringify(editForm.value) !== JSON.stringify(originalForm.value)
})

// Lifecycle
onMounted(async () => {
  try {
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000))
    paper.value = mockPaper
    
    // Populate form with paper data
    editForm.value = {
      title: paper.value.title,
      abstract: paper.value.abstract,
      category: paper.value.category,
      keywords: [...paper.value.keywords],
      authors: paper.value.authors.map(author => ({ ...author })),
      venue: paper.value.venue || '',
      doi: paper.value.doi || '',
      publishedAt: paper.value.publishedAt ? parseDate(paper.value.publishedAt) : null,
      license: paper.value.license,
      funding: paper.value.funding || '',
      status: paper.value.status,
      peerReviewId: paper.value.peerReviewId,
      createdAt: paper.value.createdAt ? parseDate(paper.value.createdAt) : null
    }
    
    // Store original form data
    originalForm.value = { ...editForm.value }
    
  } catch (error) {
    console.error('Failed to load paper:', error)
    message.error('Failed to load paper data')
  } finally {
    isLoading.value = false
  }
})
</script>

<style scoped>
.paper-edit-page {
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

.paper-edit-content {
  max-width: 1400px;
  margin: 0 auto;
  padding: 24px;
}

.edit-header {
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

.edit-badge {
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

.edit-form-container {
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

.authors-section {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.author-item {
  padding: 16px;
  background: #21262d;
  border: 1px solid #30363d;
  border-radius: 6px;
}

.author-actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}

.file-upload-section {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.upload-area {
  width: 100%;
}

.upload-icon {
  color: #58a6ff;
}

.status-note {
  margin-top: 12px;
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

:deep(.n-select) {
  background-color: #21262d;
}

:deep(.n-date-picker) {
  background-color: #21262d;
}

:deep(.n-upload-dragger) {
  background-color: #21262d;
  border-color: #30363d;
}

:deep(.n-upload-dragger:hover) {
  border-color: #58a6ff;
}

:deep(.n-tag) {
  border-color: #30363d;
}

:deep(.n-alert) {
  background-color: #21262d;
  border-color: #30363d;
}

/* Responsive design */
@media (max-width: 1200px) {
  .form-grid {
    grid-template-columns: 1fr;
  }
  
  .header-actions {
    flex-direction: column;
    align-items: stretch;
  }
}

@media (max-width: 768px) {
  .paper-edit-content {
    padding: 16px;
  }
  
  .edit-header {
    flex-direction: column;
    gap: 16px;
  }
  
  .header-actions {
    flex-direction: row;
    justify-content: space-between;
  }
}
</style>