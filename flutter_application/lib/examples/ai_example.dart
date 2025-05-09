import '../services/ai_service.dart';
import '../services/transformer_model.dart';
import '../services/rag_service.dart';
import '../config/ai_config.dart';

class AIExample {
  late final AIService _aiService;
  late final TransformerModel _transformerModel;
  late final RAGService _ragService;

  AIExample() {
    // Initialize services with configuration
    _transformerModel = TransformerModel(
      modelEndpoint: AIConfig.openAiEndpoint,
      apiKey: AIConfig.openAiApiKey,
    );

    _ragService = RAGService(
      vectorDbEndpoint: AIConfig.pineconeEndpoint,
      apiKey: AIConfig.pineconeApiKey,
    );

    _aiService = AIService();
  }

  // Example of getting recommendations
  Future<void> getRecommendationsExample() async {
    try {
      // Example user preferences
      final userPreferences = {
        'interests': ['technology', 'finance', 'AI'],
        'riskLevel': 'moderate',
        'investmentHorizon': 'long-term',
      };

      // Get recommendations
      final recommendations = await _aiService.getRecommendations(
        userId: 'example_user_id',
        userPreferences: userPreferences,
        limit: AIConfig.maxResults,
      );

      // Process recommendations
      for (var recommendation in recommendations) {
        print('Recommendation: ${recommendation['title']}');
        print('Description: ${recommendation['description']}');
        print('Confidence: ${recommendation['confidence']}');
        print('---');
      }
    } catch (e) {
      print('Error in recommendation example: $e');
    }
  }

  // Example of updating knowledge base
  Future<void> updateKnowledgeBaseExample() async {
    try {
      // Example new data
      final newData = {
        'title': 'New Market Trend',
        'content': 'AI technology is revolutionizing investment strategies...',
        'category': 'technology',
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Update knowledge base
      await _aiService.updateKnowledgeBase(newData);
      print('Knowledge base updated successfully');
    } catch (e) {
      print('Error updating knowledge base: $e');
    }
  }

  // Example of processing user input
  Future<void> processUserInputExample() async {
    try {
      final userInput = 'What are the best AI stocks to invest in?';
      
      // Process input
      final processedInput = await _transformerModel.processUserInput(userInput);
      
      // Get relevant data
      final relevantData = await _ragService.retrieveRelevantData(
        query: userInput,
        limit: AIConfig.maxResults,
      );

      // Generate recommendations
      final recommendations = await _transformerModel.generateRecommendations(
        context: processedInput,
        relevantData: relevantData,
      );

      // Display results
      for (var recommendation in recommendations) {
        print('Recommendation: ${recommendation['title']}');
        print('Reasoning: ${recommendation['reasoning']}');
        print('---');
      }
    } catch (e) {
      print('Error processing user input: $e');
    }
  }
} 