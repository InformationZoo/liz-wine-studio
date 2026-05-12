# Liz Wine Studio API 文档

> 版本: 1.0.0 | 基础路径: `/api`

---

## 概述

Liz Wine Studio 提供三类 API：

| 类别 | 前缀 | 用途 |
|------|------|------|
| AI 助手 | `/api/ai` | 智能问答、酒标识别 |
| 内容工厂 | `/api/content` | PPT/海报/酒单生成 |
| 知识库 | `/api/kb` | 产区/统计/术语查询 |

---

## 通用规范

### 请求格式

```http
Content-Type: application/json
Authorization: Bearer <token>  # 可选
```

### 响应格式

**成功响应:**
```json
{
  "success": true,
  "data": { ... },
  "timestamp": "2026-03-25T14:00:00Z"
}
```

**错误响应:**
```json
{
  "success": false,
  "error": {
    "code": "INVALID_REQUEST",
    "message": "缺少必要参数"
  },
  "timestamp": "2026-03-25T14:00:00Z"
}
```

### 错误码

| 代码 | HTTP | 描述 |
|------|------|------|
| `INVALID_REQUEST` | 400 | 请求参数错误 |
| `UNAUTHORIZED` | 401 | 未授权 |
| `NOT_FOUND` | 404 | 资源不存在 |
| `RATE_LIMITED` | 429 | 请求过于频繁 |
| `AI_ERROR` | 500 | AI 服务错误 |
| `DATABASE_ERROR` | 500 | 数据库错误 |

---

## AI 助手 API

### 1. 智能问答

```http
POST /api/ai/chat
```

**请求体:**
```json
{
  "message": "勃艮第有哪些特级园？",
  "session_id": "sess_abc123",  // 可选，用于连续对话
  "context": {                  // 可选，额外上下文
    "wine_id": 42,
    "region": "Burgundy"
  }
}
```

**响应:**
```json
{
  "success": true,
  "answer": "勃艮第共有33个特级园（Grand Cru），分布在夜丘和博纳丘。最著名的包括：\n\n1. 罗曼尼·康帝（Romanée-Conti）\n2. 拉塔什（La Tâche）\n3. 里什堡（Richebourg）\n4. 木西尼（Musigny）\n5. 香贝丹（Chambertin）\n\n这些特级园出产的黑皮诺被认为是世界最顶级的红葡萄酒。",
  "session_id": "sess_abc123",
  "message_id": "msg_xyz789",
  "source": "llm",
  "query_type": "region",
  "wines": [
    {
      "id": 1,
      "name_cn": "罗曼尼·康帝特级园",
      "producer": "Domaine de la Romanée-Conti",
      "score": 99,
      "price": 188000
    }
  ],
  "confidence": 0.92
}
```

**source 字段说明:**
| 值 | 描述 |
|------|------|
| `llm` | 来自大语言模型 |
| `knowledge` | 来自本地知识库 |
| `rule` | 来自规则引擎（兜底） |

---

### 2. 酒标识别

```http
POST /api/ai/recognize
```

**请求体:**
```json
{
  "image": "data:image/jpeg;base64,/9j/4AAQSkZJRg..."
}
```

**响应:**
```json
{
  "success": true,
  "wine": {
    "winery": "Domaine de la Romanée-Conti",
    "winery_cn": "罗曼尼·康帝酒庄",
    "region": "Burgogne",
    "region_cn": "勃艮第",
    "sub_region": "Côte de Nuits",
    "classification": "Grand Cru",
    "vineyard": "Romanée-Conti",
    "vintage": 2019,
    "grape": "Pinot Noir",
    "grape_cn": "黑皮诺",
    "abv": 13.0,
    "volume_ml": 750,
    "price_range": "¥150,000-200,000"
  },
  "description": "这是罗曼尼·康帝酒庄的旗舰酒款，来自勃艮第最负盛名的特级园。2019年是一个温暖的年份，酒体饱满，结构紧实，具有出色的陈年潜力。",
  "confidence": 0.92,
  "alternatives": [
    {
      "winery": "Domaine Leroy",
      "confidence": 0.05
    }
  ]
}
```

**confidence 字段说明:**
| 范围 | 置信度 |
|------|--------|
| 0.9-1.0 | 非常确定 |
| 0.7-0.9 | 较为确定 |
| 0.5-0.7 | 可能正确 |
| < 0.5 | 不确定 |

---

### 3. 提交反馈

```http
POST /api/ai/feedback
```

**请求体:**
```json
{
  "session_id": "sess_abc123",
  "message_id": "msg_xyz789",
  "action": "thumbs_up",  // thumbs_up, thumbs_down, rating, text
  "value": 5,             // 1-5 for rating
  "comment": "回答很专业"  // 可选
}
```

**响应:**
```json
{
  "success": true,
  "feedback_id": "fb_001",
  "message": "感谢您的反馈！"
}
```

---

### 4. 获取对话历史

```http
GET /api/ai/history/:session_id
```

**响应:**
```json
{
  "success": true,
  "session_id": "sess_abc123",
  "messages": [
    {
      "id": "msg_001",
      "role": "user",
      "content": "勃艮第有哪些特级园？",
      "created_at": "2026-03-25T14:00:00Z"
    },
    {
      "id": "msg_002",
      "role": "assistant",
      "content": "勃艮第共有33个特级园...",
      "source": "llm",
      "created_at": "2026-03-25T14:00:05Z"
    }
  ]
}
```

---

## 内容工厂 API

### 1. 获取酒款列表

```http
GET /api/content/wines
```

**查询参数:**
| 参数 | 类型 | 描述 |
|------|------|------|
| `region` | string | 产区筛选 |
| `grape` | string | 品种筛选 |
| `min_price` | number | 最低价格 |
| `max_price` | number | 最高价格 |
| `min_score` | number | 最低评分 |
| `in_stock` | boolean | 仅显示有库存 |
| `search` | string | 关键词搜索 |
| `page` | number | 页码 (默认 1) |
| `limit` | number | 每页数量 (默认 20) |

**响应:**
```json
{
  "success": true,
  "wines": [
    {
      "id": 1,
      "name_cn": "罗曼尼·康帝特级园",
      "name_en": "Romanée-Conti Grand Cru",
      "producer": "Domaine de la Romanée-Conti",
      "region": "Burgundy",
      "classification": "Grand Cru",
      "vintage": 2019,
      "grape": "Pinot Noir",
      "score": 99,
      "price": 188000,
      "stock": 6,
      "image_url": "/images/wines/1.jpg"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 156,
    "total_pages": 8
  }
}
```

---

### 2. 生成内容

```http
POST /api/content/generate
```

**请求体:**
```json
{
  "type": "ppt",  // ppt, poster_square, poster_vertical, menu
  "wine_ids": [1, 2, 3, 4, 5],
  "options": {
    "brand": "Liz Wine",
    "tagline": "勃艮第美酒坊",
    "theme": "dark",  // dark, light
    "include_index": true,
    "show_price": false
  }
}
```

**响应:**
```json
{
  "success": true,
  "job_id": "job_abc123",
  "status": "processing",
  "preview_url": "/api/content/preview/job_abc123"
}
```

---

### 3. 获取生成结果

```http
GET /api/content/result/:job_id
```

**响应 (处理中):**
```json
{
  "success": true,
  "job_id": "job_abc123",
  "status": "processing",
  "progress": 60
}
```

**响应 (完成):**
```json
{
  "success": true,
  "job_id": "job_abc123",
  "status": "completed",
  "download_url": "/api/content/download/job_abc123",
  "files": [
    {
      "name": "liz-wine-presentation.pdf",
      "size": 2048576,
      "type": "application/pdf"
    }
  ]
}
```

---

### 4. 获取模板列表

```http
GET /api/content/templates
```

**响应:**
```json
{
  "success": true,
  "templates": [
    {
      "id": 1,
      "name": "PPT 封面",
      "type": "ppt",
      "description": "PPT 演示文稿封面页",
      "preview_url": "/images/templates/ppt-cover.png"
    }
  ]
}
```

---

## 知识库 API

### 1. 产区查询

```http
GET /api/kb/regions
```

**查询参数:**
| 参数 | 类型 | 描述 |
|------|------|------|
| `country` | string | 国家筛选 |
| `search` | string | 关键词搜索 |

**响应:**
```json
{
  "success": true,
  "regions": [
    {
      "id": 1,
      "name": "Bourgogne",
      "name_cn": "勃艮第",
      "country": "France",
      "country_cn": "法国",
      "grapes": ["Pinot Noir", "Chardonnay"],
      "classifications": ["Grand Cru", "Premier Cru", "Village"],
      "area_hectares": 29452
    }
  ]
}
```

---

### 2. 产区详情

```http
GET /api/kb/regions/:id
```

**响应:**
```json
{
  "success": true,
  "region": {
    "id": 1,
    "name": "Bourgogne",
    "name_cn": "勃艮第",
    "country": "France",
    "country_cn": "法国",
    "latitude": 47.03,
    "longitude": 4.84,
    "climate": "大陆性气候",
    "soil": "石灰岩、黏土",
    "grapes": ["Pinot Noir", "Chardonnay", "Gamay", "Aligoté"],
    "sub_regions": ["Côte de Nuits", "Côte de Beaune", "Chablis", "Mâconnais"],
    "classifications": [
      {
        "level": "Grand Cru",
        "count": 33,
        "description": "特级园，最高等级"
      },
      {
        "level": "Premier Cru",
        "count": 635,
        "description": "一级园"
      }
    ],
    "area_hectares": 29452,
    "annual_production_hl": 1970000
  }
}
```

---

### 3. 统计数据

```http
GET /api/kb/stats
```

**查询参数:**
| 参数 | 类型 | 描述 |
|------|------|------|
| `type` | string | production, consumption, export |
| `country` | string | 国家代码 |
| `year` | number | 年份 |

**响应:**
```json
{
  "success": true,
  "stats": {
    "year": 2025,
    "type": "production",
    "data": [
      {
        "country": "Italy",
        "country_cn": "意大利",
        "value": 47.3,
        "unit": "Mhl",
        "rank": 1
      },
      {
        "country": "France",
        "country_cn": "法国",
        "value": 35.9,
        "unit": "Mhl",
        "rank": 2
      },
      {
        "country": "Spain",
        "country_cn": "西班牙",
        "value": 29.4,
        "unit": "Mhl",
        "rank": 3
      }
    ]
  },
  "source": "OIV 2025"
}
```

---

### 4. 出口数据

```http
GET /api/kb/exports
```

**查询参数:**
| 参数 | 类型 | 描述 |
|------|------|------|
| `region` | string | 产区名称 |
| `year` | number | 年份 |
| `destination` | string | 目的地国家 |

**响应:**
```json
{
  "success": true,
  "exports": [
    {
      "year": 2024,
      "region": "Bourgogne",
      "destination": "China",
      "volume_hl": 15200,
      "value_eur": 285000000,
      "avg_price_eur": 18.75
    }
  ],
  "trend": {
    "direction": "down",
    "change_percent": -12.5
  }
}
```

---

### 5. 术语词典

```http
GET /api/kb/terms
```

**查询参数:**
| 参数 | 类型 | 描述 |
|------|------|------|
| `search` | string | 关键词搜索 |
| `category` | string | 分类筛选 |

**响应:**
```json
{
  "success": true,
  "terms": [
    {
      "id": 1,
      "name_cn": "风土",
      "name_en": "Terroir",
      "category": "terminology",
      "content": "风土是法语术语，指影响葡萄酒风味的自然环境因素总和..."
    }
  ]
}
```

---

## 健康检查

```http
GET /api/health
```

**响应:**
```json
{
  "success": true,
  "message": "服务运行正常",
  "version": "1.0.0",
  "timestamp": "2026-03-25T14:00:00Z",
  "components": {
    "database": "ok",
    "ai": "ok",
    "storage": "ok"
  }
}
```

---

## 速率限制

| 端点 | 限制 |
|------|------|
| `/api/ai/chat` | 20 次/分钟 |
| `/api/ai/recognize` | 10 次/分钟 |
| `/api/content/*` | 30 次/分钟 |
| `/api/kb/*` | 60 次/分钟 |

超过限制返回 `429 Too Many Requests`。

---

## WebSocket (规划中)

实时推送功能：

```javascript
const ws = new WebSocket('ws://localhost:3104/ws');

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  // data.type: 'chat', 'progress', 'notification'
};
```

---

*文档版本: 1.0.0 | 更新日期: 2026-03-25*
