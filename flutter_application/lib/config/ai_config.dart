class AIConfig {
  // OpenAI Configuration
  static const String openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String openAiEndpoint = 'https://api.openai.com/v1/chat/completions';
  
  // Vector Database Configuration (Pinecone example)
  static const String pineconeApiKey = 'pcsk_6wAoJA_69yz3fwfBKoo7dEY6nhzmomPv7vq3XY6CyuDFQGoUnyaQ4fE6Rq9zLtgDq2AZyW';
  static const String pineconeEndpoint = 'https://pinecone-production-01.up.railway.app';
  static const String pineconeIndex = 'ai-assistant';
  
  // Model Configuration
  static const String modelName = 'gpt-3.5-turbo';
  static const int maxTokens = 500;
  static const double temperature = 0.7;
   
  // RAG Configuration
  static const int maxResults = 5;
  static const double similarityThreshold = 0.7;
}