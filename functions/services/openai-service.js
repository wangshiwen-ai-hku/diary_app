const functions = require('firebase-functions');
const OpenAI = require('openai');

/**
 * OpenAI Service
 */
class OpenAIService {
  constructor() {
    this.apiKey = functions.config().openai?.api_key;
    this.modelName = 'gpt-4';
    
    if (!this.apiKey) {
      console.warn('OPENAI_API_KEY not configured');
    }
    
    if (this.apiKey) {
      this.client = new OpenAI({
        apiKey: this.apiKey
      });
    }
  }

  async generate(prompt) {
    if (!this.client) {
      throw new Error('OpenAI API Key未配置');
    }

    try {
      const completion = await this.client.chat.completions.create({
        model: this.modelName,
        messages: [
          { role: 'user', content: prompt }
        ],
        temperature: 0.7,
        max_tokens: 800
      });

      return completion.choices[0].message.content;

    } catch (error) {
      console.error('OpenAI generation error:', error);
      throw new Error(`OpenAI生成失败: ${error.message}`);
    }
  }

  getModelName() {
    return this.modelName;
  }
}

module.exports = OpenAIService;
