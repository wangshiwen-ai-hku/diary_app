const functions = require('firebase-functions');
const admin = require('firebase-admin');

// 初始化Firebase Admin
admin.initializeApp();

// AI服务
const GeminiService = require('./services/gemini-service');
const OpenAIService = require('./services/openai-service');
const ClaudeService = require('./services/claude-service');

// Prompt构建器
const PromptBuilder = require('./utils/prompt-builder');

/**
 * 生成日记
 * POST /generateDiary
 */
exports.generateDiary = functions
  .region('asia-northeast1')
  .runWith({
    timeoutSeconds: 60,
    memory: '512MB'
  })
  .https.onCall(async (data, context) => {
    try {
      if (!data.content) {
        throw new functions.https.HttpsError(
          'invalid-argument',
          'content参数不能为空'
        );
      }

      const {
        content,
        style = 'warm',
        mood,
        provider = 'gemini'
      } = data;

      console.log(`Generating diary with provider: ${provider}, style: ${style}`);

      const prompt = PromptBuilder.buildDiaryPrompt(content, style, mood);

      let aiService;
      switch (provider.toLowerCase()) {
        case 'gemini':
          aiService = new GeminiService();
          break;
        case 'openai':
          aiService = new OpenAIService();
          break;
        case 'claude':
          aiService = new ClaudeService();
          break;
        default:
          throw new functions.https.HttpsError(
            'invalid-argument',
            `不支持的AI提供商: ${provider}`
          );
      }

      const generatedText = await aiService.generate(prompt);

      return {
        success: true,
        data: {
          generated_text: generatedText,
          provider: provider,
          model: aiService.getModelName()
        }
      };

    } catch (error) {
      console.error('Generate diary error:', error);
      
      if (error instanceof functions.https.HttpsError) {
        throw error;
      }
      
      throw new functions.https.HttpsError(
        'internal',
        `生成失败: ${error.message}`
      );
    }
  });

/**
 * 重新生成日记
 */
exports.regenerateDiary = functions
  .region('asia-northeast1')
  .runWith({
    timeoutSeconds: 60,
    memory: '512MB'
  })
  .https.onCall(async (data, context) => {
    try {
      if (!data.originalContent) {
        throw new functions.https.HttpsError(
          'invalid-argument',
          'originalContent参数不能为空'
        );
      }

      const {
        originalContent,
        previousAIContent,
        style = 'warm',
        mood,
        provider = 'gemini'
      } = data;

      const prompt = PromptBuilder.buildRegeneratePrompt(
        originalContent,
        previousAIContent,
        style,
        mood
      );

      let aiService;
      switch (provider.toLowerCase()) {
        case 'gemini':
          aiService = new GeminiService();
          break;
        case 'openai':
          aiService = new OpenAIService();
          break;
        case 'claude':
          aiService = new ClaudeService();
          break;
        default:
          throw new functions.https.HttpsError(
            'invalid-argument',
            `不支持的AI提供商: ${provider}`
          );
      }

      const generatedText = await aiService.generate(prompt);

      return {
        success: true,
        data: {
          generated_text: generatedText,
          provider: provider,
          model: aiService.getModelName()
        }
      };

    } catch (error) {
      console.error('Regenerate diary error:', error);
      
      if (error instanceof functions.https.HttpsError) {
        throw error;
      }
      
      throw new functions.https.HttpsError(
        'internal',
        `重新生成失败: ${error.message}`
      );
    }
  });

/**
 * 健康检查
 */
exports.health = functions
  .region('asia-northeast1')
  .https.onRequest((req, res) => {
    res.json({
      status: 'healthy',
      version: '1.0.0',
      timestamp: new Date().toISOString()
    });
  });
