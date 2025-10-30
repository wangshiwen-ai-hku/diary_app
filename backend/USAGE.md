# 🚀 后端服务使用指南

## 📋 目录

1. [快速开始](#快速开始)
2. [配置说明](#配置说明)
3. [API文档](#api文档)
4. [测试](#测试)
5. [Flutter集成](#flutter集成)
6. [常见问题](#常见问题)

---

## 快速开始

### 1. 安装依赖

```bash
cd backend
pip install -r requirements.txt
```

### 2. 配置环境变量

复制示例配置文件：

```bash
cp .env.example .env
```

编辑 `.env` 文件，添加你的API Key：

```bash
# 至少配置一个AI提供商
GEMINI_API_KEY=your_gemini_api_key_here
# OPENAI_API_KEY=your_openai_api_key_here
# CLAUDE_API_KEY=your_claude_api_key_here

DEFAULT_AI_PROVIDER=gemini
```

### 3. 启动服务

**方式1：使用启动脚本（推荐）**

```bash
./start.sh
```

**方式2：直接运行**

```bash
python app.py
```

服务将在 `http://localhost:5000` 启动

---

## 配置说明

### Gemini API

1. 访问 https://makersuite.google.com/app/apikey
2. 创建API Key
3. 添加到 `.env` 文件：
   ```
   GEMINI_API_KEY=AIzaSy...
   ```

**注意**: Gemini API有地区限制，可能需要使用VPN

### OpenAI API

1. 访问 https://platform.openai.com/api-keys
2. 创建API Key
3. 添加到 `.env` 文件：
   ```
   OPENAI_API_KEY=sk-...
   ```

### Claude API

1. 访问 https://console.anthropic.com/
2. 创建API Key
3. 添加到 `.env` 文件：
   ```
   CLAUDE_API_KEY=sk-ant-...
   ```

---

## API文档

### 1. 健康检查

```bash
GET /api/health
```

**响应**:
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "providers": {
    "gemini": true,
    "openai": false,
    "claude": false
  }
}
```

### 2. 生成日记

```bash
POST /api/generate-diary
Content-Type: application/json
```

**请求体**:
```json
{
  "content": "今天和他一起看了电影",
  "style": "warm",
  "mood": "sweet",
  "provider": "gemini"
}
```

**参数说明**:
- `content` (必需): 日记原始内容
- `style` (可选): 风格
  - `warm`: 温馨（默认）
  - `poetic`: 诗意
  - `real`: 真实
  - `funny`: 搞笑
- `mood` (可选): 心情
  - `happy`: 开心
  - `sweet`: 甜蜜
  - `miss`: 想念
  - `excited`: 激动
  - `calm`: 平静
- `provider` (可选): AI提供商（gemini/openai/claude），默认gemini

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

### 3. 重新生成日记

```bash
POST /api/regenerate-diary
Content-Type: application/json
```

**请求体**:
```json
{
  "original_content": "今天和他一起看了电影",
  "previous_ai_content": "之前生成的内容...",
  "style": "poetic",
  "mood": "sweet",
  "provider": "gemini"
}
```

### 4. 获取提供商列表

```bash
GET /api/providers
```

**响应**:
```json
{
  "success": true,
  "providers": [
    {
      "name": "gemini",
      "available": true,
      "model": "gemini-2.5-flash"
    },
    {
      "name": "openai",
      "available": false,
      "error": "API Key not configured"
    }
  ]
}
```

---

## 测试

### 测试后端API

```bash
python backend/test_api.py
```

### 使用curl测试

```bash
# 健康检查
curl http://localhost:5000/api/health

# 生成日记
curl -X POST http://localhost:5000/api/generate-diary \
  -H "Content-Type: application/json" \
  -d '{
    "content": "今天和他一起看了电影",
    "style": "warm",
    "mood": "sweet"
  }'
```

### 使用Python测试

```python
import requests

response = requests.post(
    'http://localhost:5000/api/generate-diary',
    json={
        'content': '今天和他一起看了电影',
        'style': 'warm',
        'mood': 'sweet'
    }
)

print(response.json())
```

---

## Flutter集成

### 1. 确保后端服务运行

```bash
cd backend
./start.sh
```

### 2. 更新Flutter代码

已创建的 `lib/data/services/ai_service.dart` 会自动连接后端。

### 3. 测试连接

在Flutter应用中：

```dart
final aiService = AIService();

// 检查健康状态
final health = await aiService.checkHealth();
print('Backend status: $health');

// 生成日记
try {
  final result = await aiService.generateDiary(
    content: '今天和他一起看了电影',
    style: 'warm',
    mood: 'sweet',
  );
  print('Generated: $result');
} catch (e) {
  print('Error: $e');
}
```

### 4. 配置后端地址

在 `lib/data/services/ai_service.dart` 中修改：

```dart
// 开发环境
final String _baseUrl = 'http://localhost:5000/api';

// 生产环境（部署后）
// final String _baseUrl = 'https://your-domain.com/api';
```

---

## 常见问题

### Q1: 启动失败，提示模块找不到

**A**: 安装依赖

```bash
cd backend
pip install -r requirements.txt
```

### Q2: Gemini API报错"User location is not supported"

**A**: Gemini API有地区限制，解决方案：
1. 使用VPN切换到支持的地区
2. 或使用OpenAI/Claude API

### Q3: Flutter无法连接后端

**A**: 检查：
1. 后端服务是否运行：访问 http://localhost:5000/api/health
2. Flutter是否在同一网络
3. iOS模拟器需要用 `http://localhost:5000`
4. Android模拟器需要用 `http://10.0.2.2:5000`

### Q4: 生成速度慢

**A**: 
1. 检查网络连接
2. 不同AI提供商速度不同，尝试切换
3. 考虑增加超时时间

### Q5: API Key无效

**A**: 
1. 检查API Key格式是否正确
2. 检查API Key是否有效
3. 检查是否有配额限制

---

## 部署

### Docker部署

创建 `Dockerfile`:

```dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
```

构建和运行：

```bash
docker build -t diary-backend .
docker run -p 5000:5000 --env-file .env diary-backend
```

### 生产环境

使用Gunicorn：

```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

---

## 性能优化

### 1. 使用缓存

考虑添加Redis缓存相似请求

### 2. 异步处理

对于耗时请求，考虑使用异步任务队列（Celery）

### 3. 负载均衡

使用Nginx做反向代理和负载均衡

---

## 安全建议

1. ✅ 使用环境变量存储API Key
2. ✅ 不要将API Key提交到Git
3. ✅ 生产环境使用HTTPS
4. ✅ 添加请求频率限制
5. ✅ 添加身份验证

---

## 支持

遇到问题？

1. 查看日志输出
2. 运行测试脚本诊断
3. 检查API Key配置
4. 查看常见问题部分

---

**祝使用愉快！** 🎉
