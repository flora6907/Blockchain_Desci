<template>
  <div class="paper-import-page">
    <!-- Page Header -->
    <div class="page-header">
      <div class="header-content only-steps">
        <div class="step-indicator">
          <n-steps :current="currentStep" size="small">
            <n-step title="Basic Info" description="DOI and source" />
            <n-step title="PDF" description="Upload paper PDF" />
            <n-step title="Details" description="Fill paper details" />
            <n-step title="Metrics" description="Citations and metrics" />
            <n-step title="Preview" description="Review import" />
          </n-steps>
        </div>
      </div>
    </div>

    <!-- Form Steps -->
    <div class="form-container">
      <!-- Step 1: Basic Information -->
      <div v-if="currentStep === 1" class="step-content">
        <n-card title="Paper Source Information" class="step-card">
          <template #header-extra>
            <n-tag type="info" size="small">Step 1 of 5</n-tag>
          </template>
          
          <n-form :model="paperForm" :rules="basicRules" ref="basicFormRef" label-placement="top">
            <n-grid :cols="1" :x-gap="24">
              <n-gi>
                <n-form-item label="DOI (Digital Object Identifier)" path="doi">
                  <n-input 
                    v-model:value="paperForm.doi" 
                    placeholder="e.g., 10.1038/nature12373" 
                    @blur="fetchDOIInfo"
                    @keyup.enter="fetchDOIInfo"
                  >
                    <template #prefix>
                      <n-icon :component="LinkOutline" />
                    </template>
                    <template #suffix>
                      <n-button text @click="fetchDOIInfo" :loading="fetchingDOI">
                        <n-icon :component="SearchOutline" />
                      </n-button>
                    </template>
                  </n-input>
                  <template #feedback>
                    <span class="form-help">
                      Enter the DOI to automatically fetch: title, authors, abstract, publication date, journal, and keywords
                    </span>
                  </template>
                </n-form-item>
              </n-gi>
              
              <n-gi>
                <n-form-item label="Source Platform/Journal" path="source">
                  <n-select
                    v-model:value="paperForm.source"
                    :options="sourceOptions"
                    placeholder="Select the publication source"
                    filterable
                    tag
                  />
                </n-form-item>
              </n-gi>
              
              <n-gi>
                <n-form-item label="Publication Date" path="publishedDate">
                  <n-date-picker
                    v-model:value="paperForm.publishedDate"
                    type="date"
                    placeholder="When was this paper published?"
                    style="width: 100%"
                  />
                </n-form-item>
              </n-gi>
              
              <n-gi>
                <n-form-item label="Original URL (Optional)" path="originalUrl">
                  <n-input 
                    v-model:value="paperForm.originalUrl" 
                    placeholder="https://..." 
                  >
                    <template #prefix>
                      <n-icon :component="GlobeOutline" />
                    </template>
                  </n-input>
                </n-form-item>
              </n-gi>
            </n-grid>
          </n-form>
          
          <div class="form-actions">
            <n-button @click="goBack">Cancel</n-button>
            <n-button type="primary" @click="nextStep" :loading="fetchingDOI">
              Next: Upload PDF
            </n-button>
          </div>
        </n-card>
      </div>

      <!-- Step 2: PDF Upload -->
      <div v-if="currentStep === 2" class="step-content">
        <n-card title="Upload Published PDF" class="step-card">
          <template #header-extra>
            <n-tag type="info" size="small">Step 2 of 5</n-tag>
          </template>

          <n-upload
            :max="1"
            accept=".pdf"
            :custom-request="handlePdfUpload"
            :on-remove="handlePdfRemove"
            :file-list="pdfFileList"
            :on-before-upload="onBeforeUpload"
            :on-error="onUploadError"
            :default-upload="false"
            @change="onUploadChange"
            :show-file-list="true"
            list-type="text"
          >
            <n-upload-dragger v-if="!paperForm.pdf">
              <n-icon size="48" :component="DocumentOutline" class="upload-icon" />
              <n-text>Click or drag PDF to upload</n-text>
            </n-upload-dragger>
            <div v-else class="upload-replacement">
              <n-button @click="replacePdf" type="dashed" style="width: 100%; height: 80px;">
                <template #icon>
                  <n-icon :component="DocumentOutline" />
                </template>
                <div style="display: flex; flex-direction: column; align-items: center; gap: 8px;">
                  <span>Replace PDF</span>
                  <span style="font-size: 0.875rem; opacity: 0.7;">Click or drag new PDF to replace</span>
                </div>
              </n-button>
            </div>
          </n-upload>

          <div v-if="paperForm.pdf" class="file-info">
            <div class="file-details">
              <n-icon :component="DocumentOutline" class="file-icon" />
              <div class="file-meta">
                <h4>{{ paperForm.pdf.file_name }}</h4>
                <p>{{ formatMb(paperForm.pdf.file_size) }} MB • {{ paperForm.pdf.mime_type || 'application/pdf' }}</p>
                <p class="upload-success">✓ PDF uploaded successfully</p>
              </div>
            </div>
          </div>

          <div class="form-actions">
            <n-button @click="prevStep">Previous</n-button>
            <n-button type="primary" @click="nextStep" :disabled="!paperForm.pdf">
              Next: Paper Details
            </n-button>
          </div>
        </n-card>
      </div>

      <!-- Step 3: Paper Details -->
      <div v-if="currentStep === 3" class="step-content">
        <n-card title="Paper Information" class="step-card">
          <template #header-extra>
            <n-tag type="info" size="small">Step 3 of 5</n-tag>
          </template>
          
          <n-form :model="paperForm" :rules="paperRules" ref="paperFormRef" label-placement="top">
            <n-grid :cols="1" :x-gap="24">
              <n-gi>
                <n-form-item label="Paper Title" path="title">
                  <n-input 
                    v-model:value="paperForm.title" 
                    placeholder="Enter the exact title of your published paper"
                    type="textarea"
                    :rows="2"
                  />
                </n-form-item>
              </n-gi>
              
              <n-gi>
                <n-form-item label="Authors" path="authors">
                  <n-dynamic-tags v-model:value="paperForm.authors" :max="20">
                    <template #trigger="{ activate, disabled }">
                      <n-button
                        size="small"
                        type="dashed"
                        :disabled="disabled"
                        @click="activate()"
                      >
                        <template #icon>
                          <n-icon :component="AddOutline" />
                        </template>
                        Add Author
                      </n-button>
                    </template>
                  </n-dynamic-tags>
                  <template #feedback>
                    <span class="form-help">Add all authors in order of appearance</span>
                  </template>
                </n-form-item>
              </n-gi>
              
              <n-gi>
                <n-form-item label="Abstract" path="abstract">
                  <n-input 
                    v-model:value="paperForm.abstract" 
                    type="textarea" 
                    placeholder="Paste the paper's abstract here..."
                    :rows="6"
                  />
                </n-form-item>
              </n-gi>
              
              <n-gi>
                <n-form-item label="Keywords" path="keywords">
                  <n-dynamic-tags v-model:value="paperForm.keywords" :max="15">
                    <template #trigger="{ activate, disabled }">
                      <n-button
                        size="small"
                        type="dashed"
                        :disabled="disabled"
                        @click="activate()"
                      >
                        <template #icon>
                          <n-icon :component="AddOutline" />
                        </template>
                        Add Keyword
                      </n-button>
                    </template>
                  </n-dynamic-tags>
                </n-form-item>
              </n-gi>
              
              <n-gi>
                <n-form-item label="Research Category" path="category">
                  <n-select
                    v-model:value="paperForm.category"
                    :options="categoryOptions"
                    placeholder="Select the research field"
                  />
                </n-form-item>
              </n-gi>
            </n-grid>
          </n-form>
          
          <div class="form-actions">
            <n-button @click="prevStep">Previous</n-button>
            <n-button type="primary" @click="nextStep">
              Next: Citations & Metrics
            </n-button>
          </div>
        </n-card>
      </div>

      <!-- Step 4: Citations and Metrics -->
      <div v-if="currentStep === 4" class="step-content">
        <n-card title="Publication Metrics" class="step-card">
          <template #header-extra>
            <n-tag type="info" size="small">Step 4 of 5</n-tag>
          </template>
          
          <n-form :model="paperForm" ref="metricsFormRef" label-placement="top">
            <n-grid :cols="2" :x-gap="24">
              <n-gi>
                <n-form-item label="Current Citation Count">
                  <n-input-number 
                    v-model:value="paperForm.citationCount" 
                    :min="0" 
                    :max="999999"
                    placeholder="Number of times cited"
                    style="width: 100%"
                  />
                  <template #feedback>
                    <span class="form-help">From Google Scholar, Web of Science, etc.</span>
                  </template>
                </n-form-item>
              </n-gi>
              
              <n-gi>
                <n-form-item label="Download Count (Optional)">
                  <n-input-number 
                    v-model:value="paperForm.downloadCount" 
                    :min="0" 
                    :max="999999"
                    placeholder="Download count"
                    style="width: 100%"
                  />
                </n-form-item>
              </n-gi>
              
              <n-gi>
                <n-form-item label="Views Count (Optional)">
                  <n-input-number 
                    v-model:value="paperForm.views" 
                    :min="0" 
                    :max="999999"
                    placeholder="View count"
                    style="width: 100%"
                  />
                </n-form-item>
              </n-gi>
              
              <n-gi>
                <n-form-item label="Impact Factor (Optional)">
                  <n-input-number 
                    v-model:value="paperForm.impactFactor" 
                    :min="0" 
                    :max="100"
                    :precision="3"
                    placeholder="Journal impact factor"
                    style="width: 100%"
                  />
                </n-form-item>
              </n-gi>
            </n-grid>
            
            <n-form-item label="Publisher/Conference Details">
              <n-input 
                v-model:value="paperForm.publisher" 
                placeholder="e.g., Nature, IEEE, ACM, etc."
              />
            </n-form-item>
            
            <n-form-item label="Volume/Issue (Optional)">
              <n-input 
                v-model:value="paperForm.volume" 
                placeholder="e.g., Vol. 123, Issue 4, pp. 45-67"
              />
            </n-form-item>
            
            <n-form-item label="Additional Notes (Optional)">
              <n-input 
                v-model:value="paperForm.notes" 
                type="textarea"
                placeholder="Any additional information about this publication..."
                :rows="3"
              />
            </n-form-item>
          </n-form>
          
          <div class="form-actions">
            <n-button @click="prevStep">Previous</n-button>
            <n-button type="primary" @click="nextStep">
              Next: Preview
            </n-button>
          </div>
        </n-card>
      </div>

      <!-- Step 5: Preview -->
      <div v-if="currentStep === 5" class="step-content">
        <n-card title="Import Preview" class="step-card">
          <template #header-extra>
            <n-tag type="info" size="small">Step 5 of 5</n-tag>
          </template>
          
          <div class="preview-content">
            <div class="preview-section">
              <h3>Paper Information</h3>
              <div class="preview-item">
                <strong>Title:</strong> {{ paperForm.title }}
              </div>
              <div class="preview-item">
                <strong>Authors:</strong> {{ paperForm.authors.join(', ') }}
              </div>
              <div class="preview-item">
                <strong>DOI:</strong> {{ paperForm.doi }}
              </div>
              <div class="preview-item">
                <strong>Published:</strong> {{ formatDate(paperForm.publishedDate) }}
              </div>
              <div class="preview-item">
                <strong>Source:</strong> {{ paperForm.source }}
              </div>
              <div class="preview-item">
                <strong>Category:</strong> {{ paperForm.category }}
              </div>
            </div>
            
            <div class="preview-section">
              <h3>Abstract</h3>
              <p class="abstract-preview">{{ paperForm.abstract }}</p>
            </div>
            
            <div class="preview-section">
              <h3>Keywords</h3>
              <div class="keywords-preview">
                <n-tag v-for="keyword in paperForm.keywords" :key="keyword" size="small">
                  {{ keyword }}
                </n-tag>
              </div>
            </div>
            
            <div class="preview-section">
              <h3>Metrics</h3>
              <n-grid :cols="4" :x-gap="16">
                <n-gi>
                  <n-statistic label="Citations" :value="paperForm.citationCount || 0" />
                </n-gi>
                <n-gi>
                  <n-statistic label="Downloads" :value="paperForm.downloadCount || 0" />
                </n-gi>
                <n-gi>
                  <n-statistic label="Views" :value="paperForm.views || 0" />
                </n-gi>
                <n-gi>
                  <n-statistic label="Impact Factor" :value="paperForm.impactFactor || 'N/A'" />
                </n-gi>
              </n-grid>
            </div>
          </div>
          
          <div class="form-actions">
            <n-button @click="prevStep">Previous</n-button>
            <n-button type="primary" @click="importPaper" :loading="importing">
              <template #icon>
                <n-icon :component="DownloadOutline" />
              </template>
              Import Paper
            </n-button>
          </div>
        </n-card>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, nextTick, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { 
  NCard, NButton, NForm, NFormItem, NInput, NInputNumber, NSelect, NDatePicker, 
  NGrid, NGi, NTag, NIcon, NSteps, NStep, NDynamicTags, NStatistic,
  useMessage, NUpload, NUploadDragger, NText
} from 'naive-ui'
import axios from 'axios'
import {
  LinkOutline, SearchOutline, GlobeOutline, AddOutline, DownloadOutline, DocumentOutline
} from '@vicons/ionicons5'
import dayjs from 'dayjs'

const router = useRouter()
const message = useMessage()

// Test server connection on component mount
const testServerConnection = async () => {
  try {
    console.log('Testing server connection...')
    const response = await axios.get('http://localhost:3000/api/publications/test')
    console.log('Server connection test successful:', response.data)
  } catch (error) {
    console.error('Server connection test failed:', error)
    message.error('Cannot connect to server. Please make sure the backend is running.')
  }
}

// Reactive data
const currentStep = ref(1)
const fetchingDOI = ref(false)
const importing = ref(false)

const paperForm = reactive({
  // Step 1: Basic Info
  doi: '',
  source: '',
  publishedDate: null,
  originalUrl: '',
  
  // Step 2: PDF Upload
  pdf: null,
  
  // Step 2: Paper Details
  title: '',
  authors: [],
  abstract: '',
  keywords: [],
  category: '',
  
  // Step 3: Metrics
  citationCount: 0,
  downloadCount: 0,
  views: 0,
  impactFactor: null,
  publisher: '',
  volume: '',
  notes: ''
})

const pdfFileList = ref([])

const formatMb = (bytes) => {
  if (!bytes && bytes !== 0) return '0.00'
  const n = Number(bytes)
  if (isNaN(n)) return '0.00'
  return (n / 1024 / 1024).toFixed(2)
}

// Form refs
const basicFormRef = ref(null)
const paperFormRef = ref(null)
const metricsFormRef = ref(null)

// Options
const sourceOptions = [
  { label: 'Nature', value: 'Nature' },
  { label: 'Science', value: 'Science' },
  { label: 'Cell', value: 'Cell' },
  { label: 'The Lancet', value: 'The Lancet' },
  { label: 'New England Journal of Medicine', value: 'NEJM' },
  { label: 'IEEE Transactions', value: 'IEEE' },
  { label: 'ACM Digital Library', value: 'ACM' },
  { label: 'PLoS ONE', value: 'PLoS ONE' },
  { label: 'Scientific Reports', value: 'Scientific Reports' },
  { label: 'arXiv', value: 'arXiv' },
  { label: 'bioRxiv', value: 'bioRxiv' },
  { label: 'medRxiv', value: 'medRxiv' },
  { label: 'Other', value: 'Other' }
]

const categoryOptions = [
  { label: 'Computer Science', value: 'Computer Science' },
  { label: 'Biology & Life Sciences', value: 'Biology' },
  { label: 'Medicine & Health', value: 'Medicine' },
  { label: 'Physics', value: 'Physics' },
  { label: 'Chemistry', value: 'Chemistry' },
  { label: 'Materials Science', value: 'Materials Science' },
  { label: 'Engineering', value: 'Engineering' },
  { label: 'Mathematics', value: 'Mathematics' },
  { label: 'Environmental Science', value: 'Environmental Science' },
  { label: 'Social Sciences', value: 'Social Sciences' },
  { label: 'Other', value: 'Other' }
]

// Validation rules
const basicRules = {
  doi: [
    { required: true, message: 'DOI is required', trigger: 'blur' },
    { pattern: /^10\.\d{4,9}\/[-._;()\/:a-zA-Z0-9]+$/, message: 'Please enter a valid DOI format', trigger: 'blur' }
  ],
  source: [
    { required: true, message: 'Please select or enter the source platform', trigger: 'change' }
  ],
  publishedDate: [
    { required: true, type: 'number', message: 'Publication date is required', trigger: ['blur', 'change'] }
  ]
}

const paperRules = {
  title: [
    { required: true, message: 'Paper title is required', trigger: 'blur' },
    { min: 10, message: 'Title should be at least 10 characters', trigger: 'blur' }
  ],
  authors: [
    { type: 'array', required: true, message: 'At least one author is required', trigger: 'change' },
    { type: 'array', min: 1, message: 'At least one author is required', trigger: 'change' }
  ],
  abstract: [
    { required: true, message: 'Abstract is required', trigger: 'blur' },
    { min: 100, message: 'Abstract should be at least 100 characters', trigger: 'blur' }
  ],
  category: [
    { required: true, message: 'Please select a research category', trigger: 'change' }
  ]
}

// Methods
const nextStep = async () => {
  let isValid = true
  
  if (currentStep.value === 1) {
    try {
      await basicFormRef.value?.validate()
    } catch {
      isValid = false
    }
  } else if (currentStep.value === 2) {
    // PDF upload step - check if PDF is uploaded
    if (!paperForm.pdf) {
      message.error('Please upload a PDF file to continue')
      isValid = false
    }
  } else if (currentStep.value === 3) {
    try {
      await paperFormRef.value?.validate()
    } catch {
      isValid = false
    }
  }
  
  if (isValid && currentStep.value < 5) {
    currentStep.value++
  }
}

const prevStep = () => {
  if (currentStep.value > 1) {
    currentStep.value--
  }
}

const fetchDOIInfo = async () => {
  if (!paperForm.doi) return
  
  // Validate DOI format
  const doiPattern = /^10\.\d{4,9}\/[-._;()\/:a-zA-Z0-9]+$/
  if (!doiPattern.test(paperForm.doi)) {
    message.error('Please enter a valid DOI format (e.g., 10.1038/nature12373)')
    return
  }
  
  fetchingDOI.value = true
  try {
    message.info('Looking up DOI information...')
    
    // Option 1: Call CrossRef API directly (may have CORS issues in some browsers)
    // const response = await fetch(`https://api.crossref.org/works/${paperForm.doi}`, {
    //   headers: {
    //     'Accept': 'application/json',
    //     'User-Agent': 'DeSci-Platform/1.0 (mailto:contact@desci-platform.org)'
    //   }
    // })
    
    // Option 2: Use backend proxy (recommended)
    const response = await fetch(`http://localhost:3000/api/publications/doi/${encodeURIComponent(paperForm.doi)}`, {
      headers: {
        'Accept': 'application/json'
      }
    })
    
    if (!response.ok) {
      if (response.status === 404) {
        throw new Error('DOI not found in database')
      }
      throw new Error(`Failed to fetch DOI information: ${response.status}`)
    }
    
    const data = await response.json()
    
    if (data) {
      // Populate form with extracted data
      if (data.title) paperForm.title = data.title
      if (data.authors && data.authors.length > 0) paperForm.authors = data.authors
      if (data.abstract) paperForm.abstract = data.abstract
      if (data.publishedDate) {
        paperForm.publishedDate = new Date(data.publishedDate).getTime()
        await nextTick()
        basicFormRef.value?.restoreValidation(['publishedDate'])
      }
      if (data.source) paperForm.source = data.source
      if (data.publisher) paperForm.publisher = data.publisher
      if (data.volume) paperForm.volume = data.volume
      if (data.keywords && data.keywords.length > 0) paperForm.keywords = data.keywords
      if (data.category) paperForm.category = data.category
      if (data.citationCount) paperForm.citationCount = data.citationCount
      if (data.originalUrl) paperForm.originalUrl = data.originalUrl
      
      message.success('DOI information successfully retrieved!')
      
      // Clear validation error for published date if it was programmatically set
      await Promise.resolve()
      basicFormRef.value?.restoreValidation(['publishedDate'])
    } else {
      throw new Error('No publication data found for this DOI')
    }
    
  } catch (error) {
    console.error('DOI lookup error:', error)
    if (error.message.includes('not found')) {
      message.error('DOI not found. Please check the DOI and try again.')
    } else if (error.message.includes('Failed to fetch')) {
      message.error('Network error. Please check your internet connection and try again.')
    } else {
      message.error(`Failed to fetch DOI information: ${error.message}`)
    }
  } finally {
    fetchingDOI.value = false
  }
}

const formatDate = (timestamp) => {
  if (!timestamp) return 'Not specified'
  return dayjs(timestamp).format('MMMM DD, YYYY')
}

const handlePdfUpload = async ({ file, onFinish, onError }) => {
  console.log('=== handlePdfUpload CALLED ===')
  console.log('Upload parameters:', { file, onFinish, onError })
  try {
    console.log('Starting PDF upload for file:', file)
    
    // Check if file is valid
    if (!file || !file.file) {
      throw new Error('Invalid file object')
    }
    
    // Check file type
    if (file.file.type !== 'application/pdf') {
      throw new Error('Only PDF files are allowed')
    }
    
    const form = new FormData()
    form.append('pdf', file.file)
    
    console.log('Uploading to:', 'http://localhost:3000/api/publications/upload')
    
    const res = await axios.post('http://localhost:3000/api/publications/upload', form, {
      headers: { 
        'Content-Type': 'multipart/form-data'
      },
      timeout: 30000 // 30 second timeout
    })
    
    console.log('Upload response:', res.data)
    
    const meta = res.data
    paperForm.pdf = meta
    pdfFileList.value = [{
      id: Date.now().toString(),
      name: meta.file_name,
      size: meta.file_size,
      type: meta.mime_type,
      status: 'finished'
    }]
    
    if (onFinish) onFinish()
    message.success(`${meta.file_name} uploaded successfully`)
  } catch (e) {
    console.error('PDF upload failed:', e)
    if (onError) onError()
    
    let errorMessage = 'PDF upload failed'
    if (e.response) {
      console.error('Server response:', e.response.data)
      errorMessage = e.response.data.error || `Server error: ${e.response.status}`
    } else if (e.message) {
      errorMessage = e.message
    }
    
    message.error(errorMessage)
  }
}

const onBeforeUpload = ({ file }) => {
  console.log('Before upload - file object:', file)
  console.log('File type:', file.file?.type)
  console.log('File size:', file.file?.size)
  console.log('File name:', file.file?.name)
  
  if (file.file?.type !== 'application/pdf') {
    message.error('Only PDF files are allowed')
    return false
  }
  
  if (file.file?.size > 50 * 1024 * 1024) { // 50MB limit
    message.error('File size must be less than 50MB')
    return false
  }
  
  return true
}

const onUploadError = ({ file, event }) => {
  console.error('Upload error event:', event)
  console.error('Failed file:', file)
}

const onUploadChange = ({ file, fileList, event }) => {
  console.log('=== Upload Change Event ===')
  console.log('File:', file)
  console.log('FileList:', fileList)
  console.log('Event:', event)
  
  // If file is added, trigger upload manually
  if (file && file.status === 'pending') {
    console.log('File pending, triggering upload...')
    // Manual trigger upload
    setTimeout(() => {
      handlePdfUpload({ 
        file, 
        onFinish: () => {
          console.log('Upload finished')
        },
        onError: () => {
          console.log('Upload error')
        }
      })
    }, 100)
  }
}

const handlePdfRemove = ({ file }) => {
  console.log('Removing PDF file:', file)
  paperForm.pdf = null
  pdfFileList.value = []
  return true
}

const replacePdf = () => {
  console.log('Replacing PDF file')
  paperForm.pdf = null
  pdfFileList.value = []
  // Trigger file picker
  const uploadComponent = document.querySelector('.n-upload input[type="file"]')
  if (uploadComponent) {
    uploadComponent.click()
  }
}

const importPaper = async () => {
  importing.value = true
  
  try {
    const user = JSON.parse(localStorage.getItem('user') || '{}')
    console.log('=== IMPORTING PAPER ===')
    console.log('User from localStorage:', user)
    console.log('paperForm.pdf:', paperForm.pdf)
    
    const importData = {
      title: paperForm.title,
      authors: paperForm.authors,
      abstract: paperForm.abstract,
      keywords: paperForm.keywords,
      category: paperForm.category,
      status: 'Published', // Directly set as published
      author_wallet_address: user.wallet_address,
      doi: paperForm.doi,
      published_at: paperForm.publishedDate ? new Date(paperForm.publishedDate).toISOString() : null,
      citation_count: paperForm.citationCount || 0,
      download_count: paperForm.downloadCount || 0,
      views: paperForm.views || 0,
      preprint_server: paperForm.source,
      // Additional import-specific fields
      original_url: paperForm.originalUrl,
      publisher: paperForm.publisher,
      volume: paperForm.volume,
      impact_factor: paperForm.impactFactor,
      import_notes: paperForm.notes,
      is_imported: true, // Flag to distinguish imported papers
      // PDF meta will be merged after upload
      pdf_path: paperForm.pdf?.file_path || null,
      pdf_file_name: paperForm.pdf?.file_name || null,
      pdf_file_size: paperForm.pdf?.file_size || null,
      pdf_mime_type: paperForm.pdf?.mime_type || null
    }
    
    console.log('Import data being sent:', JSON.stringify(importData, null, 2))
    
    const response = await fetch('http://localhost:3000/api/publications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(importData)
    })
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }
    
    const result = await response.json()
    
    // Auto-mint imported paper as NFT
    if (result.id) {
      await autoMintPublicationNFT(result.id)
    }
    
    message.success('Paper imported successfully and minted as NFT!')
    router.push('/publications')
  } catch (error) {
    console.error('Failed to import paper:', error)
    message.error('Failed to import paper. Please try again.')
  } finally {
    importing.value = false
  }
}

const goBack = () => {
  router.push('/publications')
}

const autoMintPublicationNFT = async (publicationId) => {
  try {
    // Get publication details
    const pubResponse = await fetch(`http://localhost:3000/api/publications/${publicationId}`)
    if (!pubResponse.ok) return
    
    const publication = await pubResponse.json()
    const userData = localStorage.getItem('user')
    if (!userData) return
    
    const user = JSON.parse(userData)
    
    // Prepare NFT mint data
    const mintData = {
      assetType: 'Publication',
      selectedAsset: publicationId,
      title: `${publication.title} - NFT`,
      category: publication.category || 'Other',
      keywords: publication.keywords || [],
      description: publication.abstract || publication.description || '',
      authors: [{ address: user.wallet_address, share: 10000 }],
      contentCID: publication.file_cid || `ipfs://Qm${Math.random().toString(36).substr(2, 44)}`, // Mock CID if not available
      openAccess: true, // Default to open access for published papers
      accessPrice: 0,
      isLimitedEdition: false,
      editionSize: 0,
      coverImageCID: publication.preview_image || ''
    }
    
    // Call NFT mint API
    const mintResponse = await fetch('http://localhost:3000/api/nfts/mint', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(mintData)
    })
    
    if (mintResponse.ok) {
      console.log('Imported publication automatically minted as NFT')
    }
  } catch (error) {
    console.error('Failed to auto-mint publication NFT:', error)
    // Don't throw error to avoid interrupting the import process
  }
}

// Test server connection when component mounts
onMounted(() => {
  testServerConnection()
})
</script>

<style scoped>
.paper-import-page {
  padding: 24px;
  max-width: 1000px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 32px;
}

.header-content {
  justify-content: center;
}

.header-content.only-steps {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 32px;
}

.header-text {
  flex: 1;
}

.page-title {
  font-size: 2.5rem;
  font-weight: 700;
  color: #c9d1d9;
  margin: 0 0 8px 0;
}

.page-description {
  font-size: 1.125rem;
  color: #8b949e;
  margin: 0;
}

.step-indicator {
  margin: 0 auto;
  width: 92vw;
  max-width: 1400px;
  text-align: center;
}

.only-steps .step-indicator {
  width: 92vw;
  max-width: 1400px;
}

:deep(.n-steps .n-step .n-step-description) {
  white-space: nowrap;
}

.form-container {
  max-width: 800px;
  margin: 0 auto;
}

.step-card {
  background: #161b22;
  border: 1px solid #30363d;
}

.form-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 32px;
  padding-top: 24px;
  border-top: 1px solid #30363d;
}

.form-help {
  color: #8b949e;
  font-size: 0.875rem;
}

.preview-content {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.preview-section h3 {
  color: #c9d1d9;
  margin: 0 0 16px 0;
  font-size: 1.25rem;
}

.preview-item {
  margin-bottom: 12px;
  color: #c9d1d9;
}

.preview-item strong {
  color: #8b949e;
  margin-right: 8px;
}

.abstract-preview {
  color: #c9d1d9;
  line-height: 1.6;
  margin: 0;
  text-align: justify;
}

.keywords-preview {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.file-info {
  margin-top: 24px;
  padding: 16px;
  background-color: #0d1117;
  border: 1px solid #30363d;
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.file-details {
  display: flex;
  align-items: center;
  gap: 12px;
}

.file-icon {
  color: #58a6ff;
}

.file-meta h4 {
  margin: 0 0 4px 0;
  color: #c9d1d9;
  font-size: 1rem;
}

.file-meta p {
  margin: 0;
  color: #8b949e;
  font-size: 0.875rem;
}

.upload-success {
  color: #4ade80 !important;
  font-weight: 500;
  margin-top: 4px !important;
}

.upload-icon {
  color: #58a6ff;
}

.upload-replacement {
  margin-bottom: 16px;
}

/* Dark theme adjustments */
:deep(.n-card) {
  background-color: #161b22;
  border-color: #30363d;
}

:deep(.n-form-item .n-form-item-label) {
  color: #c9d1d9;
}

:deep(.n-input) {
  background-color: #0d1117;
}

:deep(.n-select) {
  background-color: #0d1117;
}

:deep(.n-date-picker) {
  background-color: #0d1117;
}

:deep(.n-statistic .n-statistic-value) {
  color: #c9d1d9;
}

:deep(.n-statistic .n-statistic-label) {
  color: #8b949e;
}
</style> 