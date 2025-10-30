const functions = require('firebase-functions');

/**
 * Gemini AI Service
 */
class GeminiService {
  constructor() {
    this.apiKey = functions.config().gemini?.api_key;
    this.modelName = 'gemini-2.5-flash';
    
    if (!this.apiKey) {
      console.warn('GEMINI_API_KEY not configured');
    }
  }

  async generate(prompt) {
    if (!this.apiKey) {
      throw new Error('Gemini API Key未配置');
    }

    try {
      const { GoogleGenerativeAI } = require('@google/generative-ai');
      const genAI = new GoogleGenerativeAI(this.apiKey);
      const model = genAI.getGenerativeModel({ model: this.modelName });

      const result = await model.generateContent(prompt);
      const response = await result.response;
      let text = response.text();

      // 清理Markdown代码块
      if (text.includes('```markdown')) {
        const start = text.indexOf('```markdown') + 11;
        const end = text.indexOf('```', start);
        text = text.substring(start, end).trim();
      } else if (text.includes('```')) {
        const start = text.indexOf('```') + 3;
        const end = text.indexOf('```', start);
        text = text.substring(start, end).trim();
      }

      return text;

    } catch (error) {
      console.error('Gemini generation error:', error);
      throw new Error(`Gemini生成失败: ${error.message}`);
    }
  }

  getModelName() {
    return this.modelName;
  }
}

module.exports = GeminiService;
