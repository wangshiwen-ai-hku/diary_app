"""
Claude AI服务实现
"""

import os
import logging
from anthropic import Anthropic

from services import AIService

logger = logging.getLogger(__name__)


class ClaudeService(AIService):
    """Claude AI服务实现"""
    
    def __init__(self):
        self.api_key = os.getenv('CLAUDE_API_KEY')
        self.model_name = 'claude-3-sonnet-20240229'
        self.client = None
        
        if self.api_key:
            try:
                self.client = Anthropic(api_key=self.api_key)
                logger.info("Claude service initialized successfully")
            except Exception as e:
                logger.error(f"Failed to initialize Claude: {e}")
        else:
            logger.warning("CLAUDE_API_KEY not found in environment")
    
    def generate(self, prompt: str) -> str:
        """使用Claude生成文本"""
        if not self.client:
            raise ValueError("Claude service is not properly initialized")
        
        try:
            message = self.client.messages.create(
                model=self.model_name,
                max_tokens=1024,
                messages=[
                    {"role": "user", "content": prompt}
                ]
            )
            
            return message.content[0].text
            
        except Exception as e:
            logger.error(f"Claude generation error: {e}")
            raise Exception(f"Claude生成失败: {str(e)}")
    
    def is_available(self) -> bool:
        """检查Claude服务是否可用"""
        return self.client is not None and self.api_key is not None
    
    def get_model_name(self) -> str:
        """获取模型名称"""
        return self.model_name
