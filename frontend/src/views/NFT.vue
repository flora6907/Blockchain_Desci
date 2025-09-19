<template>
  <div class="nft-page">
    <!-- Page Header -->
    <div class="page-header">
      <div class="header-content">
        <div class="header-text">
          <h1 class="page-title">NFT Collections</h1>
          <p class="page-description">
            Your research publications minted as NFTs on the blockchain
          </p>
        </div>
        <div class="header-actions">
          <n-button type="primary" @click="goToMintPage">
            <template #icon>
              <n-icon :component="AddOutline" />
            </template>
            Mint New NFT
          </n-button>
        </div>
      </div>
    </div>

    <!-- Filters and Search -->
    <div class="filters-section">
      <div class="search-container">
        <n-input
          v-model:value="searchQuery"
          placeholder="Search NFTs by title, author, or category..."
          clearable
          class="search-input"
        >
          <template #prefix>
            <n-icon :component="SearchOutline" />
          </template>
        </n-input>
      </div>
      
      <div class="filter-container">
        <n-select
          v-model:value="selectedCategory"
          :options="categoryOptions"
          placeholder="Category"
          clearable
          class="filter-select"
        />
        <n-select
          v-model:value="selectedStatus"
          :options="statusOptions"
          placeholder="Status"
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

    <!-- NFT Stats -->
    <div class="stats-section">
      <n-grid :cols="4" :x-gap="24">
        <n-gi>
          <n-statistic label="Total NFTs" :value="filteredNFTs.length" />
        </n-gi>
        <n-gi>
          <n-statistic label="Total Value" :value="totalValue" :precision="2" />
        </n-gi>
        <n-gi>
          <n-statistic label="This Month" :value="thisMonthCount" />
        </n-gi>
        <n-gi>
          <n-statistic label="Floor Price" :value="floorPrice" :precision="3" />
        </n-gi>
      </n-grid>
    </div>

    <!-- Loading State -->
    <div v-if="isLoadingNFTs" class="loading-container">
      <n-spin size="large">
        <template #description>Loading your NFTs...</template>
      </n-spin>
    </div>

    <!-- NFT Grid -->
    <div v-else class="nft-grid">
      <div 
        v-for="nft in paginatedNFTs" 
        :key="nft.id" 
        class="nft-card"
        @click="viewNFTDetails(nft)"
      >
        <div class="nft-image-container">
          <img :src="nft.image" :alt="nft.title" class="nft-image" />
          <div class="nft-overlay">
            <n-tag :type="getStatusType(nft.status)" size="small" class="status-tag">
              {{ nft.status }}
            </n-tag>
            <div class="overlay-actions">
              <n-button circle size="small" @click.stop="shareNFT(nft)">
                <template #icon>
                  <n-icon :component="ShareOutline" />
                </template>
              </n-button>
              <n-button circle size="small" @click.stop="viewOnBlockchain(nft)">
                <template #icon>
                  <n-icon :component="LinkOutline" />
                </template>
              </n-button>
            </div>
          </div>
        </div>
        
        <div class="nft-content">
          <div class="nft-header">
            <h3 class="nft-title">{{ nft.title }}</h3>
            <div class="nft-price">
              <span class="price-value">
                {{ nft.openAccess ? 'Free' : `${nft.price || nft.accessPrice || 0} ETH` }}
              </span>
              <span v-if="!nft.openAccess" class="price-usd">
                ${{ ((nft.price || nft.accessPrice || 0) * 2500).toFixed(0) }}
              </span>
            </div>
          </div>
          
          <div class="nft-meta">
            <div class="meta-item">
              <n-icon :component="PersonOutline" class="meta-icon" />
              <span>{{ Array.isArray(nft.authors) ? nft.authors.join(', ') : nft.authors || 'Unknown' }}</span>
            </div>
            <div class="meta-item">
              <n-icon :component="CalendarOutline" class="meta-icon" />
              <span>{{ formatDate(nft.mintedAt) }}</span>
            </div>
            <div class="meta-item">
              <n-icon :component="EyeOutline" class="meta-icon" />
              <span>{{ nft.views }} views</span>
            </div>
          </div>
          
          <div class="nft-tags">
            <n-tag 
              v-for="tag in (Array.isArray(nft.tags) ? nft.tags : []).slice(0, 2)" 
              :key="tag" 
              size="small" 
              class="nft-tag"
            >
              {{ tag }}
            </n-tag>
            <span v-if="Array.isArray(nft.tags) && nft.tags.length > 2" class="more-tags">
              +{{ nft.tags.length - 2 }} more
            </span>
          </div>
          
          <div class="nft-actions">
            <n-button size="small" @click.stop="downloadPaper(nft)">
              <template #icon>
                <n-icon :component="DownloadOutline" />
              </template>
              Download
            </n-button>
            <n-button 
              v-if="!nft.openAccess && (nft.price > 0 || nft.accessPrice > 0)"
              size="small" 
              type="primary" 
              @click.stop="listForSale(nft)"
            >
              <template #icon>
                <n-icon :component="CashOutline" />
              </template>
              List for Sale
            </n-button>
            <n-button 
              v-else
              size="small" 
              disabled
              @click.stop
            >
              <template #icon>
                <n-icon :component="CashOutline" />
              </template>
              Free NFT
            </n-button>
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
        :page-sizes="[8, 16, 24, 32]"
        @update:page-size="handlePageSizeChange"
      />
    </div>

    <!-- Empty State -->
    <div v-if="filteredNFTs.length === 0" class="empty-state">
      <n-empty description="No NFTs found" size="large">
        <template #extra>
          <n-button type="primary" @click="showMintDialog = true">
            Mint Your First NFT
          </n-button>
        </template>
      </n-empty>
    </div>

    <!-- Mint Dialog -->
    <n-modal v-model:show="showMintDialog" preset="dialog" title="Mint New NFT">
      <template #header>
        <div class="dialog-header">
          <n-icon :component="DiamondOutline" class="dialog-icon" />
          <span>Mint Research Paper as NFT</span>
        </div>
      </template>
      <div class="mint-form">
        <n-form :model="mintForm" ref="mintFormRef" :rules="mintRules">
          <n-form-item label="Paper Title" path="title">
            <n-input v-model:value="mintForm.title" placeholder="Enter paper title" />
          </n-form-item>
          <n-form-item label="Authors" path="authors">
            <n-input v-model:value="mintForm.authors" placeholder="Enter authors (comma separated)" />
          </n-form-item>
          <n-form-item label="Category" path="category">
            <n-select v-model:value="mintForm.category" :options="categoryOptions" placeholder="Select category" />
          </n-form-item>
          
          <n-form-item label="Access Type" path="accessType">
            <n-radio-group v-model:value="mintForm.accessType">
              <n-radio value="open">Open Access (Free)</n-radio>
              <n-radio value="restricted">Restricted Access</n-radio>
            </n-radio-group>
          </n-form-item>
          
          <!-- Revenue sharing for restricted access -->
          <div v-if="mintForm.accessType === 'restricted'" class="revenue-sharing-section">
            <n-form-item label="Revenue Sharing" path="authorShares">
              <div class="author-shares">
                <div v-for="(author, index) in parsedAuthors" :key="index" class="author-share-item">
                  <span class="author-name">{{ author.trim() }}</span>
                  <n-input-number 
                    v-model:value="mintForm.authorShares[index]" 
                    :min="0" 
                    :max="100" 
                    :step="1"
                    suffix="%"
                    :placeholder="`${Math.floor(100 / parsedAuthors.length)}`"
                  />
                </div>
              </div>
              <template #feedback>
                <span class="share-feedback">
                  Total: {{ totalShares }}% (must equal 100%)
                </span>
              </template>
            </n-form-item>
          </div>
          
          <n-form-item label="Paper File" path="file">
            <n-upload
              :file-list="mintForm.fileList"
              :max="1"
              accept=".pdf"
              @change="handleFileChange"
            >
              <n-button>Upload PDF</n-button>
            </n-upload>
          </n-form-item>
        </n-form>
      </div>
      <template #action>
        <n-space>
          <n-button @click="showMintDialog = false">Cancel</n-button>
          <n-button type="primary" @click="mintNFT" :loading="isMinting">
            Mint NFT
          </n-button>
        </n-space>
      </template>
    </n-modal>

    <!-- List for Sale Dialog -->
    <n-modal v-model:show="showListDialog" preset="dialog" title="List NFT for Sale">
      <template #header>
        <div class="dialog-header">
          <n-icon :component="CashOutline" class="dialog-icon" />
          <span>List NFT for Sale</span>
        </div>
      </template>
      
      <div v-if="selectedNFT" class="list-form">
        <div class="nft-preview">
          <div class="preview-header">
            <img :src="selectedNFT.image" :alt="selectedNFT.title" class="preview-image" />
            <div class="preview-info">
              <h3>{{ selectedNFT.title }}</h3>
              <p class="preview-authors">{{ selectedNFT.authors.join(', ') }}</p>
              <p class="preview-category">{{ selectedNFT.category }}</p>
            </div>
          </div>
        </div>
        
        <n-form :model="listForm" ref="listFormRef" :rules="listRules">
          <n-form-item label="Sale Price (ETH)" path="price">
            <n-input-number 
              v-model:value="listForm.price" 
              :min="0" 
              :step="0.01" 
              placeholder="0.00" 
              style="width: 100%"
            />
            <template #feedback>
              <span class="price-feedback">
                Current market price: ~{{ getMarketPrice() }} ETH
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
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { 
  NButton, NInput, NSelect, NGrid, NGi, NStatistic, NTag, NIcon, 
  NPagination, NEmpty, NModal, NForm, NFormItem, NInputNumber, 
  NUpload, NSpace, NSpin, NRadio, NRadioGroup, useMessage 
} from 'naive-ui'
import {
  AddOutline, SearchOutline, ShareOutline, LinkOutline, PersonOutline,
  CalendarOutline, EyeOutline, DownloadOutline, CashOutline, DiamondOutline
} from '@vicons/ionicons5'
import dayjs from 'dayjs'

const message = useMessage()
const route = useRoute()
const router = useRouter()

// Reactive data
const searchQuery = ref('')
const selectedCategory = ref(null)
const selectedStatus = ref(null)
const sortBy = ref('newest')
const currentPage = ref(1)
const pageSize = ref(8)
const showMintDialog = ref(false)
const isMinting = ref(false)
const currentPaperData = ref(null)

// List for Sale dialog data
const showListDialog = ref(false)
const isListing = ref(false)
const selectedNFT = ref(null)
const listFormRef = ref(null)

// NFT data from API
const nfts = ref([])
const isLoadingNFTs = ref(true)

// Form data for minting
const mintForm = ref({
  title: '',
  authors: '',
  category: null,
  accessType: 'open', // 'open' or 'restricted'
  authorShares: [], // Array of percentage shares for each author
  fileList: []
})

const mintFormRef = ref(null)

// Form data for listing
const listForm = ref({
  price: 0,
  duration: null,
  royalty: 2.5,
  description: ''
})

// Options
const categoryOptions = [
  { label: 'Computer Science', value: 'Computer Science' },
  { label: 'Medical Science', value: 'Medical Science' },
  { label: 'Environmental Science', value: 'Environmental Science' },
  { label: 'Biotechnology', value: 'Biotechnology' },
  { label: 'Marine Biology', value: 'Marine Biology' },
  { label: 'Physics', value: 'Physics' },
  { label: 'Chemistry', value: 'Chemistry' },
  { label: 'Mathematics', value: 'Mathematics' }
]

const statusOptions = [
  { label: 'Minted', value: 'Minted' },
  { label: 'Listed', value: 'Listed' },
  { label: 'Sold', value: 'Sold' }
]

const durationOptions = [
  { label: '1 Day', value: '1d' },
  { label: '3 Days', value: '3d' },
  { label: '1 Week', value: '1w' },
  { label: '2 Weeks', value: '2w' },
  { label: '1 Month', value: '1m' },
  { label: '3 Months', value: '3m' },
  { label: '6 Months', value: '6m' },
  { label: '1 Year', value: '1y' }
]

const sortOptions = [
  { label: 'Newest First', value: 'newest' },
  { label: 'Oldest First', value: 'oldest' },
  { label: 'Price: High to Low', value: 'price_desc' },
  { label: 'Price: Low to High', value: 'price_asc' },
  { label: 'Most Views', value: 'views' }
]

// Form validation rules
const mintRules = {
  title: [
    { required: true, message: 'Please enter paper title', trigger: 'blur' }
  ],
  authors: [
    { required: true, message: 'Please enter authors', trigger: 'blur' }
  ],
  category: [
    { required: true, message: 'Please select category', trigger: 'change' }
  ],
  accessType: [
    { required: true, message: 'Please select access type', trigger: 'change' }
  ],
  authorShares: [
    { 
      validator: (rule, value) => {
        if (mintForm.value.accessType === 'restricted') {
          if (!value || value.length === 0) {
            return new Error('Please set revenue sharing for all authors')
          }
          const total = value.reduce((sum, share) => sum + (share || 0), 0)
          if (total !== 100) {
            return new Error('Total revenue shares must equal 100%')
          }
        }
        return true
      }, 
      trigger: 'blur' 
    }
  ]
}

const listRules = {
  price: [
    { 
      validator: (rule, value) => {
        if (value === null || value === undefined || value === '') {
          return new Error('Please enter sale price')
        }
        const numValue = Number(value)
        if (isNaN(numValue) || numValue <= 0) {
          return new Error('Price must be greater than 0')
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
const filteredNFTs = computed(() => {
  let filtered = nfts.value

  // Search filter
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(nft => 
      nft.title.toLowerCase().includes(query) ||
      nft.authors.some(author => author.toLowerCase().includes(query)) ||
      nft.category.toLowerCase().includes(query) ||
      nft.tags.some(tag => tag.toLowerCase().includes(query))
    )
  }

  // Category filter
  if (selectedCategory.value) {
    filtered = filtered.filter(nft => nft.category === selectedCategory.value)
  }

  // Status filter
  if (selectedStatus.value) {
    filtered = filtered.filter(nft => nft.status === selectedStatus.value)
  }

  // Sorting
  filtered = filtered.sort((a, b) => {
    switch (sortBy.value) {
      case 'newest':
        return new Date(b.mintedAt) - new Date(a.mintedAt)
      case 'oldest':
        return new Date(a.mintedAt) - new Date(b.mintedAt)
      case 'price_desc':
        return b.price - a.price
      case 'price_asc':
        return a.price - b.price
      case 'views':
        return b.views - a.views
      default:
        return 0
    }
  })

  return filtered
})

const paginatedNFTs = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return filteredNFTs.value.slice(start, end)
})

const totalPages = computed(() => {
  return Math.ceil(filteredNFTs.value.length / pageSize.value)
})

const totalValue = computed(() => {
  return nfts.value.reduce((sum, nft) => sum + nft.price, 0)
})

const thisMonthCount = computed(() => {
  const thisMonth = dayjs().format('YYYY-MM')
  return nfts.value.filter(nft => nft.mintedAt.startsWith(thisMonth)).length
})

const floorPrice = computed(() => {
  const prices = nfts.value.map(nft => nft.price)
  return Math.min(...prices)
})

// Mint form computed properties
const parsedAuthors = computed(() => {
  if (!mintForm.value.authors) return []
  return mintForm.value.authors.split(',').map(a => a.trim()).filter(a => a.length > 0)
})

const totalShares = computed(() => {
  return mintForm.value.authorShares.reduce((sum, share) => sum + (share || 0), 0)
})

// Watch for changes in authors to initialize shares
watch(parsedAuthors, (newAuthors) => {
  if (newAuthors.length > 0) {
    // Initialize shares array if needed
    if (mintForm.value.authorShares.length !== newAuthors.length) {
      const equalShare = Math.floor(100 / newAuthors.length)
      const remainder = 100 - (equalShare * newAuthors.length)
      
      mintForm.value.authorShares = newAuthors.map((_, index) => 
        index === 0 ? equalShare + remainder : equalShare
      )
    }
  }
})

// Methods
const loadNFTs = async () => {
  isLoadingNFTs.value = true
  try {
    // Get current user's wallet address
    const userData = localStorage.getItem('user')
    if (!userData) {
      message.error('Please log in to view your NFTs')
      return
    }
    
    const user = JSON.parse(userData)
    const walletAddress = user.wallet_address
    
    if (!walletAddress) {
      message.error('Wallet address not found')
      return
    }
    
    // Fetch NFTs from backend API
    const response = await fetch(`http://localhost:3000/api/nfts/user/${walletAddress}`)
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }
    
    const nftData = await response.json()
    
    // Transform the data to match the expected format
    nfts.value = nftData.map(nft => ({
      id: nft.id,
      title: nft.title,
      authors: Array.isArray(nft.authors) ? nft.authors.map(a => a.name || a.address || a) : [nft.owner?.username || 'Unknown'],
      category: nft.category || 'Research',
      tags: nft.keywords || nft.tags || ['Research', 'NFT'],
      image: nft.image || `https://via.placeholder.com/300x400/1a1a2e/eee?text=${encodeURIComponent((nft.title || 'NFT').substring(0, 20))}`,
      price: parseFloat(nft.price || nft.accessPrice || 0),
      status: nft.status || 'Minted',
      mintedAt: nft.mintedAt || nft.created_at,
      views: nft.views || 0,
      tokenId: nft.tokenId,
      blockchain: 'Ethereum',
      assetType: nft.assetType,
      openAccess: nft.openAccess,
      accessPrice: nft.accessPrice,
      contentCID: nft.contentCID
    }))
    
    console.log('Loaded NFTs:', nfts.value)
    
  } catch (error) {
    console.error('Failed to load NFTs:', error)
    message.error('Failed to load NFTs')
  } finally {
    isLoadingNFTs.value = false
  }
}

const formatDate = (date) => {
  return dayjs(date).format('MMM DD, YYYY')
}

const getStatusType = (status) => {
  switch (status) {
    case 'Minted': return 'info'
    case 'Listed': return 'warning'
    case 'Sold': return 'success'
    default: return 'default'
  }
}

const handlePageSizeChange = (newPageSize) => {
  pageSize.value = newPageSize
  currentPage.value = 1
}

const handleFileChange = ({ fileList }) => {
  mintForm.value.fileList = fileList
}

const viewNFTDetails = (nft) => {
  router.push(`/nft/${nft.id}`)
}

const goToMintPage = () => {
  router.push('/nft/mint')
}

const shareNFT = (nft) => {
  navigator.clipboard.writeText(`${window.location.origin}/nfts/${nft.id}`)
  message.success('NFT link copied to clipboard!')
}

const viewOnBlockchain = (nft) => {
  message.info(`Opening blockchain explorer for token: ${nft.tokenId}`)
  // TODO: Open blockchain explorer
}

const downloadPaper = async (nft) => {
  try {
    message.info(`Downloading: ${nft.title}`)
    
    if (!nft.fileUrl && !nft.filePath) {
      message.warning('This NFT has no associated file')
      return
    }
    
    const downloadUrl = nft.fileUrl || nft.filePath
    
    if (downloadUrl.startsWith('http')) {
      const link = document.createElement('a')
      link.href = downloadUrl
      link.download = `${nft.title}.pdf`
      link.target = '_blank'
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      message.success('Download started')
      return
    }
    
    const response = await fetch(`/api/nfts/${nft.id}/download`, {
      method: 'GET',
      headers: {
        'Accept': 'application/pdf, application/octet-stream'
      }
    })
    
    if (!response.ok) {
      throw new Error(`Download failed: ${response.statusText}`)
    }
    
    const contentDisposition = response.headers.get('Content-Disposition')
    let filename = `${nft.title}.pdf`
    if (contentDisposition) {
      const filenameMatch = contentDisposition.match(/filename="(.+)"/)
      if (filenameMatch) {
        filename = filenameMatch[1]
      }
    }
    
    const blob = await response.blob()
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = filename
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    URL.revokeObjectURL(url)
    
    message.success('Download completed')
    
  } catch (error) {
    console.error('Download error:', error)
    message.error(`Download failed: ${error.message}`)
  }
}

const listForSale = (nft) => {
  // Check if NFT is free
  if (nft.openAccess === true || nft.price === 0 || nft.accessPrice === 0) {
    message.warning('Free NFTs cannot be listed for sale')
    return
  }
  
  selectedNFT.value = nft
  // Pre-fill form with current NFT data
  listForm.value = {
    price: nft.price || nft.accessPrice || 0.1,
    duration: '1w', // Default to 1 week
    royalty: 2.5,
    description: `${nft.assetType || 'Research'}: ${nft.title} by ${Array.isArray(nft.authors) ? nft.authors.join(', ') : nft.authors || 'Author'}`
  }
  showListDialog.value = true
}

const getMarketPrice = () => {
  // Mock market price calculation
  const basePrice = 0.1
  const categoryMultiplier = {
    'Computer Science': 1.2,
    'Medical Science': 1.5,
    'Environmental Science': 1.1,
    'Biotechnology': 1.3,
    'Marine Biology': 1.0,
    'Physics': 1.1,
    'Chemistry': 1.0,
    'Mathematics': 1.1
  }
  
  if (selectedNFT.value) {
    const multiplier = categoryMultiplier[selectedNFT.value.category] || 1.0
    return (basePrice * multiplier).toFixed(3)
  }
  return basePrice.toFixed(3)
}

const confirmListing = async () => {
  try {
    await listFormRef.value?.validate()
    isListing.value = true
    
    // Simulate blockchain transaction
    await new Promise(resolve => setTimeout(resolve, 3000))
    
    // Update NFT status
    const nftIndex = nfts.value.findIndex(n => n.id === selectedNFT.value.id)
    if (nftIndex !== -1) {
      nfts.value[nftIndex] = {
        ...nfts.value[nftIndex],
        status: 'Listed',
        price: listForm.value.price,
        listedAt: new Date().toISOString().split('T')[0],
        listingDuration: listForm.value.duration,
        royalty: listForm.value.royalty,
        description: listForm.value.description
      }
    }
    
    message.success(`NFT "${selectedNFT.value.title}" listed for sale successfully!`)
    showListDialog.value = false
    
    // Reset form
    listForm.value = {
      price: 0,
      duration: null,
      royalty: 2.5,
      description: ''
    }
    selectedNFT.value = null
    
  } catch (error) {
    console.error('Listing failed:', error)
    message.error('Failed to list NFT for sale. Please check your inputs.')
  } finally {
    isListing.value = false
  }
}

const mintNFT = async () => {
  try {
    await mintFormRef.value?.validate()
    isMinting.value = true
    
    // Get current user's wallet address
    const userData = localStorage.getItem('user')
    if (!userData) {
      message.error('Please log in to mint NFTs')
      return
    }
    
    const user = JSON.parse(userData)
    const walletAddress = user.wallet_address
    
    if (!walletAddress) {
      message.error('Wallet address not found')
      return
    }
    
    // Prepare author data with revenue shares
    const authorsData = parsedAuthors.value.map((authorName, index) => ({
      address: index === 0 ? walletAddress : `0x${Math.random().toString(16).substr(2, 40)}`, // First author gets user's address
      name: authorName.trim(),
      share: mintForm.value.accessType === 'restricted' ? mintForm.value.authorShares[index] : 0
    }))
    
    // Prepare mint data
    const mintData = {
      assetType: 'Custom',
      selectedAsset: 0, // Custom asset
      title: mintForm.value.title,
      category: mintForm.value.category,
      keywords: JSON.stringify(['Research', 'NFT', 'Blockchain']),
      description: `Research NFT for: ${mintForm.value.title}`,
      authors: JSON.stringify(authorsData),
      contentCID: `QmCustom${Date.now()}${Math.random().toString(36).substr(2, 8)}`,
      openAccess: mintForm.value.accessType === 'open',
      accessPrice: 0, // Price will be set later when listing for sale
      isLimitedEdition: false,
      editionSize: 0,
      coverImageCID: `QmImage${Date.now()}${Math.random().toString(36).substr(2, 8)}`
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
    
    showMintDialog.value = false
    message.success('NFT minted successfully!')
    
    // Reset form
    mintForm.value = {
      title: '',
      authors: '',
      category: null,
      accessType: 'open',
      authorShares: [],
      fileList: []
    }
    
    // Reload NFTs to show the new one
    await loadNFTs()
    
  } catch (error) {
    console.error('Mint error:', error)
    message.error(error.message || 'Failed to mint NFT')
  } finally {
    isMinting.value = false
  }
}

onMounted(() => {
  // Load NFTs from backend
  loadNFTs()
  
  // Check if we should open mint dialog and pre-fill with paper data
  if (route.query.mint === 'true') {
    showMintDialog.value = true
    
    // 检查是否有论文数据
    if (route.query.paper_data) {
      try {
        // 解码论文数据
        const paperData = JSON.parse(atob(route.query.paper_data))
        
        // 存储论文数据用于预览
        currentPaperData.value = paperData
        
        // 预填充表单
        mintForm.value = {
          title: paperData.title,
          authors: paperData.authors,
          category: paperData.category,
          accessType: 'restricted', // 默认为限制访问，用户可以修改
          authorShares: [], // 将在authors改变时自动初始化
          fileList: []
        }
        
        // 显示论文信息
        message.success(`已加载论文信息: ${paperData.title}`)
        console.log('Loaded paper data:', paperData)
        
      } catch (error) {
        console.error('Failed to parse paper data:', error)
        message.error('无法解析论文数据，请重试')
      }
    } else if (route.query.paper_id) {
      // 兼容旧的 paper_id 参数
      const paperId = route.query.paper_id
      mintForm.value = {
        title: `Research Paper #${paperId}`,
        authors: 'Dr. Jane Smith, Dr. John Doe',
        category: 'Research',
        accessType: 'restricted',
        authorShares: [], // 将在authors改变时自动初始化
        fileList: []
      }
      
      message.info('Pre-filled with paper data. Please review and adjust as needed.')
    }
  }
})
</script>

<style scoped>
.nft-page {
  padding: 24px;
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 32px;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 24px;
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

.filters-section {
  background: #161b22;
  border: 1px solid #30363d;
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 32px;
}

.search-container {
  margin-bottom: 16px;
}

.search-input {
  max-width: 400px;
}

.filter-container {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.filter-select {
  min-width: 140px;
}

.stats-section {
  background: #161b22;
  border: 1px solid #30363d;
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 32px;
}

.nft-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 24px;
  margin-bottom: 32px;
}

.nft-card {
  background: #161b22;
  border: 1px solid #30363d;
  border-radius: 12px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s ease;
}

.nft-card:hover {
  border-color: #58a6ff;
  transform: translateY(-4px);
  box-shadow: 0 8px 32px rgba(88, 166, 255, 0.1);
}

.nft-image-container {
  position: relative;
  width: 100%;
  height: 200px;
  overflow: hidden;
}

.nft-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.nft-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(to bottom, rgba(0,0,0,0.3), transparent, rgba(0,0,0,0.7));
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  padding: 12px;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.nft-card:hover .nft-overlay {
  opacity: 1;
}

.status-tag {
  align-self: flex-start;
}

.overlay-actions {
  display: flex;
  gap: 8px;
}

.nft-content {
  padding: 20px;
}

.nft-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
  gap: 12px;
}

.nft-title {
  font-size: 1.1rem;
  font-weight: 600;
  color: #c9d1d9;
  margin: 0;
  line-height: 1.4;
  flex: 1;
}

.nft-price {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  flex-shrink: 0;
}

.price-value {
  font-size: 1rem;
  font-weight: 600;
  color: #58a6ff;
}

.price-usd {
  font-size: 0.85rem;
  color: #8b949e;
}

.nft-meta {
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-bottom: 12px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.85rem;
  color: #8b949e;
}

.meta-icon {
  font-size: 14px;
}

.nft-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-bottom: 16px;
}

.nft-tag {
  font-size: 0.75rem;
}

.more-tags {
  font-size: 0.75rem;
  color: #8b949e;
  align-self: center;
}

.nft-actions {
  display: flex;
  gap: 8px;
}

.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 32px;
}

.loading-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 300px;
  padding: 60px 20px;
}

.empty-state {
  text-align: center;
  padding: 60px 20px;
}


.dialog-header {
  display: flex;
  align-items: center;
  gap: 8px;
}

.dialog-icon {
  font-size: 20px;
  color: #58a6ff;
}

.mint-form {
  padding: 20px 0;
}

.revenue-sharing-section {
  margin: 16px 0;
  padding: 16px;
  background: #21262d;
  border: 1px solid #30363d;
  border-radius: 8px;
}

.author-shares {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.author-share-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
}

.author-name {
  flex: 1;
  font-weight: 500;
  color: #c9d1d9;
}

.share-feedback {
  font-size: 0.8rem;
  color: #8b949e;
  margin-top: 4px;
}

/* List for Sale Dialog Styles */
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

.preview-authors {
  font-size: 0.9rem;
  color: #8b949e;
  margin: 0 0 4px 0;
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
</style> 