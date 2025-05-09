import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RAGService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _vectorDbEndpoint;
  final Map<String, String> _headers;

  RAGService({
    required String vectorDbEndpoint,
    required String apiKey,
  }) : _vectorDbEndpoint = vectorDbEndpoint,
       _headers = {
         'Content-Type': 'application/json',
         'Authorization': 'Bearer $apiKey',
       };

  // Retrieve relevant information for a query
  Future<List<Map<String, dynamic>>> retrieveRelevantData({
    required String query,
    required int limit,
  }) async {
    try {
      // Convert query to vector
      final queryVector = await _vectorizeQuery(query);
      
      // Search vector database
      final response = await http.post(
        Uri.parse('$_vectorDbEndpoint/search'),
        headers: _headers,
        body: jsonEncode({
          'vector': queryVector,
          'limit': limit,
        }),
      );

      if (response.statusCode == 200) {
        final results = jsonDecode(response.body) as List;
        return await _enrichResults(results);
      } else {
        throw Exception('Failed to retrieve relevant data');
      }
    } catch (e) {
      print('Error in RAG service: $e');
      return [];
    }
  }

  // Update the knowledge base with new information
  Future<void> updateKnowledgeBase(Map<String, dynamic> newData) async {
    try {
      // Vectorize the new data
      final vector = await _vectorizeData(newData);
      
      // Store in vector database
      await http.post(
        Uri.parse('$_vectorDbEndpoint/store'),
        headers: _headers,
        body: jsonEncode({
          'vector': vector,
          'metadata': newData,
        }),
      );

      // Store metadata in Firestore
      await _firestore.collection('knowledge_base').add({
        'metadata': newData,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating knowledge base: $e');
    }
  }

  // Private helper methods
  Future<List<double>> _vectorizeQuery(String query) async {
    // Implement query vectorization
    // This could use a pre-trained model or API
    return [];
  }

  Future<List<double>> _vectorizeData(Map<String, dynamic> data) async {
    // Implement data vectorization
    // This could use a pre-trained model or API
    return [];
  }

  Future<List<Map<String, dynamic>>> _enrichResults(List results) async {
    // Enrich the results with additional context from Firestore
    final enrichedResults = <Map<String, dynamic>>[];
    
    for (var result in results) {
      final metadata = result['metadata'] as Map<String, dynamic>;
      final docId = metadata['docId'] as String;
      
      // Get additional context from Firestore
      final doc = await _firestore.collection('knowledge_base').doc(docId).get();
      if (doc.exists) {
        enrichedResults.add({
          ...result,
          'additionalContext': doc.data(),
        });
      }
    }
    
    return enrichedResults;
  }
} 