"""
OpenAI服务实现
"""

import os
import logging
from openai import OpenAI

from services import AIService

logger = logging.getLogger(__name__)


class OpenAIService(AIService):
    """OpenAI服务实现"""
    
    def __init__(self):
        self.api_key = os.getenv('OPENAI_API_KEY')
        self.model_name = 'gpt-4'
        self.client = None
        
        if self.api_key:
            try:
                self.client = OpenAI(api_key=self.api_key)
                logger.info("OpenAI service initialized successfully")
            except Exception as e:
                logger.error(f"Failed to initialize OpenAI: {e}")
        else:
            logger.warning("OPENAI_API_KEY not found in environment")
    
    def generate(self, prompt: str) -> str:
        """使用OpenAI生成文本"""
        if not self.client:
            raise ValueError("OpenAI service is not properly initialized")
        
        try:
            response = self.client.chat.completions.create(
                model=self.model_name,
                messages=[
                    {"role": "user", "content": prompt}
                ],
                temperature=0.7,
                max_tokens=800
            )
            
            return response.choices[0].message.content
            
        except Exception as e:
            logger.error(f"OpenAI generation error: {e}")
            raise Exception(f"OpenAI生成失败: {str(e)}")
    
    def is_available(self) -> bool:
        """检查OpenAI服务是否可用"""
        return self.client is not None and self.api_key is not None
    
    def get_model_name(self) -> str:
        """获取模型名称"""
        return self.model_name
