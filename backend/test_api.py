#!/usr/bin/env python3
"""
后端API测试脚本
"""

import requests
import json
import sys

# API基础URL
BASE_URL = "http://localhost:5000/api"


def test_health():
    """测试健康检查接口"""
    print("🧪 测试健康检查接口...")
    try:
        response = requests.get(f"{BASE_URL}/health")
        print(f"✅ 状态码: {response.status_code}")
        print(f"📊 响应: {json.dumps(response.json(), indent=2, ensure_ascii=False)}")
        return response.status_code == 200
    except Exception as e:
        print(f"❌ 错误: {e}")
        return False


def test_providers():
    """测试获取提供商列表"""
    print("\n🧪 测试获取提供商列表...")
    try:
        response = requests.get(f"{BASE_URL}/providers")
        print(f"✅ 状态码: {response.status_code}")
        print(f"📊 响应: {json.dumps(response.json(), indent=2, ensure_ascii=False)}")
        return response.status_code == 200
    except Exception as e:
        print(f"❌ 错误: {e}")
        return False


def test_generate_diary():
    """测试生成日记接口"""
    print("\n🧪 测试生成日记接口...")
    
    test_data = {
        "content": "今天和他一起看了电影，很开心",
        "style": "warm",
        "mood": "sweet",
        "provider": "gemini"
    }
    
    print(f"📤 请求数据: {json.dumps(test_data, indent=2, ensure_ascii=False)}")
    
    try:
        response = requests.post(
            f"{BASE_URL}/generate-diary",
            json=test_data,
            timeout=60
        )
        print(f"✅ 状态码: {response.status_code}")
        result = response.json()
        
        if result.get('success'):
            print(f"🎉 生成成功!")
            print(f"📝 生成的日记:\n{result['data']['generated_text']}")
            print(f"\n🤖 使用的模型: {result['data']['model']}")
        else:
            print(f"❌ 生成失败: {result.get('error')}")
        
        return response.status_code == 200
    except Exception as e:
        print(f"❌ 错误: {e}")
        return False


def test_regenerate_diary():
    """测试重新生成日记接口"""
    print("\n🧪 测试重新生成日记接口...")
    
    test_data = {
        "original_content": "今天和他一起看了电影",
        "previous_ai_content": "这是之前生成的内容...",
        "style": "poetic",
        "mood": "sweet",
        "provider": "gemini"
    }
    
    print(f"📤 请求数据: {json.dumps(test_data, indent=2, ensure_ascii=False)}")
    
    try:
        response = requests.post(
            f"{BASE_URL}/regenerate-diary",
            json=test_data,
            timeout=60
        )
        print(f"✅ 状态码: {response.status_code}")
        result = response.json()
        
        if result.get('success'):
            print(f"🎉 重新生成成功!")
            print(f"📝 新生成的日记:\n{result['data']['generated_text']}")
        else:
            print(f"❌ 重新生成失败: {result.get('error')}")
        
        return response.status_code == 200
    except Exception as e:
        print(f"❌ 错误: {e}")
        return False


def main():
    """主测试函数"""
    print("🚀 开始测试后端API")
    print("=" * 60)
    
    # 检查服务是否运行
    try:
        requests.get(BASE_URL, timeout=5)
    except:
        print("❌ 错误: 无法连接到后端服务")
        print("💡 请先启动后端服务: python backend/app.py")
        sys.exit(1)
    
    # 运行测试
    results = []
    results.append(("健康检查", test_health()))
    results.append(("获取提供商列表", test_providers()))
    results.append(("生成日记", test_generate_diary()))
    results.append(("重新生成日记", test_regenerate_diary()))
    
    # 显示测试结果
    print("\n" + "=" * 60)
    print("📊 测试结果汇总:")
    for name, passed in results:
        status = "✅ 通过" if passed else "❌ 失败"
        print(f"  {name}: {status}")
    
    all_passed = all(result[1] for result in results)
    if all_passed:
        print("\n🎉 所有测试通过!")
        sys.exit(0)
    else:
        print("\n❌ 部分测试失败，请检查错误信息")
        sys.exit(1)


if __name__ == "__main__":
    main()
