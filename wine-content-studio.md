# Wine Content Studio

葡萄酒内容制作工作室。支持四种输出格式：PPT演示文稿、方形海报、竖版海报、餐厅酒单。

## When to Use

- 批量制作产品目录PPT
- 生成社交媒体海报（小红书、Instagram）
- 制作微信朋友圈推广图
- 为客户准备酒款推荐演示
- 制作品鉴会展示材料
- 生成餐厅酒水单

## Usage

```
/wine-content-studio
```

## Files

| File | Purpose |
|------|---------|
| `wine_content_studio.html` | 内容工作室主应用 |

---

## Output Modes

| 模式 | 尺寸 | 比例 | 用途 |
|------|------|------|------|
| PPT | 1920×1080 | 16:9 | 客户演示、经销商资料、PDF导出 |
| 方形海报 | 1600×1600 | 1:1 | 小红书、Instagram、微博 |
| 竖版海报 | 1080×1920 | 9:16 | 微信朋友圈、抖音、打印海报 |
| 酒单 | 1920×1080 | 16:9 | 餐厅酒水单、价格表 |

---

## Workflow

```
1. 打开 wine_content_studio.html
2. 选择输出模式（PPT/方形/竖版/酒单）
3. 上传JSON酒款数据（或使用示例数据）
4. 勾选需要的酒款
5. 设置主题风格（深色/浅色）
6. 点击"生成预览"
7. 上传酒瓶图片（可选）
8. 点击"下载"导出文件
```

---

## JSON 数据格式

### 简化格式（推荐）

```json
[
  {
    "id": 1,
    "name_cn": "中文名称",
    "name_en": "English Name",
    "producer": "Domaine Name",
    "producer_cn": "酒庄中文名",
    "classification": "Premier Cru",
    "score": 92,
    "abv": "13%",
    "grape": "Pinot Noir",
    "vintage": "2020",
    "price": 5000,
    "aging": "8-12年",
    "terroir": "风土描述",
    "image": "",
    "tasting": {
      "appearance": "外观描述",
      "nose": "香气描述",
      "palate": "口感描述",
      "finish": "余味描述"
    },
    "pairing": ["配餐1", "配餐2"]
  }
]
```

### 兼容 wine_database.json 格式

```json
{
  "wines": [
    {
      "basic_info": {
        "name_cn": "中文名称",
        "name_original": "English Name",
        "producer": "酒庄名",
        "alcohol": 13.5,
        "vintage": 2020,
        "grape_varieties": [{"name": "黑皮诺"}]
      },
      "tasting_notes": {
        "visual": { "color": "深红宝石色" },
        "nose": { "aroma_profile": { "fruits": ["红樱桃", "覆盆子"] } },
        "palate": { "structure": "优雅精致" },
        "finish": { "length": "悠长" }
      },
      "pairing": ["烤鸭", "羊排"]
    }
  ]
}
```

---

## Output Structure

### PPT模式
| Page | Content |
|:----:|---------|
| 1 | 封面（品牌 + 酒款数量） |
| 2~N | 各酒款详情页 |
| N+1 | 索引页（所有酒款一览） |

### 海报模式
- 每款酒生成一张独立海报
- 方形海报：突出酒名和评分
- 竖版海报：包含完整品鉴信息

### 酒单模式
| Page | Content |
|:----:|---------|
| 1 | 封面（标题 + 酒款数量） |
| 2~N | 按红/白酒分类，每页最多6款 |
| 每行 | 序号、酒名、酒庄、等级、年份、评分、价格 |

---

## Features

| Feature | Description |
|---------|-------------|
| 四种输出模式 | PPT、方形海报、竖版海报、酒单 |
| 批量选择 | 多选酒款，一键全选/清空 |
| 主题切换 | 深色优雅 / 浅色清新 |
| 图片上传 | 点击酒图区域上传 |
| 实时预览 | 生成前可预览效果 |
| 多格式导出 | PDF (PPT/酒单) / PNG (海报) |
| 自动分组 | 酒单模式按红/白酒自动分类 |

---

## Export

| Mode | Format | Resolution |
|------|--------|------------|
| PPT | PDF | 1920×1080 |
| 方形海报 | PNG | 1600×1600 |
| 竖版海报 | PNG | 1080×1920 |
| 酒单 | PDF | 1920×1080 |

---

## Customization

### 修改封面品牌

编辑HTML中 `.tagline` / `.poster-brand` 的默认值：
```html
<div class="tagline">Bourgogne Fine Wines · 勃艮第美酒坊</div>
```

### 修改配色

深色主题：
```css
--primary: #d4af7d;
--bg-dark: #1a1412;
```

浅色主题：
```css
--primary: #6b5344;
--bg-light: #faf8f5;
```

---

## Tech Stack

- html2canvas - 截图生成
- jsPDF - PDF导出
- Google Fonts (Cormorant Garamond, Noto Serif SC)
- 纯前端，无需后端

---

## Related Skills

| Skill | Purpose |
|-------|---------|
| `wine_style_prompts` | AI图片风格提示词 |
| `wine-database` | 酒款数据库管理 |

---

## Version History

| Version | Changes |
|---------|---------|
| 3.0 | 新增餐厅酒单模式，支持价格显示 |
| 2.0 | 整合PPT+海报三种模式，重命名为Wine Content Studio |
| 1.0 | 初始版本，仅支持PPT批量生成 |

---

## Quick Start

```
打开 wine_content_studio.html → 选择模式 → 选择酒款 → 生成预览 → 下载
```
