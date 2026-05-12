-- Liz Wine Studio Database Schema
-- Version: 1.0.0
-- Created: 2026-03-25

-- ==================== 酒款数据 ====================

CREATE TABLE IF NOT EXISTS wines (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name_cn TEXT NOT NULL,
    name_en TEXT,
    producer TEXT,
    producer_cn TEXT,
    region TEXT,
    region_cn TEXT,
    country TEXT,
    classification TEXT,
    sub_region TEXT,
    vineyard TEXT,
    vintage INTEGER,
    grape TEXT,
    grape_cn TEXT,
    score INTEGER,
    score_source TEXT,  -- RP, WS, JS, etc.
    abv REAL,
    volume_ml INTEGER DEFAULT 750,
    price INTEGER,
    price_currency TEXT DEFAULT 'CNY',
    cost INTEGER,
    stock INTEGER DEFAULT 0,
    min_stock INTEGER DEFAULT 10,
    tasting_notes TEXT,
    pairing TEXT,
    aging_potential TEXT,
    serving_temp TEXT,
    image_url TEXT,
    barcode TEXT,
    sku TEXT,
    active INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_wines_region ON wines(region);
CREATE INDEX IF NOT EXISTS idx_wines_producer ON wines(producer);
CREATE INDEX IF NOT EXISTS idx_wines_vintage ON wines(vintage);
CREATE INDEX IF NOT EXISTS idx_wines_grape ON wines(grape);
CREATE INDEX IF NOT EXISTS idx_wines_active ON wines(active);

-- ==================== 知识库 ====================

CREATE TABLE IF NOT EXISTS knowledge (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category TEXT NOT NULL,  -- region, grape, technique, terminology, pairing
    name_cn TEXT NOT NULL,
    name_en TEXT,
    content TEXT NOT NULL,
    keywords TEXT,  -- JSON array
    source TEXT,
    confidence REAL DEFAULT 1.0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_knowledge_category ON knowledge(category);
CREATE INDEX IF NOT EXISTS idx_knowledge_name ON knowledge(name_cn);

-- ==================== 对话历史 ====================

CREATE TABLE IF NOT EXISTS conversations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    role TEXT NOT NULL,  -- user, assistant
    content TEXT NOT NULL,
    source TEXT,  -- llm, knowledge, rule
    query_type TEXT,  -- region, grape, pairing, general
    feedback INTEGER,  -- 1=positive, -1=negative, NULL=none
    tokens_used INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_conversations_session ON conversations(session_id);
CREATE INDEX IF NOT EXISTS idx_conversations_created ON conversations(created_at);

-- ==================== 内容模板 ====================

CREATE TABLE IF NOT EXISTS templates (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    type TEXT NOT NULL,  -- ppt, poster_square, poster_vertical, menu
    description TEXT,
    content TEXT NOT NULL,  -- HTML template
    css TEXT,  -- Additional CSS
    variables TEXT,  -- JSON: available variables
    is_default INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ==================== 用户反馈 ====================

CREATE TABLE IF NOT EXISTS feedback (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT,
    message_id TEXT,
    action TEXT NOT NULL,  -- thumbs_up, thumbs_down, rating, text
    value INTEGER,  -- 1-5 for rating
    comment TEXT,
    query TEXT,
    response TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_feedback_session ON feedback(session_id);
CREATE INDEX IF NOT EXISTS idx_feedback_action ON feedback(action);

-- ==================== 产区数据 (从 wine-data 导入) ====================

CREATE TABLE IF NOT EXISTS regions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    external_id INTEGER,  -- wine-data ID
    name TEXT NOT NULL,
    name_cn TEXT,
    country TEXT,
    country_cn TEXT,
    parent_region TEXT,
    latitude REAL,
    longitude REAL,
    climate TEXT,
    soil TEXT,
    grapes TEXT,  -- JSON array
    classifications TEXT,  -- JSON array
    area_hectares INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_regions_country ON regions(country);
CREATE INDEX IF NOT EXISTS idx_regions_name ON regions(name);

-- ==================== 统计数据 (从 wine-data 导入) ====================

CREATE TABLE IF NOT EXISTS statistics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    stat_type TEXT NOT NULL,  -- production, consumption, export, import
    country TEXT,
    region TEXT,
    year INTEGER NOT NULL,
    value REAL NOT NULL,
    unit TEXT,  -- hl, bottles, EUR, etc.
    notes TEXT,
    source TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_statistics_type ON statistics(stat_type);
CREATE INDEX IF NOT EXISTS idx_statistics_year ON statistics(year);
CREATE INDEX IF NOT EXISTS idx_statistics_country ON statistics(country);

-- ==================== 默认模板 ====================

-- PPT 封面模板
INSERT INTO templates (name, type, description, content, is_default) VALUES
('PPT 封面', 'ppt', 'PPT 演示文稿封面页', '
<div class="slide cover">
    <div class="brand">{{brand}}</div>
    <div class="tagline">{{tagline}}</div>
    <div class="count">{{count}} 款精选佳酿</div>
    <div class="date">{{date}}</div>
</div>
', 1);

-- PPT 酒款页模板
INSERT INTO templates (name, type, description, content, is_default) VALUES
('PPT 酒款', 'ppt', 'PPT 演示文稿酒款详情页', '
<div class="slide wine">
    <div class="wine-image">
        <img src="{{image_url}}" alt="{{name_cn}}">
    </div>
    <div class="wine-info">
        <h1 class="name-cn">{{name_cn}}</h1>
        <h2 class="name-en">{{name_en}}</h2>
        <div class="producer">{{producer}}</div>
        <div class="region">{{region}} · {{classification}}</div>
        <div class="vintage">{{vintage}} · {{grape}}</div>
        <div class="score">{{score}}分</div>
        <div class="tasting">{{tasting_notes}}</div>
    </div>
</div>
', 1);

-- 方形海报模板
INSERT INTO templates (name, type, description, content, is_default) VALUES
('方形海报', 'poster_square', '社交媒体方形海报', '
<div class="poster square">
    <div class="brand">{{brand}}</div>
    <div class="wine-image">
        <img src="{{image_url}}" alt="{{name_cn}}">
    </div>
    <div class="wine-name">
        <h1>{{name_cn}}</h1>
        <h2>{{name_en}}</h2>
    </div>
    <div class="score">{{score}}</div>
    <div class="vintage">{{vintage}}</div>
</div>
', 1);

-- 竖版海报模板
INSERT INTO templates (name, type, description, content, is_default) VALUES
('竖版海报', 'poster_vertical', '微信朋友圈竖版海报', '
<div class="poster vertical">
    <div class="header">
        <div class="brand">{{brand}}</div>
        <div class="tagline">{{tagline}}</div>
    </div>
    <div class="wine-image">
        <img src="{{image_url}}" alt="{{name_cn}}">
    </div>
    <div class="wine-info">
        <h1 class="name-cn">{{name_cn}}</h1>
        <h2 class="name-en">{{name_en}}</h2>
        <div class="meta">
            <span>{{producer}}</span>
            <span>{{region}}</span>
            <span>{{vintage}}</span>
        </div>
        <div class="score">{{score}}分</div>
        <div class="tasting">{{tasting_notes}}</div>
    </div>
</div>
', 1);

-- 酒单模板
INSERT INTO templates (name, type, description, content, is_default) VALUES
('餐厅酒单', 'menu', '餐厅酒水单', '
<div class="menu">
    <div class="header">
        <h1>{{title}}</h1>
        <p>{{subtitle}}</p>
    </div>
    <div class="section red">
        <h2>红葡萄酒 Red Wines</h2>
        <table>
            <thead>
                <tr>
                    <th>酒名</th>
                    <th>酒庄</th>
                    <th>等级</th>
                    <th>年份</th>
                    <th>评分</th>
                    <th>价格</th>
                </tr>
            </thead>
            <tbody>
                {{#red_wines}}
                <tr>
                    <td>{{name_cn}}</td>
                    <td>{{producer}}</td>
                    <td>{{classification}}</td>
                    <td>{{vintage}}</td>
                    <td>{{score}}</td>
                    <td>¥{{price}}</td>
                </tr>
                {{/red_wines}}
            </tbody>
        </table>
    </div>
    <div class="section white">
        <h2>白葡萄酒 White Wines</h2>
        <table>
            <thead>
                <tr>
                    <th>酒名</th>
                    <th>酒庄</th>
                    <th>等级</th>
                    <th>年份</th>
                    <th>评分</th>
                    <th>价格</th>
                </tr>
            </thead>
            <tbody>
                {{#white_wines}}
                <tr>
                    <td>{{name_cn}}</td>
                    <td>{{producer}}</td>
                    <td>{{classification}}</td>
                    <td>{{vintage}}</td>
                    <td>{{score}}</td>
                    <td>¥{{price}}</td>
                </tr>
                {{/white_wines}}
            </tbody>
        </table>
    </div>
</div>
', 1);

-- ==================== 示例知识库数据 ====================

INSERT INTO knowledge (category, name_cn, name_en, content, keywords) VALUES
('region', '勃艮第', 'Burgundy', '勃艮第（Bourgogne）位于法国东部，是世界顶级的葡萄酒产区之一。南北狭长，约200公里。主要种植黑皮诺（红）和霞多丽（白）。拥有完善的分级体系：大区级、村庄级、一级园、特级园。著名子产区包括夜丘（Côte de Nuits）、博纳丘（Côte de Beaune）、夏布利（Chablis）等。', '["勃艮第", "Burgundy", "黑皮诺", "霞多丽", "特级园", "Grand Cru"]'),

('region', '香槟', 'Champagne', '香槟（Champagne）是法国最北部的葡萄酒产区，位于巴黎东北约150公里。只能使用霞多丽、黑皮诺、莫尼耶皮诺三种葡萄。必须采用传统法（Méthode Traditionnelle）在瓶中进行二次发酵。只有该地区出产的起泡酒才能称为"香槟"。', '["香槟", "Champagne", "起泡酒", "传统法", "黑皮诺", "霞多丽"]'),

('grape', '黑皮诺', 'Pinot Noir', '黑皮诺是最优雅的红葡萄品种之一。果皮薄，单宁柔和，酒体轻盈到中等。典型香气：樱桃、草莓、覆盆子，陈年后有泥土、蘑菇、皮革气息。主要产区：勃艮第、俄勒冈、新西兰、德国。适合搭配：鸭肉、三文鱼、蘑菇料理。', '["黑皮诺", "Pinot Noir", "红葡萄", "勃艮第", "轻盈"]'),

('grape', '霞多丽', 'Chardonnay', '霞多丽是最 versatile 的白葡萄品种。风格多样：从清脆的夏布利到浓郁的加州风格。典型香气：青苹果、柑橘（凉爽气候）到热带水果（温暖气候），经橡木桶后有黄油、香草气息。主要产区：勃艮第、加州、澳大利亚。', '["霞多丽", "Chardonnay", "白葡萄", "勃艮第", "夏布利"]'),

('technique', '传统法', 'Traditional Method', '传统法（Méthode Traditionnelle）是酿造高品质起泡酒的方法。二次发酵在瓶中进行，产生细腻气泡。酒泥陈酿赋予烘烤、坚果风味。转瓶（Remuage）收集沉淀，除渣（Dégorgement）去除。用于香槟、Cava、Crémant。', '["传统法", "起泡酒", "香槟", "二次发酵", "酒泥陈酿"]'),

('terminology', '风土', 'Terroir', '风土（Terroir）是法语术语，指影响葡萄酒风味的自然环境因素总和。包括：气候（Climate）、土壤（Soil）、地形（Topography）、日照（Exposure）。勃艮第是风土概念的典型代表，不同地块的酒风格迥异。', '["风土", "Terroir", "气候", "土壤", "勃艮第"]');
