"""
AI服务基类
"""

from abc import ABC, abstractmethod


class AIService(ABC):
    """AI服务抽象基类"""
    
    @abstractmethod
    def generate(self, prompt: str) -> str:
        """生成文本"""
        pass
    
    @abstractmethod
    def is_available(self) -> bool:
        """检查服务是否可用"""
        pass
    
    @abstractmethod
    def get_model_name(self) -> str:
        """获取模型名称"""
        pass
