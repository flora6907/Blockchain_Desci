# NFT 可见性修改说明

## 概述
修改了系统的可见性逻辑，使得已mint成NFT的私有内容也能在探索页面中显示，而不再仅限于public内容。

## 修改内容

### 1. 后端API修改

#### 项目探索API (`backend/routes/projects.js`)
- **路由**: `GET /api/projects/explore/public`
- **修改**: 添加了对已mint成NFT的私有项目的支持
- **新逻辑**: 
  ```sql
  WHERE p.visibility = 'Public' 
     OR (p.visibility = 'Private' AND EXISTS(SELECT 1 FROM nfts WHERE project_id = p.id))
  ```
- **新增字段**: `has_nft` - 标识项目是否有NFT

#### 数据集探索API (`backend/routes/datasets.js`)
- **路由**: `GET /api/datasets/explore` 和 `GET /api/datasets/explore/:id`
- **修改**: 添加了对已mint成NFT的私有/加密/ZK保护数据集的支持
- **新逻辑**:
  ```sql
  WHERE d.status = 'ready' AND (
    d.privacy_level = 'public' 
    OR (d.privacy_level IN ('private', 'encrypted', 'zk_proof_protected') 
        AND EXISTS(SELECT 1 FROM nfts n WHERE n.project_id = d.project_id AND n.token_id LIKE 'DATASET_%'))
  )
  ```
- **新增字段**: `has_nft` - 标识数据集是否有NFT

### 2. 前端显示修改

#### 探索页面 (`frontend/src/views/Explore.vue`)
- **项目卡片**: 为私有但已mint NFT的项目添加"NFT"标签
- **数据集卡片**: 为非公开但已mint NFT的数据集添加"NFT"标签  
- **UI改进**: 添加了标签组样式，支持多个标签同时显示

### 3. 可见性规则总结

#### 修改前（仅显示公开内容）
- **项目**: 只显示 `visibility = 'Public'` 的项目
- **数据集**: 只显示 `privacy_level = 'public'` 的数据集

#### 修改后（公开 + 已mint NFT的私有内容）
- **项目**: 
  - 所有公开项目 (`visibility = 'Public'`)
  - 已mint成NFT的私有项目 (`visibility = 'Private'` + 有NFT)
  
- **数据集**:
  - 所有公开数据集 (`privacy_level = 'public'`)
  - 已mint成NFT的私有数据集 (`privacy_level = 'private'` + 有NFT)
  - 已mint成NFT的加密数据集 (`privacy_level = 'encrypted'` + 有NFT)
  - 已mint成NFT的ZK保护数据集 (`privacy_level = 'zk_proof_protected'` + 有NFT)

### 4. 测试验证

运行了 `test_nft_visibility.sql` 脚本验证修改效果：

#### 结果统计
- **私有项目**: 3个已mint NFT的私有项目现在可见
- **私有/加密数据集**: 6个已mint NFT的非公开数据集现在可见
- **NFT标识**: 前端正确显示NFT标签来标识这些特殊可见的内容

### 5. 用户体验改进

#### NFT标签显示
- **私有项目**: 显示橙色"NFT"标签，表明因为NFT化而可见
- **私有数据集**: 显示橙色"NFT"标签，表明因为NFT化而可见
- **视觉区分**: 用户可以清楚地知道哪些内容是因为NFT化而变得可见的

#### 市场价值展示
- NFT化的私有内容现在可以在探索页面展示，增加曝光度
- 潜在买家可以发现和了解这些高价值的私有数据和项目
- 创建了一个"freemium"模式：基本信息可见，完整访问需要购买NFT

### 6. 安全考虑

- **元数据访问**: 只显示基本元数据（名称、描述、统计等）
- **内容保护**: 实际的数据文件和项目详情仍需要通过NFT所有权或权限来访问
- **隐私维护**: 不会泄露敏感的内容信息，只是让NFT的存在和基本信息可见

### 7. 商业价值

- **NFT发现性**: 提高了NFT的可发现性和市场流动性
- **价值展示**: 私有内容的价值可以通过预览得到更好的展示
- **购买激励**: 用户看到感兴趣的私有内容后更有动机购买对应的NFT

## 文件变更清单

1. `backend/routes/projects.js` - 修改项目探索API
2. `backend/routes/datasets.js` - 修改数据集探索API  
3. `frontend/src/views/Explore.vue` - 添加NFT标签显示
4. `test_nft_visibility.sql` - 测试脚本
5. `create_users_datasets_projects_and_mint_nfts_fixed.sql` - 创建测试数据
6. `list_nfts_for_sale.sql` - NFT市场脚本

## 部署说明

1. 确保数据库包含测试数据和NFT记录
2. 重启后端服务以加载新的API逻辑
3. 前端会自动显示新的NFT标签
4. 验证探索页面显示previously hidden的私有内容 