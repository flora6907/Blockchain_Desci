<template>
  <div class="paper-publish-page">
    <div class="page-header">
      <h1 class="page-title">Publish Paper</h1>
      <p class="page-description">Choose how to publish your research paper</p>
    </div>
    
    <div class="publish-options">
      <n-card title="Publication Options" class="publish-card">
        <div class="options-grid">
          <div class="option-card" :class="{ 'selected': selectedOption === 'peer-review' }" @click="selectedOption = 'peer-review'">
            <n-icon :component="PeopleOutline" class="option-icon" />
            <h3>Peer Review</h3>
            <p>Submit for formal peer review process</p>
            <n-button type="primary" @click="submitForReview" :disabled="selectedOption !== 'peer-review'">
              Submit for Review
            </n-button>
          </div>
          
          <div class="option-card" :class="{ 'selected': selectedOption === 'preprint' }" @click="selectedOption = 'preprint'">
            <n-icon :component="FlashOutline" class="option-icon" />
            <h3>Direct Publication</h3>
            <p>Publish immediately as preprint</p>
            <n-button type="primary" @click="publishDirect" :disabled="selectedOption !== 'preprint'">
              Publish Now
            </n-button>
          </div>
        </div>
        
        <div class="form-actions">
          <n-button @click="goBack">Back to Preview</n-button>
        </div>
      </n-card>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { NCard, NButton, NIcon, useMessage } from 'naive-ui'
import { PeopleOutline, FlashOutline } from '@vicons/ionicons5'

const router = useRouter()
const route = useRoute()
const message = useMessage()

const selectedOption = ref('')

const goBack = () => {
  router.push(`/papers/${route.params.paper_id}/preview`)
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
      console.log('Publication automatically minted as NFT')
    }
  } catch (error) {
    console.error('Failed to auto-mint publication NFT:', error)
    // Don't throw error to avoid interrupting the publish process
  }
}

const submitForReview = () => {
  message.success('Paper submitted for peer review!')
  router.push(`/papers/${route.params.paper_id}`)
}

const publishDirect = async () => {
  try {
    // First update paper status to Published
    const response = await fetch(`http://localhost:3000/api/publications/${route.params.paper_id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        status: 'Published',
        published_at: new Date().toISOString()
      })
    })

    if (!response.ok) {
      throw new Error('Failed to publish paper')
    }

    // Auto-mint as NFT
    await autoMintPublicationNFT(route.params.paper_id)
    
    message.success('Paper published successfully and minted as NFT!')
    router.push(`/papers/${route.params.paper_id}`)
  } catch (error) {
    console.error('Failed to publish paper:', error)
    message.error('Failed to publish paper. Please try again.')
  }
}
</script>

<style scoped>
.paper-publish-page {
  padding: 24px;
  max-width: 1200px;
  margin: 0 auto;
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
  margin: 0 0 32px 0;
}

.publish-card {
  background: #161b22;
  border: 1px solid #30363d;
}

.options-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
  margin-bottom: 24px;
}

.option-card {
  padding: 24px;
  border: 1px solid #30363d;
  border-radius: 12px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
}

.option-card:hover {
  border-color: #58a6ff;
}

.option-card.selected {
  border-color: #58a6ff;
  background: rgba(88, 166, 255, 0.1);
}

.option-icon {
  font-size: 48px;
  color: #58a6ff;
  margin-bottom: 16px;
}

.option-card h3 {
  margin: 0 0 12px 0;
  color: #c9d1d9;
  font-size: 1.25rem;
}

.option-card p {
  margin: 0 0 16px 0;
  color: #8b949e;
}

.form-actions {
  display: flex;
  justify-content: flex-start;
  gap: 12px;
  padding-top: 24px;
  border-top: 1px solid #30363d;
}
</style> 