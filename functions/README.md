# Firebase Functions - AI日记后端服务

使用Firebase Cloud Functions实现的AI日记生成后端服务，无需单独运行后端服务器。

## 🚀 快速开始

### 1. 安装Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

### 2. 安装依赖

```bash
cd functions
npm install
```

### 3. 配置API Keys

```bash
# 配置Gemini API Key（推荐）
firebase functions:config:set gemini.api_key="your_gemini_api_key"

# 查看配置
firebase functions:config:get
```

### 4. 本地测试

```bash
cd functions
npm run serve
```

### 5. 部署

```bash
firebase deploy --only functions
```

## 📱 Flutter集成

详细集成步骤请查看完整文档。

## 📚 完整文档

查看 `FIREBASE_SETUP.md` 获取详细的设置和使用说明。
