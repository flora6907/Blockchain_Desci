<template>
  <div class="dataset-detail-page">
    <div class="page-header">
      <n-button text @click="goBack" class="back-btn">
        <template #icon>
          <n-icon :component="ArrowBackOutline" />
        </template>
        Back to Explore
      </n-button>
      
      <div class="header-content">
        <div class="dataset-title-section">
          <div class="title-row">
            <n-icon :component="getDatasetIcon(dataset)" class="dataset-icon" />
            <h1 class="dataset-title">{{ dataset.name || 'Loading...' }}</h1>
            <div class="title-tags">
              <n-tag :type="getPrivacyType(dataset.privacy_level)" size="small">
                <template #icon>
                  <n-icon :component="getPrivacyIcon(dataset.privacy_level)" />
                </template>
                {{ getPrivacyLabel(dataset.privacy_level) }}
              </n-tag>
              
              <n-tag v-if="dataset.zk_proof_id" type="success" size="small">
                <template #icon>
                  <n-icon :component="ShieldCheckmarkOutline" />
                </template>
                ZK Protected
              </n-tag>
            </div>
          </div>
          
          <p class="dataset-description">{{ dataset.description || 'No description provided' }}</p>
        </div>
        
        <div class="header-actions">
          <n-button-group>
            <!-- Purchase NFT Button -->
            <n-button 
              v-if="availableNFT && availableNFT.status === 'for_sale'"
              @click="purchaseNFT" 
              :loading="isPurchasing" 
              type="primary"
              size="large"
            >
              <template #icon>
                <n-icon :component="CashOutline" />
              </template>
              Buy NFT for {{ availableNFT.price }} {{ availableNFT.currency }}
            </n-button>
            
            <n-button @click="downloadDataset" :loading="isDownloading" type="primary">
              <template #icon>
                <n-icon :component="DownloadOutline" />
              </template>
              Download
            </n-button>
            
            <n-button v-if="canQuery" @click="goToPrivateQuery" type="primary">
              <template #icon>
                <n-icon :component="SearchOutline" />
              </template>
              Query
            </n-button>
          </n-button-group>
        </div>
      </div>
    </div>

    <div class="dataset-content">
      <n-spin :show="isLoading">
        <div class="content-grid">
          <!-- Left Column: Main Info -->
          <div class="main-column">
            <n-card title="Dataset Information" class="info-card">
              <div class="info-grid">
                <div class="info-item">
                  <div class="info-label">
                    <n-icon :component="PersonOutline" />
                    Owner
                  </div>
                  <div class="info-value">{{ dataset.owner_username || 'Unknown' }}</div>
                </div>
                
                <div class="info-item">
                  <div class="info-label">
                    <n-icon :component="FolderOutline" />
                    Category
                  </div>
                  <div class="info-value">{{ dataset.category || 'Other' }}</div>
                </div>
                
                <div class="info-item">
                  <div class="info-label">
                    <n-icon :component="DocumentOutline" />
                    File Size
                  </div>
                  <div class="info-value">{{ formatFileSize(dataset.file_size) }}</div>
                </div>
                
                <div class="info-item">
                  <div class="info-label">
                    <n-icon :component="CodeOutline" />
                    File Type
                  </div>
                  <div class="info-value">{{ dataset.file_type || 'Unknown' }}</div>
                </div>
                
                <div class="info-item">
                  <div class="info-label">
                    <n-icon :component="CalendarOutline" />
                    Created
                  </div>
                  <div class="info-value">{{ formatDate(dataset.created_at) }}</div>
                </div>
                
                <div class="info-item">
                  <div class="info-label">
                    <n-icon :component="TimeOutline" />
                    Updated
                  </div>
                  <div class="info-value">{{ formatDate(dataset.updated_at) }}</div>
                </div>
              </div>
            </n-card>

            <n-card v-if="dataset.project_name" title="Project Association" class="project-card">
              <div class="project-info">
                <n-icon :component="LayersOutline" class="project-icon" />
                <div class="project-details">
                  <h4 class="project-name">{{ dataset.project_name }}</h4>
                  <p class="project-description">This dataset is associated with a research project</p>
                </div>
              </div>
            </n-card>

            <n-card title="Tags" class="tags-card">
              <div v-if="datasetTags.length > 0" class="bilibili-tags-display">
                <div class="tags-count-info">
                  <n-icon :component="PricetagOutline" class="tags-icon" />
                  <span class="tags-count-text">{{ datasetTags.length }} tags</span>
                </div>
                <div class="bilibili-tags-list">
                  <div 
                    v-for="tag in datasetTags" 
                    :key="tag" 
                    class="bilibili-display-tag"
                  >
                    <n-icon :component="PricetagOutline" class="tag-icon" />
                    <span class="tag-content">{{ tag }}</span>
                  </div>
                </div>
              </div>
              <div v-else class="empty-tags-display">
                <div class="empty-icon-wrapper">
                  <n-icon :component="PricetagOutline" class="empty-tags-icon" />
                </div>
                <div class="empty-text">
                  <span class="empty-title">No Tags</span>
                  <span class="empty-description">This dataset has no tags yet</span>
                </div>
              </div>
            </n-card>
          </div>

          <!-- Right Column: Stats & Privacy Info -->
          <div class="side-column">
            <n-card title="Usage Statistics" class="stats-card">
              <div class="stats-grid">
                <div class="stat-item">
                  <div class="stat-icon">
                    <n-icon :component="EyeOutline" />
                  </div>
                  <div class="stat-content">
                    <div class="stat-number">{{ dataset.access_count || 0 }}</div>
                    <div class="stat-label">Views</div>
                  </div>
                </div>
                
                <div class="stat-item">
                  <div class="stat-icon">
                    <n-icon :component="DownloadOutline" />
                  </div>
                  <div class="stat-content">
                    <div class="stat-number">{{ dataset.download_count || 0 }}</div>
                    <div class="stat-label">Downloads</div>
                  </div>
                </div>
              </div>
            </n-card>

            <!-- NFT Purchase Card -->
            <n-card v-if="availableNFT" title="🎯 NFT Available for Purchase" class="nft-purchase-card">
              <div class="nft-purchase-content">
                <div class="nft-price-display">
                  <n-icon :component="DiamondOutline" class="nft-icon" />
                  <div class="price-info">
                    <div class="price-amount">{{ availableNFT.price }} {{ availableNFT.currency }}</div>
                    <div class="price-label">Dataset NFT</div>
                  </div>
                </div>
                
                <div class="nft-description">
                  {{ availableNFT.description }}
                </div>
                
                <div class="nft-seller-info">
                  <span class="seller-label">Seller:</span>
                  <span class="seller-name">{{ availableNFT.seller_username }}</span>
                </div>
                
                <n-button 
                  @click="purchaseNFT" 
                  :loading="isPurchasing" 
                  type="primary"
                  size="large"
                  block
                  class="purchase-button"
                >
                  <template #icon>
                    <n-icon :component="CashOutline" />
                  </template>
                  Purchase Dataset NFT
                </n-button>
              </div>
            </n-card>

            <n-card title="Privacy & Security" class="privacy-card">
              <div class="privacy-info">
                <div class="privacy-level">
                  <n-icon :component="getPrivacyIcon(dataset.privacy_level)" class="privacy-icon" />
                  <div class="privacy-details">
                    <h4>{{ getPrivacyLabel(dataset.privacy_level) }}</h4>
                    <p>{{ getPrivacyDescription(dataset.privacy_level) }}</p>
                  </div>
                </div>
                
                <div v-if="dataset.zk_proof_id" class="zk-proof-status">
                  <n-alert type="success" size="small">
                    <template #icon>
                      <n-icon :component="ShieldCheckmarkOutline" />
                    </template>
                    Zero-Knowledge Proof Available
                  </n-alert>
                </div>
              </div>
              
              <div v-if="canQuery" class="privacy-actions">
                <n-button @click="goToPrivateQuery" type="primary" block>
                  <template #icon>
                    <n-icon :component="SearchOutline" />
                  </template>
                  Private Query
                </n-button>
              </div>
            </n-card>

            <n-card title="Owner Information" class="owner-card">
              <div class="owner-info">
                <n-avatar round size="large" :src="dataset.owner_avatar">
                  {{ (dataset.owner_username || 'U')[0].toUpperCase() }}
                </n-avatar>
                <div class="owner-details">
                  <h4 class="owner-name">{{ dataset.owner_username || 'Unknown User' }}</h4>
                  <p class="owner-role">Dataset Owner</p>
                </div>
              </div>
              
              <div v-if="dataset.owner_bio" class="owner-bio">
                <p>{{ dataset.owner_bio }}</p>
              </div>
            </n-card>
          </div>
        </div>
      </n-spin>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { 
  NButton, NIcon, NCard, NTag, NButtonGroup, NSpin, NAlert, NAvatar, useMessage
} from 'naive-ui'
import {
  ArrowBackOutline, DownloadOutline, PersonOutline, FolderOutline, 
  DocumentOutline, CodeOutline, CalendarOutline, TimeOutline, LayersOutline, 
  EyeOutline, SearchOutline, ShieldCheckmarkOutline, GlobeOutline,
  LockClosedOutline, PricetagOutline, DocumentTextOutline, GridOutline, 
  ServerOutline, DocumentAttachOutline, ImageOutline, CashOutline
} from '@vicons/ionicons5'
import axios from 'axios'
import dayjs from 'dayjs'

const route = useRoute()
const router = useRouter()
const message = useMessage()

// Reactive data
const dataset = ref({})
const isLoading = ref(true)
const isDownloading = ref(false)
const isPurchasing = ref(false)
const currentUser = ref(null)
const availableNFT = ref(null)

// Computed
const datasetId = computed(() => {
  const id = route.params.dataset_id
  console.log('Route params:', route.params)
  console.log('Dataset ID from route:', id, 'Type:', typeof id)
  return id
})

const datasetTags = computed(() => {
  if (!dataset.value.tags) return []
  
  // If tags is already an array (from backend parsing), return it directly
  if (Array.isArray(dataset.value.tags)) {
    return dataset.value.tags
  }
  
  // If tags is a string, try to parse it
  if (typeof dataset.value.tags === 'string') {
    try {
      const parsed = JSON.parse(dataset.value.tags)
      return Array.isArray(parsed) ? parsed : []
    } catch {
      // If JSON parsing fails, treat as comma-separated string
      console.warn('Tags not in JSON format, parsing as comma-separated string:', dataset.value.tags)
      return dataset.value.tags.split(',').map(tag => tag.trim()).filter(tag => tag.length > 0)
    }
  }
  
  // Fallback for unexpected data types
  return []
})

const canQuery = computed(() => {
  return dataset.value.privacy_level === 'zk_proof_protected' && dataset.value.zk_proof_id
})

// Methods
const goBack = () => {
  router.push('/explore')
}

const formatFileSize = (bytes) => {
  if (!bytes || bytes === 0) return '0 Bytes'
  const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB']
  const i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)))
  return Math.round(100 * (bytes / Math.pow(1024, i))) / 100 + ' ' + sizes[i]
}

const formatDate = (date) => {
  if (!date) return 'Unknown'
  return dayjs(date).format('MMM D, YYYY HH:mm')
}

const getDatasetIcon = (dataset) => {
  const fileType = dataset.file_type?.toLowerCase()
  if (fileType?.includes('json')) return GridOutline
  if (fileType?.includes('csv')) return DocumentAttachOutline
  if (fileType?.includes('database')) return ServerOutline
  if (fileType?.includes('image')) return ImageOutline
  return DocumentTextOutline
}

const getPrivacyType = (privacyLevel) => {
  switch (privacyLevel) {
    case 'public': return 'info'
    case 'private': return 'warning'
    case 'encrypted': return 'error'
    case 'zk_proof_protected': return 'success'
    default: return 'default'
  }
}

const getPrivacyIcon = (privacyLevel) => {
  switch (privacyLevel) {
    case 'public': return GlobeOutline
    case 'private': return LockClosedOutline
    case 'encrypted': return LockClosedOutline
    case 'zk_proof_protected': return ShieldCheckmarkOutline
    default: return GlobeOutline
  }
}

const getPrivacyLabel = (privacyLevel) => {
  switch (privacyLevel) {
    case 'public': return 'Public'
    case 'private': return 'Private'
    case 'encrypted': return 'Encrypted'
    case 'zk_proof_protected': return 'ZK Protected'
    default: return 'Public'
  }
}

const getPrivacyDescription = (privacyLevel) => {
  switch (privacyLevel) {
    case 'public': return 'This dataset is publicly accessible'
    case 'private': return 'Access requires permission from owner'
    case 'encrypted': return 'Dataset is encrypted and secure'
    case 'zk_proof_protected': return 'Protected by zero-knowledge proofs'
    default: return 'Privacy level unknown'
  }
}

const downloadDataset = async () => {
  isDownloading.value = true
  try {
    // TODO: Implement actual download functionality
    message.success('Download started')
    
    // Log usage if user is authenticated
    if (currentUser.value?.wallet_address) {
      await axios.post(`http://localhost:3000/api/datasets/${datasetId.value}/usage`, {
        action_type: 'download',
        wallet_address: currentUser.value.wallet_address
      })
    }
  } catch (error) {
    message.error('Download failed')
  } finally {
    isDownloading.value = false
  }
}

const goToPrivateQuery = () => {
  router.push(`/zkp/private-query?dataset_id=${datasetId.value}`)
}

const fetchCurrentUser = async () => {
  try {
    const userData = localStorage.getItem('user')
    if (userData) {
      currentUser.value = JSON.parse(userData)
    }
  } catch (error) {
    console.error('Failed to get current user:', error)
  }
}

const fetchDataset = async () => {
  try {
    console.log('Fetching dataset with ID:', datasetId.value);
    
    // Test server connection first
    try {
      await axios.get('http://localhost:3000/api/publications/test')
      console.log('Server connection test passed')
    } catch (testError) {
      console.error('Server connection test failed:', testError)
      throw new Error('Backend server is not running or not accessible')
    }
    
    // Use explore endpoint for public access
    const response = await axios.get(`http://localhost:3000/api/datasets/explore/${datasetId.value}`)
    console.log('Dataset response:', response.data);
    dataset.value = response.data
    
    // Check for available NFTs for this dataset
    await checkAvailableNFT()
    
    // Log view if user is authenticated
    if (currentUser.value?.wallet_address) {
      try {
        await axios.post(`http://localhost:3000/api/datasets/${datasetId.value}/usage`, {
          action_type: 'view',
          wallet_address: currentUser.value.wallet_address
        })
        console.log('Usage logged successfully')
      } catch (usageError) {
        console.warn('Failed to log usage:', usageError)
        // Don't throw error for usage logging failure
      }
    }
  } catch (error) {
    console.error('Failed to fetch dataset:', error)
    console.error('Error details:', {
      message: error.message,
      response: error.response?.data,
      status: error.response?.status,
      config: error.config
    })
    
    if (error.code === 'ECONNREFUSED' || error.message.includes('Network Error')) {
      message.error('Cannot connect to server. Please make sure the backend is running.')
    } else if (error.response?.status === 403) {
      message.error('This dataset is private and not accessible.')
    } else if (error.response?.status === 404) {
      message.error('Dataset not found. Please check the dataset ID and try again.')
    } else {
      message.error(`Failed to load dataset: ${error.message}`)
    }
    
    // Don't auto-redirect, let user decide what to do
    // User can use the back button to return to explore
  } finally {
    isLoading.value = false
  }
}

const checkAvailableNFT = async () => {
  try {
    if (!dataset.value?.project_id) return;
    
    // Get marketplace NFTs for this project/dataset
    const response = await axios.get(`http://localhost:3000/api/nfts/marketplace/project/${dataset.value.project_id}`)
    const marketplaceNFTs = response.data
    
    // Find dataset NFT that is listed for sale
    const datasetNFT = marketplaceNFTs.find(nft => 
      nft.token_id.includes('DATASET_')
    )
    
    if (datasetNFT) {
      availableNFT.value = {
        id: datasetNFT.id,
        nft_id: datasetNFT.nft_id,
        price: datasetNFT.price,
        currency: datasetNFT.currency,
        description: datasetNFT.description,
        seller_username: datasetNFT.seller_username,
        token_id: datasetNFT.token_id,
        status: 'for_sale'
      }
      console.log('Found available NFT for purchase:', availableNFT.value)
    }
  } catch (error) {
    console.error('Failed to check available NFTs:', error)
    // Don't show error to user as this is not critical
  }
}

const purchaseNFT = async () => {
  if (!availableNFT.value) {
    message.error('No NFT available for purchase')
    return
  }
  
  if (!currentUser.value?.wallet_address) {
    message.error('Please log in to purchase NFTs')
    return
  }
  
  isPurchasing.value = true
  
  try {
    message.info(`Purchasing NFT for ${availableNFT.value.price} ${availableNFT.value.currency}...`)
    
    // Call purchase API
    const response = await axios.post('http://localhost:3000/api/nfts/marketplace/purchase', {
      marketplace_id: availableNFT.value.id,
      buyer_wallet_address: currentUser.value.wallet_address
    })
    
    if (response.data.success) {
      message.success(`NFT purchased successfully for ${response.data.transaction.price} ${response.data.transaction.currency}!`)
      
      // Clear the available NFT since it's been purchased
      availableNFT.value = null
      
      // Optionally redirect to user's NFT collection after a delay
      setTimeout(() => {
        router.push('/nft')
      }, 2000)
    } else {
      message.error('Failed to purchase NFT')
    }
    
  } catch (error) {
    console.error('Purchase failed:', error)
    if (error.response?.data?.error) {
      message.error(error.response.data.error)
    } else {
      message.error('Failed to purchase NFT')
    }
  } finally {
    isPurchasing.value = false
  }
}

onMounted(async () => {
  await fetchCurrentUser()
  await fetchDataset()
})
</script>

<style scoped>
.dataset-detail-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 24px;
  background-color: #0d1117;
  color: #c9d1d9;
  min-height: 100vh;
}

.page-header {
  margin-bottom: 32px;
}

.back-btn {
  color: #8b949e;
  margin-bottom: 16px;
}

.back-btn:hover {
  color: #58a6ff;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 32px;
}

.dataset-title-section {
  flex: 1;
}

.title-row {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 12px;
}

.dataset-icon {
  font-size: 32px;
  color: #58a6ff;
}

.dataset-title {
  font-size: 32px;
  font-weight: 700;
  color: #c9d1d9;
  margin: 0;
  flex: 1;
}

.title-tags {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.dataset-description {
  color: #8b949e;
  font-size: 16px;
  line-height: 1.6;
  margin: 0;
}

.header-actions {
  flex-shrink: 0;
}

.dataset-content {
  min-height: 400px;
}

.content-grid {
  display: grid;
  grid-template-columns: 1fr 350px;
  gap: 32px;
}

.main-column {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.side-column {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.info-card,
.project-card,
.tags-card,
.stats-card,
.privacy-card,
.owner-card {
  background: #161b22;
  border: 1px solid #30363d;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.info-label {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #8b949e;
  font-size: 14px;
  font-weight: 500;
}

.info-label .n-icon {
  font-size: 16px;
}

.info-value {
  color: #c9d1d9;
  font-size: 15px;
  font-weight: 500;
}

.project-info {
  display: flex;
  align-items: center;
  gap: 16px;
}

.project-icon {
  font-size: 24px;
  color: #58a6ff;
}

.project-details {
  flex: 1;
}

.project-name {
  font-size: 16px;
  font-weight: 600;
  color: #c9d1d9;
  margin: 0 0 4px 0;
}

.project-description {
  font-size: 14px;
  color: #8b949e;
  margin: 0;
}

/* Bilibili-style tags display */
.bilibili-tags-display {
  padding: 4px 0;
}

.tags-count-info {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid #30363d;
}

.tags-icon {
  font-size: 16px;
  color: #58a6ff;
}

.tags-count-text {
  font-size: 13px;
  color: #8b949e;
  font-weight: 500;
}

.bilibili-tags-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.bilibili-display-tag {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: #21262d;
  border: 1px solid #373e47;
  border-radius: 12px;
  padding: 6px 10px;
  font-size: 13px;
  color: #c9d1d9;
  transition: all 0.15s ease;
  cursor: default;
}

.bilibili-display-tag:hover {
  background: #30363d;
  border-color: #58a6ff;
  transform: translateY(-1px);
}

.tag-icon {
  font-size: 12px;
  color: #58a6ff;
  opacity: 0.8;
}

.tag-content {
  font-weight: 500;
  user-select: text;
}

.empty-tags-display {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 24px;
  text-align: center;
  border: 1px dashed #373e47;
  border-radius: 8px;
  background: rgba(22, 27, 34, 0.3);
}

.empty-icon-wrapper {
  margin-bottom: 12px;
}

.empty-tags-icon {
  font-size: 32px;
  color: #373e47;
  opacity: 0.6;
}

.empty-text {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.empty-title {
  font-size: 14px;
  color: #8b949e;
  font-weight: 500;
}

.empty-description {
  font-size: 12px;
  color: #6e7681;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
  margin-bottom: 16px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  background: rgba(56, 139, 253, 0.05);
  border: 1px solid rgba(56, 139, 253, 0.2);
  border-radius: 8px;
}

.stat-icon {
  font-size: 20px;
  color: #58a6ff;
}

.stat-content {
  flex: 1;
}

.stat-number {
  font-size: 20px;
  font-weight: 700;
  color: #c9d1d9;
  margin-bottom: 2px;
}

.stat-label {
  font-size: 12px;
  color: #8b949e;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.privacy-info {
  margin-bottom: 20px;
}

.privacy-level {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  margin-bottom: 16px;
}

.privacy-icon {
  font-size: 24px;
  color: #58a6ff;
  margin-top: 2px;
}

.privacy-details h4 {
  font-size: 16px;
  font-weight: 600;
  color: #c9d1d9;
  margin: 0 0 4px 0;
}

.privacy-details p {
  font-size: 14px;
  color: #8b949e;
  margin: 0;
}

.zk-proof-status {
  margin-top: 12px;
}

.privacy-actions {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.owner-info {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 16px;
}

.owner-details {
  flex: 1;
}

.owner-name {
  font-size: 16px;
  font-weight: 600;
  color: #c9d1d9;
  margin: 0 0 4px 0;
}

.owner-role {
  font-size: 14px;
  color: #8b949e;
  margin: 0;
}

.owner-bio {
  padding-top: 16px;
  border-top: 1px solid #30363d;
}

.owner-bio p {
  font-size: 14px;
  color: #8b949e;
  line-height: 1.5;
  margin: 0;
}

/* Responsive design */
@media (max-width: 1024px) {
  .content-grid {
    grid-template-columns: 1fr;
  }
  
  .side-column {
    order: -1;
  }
}

@media (max-width: 768px) {
  .dataset-detail-page {
    padding: 16px;
  }
  
  .header-content {
    flex-direction: column;
    align-items: stretch;
    gap: 20px;
  }
  
  .title-row {
    flex-wrap: wrap;
    gap: 12px;
  }
  
  .dataset-title {
    font-size: 24px;
  }
  
  .info-grid {
    grid-template-columns: 1fr;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
  }
}

/* NFT Purchase Card Styles */
.nft-purchase-card {
  border: 2px solid #1f6feb;
  background: linear-gradient(135deg, rgba(31, 111, 235, 0.1), rgba(31, 111, 235, 0.05));
  box-shadow: 0 8px 32px rgba(31, 111, 235, 0.2);
}

.nft-purchase-card .n-card__header {
  color: #1f6feb;
  font-weight: 600;
}

.nft-purchase-content {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.nft-price-display {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  background: rgba(31, 111, 235, 0.1);
  border-radius: 12px;
  border: 1px solid rgba(31, 111, 235, 0.2);
}

.nft-icon {
  font-size: 24px;
  color: #1f6feb;
}

.price-info {
  flex: 1;
}

.price-amount {
  font-size: 24px;
  font-weight: 700;
  color: #1f6feb;
  line-height: 1;
}

.price-label {
  font-size: 14px;
  color: #8b949e;
  margin-top: 4px;
}

.nft-description {
  color: #c9d1d9;
  line-height: 1.5;
  font-size: 14px;
  background: rgba(255, 255, 255, 0.02);
  padding: 12px;
  border-radius: 8px;
}

.nft-seller-info {
  display: flex;
  justify-content: space-between;
  padding: 8px 12px;
  background: rgba(255, 255, 255, 0.02);
  border-radius: 8px;
}

.seller-label {
  color: #8b949e;
  font-size: 14px;
}

.seller-name {
  color: #f1f3f4;
  font-weight: 500;
  font-size: 14px;
}

.purchase-button {
  background: linear-gradient(135deg, #1f6feb, #388bfd);
  border: none;
  font-weight: 600;
  height: 48px;
  border-radius: 12px;
  font-size: 16px;
  box-shadow: 0 4px 16px rgba(31, 111, 235, 0.3);
  transition: all 0.3s ease;
}

.purchase-button:hover {
  background: linear-gradient(135deg, #388bfd, #58a6ff);
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(31, 111, 235, 0.4);
}

.purchase-button:active {
  transform: translateY(0);
}
</style> 