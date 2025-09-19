<template>
  <div class="nft-mint-form">
    <div class="mint-header">
      <h2>{{ title || 'Mint Asset as NFT' }}</h2>
      <p class="mint-description">
        Transform your {{ assetType?.toLowerCase() || 'asset' }} into a unique NFT with customizable access controls and ownership shares.
      </p>
    </div>

    <n-form
      ref="mintFormRef"
      :model="localMintForm"
      :rules="formRules"
      label-placement="top"
      require-mark-placement="right-hanging"
      class="mint-form"
    >
      <!-- Section 1: Basic Info -->
      <n-card title="1. Basic Information" class="form-section">
        <n-form-item label="Asset Type" path="assetType">
          <n-select
            v-model:value="localMintForm.assetType"
            :options="assetTypeOptions"
            placeholder="Select asset type"
            @update:value="onAssetTypeChange"
            :disabled="!!presetAssetType"
          />
          <template #feedback v-if="presetAssetType">
            <span class="form-hint">Asset type is pre-selected for this minting session</span>
          </template>
        </n-form-item>

        <n-form-item label="Select Asset" path="selectedAsset" v-if="localMintForm.assetType">
          <n-select
            v-model:value="localMintForm.selectedAsset"
            :options="filteredAssets"
            placeholder="Search and select your asset..."
            filterable
            :loading="isLoadingAssets"
            @search="searchAssets"
            @update:value="onAssetSelect"
            :filter="() => true"
            :render-label="renderAssetLabel"
            :disabled="!!presetAssetId"
          />
          <template #feedback>
            <span class="form-hint">
              {{ filteredAssets.length }} {{ localMintForm.assetType?.toLowerCase() || 'asset' }}{{ filteredAssets.length !== 1 ? 's' : '' }} available for minting
              {{ presetAssetId ? ' (Pre-selected asset)' : '' }}
              <span v-if="localMintForm.assetType === 'Project'" style="display: block; font-size: 0.75rem; color: #f0a020; margin-top: 4px;">
                Only completed projects can be minted as NFTs
              </span>
              <span v-if="localMintForm.assetType === 'Publication'" style="display: block; font-size: 0.75rem; color: #f0a020; margin-top: 4px;">
                Only published papers can be minted as NFTs
              </span>
            </span>
          </template>
        </n-form-item>

        <n-form-item label="Title" path="title">
          <n-input
            v-model:value="localMintForm.title"
            placeholder="Enter NFT title"
          />
        </n-form-item>

        <n-form-item label="Category" path="category">
          <n-select
            v-model:value="localMintForm.category"
            :options="categoryOptions"
            placeholder="Select category"
          />
        </n-form-item>

        <n-form-item label="Keywords">
          <n-dynamic-tags v-model:value="localMintForm.keywords" />
        </n-form-item>

        <n-form-item label="Description" path="description">
          <n-input
            v-model:value="localMintForm.description"
            type="textarea"
            :rows="4"
            placeholder="Describe your NFT..."
          />
        </n-form-item>

        <n-form-item label="Preview Image CID (Optional)">
          <n-input
            v-model:value="localMintForm.previewImageCID"
            placeholder="ipfs://QmXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
          />
        </n-form-item>
      </n-card>

      <!-- Section 2: Authors & Shares -->
      <n-card title="2. Authors & Shares" class="form-section">
        <div class="authors-section">
          <div class="authors-header">
            <span class="section-label">Authors (Wallet Addresses)</span>
            <n-button size="small" @click="addAuthor">
              <template #icon>
                <n-icon :component="AddOutline" />
              </template>
              Add Author
            </n-button>
          </div>

          <div class="authors-list">
            <div 
              v-for="(author, index) in localMintForm.authors" 
              :key="index"
              class="author-row"
            >
              <n-form-item 
                :path="`authors.${index}.address`" 
                :rule="authorAddressRule"
                class="author-address"
              >
                <n-input
                  v-model:value="author.address"
                  placeholder="0x..."
                />
              </n-form-item>

              <n-form-item 
                :path="`authors.${index}.share`" 
                :rule="authorShareRule"
                class="author-share"
                v-if="!localMintForm.openAccess"
              >
                <n-input-number
                  v-model:value="author.share"
                  :min="1"
                  :max="10000"
                  placeholder="0000"
                  style="width: 100%"
                />
              </n-form-item>

              <n-button
                v-if="localMintForm.authors.length > 1"
                type="error"
                size="small"
                @click="removeAuthor(index)"
                class="remove-author-btn"
              >
                <template #icon>
                  <n-icon :component="TrashOutline" />
                </template>
              </n-button>
            </div>
          </div>

          <div v-if="!localMintForm.openAccess" class="shares-summary">
            <div class="shares-info">
              <span>Total Shares: {{ totalShares }} / 10000 bps</span>
              <n-button size="small" @click="distributeEvenly">
                Distribute Evenly
              </n-button>
            </div>
            <n-progress
              :percentage="(totalShares / 10000) * 100"
              :color="totalShares === 10000 ? '#18a058' : '#f0a020'"
              :rail-color="'rgba(255, 255, 255, 0.1)'"
            />
          </div>
        </div>
      </n-card>

      <!-- Section 3: Content -->
      <n-card title="3. Content" class="form-section">
        <n-form-item label="Content CID" path="contentCID">
          <n-input
            v-model:value="localMintForm.contentCID"
            placeholder="ipfs://QmXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
          />
          <template #feedback>
            <span class="form-hint">IPFS CID of the actual content to be minted</span>
          </template>
        </n-form-item>
      </n-card>

      <!-- Section 4: Access Control -->
      <n-card title="4. Access Control" class="form-section">
        <!-- Publication Notice -->
        <n-alert
          v-if="localMintForm.assetType === 'Publication'"
          title="Publication Access Policy"
          type="info"
          :show-icon="true"
          style="margin-bottom: 16px;"
        >
          Publications must be open access to ensure free knowledge sharing in the scientific community. 
          Academic papers cannot be monetized through access fees.
        </n-alert>
        
        <n-form-item label="Access Type" path="openAccess">
          <n-radio-group v-model:value="localMintForm.openAccess" @update:value="onAccessChange">
            <n-space direction="vertical">
              <n-radio :value="true">
                <div class="radio-option">
                  <div class="option-title">Open Access</div>
                  <div class="option-desc">Free access for everyone (CID will be public)</div>
                </div>
              </n-radio>
              <n-radio :value="false" :disabled="localMintForm.assetType === 'Publication'">
                <div class="radio-option">
                  <div class="option-title">Restricted Access</div>
                  <div class="option-desc">
                    {{ localMintForm.assetType === 'Publication' 
                       ? 'Not available for Publications - must be open access' 
                       : 'Users must pay to access content' }}
                  </div>
                </div>
              </n-radio>
            </n-space>
          </n-radio-group>
        </n-form-item>

        <!-- Note: Pricing and limited edition settings will be configured when listing for sale -->
      </n-card>

      <!-- Section 5: Cover Image -->
      <n-card title="5. Cover Image" class="form-section">
        <div class="cover-image-section">
          <n-tabs v-model:value="coverImageMethod" type="segment">
            <n-tab-pane name="upload" tab="Upload File">
              <n-form-item label="Upload Cover Image">
                <n-upload
                  :file-list="coverImageFiles"
                  :max="1"
                  accept="image/*"
                  @change="handleCoverImageUpload"
                  :show-file-list="true"
                  list-type="image-card"
                >
                  <n-button>
                    <template #icon>
                      <n-icon :component="CloudUploadOutline" />
                    </template>
                    Upload Image
                  </n-button>
                </n-upload>
              </n-form-item>
            </n-tab-pane>
            
            <n-tab-pane name="cid" tab="IPFS CID">
              <n-form-item label="Image CID">
                <n-input
                  v-model:value="localMintForm.coverImageCID"
                  placeholder="ipfs://QmXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                />
              </n-form-item>
            </n-tab-pane>
          </n-tabs>
        </div>
      </n-card>

      <!-- Submit Actions -->
      <div class="submit-actions">
        <div class="mint-summary">
          <h3>Minting Summary</h3>
          <div class="summary-grid">
            <div class="summary-item">
              <span class="label">Asset Type:</span>
              <span class="value">{{ localMintForm.assetType || 'Not selected' }}</span>
            </div>
            <div class="summary-item">
              <span class="label">Access Type:</span>
              <span class="value">{{ localMintForm.openAccess ? 'Open Access' : 'Restricted Access' }}</span>
            </div>
            <div class="summary-item" v-if="!localMintForm.openAccess">
              <span class="label">Revenue Sharing:</span>
              <span class="value">{{ localMintForm.authors.length }} authors</span>
            </div>
            <div class="summary-item">
              <span class="label">Authors:</span>
              <span class="value">{{ localMintForm.authors.length }}</span>
            </div>
          </div>
        </div>

        <div class="action-buttons">
          <n-button @click="$emit('cancel')" v-if="showCancel">Cancel</n-button>
          <n-button 
            type="primary" 
            size="large"
            @click="submitMint"
            :loading="isMinting"
          >
            <template #icon>
              <n-icon :component="DiamondOutline" />
            </template>
            Mint NFT
          </n-button>
        </div>
      </div>
    </n-form>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import {
  NForm, NFormItem, NSelect, NInput, NInputNumber, NCard, NButton,
  NIcon, NRadioGroup, NRadio, NSpace, NCheckbox, NDynamicTags,
  NTabs, NTabPane, NUpload, NProgress, NAlert, useMessage
} from 'naive-ui'
import {
  AddOutline, TrashOutline, CloudUploadOutline, DiamondOutline
} from '@vicons/ionicons5'

// Props
const props = defineProps({
  title: String,
  presetAssetType: String, // If provided, asset type will be fixed
  presetAssetId: [String, Number], // If provided, asset will be pre-selected
  showCancel: {
    type: Boolean,
    default: true
  }
})

// Emits
const emit = defineEmits(['success', 'error', 'cancel'])

// Router and message
const router = useRouter()
const message = useMessage()

// Reactive data
const mintFormRef = ref(null)
const isLoadingAssets = ref(false)
const isMinting = ref(false)
const coverImageMethod = ref('upload')
const coverImageFiles = ref([])
const searchQuery = ref('')

const availableAssets = ref({
  Dataset: [],
  Project: [],
  Publication: []
})

// Form data
const localMintForm = ref({
  assetType: props.presetAssetType || '',
  selectedAsset: props.presetAssetId || null,
  title: '',
  category: '',
  keywords: [],
  description: '',
  previewImageCID: '',
  authors: [{ address: '', share: 10000 }],
  contentCID: '',
  openAccess: true,
  coverImageCID: ''
})

// Options
const assetTypeOptions = [
  { label: 'Dataset', value: 'Dataset' },
  { label: 'Project', value: 'Project' },
  { label: 'Publication', value: 'Publication' }
]

const categoryOptions = [
  { label: 'Computer Science', value: 'Computer Science' },
  { label: 'Biology', value: 'Biology' },
  { label: 'Physics', value: 'Physics' },
  { label: 'Chemistry', value: 'Chemistry' },
  { label: 'Mathematics', value: 'Mathematics' },
  { label: 'Engineering', value: 'Engineering' },
  { label: 'Medicine', value: 'Medicine' },
  { label: 'Social Sciences', value: 'Social Sciences' },
  { label: 'Other', value: 'Other' }
]

// Computed properties
const filteredAssets = computed(() => {
  const assetType = localMintForm.value.assetType
  if (!assetType) return []
  
  const assets = availableAssets.value[assetType] || []
  
  // If no search query, return all assets
  if (!searchQuery.value) {
    return assets
  }
  
  // Filter assets based on search query
  const query = searchQuery.value.toLowerCase()
  return assets.filter(asset => {
    const title = (asset.label || '').toLowerCase()
    const description = (asset.data?.description || asset.data?.abstract || '').toLowerCase()
    const category = (asset.data?.category || '').toLowerCase()
    const keywords = (asset.data?.keywords || asset.data?.tags || [])
      .map(k => k.toLowerCase()).join(' ')
    
    return title.includes(query) || 
           description.includes(query) || 
           category.includes(query) || 
           keywords.includes(query)
  })
})

const totalShares = computed(() => {
  return localMintForm.value.authors.reduce((sum, author) => sum + (author.share || 0), 0)
})

// Form validation rules
const formRules = {
  assetType: [
    { required: true, message: 'Please select asset type', trigger: 'change' }
  ],
  selectedAsset: [
    { required: true, message: 'Please select an asset', trigger: 'change' }
  ],
  title: [
    { required: true, message: 'Please enter title', trigger: 'blur' }
  ],
  category: [
    { required: true, message: 'Please select category', trigger: 'change' }
  ],
  description: [
    { required: true, message: 'Please enter description', trigger: 'blur' },
    { min: 10, message: 'Description must be at least 10 characters', trigger: 'blur' }
  ],
  contentCID: [
    { required: true, message: 'Please enter content CID', trigger: 'blur' },
    { pattern: /^ipfs:\/\/Qm[1-9A-HJ-NP-Za-km-z]{44}$/, message: 'Invalid IPFS CID format', trigger: 'blur' }
  ],
  openAccess: [
    {
      validator: (rule, value) => {
        if (localMintForm.value.assetType === 'Publication' && !value) {
          return new Error('Publications must be open access')
        }
        return true
      },
      trigger: 'change'
    }
  ],

}

const authorAddressRule = {
  required: true,
  message: 'Please enter wallet address',
  trigger: 'blur',
  pattern: /^0x[a-fA-F0-9]{40}$/
}

const authorShareRule = {
  validator: (rule, value) => {
    if (!localMintForm.value.openAccess && (!value || value < 1 || value > 10000)) {
      return new Error('Share must be between 1 and 10000 bps')
    }
    return true
  },
  trigger: 'blur'
}

// Methods
const onAssetTypeChange = (value) => {
  localMintForm.value.selectedAsset = null
  searchQuery.value = '' // Clear search when changing asset type
  
  // Enforce open access for Publications
  if (value === 'Publication') {
    localMintForm.value.openAccess = true
  }
  
  loadUserAssets(value)
}

const loadUserAssets = async (assetType) => {
  isLoadingAssets.value = true
  try {
    const userData = localStorage.getItem('user')
    if (!userData) {
      throw new Error('Please log in first')
    }
    
    const user = JSON.parse(userData)
    let endpoint = ''
    
    switch (assetType) {
      case 'Dataset':
        endpoint = `http://localhost:3000/api/datasets?wallet_address=${user.wallet_address}`
        break
      case 'Project':
        endpoint = `http://localhost:3000/api/projects/user/${user.wallet_address}`
        break
      case 'Publication':
        endpoint = `http://localhost:3000/api/publications/user/${user.wallet_address}`
        break
    }
    
    const response = await fetch(endpoint)
    if (response.ok) {
      const assets = await response.json()
      
      // Filter assets based on their readiness for NFT minting
      let filteredAssets = assets
      
      if (assetType === 'Project') {
        // Only show completed projects for NFT minting
        filteredAssets = assets.filter(asset => asset.status === 'Completed')
      } else if (assetType === 'Publication') {
        // Only show published publications for NFT minting
        filteredAssets = assets.filter(asset => asset.status === 'Published')
      }
      // Datasets don't need status filtering as they're always available once uploaded
      
      availableAssets.value[assetType] = filteredAssets.map(asset => {
        // Create a comprehensive label for better searchability
        const baseTitle = asset.title || asset.name || 'Untitled'
        const category = asset.category ? ` (${asset.category})` : ''
        const status = asset.status ? ` - ${asset.status}` : ''
        
        return {
          label: `${baseTitle}${category}${status}`,
          value: asset.id,
          data: asset
        }
      })
      
      console.log(`Loaded ${filteredAssets.length} mintable ${assetType.toLowerCase()}s for user (${assets.length} total)`)
    } else {
      console.error(`Failed to load ${assetType.toLowerCase()}s:`, response.status)
      availableAssets.value[assetType] = []
    }
  } catch (error) {
    console.error('Failed to load assets:', error)
    message.error('Failed to load assets')
  } finally {
    isLoadingAssets.value = false
  }
}

const searchAssets = (query) => {
  searchQuery.value = query
  console.log('Searching for:', query)
}

const renderAssetLabel = (option) => {
  const asset = option.data
  if (!asset) return option.label
  
  const title = asset.title || asset.name || 'Untitled'
  const category = asset.category ? ` (${asset.category})` : ''
  const status = asset.status ? ` - ${asset.status}` : ''
  
  return `${title}${category}${status}`
}

// Helper function to get selected asset display name
const getSelectedAssetLabel = computed(() => {
  if (!localMintForm.value.selectedAsset || !filteredAssets.value.length) return ''
  
  const selectedOption = filteredAssets.value.find(option => option.value === localMintForm.value.selectedAsset)
  return selectedOption ? renderAssetLabel(selectedOption) : ''
})

const onAssetSelect = (value) => {
  const selectedOption = filteredAssets.value.find(option => option.value === value)
  if (selectedOption) {
    const asset = selectedOption.data
    console.log('Selected asset:', asset)
    
    // Pre-fill form with asset data
    const assetTitle = asset.title || asset.name || 'Untitled Asset'
    localMintForm.value.title = `${assetTitle} - NFT`
    
    // Handle different description fields based on asset type
    let description = ''
    switch (localMintForm.value.assetType) {
      case 'Dataset':
        description = asset.description || asset.summary || ''
        break
      case 'Project':
        description = asset.description || asset.summary || ''
        break
      case 'Publication':
        description = asset.abstract || asset.description || asset.summary || ''
        break
    }
    localMintForm.value.description = description
    
    // Set category
    localMintForm.value.category = asset.category || 'Other'
    
    // Handle keywords/tags
    const keywords = asset.keywords || asset.tags || []
    localMintForm.value.keywords = Array.isArray(keywords) ? keywords : 
      (typeof keywords === 'string' ? keywords.split(',').map(k => k.trim()) : [])
    
    // Set content CID based on asset type
    let contentCID = ''
    switch (localMintForm.value.assetType) {
      case 'Project':
        contentCID = asset.repo_cid || asset.repository_cid || asset.content_cid || ''
        break
      case 'Dataset':
        contentCID = asset.file_cid || asset.data_cid || asset.content_cid || ''
        break
      case 'Publication':
        contentCID = asset.file_cid || asset.pdf_cid || asset.content_cid || ''
        break
    }
    
    // Generate mock CID if none exists
    if (!contentCID) {
      contentCID = `ipfs://Qm${Math.random().toString(36).substr(2, 44)}`
    }
    localMintForm.value.contentCID = contentCID
    
    // Set preview image if available
    if (asset.preview_image || asset.image || asset.cover_image) {
      localMintForm.value.previewImageCID = asset.preview_image || asset.image || asset.cover_image
    }
    
    // Set current user as first author
    const userData = localStorage.getItem('user')
    if (userData) {
      const user = JSON.parse(userData)
      localMintForm.value.authors[0].address = user.wallet_address
    }
    
    console.log('Form auto-filled with asset data')
  }
}

const onAccessChange = (isOpen) => {
  // Prevent changing away from open access for Publications
  if (localMintForm.value.assetType === 'Publication' && !isOpen) {
    localMintForm.value.openAccess = true
    message.warning('Publications must remain open access')
    return
  }
  
  if (isOpen) {
    // Reset author shares for open access
    localMintForm.value.authors.forEach(author => {
      author.share = Math.floor(10000 / localMintForm.value.authors.length)
    })
  }
}

const addAuthor = () => {
  localMintForm.value.authors.push({ address: '', share: 0 })
}

const removeAuthor = (index) => {
  localMintForm.value.authors.splice(index, 1)
}

const distributeEvenly = () => {
  const sharePerAuthor = Math.floor(10000 / localMintForm.value.authors.length)
  const remainder = 10000 % localMintForm.value.authors.length
  
  localMintForm.value.authors.forEach((author, index) => {
    author.share = sharePerAuthor + (index < remainder ? 1 : 0)
  })
}

const handleCoverImageUpload = ({ fileList }) => {
  coverImageFiles.value = fileList
}

const submitMint = async () => {
  try {
    await mintFormRef.value?.validate()
    
    // Additional validation for shares
    if (!localMintForm.value.openAccess && totalShares.value !== 10000) {
      message.error('Author shares must sum to exactly 10000 basis points')
      return
    }
    
    // Validate asset status before minting
    const selectedAsset = filteredAssets.value.find(asset => asset.value === localMintForm.value.selectedAsset)
    if (selectedAsset) {
      const asset = selectedAsset.data
      if (localMintForm.value.assetType === 'Project' && asset.status !== 'Completed') {
        message.error('Only completed projects can be minted as NFTs')
        return
      }
      if (localMintForm.value.assetType === 'Publication' && asset.status !== 'Published') {
        message.error('Only published papers can be minted as NFTs')
        return
      }
    }
    
    isMinting.value = true
    
    // Prepare mint data
    const mintData = {
      ...localMintForm.value,
      coverImage: coverImageFiles.value.length > 0 ? coverImageFiles.value[0] : null
    }
    
    // Call backend API to mint NFT
    const response = await fetch('http://localhost:3000/api/nfts/mint', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(mintData)
    })
    
    if (!response.ok) {
      const errorData = await response.json()
      throw new Error(errorData.error || 'Failed to mint NFT')
    }
    
    const result = await response.json()
    
    message.success('Asset successfully minted as NFT!')
    emit('success', result)
    
    // Navigate to NFT details page
    if (result.nft && result.nft.id) {
      setTimeout(() => {
        router.push(`/nft/${result.nft.id}`)
      }, 1000)
    }
    
  } catch (error) {
    console.error('Failed to mint NFT:', error)
    const errorMessage = error.message || 'Failed to mint NFT'
    message.error(errorMessage)
    emit('error', error)
  } finally {
    isMinting.value = false
  }
}

// Initialize
onMounted(() => {
  // Load current user data
  const userData = localStorage.getItem('user')
  if (userData) {
    const user = JSON.parse(userData)
    localMintForm.value.authors[0].address = user.wallet_address
  }
  
  // If preset asset type is provided, set it and load assets
  if (props.presetAssetType) {
    localMintForm.value.assetType = props.presetAssetType
    
    // Enforce open access for Publications
    if (props.presetAssetType === 'Publication') {
      localMintForm.value.openAccess = true
    }
    
    loadUserAssets(props.presetAssetType)
  }
})

// Watch for preset asset ID
watch(() => props.presetAssetId, (newId) => {
  if (newId && props.presetAssetType) {
    localMintForm.value.selectedAsset = newId
    // Trigger asset selection after assets are loaded
    setTimeout(() => {
      onAssetSelect(newId)
    }, 1000)
  }
})

// Watch for preset asset type to ensure form is updated
watch(() => props.presetAssetType, (newType) => {
  if (newType) {
    localMintForm.value.assetType = newType
    
    // Enforce open access for Publications
    if (newType === 'Publication') {
      localMintForm.value.openAccess = true
    }
  }
})
</script>

<style scoped>
.nft-mint-form {
  max-width: 800px;
  margin: 0 auto;
  padding: 24px;
  background: #0d1117;
  color: #c9d1d9;
}

.mint-header {
  text-align: center;
  margin-bottom: 32px;
}

.mint-header h2 {
  font-size: 2rem;
  font-weight: 700;
  color: #c9d1d9;
  margin: 0 0 12px 0;
}

.mint-description {
  font-size: 1rem;
  color: #8b949e;
  line-height: 1.6;
  margin: 0;
}

.form-section {
  margin-bottom: 24px;
}

.form-hint {
  font-size: 0.8rem;
  color: #8b949e;
}

.radio-option {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.option-title {
  font-weight: 600;
  color: #c9d1d9;
}

.option-desc {
  font-size: 0.85rem;
  color: #8b949e;
}

.authors-section {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.authors-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.section-label {
  font-weight: 600;
  color: #c9d1d9;
}

.authors-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.author-row {
  display: grid;
  grid-template-columns: 1fr auto auto;
  gap: 12px;
  align-items: start;
}

.author-address {
  flex: 1;
}

.author-share {
  width: 120px;
}

.remove-author-btn {
  margin-top: 2px;
}

.shares-summary {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 16px;
  background: #161b22;
  border: 1px solid #30363d;
  border-radius: 8px;
}

.shares-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.9rem;
  color: #c9d1d9;
}



.cover-image-section {
  width: 100%;
}

.submit-actions {
  display: flex;
  flex-direction: column;
  gap: 24px;
  margin-top: 32px;
}

.mint-summary {
  background: #161b22;
  border: 1px solid #30363d;
  border-radius: 12px;
  padding: 20px;
}

.mint-summary h3 {
  font-size: 1.2rem;
  font-weight: 600;
  color: #c9d1d9;
  margin: 0 0 16px 0;
}

.summary-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 12px;
}

.summary-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
}

.summary-item .label {
  font-size: 0.9rem;
  color: #8b949e;
}

.summary-item .value {
  font-weight: 600;
  color: #58a6ff;
}

.action-buttons {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
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
  background-color: #0d1117;
  border-color: #30363d;
  color: #c9d1d9;
}

:deep(.n-select) {
  background-color: #0d1117;
}

:deep(.n-upload) {
  background-color: #0d1117;
}

/* Disabled select styles */
:deep(.n-select.n-select--disabled .n-base-selection) {
  background-color: #21262d !important;
  border-color: #58a6ff !important;
  opacity: 0.8;
}

:deep(.n-select.n-select--disabled .n-base-selection-label) {
  color: #58a6ff !important;
  font-weight: 600;
}

:deep(.n-select.n-select--disabled .n-base-selection__border) {
  border-color: #58a6ff !important;
}

:deep(.n-select.n-select--disabled) {
  cursor: not-allowed;
}

/* Responsive design */
@media (max-width: 768px) {
  .nft-mint-form {
    padding: 16px;
  }
  
  .author-row {
    grid-template-columns: 1fr;
    gap: 8px;
  }
  
  .summary-grid {
    grid-template-columns: 1fr;
  }
  
  .action-buttons {
    flex-direction: column;
  }
  
  .authors-header {
    flex-direction: column;
    gap: 8px;
    align-items: stretch;
  }
}
</style> 