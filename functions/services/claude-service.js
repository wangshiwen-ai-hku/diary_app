const functions = require('firebase-functions');
const Anthropic = require('@anthropic-ai/sdk');

/**
 * Claude Service
 */
class ClaudeService {
  constructor() {
    this.apiKey = functions.config().claude?.api_key;
    this.modelName = 'claude-3-sonnet-20240229';
    
    if (!this.apiKey) {
      console.warn('CLAUDE_API_KEY not configured');
    }
    
    if (this.apiKey) {
      this.client = new Anthropic({
        apiKey: this.apiKey
      });
    }
  }

  async generate(prompt) {
    if (!this.client) {
      throw new Error('Claude API Key未配置');
    }

    try {
      const message = await this.client.messages.create({
        model: this.modelName,
        max_tokens: 1024,
        messages: [
          { role: 'user', content: prompt }
        ]
      });

      return message.content[0].text;

    } catch (error) {
      console.error('Claude generation error:', error);
      throw new Error(`Claude生成失败: ${error.message}`);
    }
  }

  getModelName() {
    return this.modelName;
  }
}

module.exports = ClaudeService;
