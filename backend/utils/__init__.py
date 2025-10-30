"""
Prompt构建器
"""


class PromptBuilder:
    """日记Prompt构建器"""
    
    # 风格描述
    STYLE_DESCRIPTIONS = {
        'warm': '温柔细腻，充满爱意，强调细节和关怀',
        'poetic': '文艺浪漫，富有诗意，使用优美的文学化表达',
        'real': '口语化，原汁原味，保持真实不过度修饰',
        'funny': '幽默风趣，逗趣可爱，轻松愉快的语调'
    }
    
    # 心情关键词
    MOOD_KEYWORDS = {
        'happy': '开心、愉快、喜悦',
        'sweet': '甜蜜、温馨、幸福',
        'miss': '想念、思念、期待',
        'excited': '激动、兴奋、期待',
        'calm': '平静、安宁、舒适',
        'sad': '难过、伤心、失落',
        'angry': '生气、不满、委屈'
    }
    
    @classmethod
    def build_diary_prompt(cls, content: str, style: str = 'warm', mood: str = None) -> str:
        """构建日记生成Prompt"""
        
        # 获取风格描述
        style_desc = cls.STYLE_DESCRIPTIONS.get(style, cls.STYLE_DESCRIPTIONS['warm'])
        
        # 获取心情关键词
        mood_desc = ''
        if mood and mood in cls.MOOD_KEYWORDS:
            mood_desc = f"\n- 情绪基调: {cls.MOOD_KEYWORDS[mood]}"
        
        prompt = f"""你是一个温柔细腻的情感记录者，擅长将简短的记录扩写成感人的日记。

请基于以下信息生成一篇日记：

**原始内容**: {content}

**风格要求**: {style_desc}{mood_desc}

**格式要求**:
1. 字数控制在300-500字
2. 使用Markdown格式
3. 适当添加emoji表情（不超过3个）
4. 段落清晰，使用空行分隔
5. 可以适当使用标题、引用等Markdown语法
6. 保持原汁原味的情感，不要过度夸张

**输出要求**:
- 直接输出日记内容，不要任何解释
- 不要输出"这是根据您的要求生成的日记"之类的说明
- 从日记正文开始

请开始生成:"""
        
        return prompt
    
    @classmethod
    def build_regenerate_prompt(cls, original_content: str, previous_ai_content: str, 
                                 style: str = 'warm', mood: str = None) -> str:
        """构建重新生成Prompt（带历史上下文）"""
        
        style_desc = cls.STYLE_DESCRIPTIONS.get(style, cls.STYLE_DESCRIPTIONS['warm'])
        
        mood_desc = ''
        if mood and mood in cls.MOOD_KEYWORDS:
            mood_desc = f"\n- 情绪基调: {cls.MOOD_KEYWORDS[mood]}"
        
        prompt = f"""你是一个温柔细腻的情感记录者。用户对之前生成的日记不太满意，希望重新生成一个不同风格的版本。

**原始记录**: {original_content}

**之前生成的版本**:
{previous_ai_content}

**新的风格要求**: {style_desc}{mood_desc}

**要求**:
1. 完全不同的角度和表达方式
2. 保持300-500字
3. 使用Markdown格式
4. 适当使用emoji（不超过3个）
5. 不要重复之前版本的表达和结构

**输出要求**:
- 直接输出新的日记内容
- 不要任何解释或说明
- 从日记正文开始

请生成一个全新版本:"""
        
        return prompt
