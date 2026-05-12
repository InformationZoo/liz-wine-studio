# Liz Wine Studio

> 葡萄酒智能工作室 - AI 助手 + 内容工厂，独立应用

## 项目概述

**Liz Wine Studio** 是一个完全独立的葡萄酒智能应用，整合 AI 助手和内容工厂功能。

### 系统架构

```
┌─────────────────────────────────────────────────────────────────┐
│                      Liz Wine Studio                             │
│                        Port: 3104                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐  │
│   │   AI 智能助手     │  │    内容工厂      │  │   知识库     │  │
│   │                  │  │                  │  │              │  │
│   │ · 智能问答        │  │ · PPT 生成       │  │ · 产区查询   │  │
│   │ · 酒标识别        │  │ · 海报生成       │  │ · 统计数据   │  │
│   │ · 语音对话        │  │ · 酒单生成       │  │ · 术语词典   │  │
│   └──────────────────┘  └──────────────────┘  └──────────────┘  │
│                                                                  │
│   ┌──────────────────────────────────────────────────────────┐  │
│   │              wine-data (GitHub Public)                    │  │
│   │              葡萄酒产区数据库 · 数据源                     │  │
│   └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 核心定位

| 模块 | 功能 | 技术栈 |
|------|------|--------|
| **AI 助手** | 问答 + 识别 + 语音 | GLM-4-flash + GLM-4v-flash |
| **内容工厂** | PPT + 海报 + 酒单 | html2canvas + jsPDF |
| **知识库** | 产区 + 统计 + 术语 | wine-data + SQLite |

---

## 技术架构

### 技术选型

| 层级 | 技术选择 | 理由 |
|------|----------|------|
| **前端框架** | Alpine.js | 渐进增强，无需构建 |
| **UI 样式** | 深色金色主题 | 品牌一致性 |
| **后端框架** | Express.js | 轻量成熟 |
| **数据库** | SQLite (better-sqlite3) | 本地文件，无需安装 |
| **AI 服务** | GLM-4-flash + GLM-4v-flash | 免费，中文友好，支持视觉 |
| **向量搜索** | 腾讯混元 Embedding | 复用现有配置 |
| **内容生成** | html2canvas + jsPDF | 纯前端，无需后端 |

### 系统架构图

```
┌──────────────────────────────────────────────────────────────────┐
│                         前端层 (Alpine.js)                         │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐            │
│   │  AI 助手     │   │  内容工厂    │   │  知识库     │            │
│   │ ai.html     │   │ content.html│   │ kb.html     │            │
│   │             │   │             │   │             │            │
│   │ · 智能问答   │   │ · PPT 生成   │   │ · 产区查询   │            │
│   │ · 酒标识别   │   │ · 海报生成   │   │ · 统计数据   │            │
│   │ · 语音对话   │   │ · 酒单生成   │   │ · 出口趋势   │            │
│   └─────────────┘   └─────────────┘   └─────────────┘            │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│                        API 层 (Express.js)                         │
│                          Port: 3104                                │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│   /api/ai/*              /api/content/*          /api/kb/*        │
│   · POST /chat           · POST /ppt             · GET /regions   │
│   · POST /recognize      · POST /poster          · GET /stats     │
│   · POST /voice          · POST /menu            · GET /exports   │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│                        服务层 (Services)                           │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐            │
│   │  llm.js     │   │ knowledge.js │   │ content.js  │            │
│   │             │   │             │   │             │            │
│   │ · GLM 调用  │   │ · 本地知识库 │   │ · 模板渲染  │            │
│   │ · 路由选择  │   │ · 向量搜索  │   │ · 图片生成  │            │
│   │ · 速率限制  │   │ · 上下文构建│   │ · PDF导出   │            │
│   └─────────────┘   └─────────────┘   └─────────────┘            │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│                        数据层 (SQLite)                             │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│   studio.db                                                       │
│   ├── wines          # 酒款数据 (复用 workbench 或独立)            │
│   ├── knowledge      # 知识库条目                                 │
│   ├── conversations  # 对话历史                                   │
│   ├── templates      # 内容模板                                   │
│   └── feedback       # 用户反馈                                   │
│                                                                   │
│   外部数据源:                                                      │
│   └── wine-data (GitHub) → 产区/统计/出口数据                      │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

---

## 目录结构

```
09_Liz_Wine_Studio/
├── README.md                    # 本文档
├── package.json                 # 依赖配置
├── .env                         # 环境变量 (API Keys)
├── .gitignore
│
├── server/                      # 后端服务
│   ├── src/
│   │   ├── app.js               # Express 入口
│   │   ├── routes/
│   │   │   ├── index.js         # 路由汇总
│   │   │   ├── ai.js            # AI 助手 API
│   │   │   ├── content.js       # 内容工厂 API
│   │   │   └── kb.js            # 知识库 API
│   │   ├── services/
│   │   │   ├── llm.js           # LLM 服务 (GLM 封装)
│   │   │   ├── knowledge.js     # 知识库服务
│   │   │   └── content.js       # 内容生成服务
│   │   └── middleware/
│   │       └── errorHandler.js  # 错误处理
│   │
│   └── db/
│       ├── studio.db            # SQLite 数据库
│       ├── schema.sql           # 数据库结构
│       └── seed.sql             # 初始数据
│
├── src/                         # 前端源码
│   ├── index.html               # 主页 (功能入口)
│   ├── ai.html                  # AI 助手页面
│   ├── content.html             # 内容工厂页面
│   ├── kb.html                  # 知识库页面
│   │
│   ├── js/
│   │   ├── main.js              # 入口文件
│   │   ├── core/
│   │   │   ├── api.js           # API 封装
│   │   │   └── utils.js         # 工具函数
│   │   └── modules/
│   │       ├── ai.js            # AI 助手模块
│   │       ├── content.js       # 内容工厂模块
│   │       └── kb.js            # 知识库模块
│   │
│   └── css/
│       ├── variables.css        # CSS 变量
│       ├── base.css             # 基础样式
│       ├── components.css       # 组件样式
│       └── pages/
│           ├── ai.css           # AI 页面样式
│           ├── content.css      # 内容工厂样式
│           └── kb.css           # 知识库样式
│
├── docs/                        # 文档
│   ├── api.md                   # API 文档
│   ├── database.md              # 数据库设计
│   └── deployment.md            # 部署指南
│
└── tests/                       # 测试
    ├── api/                     # API 测试
    └── e2e/                     # 端到端测试
```

---

## 功能模块

### 1. AI 智能助手

#### 1.1 智能问答

**功能描述:**
- 葡萄酒知识问答（产区、品种、酿造工艺）
- 配餐推荐
- 储存建议
- 品鉴术语解释

**API:**
```http
POST /api/ai/chat
Content-Type: application/json

{
  "message": "勃艮第有哪些特级园？",
  "session_id": "optional-session-id",
  "context": {}
}

Response:
{
  "success": true,
  "answer": "勃艮第共有33个特级园...",
  "session_id": "sess_xxx",
  "source": "llm|knowledge|rule",
  "wines": []  // 相关酒款推荐
}
```

**技术实现:**
1. 用户输入 → 意图分类
2. 知识库检索 → 获取上下文
3. LLM 生成 → 返回答案
4. 本地规则引擎 → 兜底响应

#### 1.2 酒标识别

**功能描述:**
- 上传酒标图片
- 识别酒庄、产区、年份、品种
- 返回结构化信息

**API:**
```http
POST /api/ai/recognize
Content-Type: application/json

{
  "image": "base64-encoded-image"
}

Response:
{
  "success": true,
  "wine": {
    "winery": "Domaine de la Romanée-Conti",
    "winery_cn": "罗曼尼·康帝酒庄",
    "region": "Bourgogne",
    "region_cn": "勃艮第",
    "classification": "Grand Cru",
    "vintage": "2019",
    "grape": "Pinot Noir",
    "price_range": "¥150,000-200,000"
  },
  "description": "这是罗曼尼·康帝酒庄...",
  "confidence": 0.92
}
```

**技术实现:**
- GLM-4v-flash 视觉模型
- 提示词工程优化识别准确率
- 返回 JSON 结构化数据

#### 1.3 语音对话

**功能描述:**
- 浏览器语音识别 (Web Speech API)
- 语音播报回答
- 连续对话模式

**前端实现:**
```javascript
// 语音识别
const recognition = new webkitSpeechRecognition();
recognition.lang = 'zh-CN';
recognition.continuous = false;

// 语音合成
const utterance = new SpeechSynthesisUtterance(text);
utterance.lang = 'zh-CN';
speechSynthesis.speak(utterance);
```

---

### 2. 内容工厂

#### 2.1 PPT 生成

**功能描述:**
- 批量选择酒款
- 生成 16:9 演示文稿
- 导出 PDF

**输出结构:**
| 页面 | 内容 |
|------|------|
| 封面 | 品牌 + 酒款数量 |
| 详情页 | 各酒款详情 (每页1款) |
| 索引页 | 所有酒款一览 |

**技术实现:**
- html2canvas 截图
- jsPDF 生成 PDF
- 模板系统支持自定义

#### 2.2 海报生成

**功能描述:**
- 方形海报 (1:1) - 社交媒体
- 竖版海报 (9:16) - 朋友圈/打印
- 批量导出 PNG

**输出规格:**
| 类型 | 尺寸 | 用途 |
|------|------|------|
| 方形 | 1600×1600 | 小红书、Instagram |
| 竖版 | 1080×1920 | 微信朋友圈、抖音 |

#### 2.3 酒单生成

**功能描述:**
- 按红/白酒自动分组
- 显示价格
- 适合餐厅使用

**输出格式:**
```
┌─────────────────────────────────────┐
│           酒单标题                    │
├─────────────────────────────────────┤
│  红葡萄酒                             │
│  1. 酒名  酒庄  等级  年份  评分  价格 │
│  2. ...                              │
├─────────────────────────────────────┤
│  白葡萄酒                             │
│  1. ...                              │
└─────────────────────────────────────┘
```

---

### 3. 知识库

#### 3.1 产区查询

**功能描述:**
- 全球葡萄酒产区信息
- 法定品种、酿造规范
- 气候土壤特点

**数据来源:** wine-data (GitHub)

**API:**
```http
GET /api/kb/regions?country=France

Response:
{
  "regions": [
    {
      "id": 1,
      "name": "Bourgogne",
      "name_cn": "勃艮第",
      "country": "France",
      "grapes": ["Pinot Noir", "Chardonnay"],
      "classifications": ["Grand Cru", "Premier Cru", "Village"],
      "area_hectares": 29452
    }
  ]
}
```

#### 3.2 统计数据

**功能描述:**
- 全球产量排名
- 出口趋势
- 拍卖行情

**数据来源:** OIV、BIVB、IVDP

#### 3.3 术语词典

**功能描述:**
- 葡萄酒术语解释
- 中英对照
- 品鉴词汇

---

## 数据库设计

### 表结构

```sql
-- 酒款数据
CREATE TABLE wines (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name_cn TEXT NOT NULL,
    name_en TEXT,
    producer TEXT,
    producer_cn TEXT,
    region TEXT,
    region_cn TEXT,
    country TEXT,
    classification TEXT,
    vintage INTEGER,
    grape TEXT,
    score INTEGER,
    abv REAL,
    price INTEGER,
    tasting_notes TEXT,
    pairing TEXT,
    image_url TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 知识库条目
CREATE TABLE knowledge (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category TEXT NOT NULL,  -- region, grape, technique, terminology
    name_cn TEXT NOT NULL,
    name_en TEXT,
    content TEXT NOT NULL,
    keywords TEXT,
    source TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 对话历史
CREATE TABLE conversations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    role TEXT NOT NULL,  -- user, assistant
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 内容模板
CREATE TABLE templates (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    type TEXT NOT NULL,  -- ppt, poster, menu
    content TEXT NOT NULL,  -- HTML template
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 用户反馈
CREATE TABLE feedback (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT,
    message_id TEXT,
    action TEXT NOT NULL,  -- thumbs_up, thumbs_down, rating
    value INTEGER,
    comment TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 索引
CREATE INDEX idx_wines_region ON wines(region);
CREATE INDEX idx_wines_producer ON wines(producer);
CREATE INDEX idx_knowledge_category ON knowledge(category);
CREATE INDEX idx_conversations_session ON conversations(session_id);
```

---

## API 设计

### AI 助手 API

| 方法 | 端点 | 描述 |
|------|------|------|
| POST | `/api/ai/chat` | 智能问答 |
| POST | `/api/ai/recognize` | 酒标识别 |
| POST | `/api/ai/feedback` | 提交反馈 |
| GET | `/api/ai/history/:session_id` | 获取对话历史 |

### 内容工厂 API

| 方法 | 端点 | 描述 |
|------|------|------|
| GET | `/api/content/wines` | 获取酒款列表 |
| POST | `/api/content/generate` | 生成内容 |
| GET | `/api/content/templates` | 获取模板列表 |

### 知识库 API

| 方法 | 端点 | 描述 |
|------|------|------|
| GET | `/api/kb/regions` | 产区查询 |
| GET | `/api/kb/stats` | 统计数据 |
| GET | `/api/kb/exports` | 出口数据 |
| GET | `/api/kb/terms` | 术语词典 |

---

## 开发计划

### Phase 1: 基础架构 (1-2天)

**目标:** 搭建项目骨架

**任务:**
- [ ] 创建项目目录结构
- [ ] 初始化 package.json
- [ ] 配置 Express 服务器
- [ ] 创建 SQLite 数据库
- [ ] 实现基础路由

**验收标准:**
- 服务器启动成功 (port 3104)
- `/api/health` 返回正常
- 数据库文件创建成功

### Phase 2: AI 助手 (2-3天)

**目标:** 实现 AI 助手核心功能

**任务:**
- [ ] 创建 LLM 服务 (GLM API 封装)
- [ ] 实现智能问答 API
- [ ] 实现酒标识别 API
- [ ] 创建 AI 助手前端页面
- [ ] 集成语音输入/输出

**验收标准:**
- 智能问答正常工作
- 酒标识别返回结构化数据
- 语音输入可正常使用

### Phase 3: 内容工厂 (2-3天)

**目标:** 迁移内容工厂功能

**任务:**
- [ ] 创建内容工厂前端页面
- [ ] 实现 PPT 生成功能
- [ ] 实现海报生成功能
- [ ] 实现酒单生成功能
- [ ] 迁移现有模板

**验收标准:**
- 可生成 PDF/PNG
- 输出格式正确
- 批量导出正常

### Phase 4: 知识库 (1-2天)

**目标:** 整合知识库功能

**任务:**
- [ ] 创建知识库 API
- [ ] 导入 wine-data 数据
- [ ] 创建知识库前端页面
- [ ] 实现搜索功能

**验收标准:**
- 可查询产区信息
- 统计数据展示正常
- 搜索返回正确结果

### Phase 5: 整合优化 (1天)

**目标:** 系统整合与优化

**任务:**
- [ ] 性能优化
- [ ] 错误处理完善
- [ ] 文档完善
- [ ] 测试覆盖

**验收标准:**
- 页面加载 < 2秒
- 无明显 bug
- 所有功能正常

---

## 环境配置

### .env 文件

```env
# 服务器配置
PORT=3104

# 智谱 AI
ZHIPU_API_KEY=your_glm_api_key

# 腾讯云 (向量搜索)
TENCENT_SECRET_ID=your_secret_id
TENCENT_SECRET_KEY=your_secret_key

# JWT (可选)
JWT_SECRET=your_jwt_secret
```

### 依赖包

```json
{
  "dependencies": {
    "express": "^4.18.2",
    "better-sqlite3": "^9.4.3",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "compression": "^1.7.4",
    "dotenv": "^16.4.1",
    "node-fetch": "^2.7.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.3"
  }
}
```

---

## 与现有资产的复用

### 复用 07_葡萄酒智能助手

| 组件 | 来源 | 复用方式 |
|------|------|----------|
| LLM 路由 | `llm_router.py` | 翻译为 JavaScript |
| 提示词 | `prompt_engineering.py` | 直接复用 |
| 规则引擎 | `local_rule_engine.py` | 翻译为 JavaScript |
| 护栏系统 | `guardrails.py` | 参考实现 |

### 复用 Wine Content Studio

| 组件 | 来源 | 复用方式 |
|------|------|----------|
| 模板 | `wine_content_studio.html` | 直接复用 HTML/CSS |
| 导出逻辑 | html2canvas + jsPDF | 直接复用 |
| 配色方案 | 深色金色主题 | 保持一致 |

### 复用 wine-data

| 数据 | 来源 | 复用方式 |
|------|------|----------|
| 产区数据 | `wine_regions.db` | HTTP 请求获取 |
| 统计数据 | `stats.json` | 直接 fetch |
| RAG 文档 | `rag/chunks.jsonl` | 导入本地数据库 |

---

## 部署

### 开发环境

```bash
# 安装依赖
cd 09_Liz_Wine_Studio
npm install

# 启动开发服务器
npm run dev

# 访问
open http://localhost:3104
```

### 生产环境

```bash
# 启动
npm start

# PM2 守护
pm2 start server/src/app.js --name "liz-wine-studio"
```

### 访问地址

```
http://localhost:3104
```

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| 0.1.0 | 2026-03-25 | 项目规划文档创建 |

---

## 状态

📋 **规划阶段** - 2026-03-25 创建

---

*Created: 2026-03-25*
*Author: Claude Code*
