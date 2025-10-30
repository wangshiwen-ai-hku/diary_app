"""
Gemini AI服务实现
"""

import os
import logging
import google.generativeai as genai

from services import AIService

logger = logging.getLogger(__name__)


class GeminiService(AIService):
    """Gemini AI服务实现"""
    
    def __init__(self):
        self.api_key = os.getenv('GEMINI_API_KEY')
        self.model_name = 'gemini-2.0-flash-exp'
        self.model = None
        
        if self.api_key:
            try:
                genai.configure(api_key=self.api_key, transport='rest')
                self.model = genai.GenerativeModel(self.model_name)
                logger.info("Gemini service initialized successfully")
            except Exception as e:
                logger.error(f"Failed to initialize Gemini: {e}")
        else:
            logger.warning("GEMINI_API_KEY not found in environment")
    
    def generate(self, prompt: str) -> str:
        """使用Gemini生成文本"""
        if not self.model:
            raise ValueError("Gemini service is not properly initialized")
        
        try:
            response = self.model.generate_content(prompt)
            generated_text = response.text
            
            # 清理Markdown代码块标记
            if "```markdown" in generated_text:
                start = generated_text.find("```markdown") + 11
                end = generated_text.find("```", start)
                generated_text = generated_text[start:end].strip()
            elif "```" in generated_text:
                start = generated_text.find("```") + 3
                end = generated_text.find("```", start)
                generated_text = generated_text[start:end].strip()
            
            return generated_text
            
        except Exception as e:
            logger.error(f"Gemini generation error: {e}")
            raise Exception(f"Gemini生成失败: {str(e)}")
    
    def is_available(self) -> bool:
        """检查Gemini服务是否可用"""
        return self.model is not None and self.api_key is not None
    
    def get_model_name(self) -> str:
        """获取模型名称"""
        return self.model_name
