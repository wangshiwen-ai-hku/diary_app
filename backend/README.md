# AI日记后端服务

基于Flask的AI日记生成后端服务，支持多个AI提供商。

## 功能特性

- ✅ 支持多个AI提供商（Gemini、OpenAI、Claude）
- ✅ RESTful API接口
- ✅ 错误处理和日志
- ✅ 配置管理
- ✅ CORS支持

## 快速开始

### 1. 安装依赖

```bash
cd backend
pip install -r requirements.txt
```

### 2. 配置环境变量

创建 `.env` 文件：

```bash
# Gemini API
GEMINI_API_KEY=your_gemini_api_key_here

# OpenAI API (可选)
OPENAI_API_KEY=your_openai_api_key_here

# Claude API (可选)
CLAUDE_API_KEY=your_claude_api_key_here

# 服务配置
FLASK_ENV=development
PORT=5000
```

### 3. 运行服务

```bash
# 开发模式
python app.py

# 或使用 Flask 命令
flask run --port=5000
```

服务将在 `http://localhost:5000` 启动

## API文档

### 生成日记

**接口**: `POST /api/generate-diary`

**请求体**:
```json
{
  "content": "今天和他一起看了电影",
  "style": "warm",
  "mood": "sweet",
  "provider": "gemini"
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "generated_text": "# 今天的美好\n\n今天和他一起看了电影...",
    "provider": "gemini",
    "model": "gemini-2.5-flash"
  }
}
```

## 测试

```bash
curl -X POST http://localhost:5000/api/generate-diary \
  -H "Content-Type: application/json" \
  -d '{
    "content": "今天和他一起看了电影",
    "style": "warm",
    "mood": "sweet"
  }'
```
