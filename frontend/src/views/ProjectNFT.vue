<template>
  <div class="project-nft-page">
    <div class="page-header">
      <div class="header-content">
        <div class="header-navigation">
          <n-button text @click="goBack" class="back-btn">
            <template #icon>
              <n-icon :component="ArrowBackOutline" />
            </template>
            Back to NFT Gallery
          </n-button>
        </div>
      </div>
    </div>

    <div class="nft-content">
      <!-- Loading State -->
      <div v-if="isLoading" class="loading-state">
        <n-spin size="large" />
        <p>Checking project status...</p>
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="error-state">
        <div class="error-icon">
          <n-icon :component="AlertCircleOutline" />
        </div>
        <h3>Unable to Load Project</h3>
        <p>{{ error }}</p>
        <n-button @click="goBack" type="primary">
          Back to NFT Gallery
        </n-button>
      </div>

      <!-- No Completed Projects State -->
      <div v-else-if="showNoCompletedProjectsWarning" class="warning-state">
        <div class="warning-icon">
          <n-icon :component="WarningOutline" />
        </div>
        <h3>Project Not Ready for NFT Minting</h3>
        <p>Only completed projects can be minted as NFTs. This project has status: <strong>{{ projectStatus }}</strong></p>
        <div class="warning-details">
          <p>To mint this project as an NFT, please:</p>
          <ul>
            <li>Complete all project milestones</li>
            <li>Update the project status to "Completed"</li>
            <li>Ensure all deliverables are finalized</li>
          </ul>
        </div>
        <div class="warning-actions">
          <n-button @click="goToProject" type="primary">
            Go to Project
          </n-button>
          <n-button @click="goBack" secondary>
            Back to NFT Gallery
          </n-button>
        </div>
      </div>

      <!-- NFT Mint Form - Only show for completed projects -->
      <div v-else>
        <NFTMintForm 
          :preset-asset-type="presetAssetType"
          :preset-asset-id="presetAssetId"
          :title="mintFormTitle"
          @success="onMintSuccess"
          @error="onMintError"
          @cancel="goBack"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { NButton, NIcon, NSpin, useMessage } from 'naive-ui'
import { ArrowBackOutline, AlertCircleOutline, WarningOutline } from '@vicons/ionicons5'
import NFTMintForm from '../components/NFTMintForm.vue'
import axios from 'axios'

const route = useRoute()
const router = useRouter()
const message = useMessage()

// Reactive data
const presetAssetType = ref('')
const presetAssetId = ref(null)
const isLoading = ref(false)
const error = ref(null)
const projectStatus = ref('')
const projectData = ref(null)

// Computed properties
const mintFormTitle = computed(() => {
  if (presetAssetType.value) {
    return `Mint ${presetAssetType.value} as NFT`
  }
  return 'Mint Asset as NFT'
})

const showNoCompletedProjectsWarning = computed(() => {
  return presetAssetType.value === 'Project' && 
         presetAssetId.value && 
         projectStatus.value !== 'Completed' &&
         !error.value
})

// Methods
const goBack = () => {
  // Always go back to NFT Gallery
  router.push('/nft')
}

const goToProject = () => {
  if (presetAssetId.value) {
    router.push(`/projects/${presetAssetId.value}`)
  } else {
    router.push('/projects')
  }
}

const onMintSuccess = (result) => {
  console.log('NFT minted successfully:', result)
  // The NFTMintForm component will handle navigation
}

const onMintError = (error) => {
  console.error('Failed to mint NFT:', error)
}

const fetchProjectDetails = async (projectId) => {
  if (!projectId) return
  
  isLoading.value = true
  error.value = null
  
  try {
    console.log('🔍 [ProjectNFT] Fetching project details for ID:', projectId)
    
    const response = await axios.get(`http://localhost:3000/api/projects/${projectId}`)
    projectData.value = response.data
    projectStatus.value = response.data.status || 'Unknown'
    
    console.log('📊 [ProjectNFT] Project status:', projectStatus.value)
    
    if (projectStatus.value !== 'Completed') {
      console.log('⚠️ [ProjectNFT] Project not completed, showing warning')
      message.warning(`Project status is "${projectStatus.value}" - only completed projects can be minted as NFTs`)
    } else {
      console.log('✅ [ProjectNFT] Project is completed, allowing NFT minting')
    }
    
  } catch (err) {
    console.error('❌ [ProjectNFT] Failed to fetch project details:', err)
    error.value = err.response?.data?.error || 'Failed to load project details'
    message.error('Failed to load project information')
  } finally {
    isLoading.value = false
  }
}

// Initialize component based on route
onMounted(async () => {
  // Check if we're coming from a specific project
  if (route.params.projectId) {
    presetAssetType.value = 'Project'
    presetAssetId.value = parseInt(route.params.projectId)
    await fetchProjectDetails(presetAssetId.value)
  }
  
  // Check query parameters for asset type and ID
  if (route.query.assetType) {
    presetAssetType.value = route.query.assetType
  }
  
  if (route.query.assetId) {
    presetAssetId.value = parseInt(route.query.assetId)
    
    // If it's a project asset, fetch details
    if (presetAssetType.value === 'Project') {
      await fetchProjectDetails(presetAssetId.value)
    }
  }
})
</script>

<style scoped>
.project-nft-page {
  min-height: 100vh;
  background: #0d1117;
  color: #c9d1d9;
}

.page-header {
  background: #161b22;
  border-bottom: 1px solid #30363d;
  padding: 24px 0;
}

.header-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 24px;
}

.header-navigation {
  margin-bottom: 0;
}

.back-btn {
  color: #58a6ff;
  font-size: 0.9rem;
}

.nft-content {
  padding: 32px 0;
}

.loading-state, .error-state, .warning-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  padding: 60px 20px;
  max-width: 600px;
  margin: 0 auto;
}

.loading-state p {
  margin-top: 16px;
  color: #8b949e;
  font-size: 1rem;
}

.error-state {
  background: #161b22;
  border: 1px solid #30363d;
  border-radius: 12px;
}

.error-icon {
  font-size: 4rem;
  color: #f85149;
  margin-bottom: 24px;
}

.error-state h3 {
  font-size: 1.5rem;
  font-weight: 600;
  color: #c9d1d9;
  margin: 0 0 12px 0;
}

.error-state p {
  font-size: 1rem;
  color: #8b949e;
  margin: 0 0 24px 0;
}

.warning-state {
  background: #161b22;
  border: 1px solid #d29922;
  border-radius: 12px;
}

.warning-icon {
  font-size: 4rem;
  color: #d29922;
  margin-bottom: 24px;
}

.warning-state h3 {
  font-size: 1.5rem;
  font-weight: 600;
  color: #c9d1d9;
  margin: 0 0 12px 0;
}

.warning-state p {
  font-size: 1rem;
  color: #8b949e;
  margin: 0 0 16px 0;
  line-height: 1.6;
}

.warning-details {
  background: rgba(210, 153, 34, 0.1);
  border: 1px solid rgba(210, 153, 34, 0.3);
  border-radius: 8px;
  padding: 20px;
  margin: 24px 0;
  text-align: left;
}

.warning-details p {
  font-weight: 600;
  color: #c9d1d9;
  margin-bottom: 12px;
}

.warning-details ul {
  margin: 0;
  padding-left: 20px;
  color: #8b949e;
}

.warning-details li {
  margin-bottom: 8px;
  line-height: 1.5;
}

.warning-actions {
  display: flex;
  gap: 12px;
  justify-content: center;
  flex-wrap: wrap;
  margin-top: 24px;
}

/* Responsive design */
@media (max-width: 768px) {
  .header-content {
    padding: 0 16px;
  }
  
  .page-header {
    padding: 16px 0;
  }
  
  .nft-content {
    padding: 16px 0;
  }
  
  .loading-state, .error-state, .warning-state {
    padding: 40px 16px;
    margin: 0 16px;
  }
  
  .warning-actions {
    flex-direction: column;
    align-items: stretch;
  }
  
  .warning-details {
    margin: 16px 0;
    padding: 16px;
  }
}
</style> 