<template>
  <div>
    <!-- Profile Completion Alert -->
    <n-alert
      v-if="user && !isProfileComplete"
      title="Complete Your Profile"
      type="info"
      class="profile-alert"
    >
                To get the most out of Verno, please take a moment to complete your user profile.
      <template #action>
        <n-button type="primary" size="small" @click="goToProfile">
          Go to Profile
        </n-button>
      </template>
    </n-alert>

    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <n-spin size="large" />
      <p class="loading-text">Loading dashboard data...</p>
    </div>

    <!-- Stats Cards -->
    <n-grid v-else x-gap="24" y-gap="24" :cols="4" style="margin-bottom: 24px;">
      <n-gi>
        <n-card title="My Projects" class="stats-card projects-card">
          <template #header-extra>
            <n-icon :component="FolderOutline" class="card-icon projects-icon" />
          </template>
          <n-statistic label="Active" :value="dashboardStats?.projects?.active || 0" />
          <template #footer>
            <n-text depth="3" style="font-size: 12px;">
              Total: {{ dashboardStats?.projects?.total || 0 }}
            </n-text>
          </template>
        </n-card>
      </n-gi>
      <n-gi>
        <n-card title="Contributions" class="stats-card contributions-card">
          <template #header-extra>
            <n-icon :component="PeopleOutline" class="card-icon contributions-icon" />
          </template>
          <n-statistic label="Reviews" :value="dashboardStats?.reviews || 0" />
        </n-card>
      </n-gi>
      <n-gi>
        <n-card title="Citations" class="stats-card citations-card">
          <template #header-extra>
            <n-icon :component="DocumentTextOutline" class="card-icon citations-icon" />
          </template>
          <n-statistic label="Total" :value="dashboardStats?.citations || 0" />
        </n-card>
      </n-gi>
      <n-gi>
        <n-card title="Influence" class="stats-card influence-card clickable-card" @click="goToInfluence">
          <template #header-extra>
            <n-icon :component="TrophyOutline" class="card-icon influence-icon" />
          </template>
          <n-statistic 
            label="Score" 
            :value="dashboardStats?.influence || 1250" 
          />
          <template #footer>
            <n-text depth="3" style="font-size: 12px;">
              Scientific Impact
            </n-text>
          </template>
        </n-card>
      </n-gi>
    </n-grid>

    <!-- Recent Activity List -->
    <n-card title="Recent Activity" class="activity-card">
      <template #header-extra>
        <n-icon :component="TimeOutline" class="card-icon activity-icon" />
      </template>
      <div v-if="loading" class="activity-loading">
        <n-skeleton text :repeat="3" />
      </div>
      <n-list v-else-if="dashboardStats?.recentActivities?.length > 0">
        <n-list-item 
          v-for="activity in dashboardStats.recentActivities" 
          :key="`${activity.type}-${activity.timestamp}`"
          class="activity-list-item"
        >
          <div class="activity-item">
            <div class="activity-icon-wrapper">
              <n-icon :component="getActivityIcon(activity.type)" class="activity-type-icon" />
            </div>
            <div class="activity-content">
              <span class="activity-description">{{ activity.description }}</span>
              <span class="activity-time">{{ formatActivityTime(activity.timestamp) }}</span>
            </div>
          </div>
        </n-list-item>
      </n-list>
      <n-empty 
        v-else 
        description="No recent activity" 
        size="small"
        style="margin: 20px 0;"
      />
    </n-card>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { NGrid, NGi, NCard, NStatistic, NList, NListItem, NAlert, NButton, NSpin, NSkeleton, NEmpty, NText, NIcon } from 'naive-ui';
import { useRouter } from 'vue-router';
import { FolderOutline, PeopleOutline, DocumentTextOutline, TrophyOutline, TimeOutline, GitCommitOutline, EyeOutline, CloudUploadOutline } from '@vicons/ionicons5';
import dayjs from 'dayjs';
import relativeTime from 'dayjs/plugin/relativeTime';

dayjs.extend(relativeTime);

const router = useRouter();
const user = ref(null);
const dashboardStats = ref(null);
const loading = ref(true);
const error = ref(null);

const isProfileComplete = computed(() => {
  return user.value && user.value.email && user.value.username;
});

const fetchDashboardStats = async () => {
  if (!user.value || !user.value.wallet_address) {
    console.error('No user or wallet address available');
    loading.value = false;
    return;
  }

  try {
    loading.value = true;
    const response = await fetch(`http://localhost:3000/api/users/wallet/${user.value.wallet_address}/dashboard-stats`);
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const stats = await response.json();
    dashboardStats.value = stats;
    error.value = null;
  } catch (err) {
    console.error('Failed to fetch dashboard stats:', err);
    error.value = 'Failed to load dashboard data';
    // Set fallback data
    dashboardStats.value = {
      projects: { active: 0, total: 0 },
      reviews: 0,
      citations: 0,
      influence: null,
      recentActivities: []
    };
  } finally {
    loading.value = false;
  }
};

const formatActivityTime = (timestamp) => {
  return dayjs(timestamp).fromNow();
};

const getActivityIcon = (activityType) => {
  const iconMap = {
    'project_created': FolderOutline,
    'project_updated': GitCommitOutline,
    'review_submitted': EyeOutline,
    'dataset_uploaded': CloudUploadOutline,
    'publication_submitted': DocumentTextOutline,
    'default': GitCommitOutline
  };
  
  return iconMap[activityType] || iconMap.default;
};

const goToProfile = () => {
  router.push('/profile');
};

const goToInfluence = () => {
  router.push('/influence');
};

onMounted(() => {
  const storedUser = localStorage.getItem('user');
  if (storedUser) {
    try {
      const userData = JSON.parse(storedUser);
      user.value = userData;
      fetchDashboardStats();
    } catch (err) {
      console.error('Failed to parse stored user data:', err);
      loading.value = false;
    }
  } else {
    console.warn('No user data found in localStorage');
    loading.value = false;
  }
});
</script>

<style scoped>
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  background: #161b22;
  border: 1px solid #30363d;
  border-radius: 12px;
  margin-bottom: 24px;
}

.loading-text {
  margin-top: 16px;
  color: #8b949e;
  font-size: 14px;
}

.activity-loading {
  padding: 16px 0;
}



.profile-alert {
  margin-bottom: 24px;
  background-color: #161b22;
  border: 1px solid #30363d;
}

.profile-alert :deep(.n-alert-header__title) {
  color: #ffffff !important;
}

.profile-alert :deep(.n-alert__content) {
  color: #e2e8f0 !important;
}

/* Stats Cards Styling */
.stats-card {
  border-radius: 12px !important;
  transition: all 0.3s ease;
  height: 140px;
  position: relative;
  overflow: hidden;
}

.stats-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.3) !important;
}

.clickable-card {
  cursor: pointer;
}

.clickable-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 30px rgba(251, 191, 36, 0.2) !important;
}

.card-icon {
  font-size: 24px;
  opacity: 0.8;
}

/* Projects Card - Blue Theme */
.projects-card {
  background: linear-gradient(135deg, #0f172a 0%, #1e3a8a 100%) !important;
  border: 1px solid #3b82f6 !important;
}

.projects-icon {
  color: #60a5fa;
}

.projects-card :deep(.n-card-header) {
  background: rgba(59, 130, 246, 0.1);
  border-bottom: 1px solid rgba(59, 130, 246, 0.2);
}

.projects-card :deep(.n-statistic-value) {
  color: #60a5fa !important;
  font-weight: 700;
}

/* Contributions Card - Green Theme */
.contributions-card {
  background: linear-gradient(135deg, #0f1f0f 0%, #166534 100%) !important;
  border: 1px solid #22c55e !important;
}

.contributions-icon {
  color: #4ade80;
}

.contributions-card :deep(.n-card-header) {
  background: rgba(34, 197, 94, 0.1);
  border-bottom: 1px solid rgba(34, 197, 94, 0.2);
}

.contributions-card :deep(.n-statistic-value) {
  color: #4ade80 !important;
  font-weight: 700;
}

/* Citations Card - Purple Theme */
.citations-card {
  background: linear-gradient(135deg, #1f0f1f 0%, #7c2d92 100%) !important;
  border: 1px solid #a855f7 !important;
}

.citations-icon {
  color: #c084fc;
}

.citations-card :deep(.n-card-header) {
  background: rgba(168, 85, 247, 0.1);
  border-bottom: 1px solid rgba(168, 85, 247, 0.2);
}

.citations-card :deep(.n-statistic-value) {
  color: #c084fc !important;
  font-weight: 700;
}

/* Influence Card - Gold Theme */
.influence-card {
  background: linear-gradient(135deg, #1c1917 0%, #eab308 100%) !important;
  border: 1px solid #fbbf24 !important;
}

.influence-icon {
  color: #fcd34d;
}

.influence-card :deep(.n-card-header) {
  background: rgba(251, 191, 36, 0.1);
  border-bottom: 1px solid rgba(251, 191, 36, 0.2);
}

.influence-card :deep(.n-statistic-value) {
  color: #fcd34d !important;
  font-weight: 700;
}

/* Activity Card Styling */
.activity-card {
  background: linear-gradient(135deg, #0d1117 0%, #161b22 100%) !important;
  border: 1px solid #30363d !important;
  border-radius: 12px !important;
}

.activity-icon {
  color: #58a6ff;
}

.activity-card :deep(.n-card-header) {
  background: rgba(88, 166, 255, 0.05);
  border-bottom: 1px solid rgba(88, 166, 255, 0.1);
}

.activity-list-item {
  padding: 16px !important;
  border-radius: 8px;
  transition: all 0.2s ease;
}

.activity-list-item:hover {
  background: rgba(88, 166, 255, 0.05) !important;
}

.activity-item {
  display: flex;
  align-items: center;
  gap: 16px;
  width: 100%;
}

.activity-icon-wrapper {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: rgba(88, 166, 255, 0.1);
  flex-shrink: 0;
}

.activity-type-icon {
  font-size: 18px;
  color: #58a6ff;
}

.activity-content {
  display: flex;
  flex-direction: column;
  gap: 4px;
  flex: 1;
}

.activity-description {
  color: #e6edf3;
  font-size: 14px;
  font-weight: 500;
}

.activity-time {
  color: #7d8590;
  font-size: 12px;
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

:deep(.n-list-item) {
  border-color: #30363d;
}

:deep(.n-skeleton) {
  background-color: #21262d;
}
</style> 