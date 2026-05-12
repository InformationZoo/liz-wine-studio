# LLM 服务设计

> 智谱 AI GLM API 封装

---

## 概述

Liz Wine Studio 使用智谱 AI 的 GLM 系列模型：

| 模型 | 用途 | 特点 |
|------|------|------|
| GLM-4-flash | 智能问答 | 免费额度大，响应快 |
| GLM-4v-flash | 酒标识别 | 支持视觉输入，免费 |

---

## API 配置

### 环境变量

```env
# .env
ZHIPU_API_KEY=your_api_key_here
```

### API 端点

```
Base URL: https://open.bigmodel.cn/api/paas/v4/chat/completions
```

---

## 服务封装

### llm.js

```javascript
/**
 * LLM 服务 - GLM API 封装
 */

const fetch = require('node-fetch');

class LLMService {
    constructor(apiKey) {
        this.apiKey = apiKey || process.env.ZHIPU_API_KEY;
        this.baseUrl = 'https://open.bigmodel.cn/api/paas/v4/chat/completions';
        this.models = {
            chat: 'glm-4-flash',      // 文本对话
            vision: 'glm-4v-flash'    // 视觉识别
        };
        this.timeout = 30000; // 30秒超时
    }

    /**
     * 文本对话
     * @param {string} message - 用户消息
     * @param {object} options - 选项
     * @returns {Promise<object>} - 响应
     */
    async chat(message, options = {}) {
        const {
            context = '',
            systemPrompt = this.getDefaultSystemPrompt(),
            temperature = 0.7,
            maxTokens = 2000
        } = options;

        const messages = [];

        // 系统提示
        if (systemPrompt) {
            messages.push({
                role: 'system',
                content: systemPrompt
            });
        }

        // 上下文
        if (context) {
            messages.push({
                role: 'system',
                content: `参考信息：\n${context}`
            });
        }

        // 用户消息
        messages.push({
            role: 'user',
            content: message
        });

        try {
            const response = await fetch(this.baseUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${this.apiKey}`
                },
                body: JSON.stringify({
                    model: this.models.chat,
                    messages,
                    temperature,
                    max_tokens: maxTokens
                }),
                timeout: this.timeout
            });

            const data = await response.json();

            if (data.error) {
                return {
                    success: false,
                    error: data.error.message || 'API 错误'
                };
            }

            return {
                success: true,
                content: data.choices[0].message.content,
                usage: data.usage,
                model: data.model
            };

        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * 视觉识别 (酒标)
     * @param {string} imageBase64 - 图片 Base64 (不含前缀)
     * @param {string} prompt - 提示词
     * @returns {Promise<object>} - 响应
     */
    async recognize(imageBase64, prompt) {
        const messages = [
            {
                role: 'user',
                content: [
                    {
                        type: 'image_url',
                        image_url: {
                            url: imageBase64
                        }
                    },
                    {
                        type: 'text',
                        text: prompt
                    }
                ]
            }
        ];

        try {
            const response = await fetch(this.baseUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${this.apiKey}`
                },
                body: JSON.stringify({
                    model: this.models.vision,
                    messages,
                    max_tokens: 2000
                }),
                timeout: this.timeout
            });

            const data = await response.json();

            if (data.error) {
                return {
                    success: false,
                    error: data.error.message || 'API 错误'
                };
            }

            return {
                success: true,
                content: data.choices[0].message.content,
                usage: data.usage,
                model: data.model
            };

        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * 酒标识别 (封装)
     * @param {string} imageBase64 - 图片 Base64
     * @returns {Promise<object>} - 结构化识别结果
     */
    async recognizeWineLabel(imageBase64) {
        // 去除 Base64 前缀
        const pureBase64 = imageBase64.includes(',')
            ? imageBase64.split(',')[1]
            : imageBase64;

        const prompt = `请识别这个葡萄酒标签，提取以下信息：
1. 酒庄名称 (winery / winery_cn)
2. 产区 (region / region_cn)
3. 年份 (vintage)
4. 葡萄品种 (grape / grape_cn)
5. 等级/分级 (classification)
6. 参考价格区间 (price_range)

请以 JSON 格式返回，同时用中文简要介绍这款酒。
格式示例：
{
  "winery": "Domaine de la Romanée-Conti",
  "winery_cn": "罗曼尼·康帝酒庄",
  "region": "Burgundy",
  "region_cn": "勃艮第",
  "vintage": 2019,
  "grape": "Pinot Noir",
  "grape_cn": "黑皮诺",
  "classification": "Grand Cru",
  "price_range": "¥150,000-200,000"
}`;

        const result = await this.recognize(pureBase64, prompt);

        if (!result.success) {
            return result;
        }

        // 解析 JSON
        const content = result.content;
        let wineInfo = {};

        const jsonMatch = content.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
            try {
                wineInfo = JSON.parse(jsonMatch[0]);
            } catch (e) {
                console.error('JSON parse error:', e);
            }
        }

        // 提取描述文本
        const description = content.replace(/\{[\s\S]*\}/, '').trim();

        return {
            success: true,
            wine: wineInfo,
            description,
            raw_content: content
        };
    }

    /**
     * 默认系统提示
     */
    getDefaultSystemPrompt() {
        return `你是 Liz Wine 的专业葡萄酒助手。你的职责是：

1. 回答葡萄酒相关问题（产区、品种、酿造、品鉴）
2. 提供配餐建议
3. 介绍储存和侍酒知识
4. 推荐适合的酒款

回答要求：
- 专业准确，有理有据
- 通俗易懂，避免过于技术化
- 适当使用emoji增加亲和力
- 如果不确定，坦诚说明

你是勃艮第和香槟专家，专注这两个产区的知识。`;
    }
}

// 单例
let llmService = null;

function getLLMService() {
    if (!llmService) {
        llmService = new LLMService();
    }
    return llmService;
}

module.exports = {
    LLMService,
    getLLMService
};
```

---

## 使用示例

### 智能问答

```javascript
const { getLLMService } = require('./services/llm');

const llm = getLLMService();

// 简单问答
const result = await llm.chat('勃艮第有哪些特级园？');
console.log(result.content);

// 带上下文
const result2 = await llm.chat('这款酒怎么样？', {
    context: '酒款：罗曼尼·康帝 2019，特级园，评分99分'
});

// 自定义系统提示
const result3 = await llm.chat('推荐配餐', {
    systemPrompt: '你是一个侍酒师，专注于葡萄酒配餐...'
});
```

### 酒标识别

```javascript
const { getLLMService } = require('./services/llm');

const llm = getLLMService();

// 从上传的图片识别
const fs = require('fs');
const imageBase64 = fs.readFileSync('wine-label.jpg', 'base64');

const result = await llm.recognizeWineLabel(imageBase64);

if (result.success) {
    console.log('识别结果:', result.wine);
    console.log('描述:', result.description);
}
```

---

## 速率限制

GLM 免费版有速率限制：

| 限制 | 值 |
|------|------|
| 每分钟请求数 | 3 |
| 每小时请求数 | 100 |
| 每天请求数 | 500 |

### 建议实现

```javascript
class RateLimiter {
    constructor(maxPerMinute = 2, minInterval = 3000) {
        this.maxPerMinute = maxPerMinute;
        this.minInterval = minInterval;
        this.requests = [];
    }

    canRequest() {
        const now = Date.now();
        this.requests = this.requests.filter(t => now - t < 60000);

        if (this.requests.length >= this.maxPerMinute) {
            return false;
        }

        if (this.requests.length > 0) {
            const elapsed = now - this.requests[this.requests.length - 1];
            if (elapsed < this.minInterval) {
                return false;
            }
        }

        return true;
    }

    recordRequest() {
        this.requests.push(Date.now());
    }

    getWaitTime() {
        if (this.requests.length === 0) return 0;

        const now = Date.now();
        const elapsed = now - this.requests[this.requests.length - 1];
        return Math.max(0, this.minInterval - elapsed);
    }
}
```

---

## 错误处理

### 常见错误

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| `rate limit exceeded` | 请求过于频繁 | 等待后重试，使用规则引擎兜底 |
| `invalid api key` | API Key 无效 | 检查 .env 配置 |
| `model not found` | 模型名称错误 | 检查模型名称 |
| `image too large` | 图片过大 | 压缩图片至 < 4MB |

### 兜底策略

```javascript
async function chatWithFallback(message, context) {
    const llm = getLLMService();

    // 检查速率限制
    if (!rateLimiter.canRequest()) {
        return getLocalResponse(message, context);
    }

    rateLimiter.recordRequest();

    const result = await llm.chat(message, { context });

    if (!result.success) {
        // 使用规则引擎兜底
        return getLocalResponse(message, context);
    }

    return result;
}

function getLocalResponse(message, context) {
    // 本地规则响应
    const rules = {
        '勃艮第': '勃艮第位于法国东部，以黑皮诺和霞多丽闻名...',
        '香槟': '香槟是法国最北部的产区，只能使用三种葡萄...',
        '黑皮诺': '黑皮诺是最优雅的红葡萄品种之一...'
    };

    for (const [keyword, response] of Object.entries(rules)) {
        if (message.includes(keyword)) {
            return {
                success: true,
                content: response,
                source: 'rule'
            };
        }
    }

    return {
        success: true,
        content: '抱歉，AI 服务暂时繁忙，请稍后再试。',
        source: 'fallback'
    };
}
```

---

## 监控与日志

### 请求日志

```javascript
function logRequest(model, prompt, response, duration) {
    console.log({
        timestamp: new Date().toISOString(),
        model,
        prompt_length: prompt.length,
        response_length: response.length,
        duration_ms: duration,
        tokens_used: response.usage?.total_tokens
    });
}
```

### 性能指标

```javascript
const metrics = {
    total_requests: 0,
    successful_requests: 0,
    failed_requests: 0,
    avg_latency_ms: 0,
    total_tokens: 0
};

function updateMetrics(result, duration) {
    metrics.total_requests++;
    if (result.success) {
        metrics.successful_requests++;
        metrics.total_tokens += result.usage?.total_tokens || 0;
    } else {
        metrics.failed_requests++;
    }
    // 更新平均延迟...
}
```

---

*文档版本: 1.0.0 | 更新日期: 2026-03-25*
