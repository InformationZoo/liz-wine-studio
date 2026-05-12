# 资产迁移指南

> 从现有项目迁移到 Liz Wine Studio

---

## 现有资产清单

### 1. 07_葡萄酒智能助手

**位置:** `D:/Claude Code/07_葡萄酒智能助手/`

**可复用组件:**

| 文件 | 功能 | 迁移方式 |
|------|------|----------|
| `knowledge_base/llm_client.py` | LLM 客户端 | 重写为 JavaScript |
| `knowledge_base/llm_router.py` | 路由器 + 速率限制 | 重写为 JavaScript |
| `knowledge_base/local_rule_engine.py` | 本地规则引擎 | 重写为 JavaScript |
| `knowledge_base/search_engine.py` | 知识库搜索 | 重写为 JavaScript |
| `knowledge_base/vector_store.py` | 向量搜索 | 简化或移除 |
| `knowledge_base/prompt_engineering.py` | 提示词工程 | 直接复用逻辑 |
| `knowledge_base/guardrails.py` | 护栏系统 | 简化版本 |
| `knowledge_base/feedback.py` | 反馈系统 | 直接复用 |
| `knowledge_base/wine_db.py` | 酒款数据库 | 复用逻辑 |
| `wine_assistant_web.html` | Web 界面 | 提取 UI 组件 |

**Python → JavaScript 对照:**

```python
# Python (llm_router.py)
class LLMRouter:
    def chat(self, message, context=None):
        result = self.client.chat(message, context)
        return {'success': True, 'content': result}
```

```javascript
// JavaScript (services/llm.js)
class LLMService {
    async chat(message, options = {}) {
        const result = await this.client.chat(message, options);
        return { success: true, content: result };
    }
}
```

---

### 2. Wine Content Studio

**位置:** `_reports/wine_poster/wine_content_studio.html`

**可复用组件:**

| 部分 | 内容 | 迁移方式 |
|------|------|----------|
| HTML 模板 | 酒款卡片、封面、索引页 | 直接复用 |
| CSS 样式 | 深色金色主题 | 直接复用 |
| 导出逻辑 | html2canvas + jsPDF | 直接复用 |
| 数据格式 | JSON 酒款结构 | 直接复用 |

**直接复用的代码:**

```html
<!-- 从 wine_content_studio.html 提取 -->
<style>
:root {
    --primary: #d4af7d;
    --bg-dark: #1a1412;
    --bg-card: #242424;
    --text: #fff;
    --text-muted: rgba(255,255,255,0.6);
    --border: rgba(212, 175, 125, 0.2);
}
</style>
```

```javascript
// 从 wine_content_studio.html 提取
async function exportToPDF() {
    const slides = document.querySelectorAll('.slide');
    const pdf = new jsPDF('landscape', 'mm', [297, 210]);

    for (let i = 0; i < slides.length; i++) {
        const canvas = await html2canvas(slides[i]);
        const imgData = canvas.toDataURL('image/png');
        pdf.addImage(imgData, 'PNG', 0, 0, 297, 210);
        if (i < slides.length - 1) pdf.addPage();
    }

    pdf.save('wine-presentation.pdf');
}
```

---

### 3. wine-data

**位置:** `D:/Claude Code/wine-data/` (GitHub: InformationZoo/wine-data)

**数据复用:**

| 文件 | 内容 | 使用方式 |
|------|------|----------|
| `data/wine_regions.db` | 产区数据库 | HTTP 下载或本地复制 |
| `data/stats.json` | 统计数据 | fetch 远程 |
| `data/exports.json` | 出口数据 | fetch 远程 |
| `data/auctions.json` | 拍卖数据 | fetch 远程 |
| `data/rag/chunks.jsonl` | RAG 文档块 | 导入本地知识库 |

**远程访问:**

```javascript
// 直接 fetch GitHub raw 文件
const statsUrl = 'https://raw.githubusercontent.com/InformationZoo/wine-data/main/data/stats.json';

async function getStats() {
    const response = await fetch(statsUrl);
    return response.json();
}
```

**本地导入:**

```bash
# 下载到本地
wget https://raw.githubusercontent.com/InformationZoo/wine-data/main/data/wine_regions.db

# 复制到项目
cp wine_regions.db 09_Liz_Wine_Studio/server/db/
```

---

### 4. 进口商工作台

**位置:** `D:/Claude Code/08_进口商工作台/`

**可复用组件:**

| 组件 | 内容 | 迁移方式 |
|------|------|----------|
| 主题样式 | CSS 变量 | 直接复用 |
| 认证系统 | JWT | 可选复用 |
| API 结构 | Express 路由模式 | 参考结构 |
| 数据库操作 | better-sqlite3 | 直接复用 |

**共享样式:**

```css
/* 从进口商工作台复用 */
:root {
    --bg-dark: #1a1a1a;
    --bg-card: #242424;
    --gold: #d4af7d;
    --gold-light: #e8c99a;
    --text: #fff;
    --text-muted: rgba(255,255,255,0.6);
}
```

---

## 迁移步骤

### Phase 1: 基础结构

1. 创建项目目录
2. 初始化 package.json
3. 复制共享样式
4. 创建 Express 服务器

### Phase 2: AI 助手

1. 翻译 `llm_client.py` → `services/llm.js`
2. 翻译 `llm_router.py` → `services/router.js`
3. 翻译 `local_rule_engine.py` → `services/rules.js`
4. 复制 `prompt_engineering.py` 逻辑
5. 提取 `wine_assistant_web.html` UI 组件

### Phase 3: 内容工厂

1. 复制 `wine_content_studio.html` 模板
2. 拆分 HTML/CSS/JS
3. 创建 API 端点
4. 测试导出功能

### Phase 4: 知识库

1. 下载 wine-data 数据库
2. 导入 RAG 文档块
3. 创建搜索 API
4. 实现前端界面

---

## 数据迁移

### 酒款数据

从进口商工作台导出：

```sql
-- 从 importer.db 导出
SELECT
    name_cn, name_en, producer, region, classification,
    vintage, grape, score, price, tasting_notes, image_url
FROM wines
WHERE active = 1;
```

导入到 Studio：

```sql
INSERT INTO wines (name_cn, name_en, producer, region, ...)
VALUES (?, ?, ?, ?, ...);
```

### 知识库数据

从 wine-data 导入：

```javascript
const fs = require('fs');
const db = require('better-sqlite3')('studio.db');

// 读取 RAG 文档块
const chunks = fs.readFileSync('data/rag/chunks.jsonl', 'utf-8')
    .split('\n')
    .filter(line => line.trim())
    .map(JSON.parse);

// 导入到知识库
const stmt = db.prepare(`
    INSERT INTO knowledge (category, name_cn, name_en, content, keywords)
    VALUES (?, ?, ?, ?, ?)
`);

for (const chunk of chunks) {
    stmt.run(
        chunk.category || 'general',
        chunk.title_cn || chunk.title,
        chunk.title,
        chunk.content,
        JSON.stringify(chunk.keywords || [])
    );
}
```

---

## 保留 vs 重写

### 保留 (直接复用)

| 组件 | 来源 | 原因 |
|------|------|------|
| CSS 主题 | 工作台 | 品牌一致性 |
| 导出逻辑 | Content Studio | 功能完整 |
| 数据格式 | wine-data | 标准化 |
| 提示词模板 | Wine Assistant | 已优化 |

### 重写 (翻译/优化)

| 组件 | 来源 | 原因 |
|------|------|------|
| LLM 客户端 | Python | 语言统一 |
| 路由器 | Python | 简化逻辑 |
| 规则引擎 | Python | 精简功能 |
| 搜索引擎 | Python | 移除向量 |

### 新增

| 组件 | 原因 |
|------|------|
| 知识库页面 | 独立功能 |
| 反馈系统 | 收集用户输入 |
| 模板管理 | 支持自定义 |

---

## 清理计划

### 迁移后可删除

| 目录/文件 | 原因 |
|-----------|------|
| `07_葡萄酒智能助手/software/knowledge_base/*.py` | 已翻译为 JS |
| `_reports/wine_poster/` | 已整合到 Studio |

### 归档保留

| 目录/文件 | 原因 |
|-----------|------|
| `07_葡萄酒智能助手/docs/` | 参考文档 |
| `07_葡萄酒智能助手/hardware/` | 硬件规划 |
| `07_葡萄酒智能助手/data/WSET/` | 知识数据 |

---

## 验收清单

- [ ] AI 问答功能正常
- [ ] 酒标识别返回结构化数据
- [ ] PPT 生成导出正常
- [ ] 海报生成导出正常
- [ ] 酒单生成导出正常
- [ ] 知识库搜索正常
- [ ] 与进口商工作台联动正常
- [ ] 所有 API 返回正确格式
- [ ] 错误处理完善
- [ ] 文档完整

---

*文档版本: 1.0.0 | 更新日期: 2026-03-25*
