#!/bin/bash

# 后端服务启动脚本

echo "🚀 启动AI日记后端服务..."

# 检查Python版本
if ! command -v python3 &> /dev/null; then
    echo "❌ 错误: 未找到python3"
    echo "💡 请先安装Python 3.8或更高版本"
    exit 1
fi

# 进入backend目录
cd "$(dirname "$0")"

# 检查.env文件
if [ ! -f .env ]; then
    echo "⚠️  警告: .env文件不存在"
    echo "💡 请从.env.example复制并配置:"
    echo "   cp .env.example .env"
    echo "   然后编辑.env文件，添加你的API Key"
    exit 1
fi

# 检查依赖
echo "📦 检查依赖..."
if ! python3 -c "import flask" 2>/dev/null; then
    echo "📥 安装依赖..."
    pip3 install -r requirements.txt
fi

# 检查API Key
source .env
if [ -z "$GEMINI_API_KEY" ] && [ -z "$OPENAI_API_KEY" ] && [ -z "$CLAUDE_API_KEY" ]; then
    echo "❌ 错误: 未配置任何AI API Key"
    echo "💡 请在.env文件中至少配置一个API Key:"
    echo "   GEMINI_API_KEY=your_key_here"
    exit 1
fi

echo "✅ 配置检查完成"
echo "🌐 启动服务..."
echo ""

# 启动Flask应用
python3 app.py
