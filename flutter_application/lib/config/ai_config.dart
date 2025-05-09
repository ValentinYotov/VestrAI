class AIConfig {
  // OpenAI Configuration
  static const String openAiApiKey = 'YOUR_OPENAI_API_KEY';
  static const String openAiEndpoint = 'https://api.openai.com/v1/chat/completions';
  
  // Vector Database Configuration (Pinecone example)
  static const String pineconeApiKey = 'YOUR_PINECONE_API_KEY';
  static const String pineconeEndpoint = 'YOUR_PINECONE_ENDPOINT';
  static const String pineconeIndex = 'YOUR_PINECONE_INDEX';
  
  // Model Configuration
  static const String modelName = 'gpt-3.5-turbo';
  static const int maxTokens = 500;
  static const double temperature = 0.7;
  
  // RAG Configuration
  static const int maxResults = 5;
  static const double similarityThreshold = 0.7;
} 