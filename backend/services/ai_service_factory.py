"""
AI服务工厂
"""

import logging
from services.gemini_service import GeminiService
from services.openai_service import OpenAIService
from services.claude_service import ClaudeService

logger = logging.getLogger(__name__)


class AIServiceFactory:
    """AI服务工厂类"""
    
    def __init__(self):
        self._services = {}
        self._initialize_services()
    
    def _initialize_services(self):
        """初始化所有服务"""
        try:
            self._services['gemini'] = GeminiService()
        except Exception as e:
            logger.error(f"Failed to initialize Gemini service: {e}")
        
        try:
            self._services['openai'] = OpenAIService()
        except Exception as e:
            logger.error(f"Failed to initialize OpenAI service: {e}")
        
        try:
            self._services['claude'] = ClaudeService()
        except Exception as e:
            logger.error(f"Failed to initialize Claude service: {e}")
    
    def get_service(self, provider: str):
        """获取指定的AI服务"""
        provider = provider.lower()
        
        if provider not in self._services:
            raise ValueError(f"不支持的AI提供商: {provider}")
        
        service = self._services[provider]
        
        if not service.is_available():
            raise ValueError(f"{provider} 服务不可用，请检查API Key配置")
        
        return service
    
    def get_available_providers(self):
        """获取所有可用的提供商"""
        return [
            name for name, service in self._services.items()
            if service.is_available()
        ]
