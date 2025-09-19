<template>
  <div class="nft-detail-page">
    <div v-if="isLoading" class="loading-container">
      <n-spin size="large">
        <template #description>Loading NFT details...</template>
      </n-spin>
    </div>

    <div v-else-if="nft" class="nft-detail-content">
      <!-- Page Header -->
      <div class="page-header">
        <div class="header-navigation">
          <n-button text @click="goBack" class="back-btn">
            <template #icon>
              <n-icon :component="ArrowBackOutline" />
            </template>
            Back to NFTs
          </n-button>
        </div>
      </div>

      <!-- NFT Content -->
      <div class="nft-content">
        <div class="content-grid">
          <!-- Left Column - NFT Image and Actions -->
          <div class="left-column">
            <div class="nft-image-card">
              <div class="nft-image-container">
                <img :src="nft.image" :alt="nft.title" class="nft-image" />
                <div class="nft-overlay">
                  <n-tag :type="getStatusType(nft.status)" size="medium">
                    {{ nft.status }}
                  </n-tag>
                </div>
              </div>
              
              <div class="nft-actions">
                <n-button 
                  v-if="nft.status === 'Minted' && isOwner && !nft.openAccess && (nft.price > 0 || nft.accessPrice > 0)"
                  type="primary" 
                  size="large" 
                  @click="openListDialog"
                  block
                >
                  <template #icon>
                    <n-icon :component="CashOutline" />
                  </template>
                  List for Sale
                </n-button>
                
                <n-button 
                  v-else-if="nft.status === 'Minted' && isOwner && (nft.openAccess || nft.price === 0 || nft.accessPrice === 0)"
                  size="large" 
                  disabled
                  block
                >
                  <template #icon>
                    <n-icon :component="CashOutline" />
                  </template>
                  Free NFT - Cannot List
                </n-button>
                
                <n-button 
                  v-else-if="nft.status === 'Listed'"
                  size="large" 
                  @click="buyNFT"
                  block
                >
                  <template #icon>
                    <n-icon :component="CardOutline" />
                  </template>
                  Buy for {{ nft.price }} ETH
                </n-button>
                
                <div class="secondary-actions">
                  <n-button @click="shareNFT">
                    <template #icon>
                      <n-icon :component="ShareOutline" />
                    </template>
                    Share
                  </n-button>
                  
                  <n-button @click="viewOnBlockchain">
                    <template #icon>
                      <n-icon :component="LinkOutline" />
                    </template>
                    View on Chain
                  </n-button>
                  
                  <n-button v-if="nft.contentCID" @click="downloadContent">
                    <template #icon>
                      <n-icon :component="DownloadOutline" />
                    </template>
                    Download
                  </n-button>
                </div>
              </div>
            </div>
          </div>

          <!-- Right Column - NFT Details -->
          <div class="right-column">
            <div class="nft-info">
              <div class="nft-header">
                <h1 class="nft-title">{{ nft.title }}</h1>
                <div class="nft-meta">
                  <span class="asset-type">{{ nft.assetType }}</span>
                  <span class="category">{{ nft.category }}</span>
                </div>
              </div>

              <div class="nft-description">
                <h3>Description</h3>
                <p>{{ nft.description }}</p>
              </div>

              <div class="nft-details">
                <div class="detail-section">
                  <h3>NFT Details</h3>
                  <div class="detail-grid">
                    <div class="detail-item">
                      <span class="detail-label">Token ID:</span>
                      <span class="detail-value">{{ formatTokenId(nft.tokenId) }}</span>
                    </div>
                    <div class="detail-item">
                      <span class="detail-label">Contract:</span>
                      <span class="detail-value">{{ formatAddress(nft.contractAddress) }}</span>
                    </div>
                    <div class="detail-item">
                      <span class="detail-label">Minted:</span>
                      <span class="detail-value">{{ formatDate(nft.mintedAt) }}</span>
                    </div>
                    <div class="detail-item">
                      <span class="detail-label">Views:</span>
                      <span class="detail-value">{{ nft.views || 0 }}</span>
                    </div>
                  </div>
                </div>

                <div class="detail-section" v-if="nft.authors && nft.authors.length > 0">
                  <h3>Authors</h3>
                  <div class="authors-list">
                    <div 
                      v-for="(author, index) in nft.authors" 
                      :key="index"
                      class="author-item"
                    >
                      <span class="author-address">{{ formatAddress(author.address) }}</span>
                      <span v-if="author.share" class="author-share">{{ (author.share / 100).toFixed(1) }}%</span>
                    </div>
                  </div>
                </div>

                <div class="detail-section" v-if="nft.keywords && nft.keywords.length > 0">
                  <h3>Keywords</h3>
                  <div class="keywords-list">
                    <n-tag 
                      v-for="keyword in nft.keywords" 
                      :key="keyword" 
                      size="small"
                      class="keyword-tag"
                    >
                      {{ keyword }}
                    </n-tag>
                  </div>
                </div>

                <div class="detail-section" v-if="nft.contentCID">
                  <h3>Content</h3>
                  <div class="content-info">
                    <div class="cid-display">
                      <span class="cid-label">IPFS CID:</span>
                      <code class="cid-value">{{ nft.contentCID }}</code>
                    </div>
                    <div class="access-info">
                      <n-tag :type="nft.openAccess ? 'success' : 'warning'">
                        {{ nft.openAccess ? 'Open Access' : 'Restricted Access' }}
                      </n-tag>
                      <span v-if="!nft.openAccess" class="access-price">
                        Access: {{ nft.accessPrice }} ETH
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- List for Sale Dialog -->
    <n-modal v-model:show="showListDialog" preset="dialog" title="List NFT for Sale">
      <template #header>
        <div class="dialog-header">
          <n-icon :component="CashOutline" class="dialog-icon" />
          <span>List NFT for Sale</span>
        </div>
      </template>
      
      <div v-if="nft" class="list-form">
        <div class="nft-preview">
          <div class="preview-header">
            <img :src="nft.image" :alt="nft.title" class="preview-image" />
            <div class="preview-info">
              <h3>{{ nft.title }}</h3>
              <p class="preview-category">{{ nft.category }}</p>
            </div>
          </div>
        </div>
        
        <n-form :model="listForm" ref="listFormRef" :rules="listRules">
          <n-form-item label="Sale Price (ETH)" path="price">
            <n-input-number 
              v-model:value="listForm.price" 
              :min="0.001" 
              :step="0.001" 
              placeholder="0.000" 
              style="width: 100%"
            />
            <template #feedback>
              <span class="price-feedback">
                Minimum price: 0.001 ETH
              </span>
            </template>
          </n-form-item>
          
          <n-form-item label="Sale Duration" path="duration">
            <n-select 
              v-model:value="listForm.duration" 
              :options="durationOptions" 
              placeholder="Select duration"
            />
          </n-form-item>
          
          <n-form-item label="Royalty Percentage" path="royalty">
            <n-input-number 
              v-model:value="listForm.royalty" 
              :min="0" 
              :max="10" 
              :step="0.5" 
              placeholder="2.5" 
              style="width: 100%"
            />
            <template #feedback>
              <span class="royalty-feedback">
                You'll receive {{ listForm.royalty || 2.5 }}% of future sales
              </span>
            </template>
          </n-form-item>
          
          <n-form-item label="Description (Optional)" path="description">
            <n-input 
              v-model:value="listForm.description" 
              type="textarea" 
              placeholder="Add a description for your listing..."
              :rows="3"
            />
          </n-form-item>
        </n-form>
        
        <div class="listing-summary">
          <h4>Listing Summary</h4>
          <div class="summary-item">
            <span>Sale Price:</span>
            <span class="summary-value">{{ listForm.price || 0 }} ETH</span>
          </div>
          <div class="summary-item">
            <span>Platform Fee (2.5%):</span>
            <span class="summary-value">-{{ ((listForm.price || 0) * 0.025).toFixed(4) }} ETH</span>
          </div>
          <div class="summary-item">
            <span>Gas Fee (Estimated):</span>
            <span class="summary-value">-0.005 ETH</span>
          </div>
          <div class="summary-item total">
            <span>You'll Receive:</span>
            <span class="summary-value">{{ ((listForm.price || 0) - (listForm.price || 0) * 0.025 - 0.005).toFixed(4) }} ETH</span>
          </div>
        </div>
      </div>
      
      <template #action>
        <n-space>
          <n-button @click="showListDialog = false">Cancel</n-button>
          <n-button type="primary" @click="confirmListing" :loading="isListing">
            <template #icon>
              <n-icon :component="CashOutline" />
            </template>
            List for Sale
          </n-button>
        </n-space>
      </template>
    </n-modal>

    <!-- Error State -->
    <div v-else class="error-state">
      <n-empty description="NFT not found" size="large">
        <template #extra>
          <n-button @click="goBack">Go Back</n-button>
        </template>
      </n-empty>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { 
  NButton, NIcon, NSpin, NEmpty, NTag, NModal, NForm, NFormItem, 
  NInputNumber, NSelect, NInput, NSpace, useMessage 
} from 'naive-ui'
import {
  ArrowBackOutline, CashOutline, CardOutline, ShareOutline, LinkOutline,
  DownloadOutline
} from '@vicons/ionicons5'
import dayjs from 'dayjs'

const route = useRoute()
const router = useRouter()
const message = useMessage()

// Reactive data
const isLoading = ref(true)
const isListing = ref(false)
const nft = ref(null)
const showListDialog = ref(false)
const listFormRef = ref(null)

// Current user info
const currentUser = ref(null)

// List form data
const listForm = ref({
  price: 0,
  duration: '',
  royalty: 2.5,
  description: ''
})

// Duration options
const durationOptions = [
  { label: '1 Day', value: '1d' },
  { label: '3 Days', value: '3d' },
  { label: '1 Week', value: '1w' },
  { label: '2 Weeks', value: '2w' },
  { label: '1 Month', value: '1m' },
  { label: '3 Months', value: '3m' },
  { label: '6 Months', value: '6m' }
]

// Form validation rules
const listRules = {
  price: [
    { 
      validator: (rule, value) => {
        if (value === null || value === undefined || value < 0.001) {
          return new Error('Price must be at least 0.001 ETH')
        }
        return true
      }, 
      trigger: 'blur' 
    }
  ],
  duration: [
    { required: true, message: 'Please select sale duration', trigger: 'change' }
  ],
  royalty: [
    { 
      validator: (rule, value) => {
        if (value === null || value === undefined || value === '') {
          return new Error('Please enter royalty percentage')
        }
        const numValue = Number(value)
        if (isNaN(numValue) || numValue < 0 || numValue > 10) {
          return new Error('Royalty must be between 0 and 10 percent')
        }
        return true
      }, 
      trigger: 'blur' 
    }
  ]
}

// Computed properties
const isOwner = computed(() => {
  if (!currentUser.value || !nft.value) return false
  return nft.value.owner?.walletAddress === currentUser.value.wallet_address
})

// Methods
const loadNFTDetails = async () => {
  isLoading.value = true
  try {
    const nftId = route.params.nftId
    
    // Call backend API to get NFT details
    const response = await fetch(`http://localhost:3000/api/nfts/${nftId}`)
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }
    
    const nftData = await response.json()
    nft.value = nftData
    
    // Update view count
    await updateViewCount(nftId)
    
  } catch (error) {
    console.error('Failed to load NFT details:', error)
    message.error('Failed to load NFT details')
  } finally {
    isLoading.value = false
  }
}

const updateViewCount = async (nftId) => {
  try {
    await fetch(`http://localhost:3000/api/nfts/${nftId}/view`, {
      method: 'POST'
    })
  } catch (error) {
    console.error('Failed to update view count:', error)
  }
}

const loadCurrentUser = () => {
  const userData = localStorage.getItem('user')
  if (userData) {
    currentUser.value = JSON.parse(userData)
  }
}

const getStatusType = (status) => {
  switch (status) {
    case 'Minted': return 'info'
    case 'Listed': return 'warning'
    case 'Sold': return 'success'
    default: return 'default'
  }
}

const formatDate = (date) => {
  return dayjs(date).format('MMM DD, YYYY')
}

const formatTokenId = (tokenId) => {
  if (!tokenId) return 'N/A'
  if (tokenId.length <= 16) return tokenId
  return `${tokenId.slice(0, 8)}...${tokenId.slice(-8)}`
}

const formatAddress = (address) => {
  if (!address) return 'N/A'
  if (address.length <= 16) return address
  return `${address.slice(0, 6)}...${address.slice(-4)}`
}

const goBack = () => {
  router.push('/nft')
}

const openListDialog = () => {
  // Check if NFT is free
  if (nft.value.openAccess === true || nft.value.price === 0 || nft.value.accessPrice === 0) {
    message.warning('Free NFTs cannot be listed for sale')
    return
  }
  
  // Pre-fill form with current NFT data
  listForm.value = {
    price: nft.value.price || nft.value.accessPrice || 0.1,
    duration: '1w',
    royalty: 2.5,
    description: `${nft.value.assetType}: ${nft.value.title}`
  }
  showListDialog.value = true
}

const confirmListing = async () => {
  try {
    await listFormRef.value?.validate()
    isListing.value = true
    
    const nftId = route.params.nftId
    
    // Call backend API to list NFT for sale
    const response = await fetch(`http://localhost:3000/api/nfts/${nftId}/list`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        price: listForm.value.price,
        duration: listForm.value.duration,
        royalty: listForm.value.royalty,
        description: listForm.value.description,
        walletAddress: currentUser.value?.wallet_address
      })
    })
    
    if (!response.ok) {
      const errorData = await response.json()
      throw new Error(errorData.error || 'Failed to list NFT')
    }
    
    const result = await response.json()
    
    // Update local NFT data
    nft.value = {
      ...nft.value,
      status: 'Listed',
      price: listForm.value.price,
      listedAt: new Date().toISOString(),
      listingDescription: listForm.value.description
    }
    
    message.success('NFT listed for sale successfully!')
    showListDialog.value = false
    
    // Reset form
    listForm.value = {
      price: 0,
      duration: '',
      royalty: 2.5,
      description: ''
    }
    
  } catch (error) {
    console.error('Failed to list NFT:', error)
    message.error(error.message || 'Failed to list NFT for sale')
  } finally {
    isListing.value = false
  }
}

const buyNFT = () => {
  message.info('Buy NFT functionality will be implemented')
  // TODO: Implement buy functionality
}

const shareNFT = () => {
  const shareUrl = `${window.location.origin}/nft/${route.params.nftId}`
  navigator.clipboard.writeText(shareUrl)
  message.success('NFT link copied to clipboard!')
}

const viewOnBlockchain = () => {
  if (nft.value?.tokenId) {
    message.info(`Opening blockchain explorer for token: ${nft.value.tokenId}`)
    // TODO: Open actual blockchain explorer
  }
}

const downloadContent = () => {
  if (nft.value?.contentCID) {
    message.info(`Downloading content: ${nft.value.contentCID}`)
    // TODO: Implement download functionality
  }
}

onMounted(() => {
  loadCurrentUser()
  loadNFTDetails()
})
</script>

<style scoped>
.nft-detail-page {
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

.nft-detail-content {
  max-width: 1400px;
  margin: 0 auto;
  padding: 24px;
}

.page-header {
  margin-bottom: 32px;
}

.back-btn {
  color: #58a6ff;
}

.nft-content {
  display: flex;
  flex-direction: column;
  gap: 32px;
}

.content-grid {
  display: grid;
  grid-template-columns: 1fr 1.5fr;
  gap: 32px;
}

.left-column {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.nft-image-card {
  background: #161b22;
  border: 1px solid #30363d;
  border-radius: 12px;
  overflow: hidden;
}

.nft-image-container {
  position: relative;
  width: 100%;
  height: 400px;
  overflow: hidden;
}

.nft-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.nft-overlay {
  position: absolute;
  top: 16px;
  right: 16px;
}

.nft-actions {
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.secondary-actions {
  display: flex;
  gap: 8px;
}

.right-column {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.nft-info {
  background: #161b22;
  border: 1px solid #30363d;
  border-radius: 12px;
  padding: 24px;
}

.nft-header {
  margin-bottom: 24px;
}

.nft-title {
  font-size: 2rem;
  font-weight: 700;
  color: #c9d1d9;
  margin: 0 0 12px 0;
  line-height: 1.3;
}

.nft-meta {
  display: flex;
  gap: 12px;
  align-items: center;
}

.asset-type {
  background: #58a6ff;
  color: #ffffff;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 500;
}

.category {
  color: #8b949e;
  font-size: 0.9rem;
}

.nft-description {
  margin-bottom: 24px;
}

.nft-description h3 {
  font-size: 1.2rem;
  font-weight: 600;
  color: #c9d1d9;
  margin: 0 0 12px 0;
}

.nft-description p {
  font-size: 1rem;
  color: #8b949e;
  line-height: 1.6;
  margin: 0;
}

.nft-details {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.detail-section h3 {
  font-size: 1.1rem;
  font-weight: 600;
  color: #c9d1d9;
  margin: 0 0 16px 0;
}

.detail-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}

.detail-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.detail-label {
  font-size: 0.85rem;
  color: #8b949e;
  font-weight: 500;
}

.detail-value {
  font-size: 0.9rem;
  color: #c9d1d9;
  font-family: 'SF Mono', Monaco, 'Cascadia Code', monospace;
}

.authors-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.author-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 12px;
  background: #0d1117;
  border: 1px solid #30363d;
  border-radius: 6px;
}

.author-address {
  font-family: 'SF Mono', Monaco, 'Cascadia Code', monospace;
  font-size: 0.85rem;
  color: #c9d1d9;
}

.author-share {
  font-size: 0.8rem;
  color: #58a6ff;
  font-weight: 500;
}

.keywords-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.keyword-tag {
  font-size: 0.8rem;
}

.content-info {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.cid-display {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.cid-label {
  font-size: 0.85rem;
  color: #8b949e;
  font-weight: 500;
}

.cid-value {
  font-family: 'SF Mono', Monaco, 'Cascadia Code', monospace;
  font-size: 0.8rem;
  color: #c9d1d9;
  background: #0d1117;
  padding: 8px 12px;
  border: 1px solid #30363d;
  border-radius: 6px;
  word-break: break-all;
}

.access-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.access-price {
  font-size: 0.9rem;
  color: #8b949e;
}

/* Dialog Styles */
.dialog-header {
  display: flex;
  align-items: center;
  gap: 8px;
}

.dialog-icon {
  font-size: 20px;
  color: #58a6ff;
}

.list-form {
  padding: 20px 0;
}

.nft-preview {
  margin-bottom: 24px;
  padding: 16px;
  background: #21262d;
  border: 1px solid #30363d;
  border-radius: 8px;
}

.preview-header {
  display: flex;
  gap: 16px;
  align-items: flex-start;
}

.preview-image {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 8px;
  flex-shrink: 0;
}

.preview-info {
  flex: 1;
}

.preview-info h3 {
  font-size: 1.1rem;
  font-weight: 600;
  color: #c9d1d9;
  margin: 0 0 8px 0;
  line-height: 1.4;
}

.preview-category {
  font-size: 0.85rem;
  color: #58a6ff;
  margin: 0;
}

.price-feedback {
  font-size: 0.8rem;
  color: #8b949e;
}

.royalty-feedback {
  font-size: 0.8rem;
  color: #8b949e;
}

.listing-summary {
  margin-top: 24px;
  padding: 16px;
  background: #21262d;
  border: 1px solid #30363d;
  border-radius: 8px;
}

.listing-summary h4 {
  font-size: 1rem;
  font-weight: 600;
  color: #c9d1d9;
  margin: 0 0 16px 0;
}

.summary-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px solid #30363d;
}

.summary-item:last-child {
  border-bottom: none;
}

.summary-item.total {
  font-weight: 600;
  color: #c9d1d9;
  border-top: 2px solid #58a6ff;
  margin-top: 8px;
  padding-top: 12px;
}

.summary-value {
  font-weight: 500;
  color: #58a6ff;
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

:deep(.n-input) {
  background-color: #0d1117;
  border-color: #30363d;
}

:deep(.n-select) {
  background-color: #0d1117;
}

/* Responsive design */
@media (max-width: 1200px) {
  .content-grid {
    grid-template-columns: 1fr;
  }
  
  .detail-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .nft-detail-content {
    padding: 16px;
  }
  
  .secondary-actions {
    flex-direction: column;
  }
  
  .preview-header {
    flex-direction: column;
    text-align: center;
  }
}
</style> 