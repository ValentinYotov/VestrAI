import 'dart:convert';
import 'package:http/http.dart' as http;

class TransformerModel {
  final String _modelEndpoint;
  final Map<String, String> _headers;

  TransformerModel({
    required String modelEndpoint,
    required String apiKey,
  }) : _modelEndpoint = modelEndpoint,
       _headers = {
         'Content-Type': 'application/json',
         'Authorization': 'Bearer $apiKey',
       };

  // Generate recommendations using the transformer model
  Future<List<Map<String, dynamic>>> generateRecommendations({
    required Map<String, dynamic> context,
    required List<Map<String, dynamic>> relevantData,
    int maxTokens = 500,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_modelEndpoint),
        headers: _headers,
        body: jsonEncode({
          'prompt': _buildPrompt(context, relevantData),
          'max_tokens': maxTokens,
          'temperature': 0.7,
          'top_p': 0.9,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return _parseRecommendations(result);
      } else {
        throw Exception('Failed to generate recommendations');
      }
    } catch (e) {
      print('Error in transformer model: $e');
      return [];
    }
  }

  // Process and understand user input
  Future<Map<String, dynamic>> processUserInput(String input) async {
    try {
      final response = await http.post(
        Uri.parse('$_modelEndpoint/process'),
        headers: _headers,
        body: jsonEncode({
          'input': input,
          'max_tokens': 200,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to process user input');
      }
    } catch (e) {
      print('Error processing user input: $e');
      return {};
    }
  }

  // Private helper methods
  String _buildPrompt(Map<String, dynamic> context, List<Map<String, dynamic>> relevantData) {
    // Build a prompt that includes context and relevant data
    final prompt = '''
    Based on the following context and relevant data, provide personalized recommendations:
    
    User Context:
    ${jsonEncode(context)}
    
    Relevant Data:
    ${jsonEncode(relevantData)}
    
    Please provide recommendations that are:
    1. Personalized to the user's preferences
    2. Based on current trends and data
    3. Practical and actionable
    ''';

    return prompt;
  }

  List<Map<String, dynamic>> _parseRecommendations(Map<String, dynamic> result) {
    // Parse the model's response into structured recommendations
    try {
      final recommendations = result['choices'][0]['text'] as String;
      return jsonDecode(recommendations) as List<Map<String, dynamic>>;
    } catch (e) {
      print('Error parsing recommendations: $e');
      return [];
    }
  }
} 