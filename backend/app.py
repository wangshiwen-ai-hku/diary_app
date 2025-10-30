"""
Flask后端服务 - AI日记生成API
"""

import os
import logging
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv

from services.ai_service_factory import AIServiceFactory
from utils.prompt_builder import PromptBuilder

# 加载环境变量
load_dotenv()

# 初始化Flask应用
app = Flask(__name__)
CORS(app)  # 允许跨域请求

# 配置日志
logging.basicConfig(
    level=getattr(logging, os.getenv('LOG_LEVEL', 'INFO')),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# 初始化AI服务工厂
ai_factory = AIServiceFactory()


@app.route('/api/health', methods=['GET'])
def health_check():
    """健康检查接口"""
    providers_status = {}
    
    # 检查各个AI提供商的可用性
    for provider in ['gemini', 'openai', 'claude']:
        try:
            service = ai_factory.get_service(provider)
            providers_status[provider] = service.is_available()
        except Exception as e:
            logger.error(f"Error checking {provider}: {e}")
            providers_status[provider] = False
    
    return jsonify({
        'status': 'healthy',
        'version': '1.0.0',
        'providers': providers_status
    })


@app.route('/api/generate-diary', methods=['POST'])
def generate_diary():
    """生成日记接口"""
    try:
        # 获取请求数据
        data = request.get_json()
        
        if not data:
            return jsonify({
                'success': False,
                'error': '请求体不能为空'
            }), 400
        
        # 验证必需参数
        content = data.get('content', '').strip()
        if not content:
            return jsonify({
                'success': False,
                'error': 'content参数不能为空'
            }), 400
        
        # 获取可选参数
        style = data.get('style', 'warm')  # warm/poetic/real
        mood = data.get('mood')  # happy/sweet/miss/excited/calm
        provider = data.get('provider', os.getenv('DEFAULT_AI_PROVIDER', 'gemini'))
        
        logger.info(f"Generating diary with provider: {provider}, style: {style}, mood: {mood}")
        
        # 构建Prompt
        prompt = PromptBuilder.build_diary_prompt(
            content=content,
            style=style,
            mood=mood
        )
        
        # 获取AI服务
        ai_service = ai_factory.get_service(provider)
        
        # 生成日记
        generated_text = ai_service.generate(prompt)
        
        # 返回结果
        return jsonify({
            'success': True,
            'data': {
                'generated_text': generated_text,
                'provider': provider,
                'model': ai_service.get_model_name()
            }
        })
        
    except ValueError as e:
        logger.error(f"Validation error: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 400
        
    except Exception as e:
        logger.error(f"Error generating diary: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': f'生成失败: {str(e)}'
        }), 500


@app.route('/api/regenerate-diary', methods=['POST'])
def regenerate_diary():
    """重新生成日记接口（带历史上下文）"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({
                'success': False,
                'error': '请求体不能为空'
            }), 400
        
        # 验证参数
        original_content = data.get('original_content', '').strip()
        previous_ai_content = data.get('previous_ai_content', '').strip()
        
        if not original_content:
            return jsonify({
                'success': False,
                'error': 'original_content参数不能为空'
            }), 400
        
        # 获取可选参数
        style = data.get('style', 'warm')
        mood = data.get('mood')
        provider = data.get('provider', os.getenv('DEFAULT_AI_PROVIDER', 'gemini'))
        
        logger.info(f"Regenerating diary with provider: {provider}")
        
        # 构建重新生成的Prompt
        prompt = PromptBuilder.build_regenerate_prompt(
            original_content=original_content,
            previous_ai_content=previous_ai_content,
            style=style,
            mood=mood
        )
        
        # 获取AI服务并生成
        ai_service = ai_factory.get_service(provider)
        generated_text = ai_service.generate(prompt)
        
        return jsonify({
            'success': True,
            'data': {
                'generated_text': generated_text,
                'provider': provider,
                'model': ai_service.get_model_name()
            }
        })
        
    except Exception as e:
        logger.error(f"Error regenerating diary: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': f'重新生成失败: {str(e)}'
        }), 500


@app.route('/api/providers', methods=['GET'])
def list_providers():
    """列出所有可用的AI提供商"""
    providers = []
    
    for provider_name in ['gemini', 'openai', 'claude']:
        try:
            service = ai_factory.get_service(provider_name)
            providers.append({
                'name': provider_name,
                'available': service.is_available(),
                'model': service.get_model_name()
            })
        except Exception as e:
            logger.error(f"Error checking provider {provider_name}: {e}")
            providers.append({
                'name': provider_name,
                'available': False,
                'error': str(e)
            })
    
    return jsonify({
        'success': True,
        'providers': providers
    })


@app.errorhandler(404)
def not_found(error):
    """404错误处理"""
    return jsonify({
        'success': False,
        'error': '接口不存在'
    }), 404


@app.errorhandler(500)
def internal_error(error):
    """500错误处理"""
    logger.error(f"Internal server error: {error}")
    return jsonify({
        'success': False,
        'error': '服务器内部错误'
    }), 500


if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    host = os.getenv('HOST', '0.0.0.0')
    debug = os.getenv('FLASK_ENV') == 'development'
    
    logger.info(f"Starting server on {host}:{port}")
    app.run(host=host, port=port, debug=debug)
