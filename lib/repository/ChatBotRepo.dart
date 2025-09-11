// ignore_for_file: file_names

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:savings/constants/API_key.dart';
import 'package:savings/repository/textGenModel.dart';

class GigaChatRepo {
  static textGenRepo(BuildContext context, List<TextGenModel> chats) async {
    try {
      // Step 1: Add financial-only system prompt at beginning
      chats.insert(
        0,
        TextGenModel(
          role: "user",
          parts: [
            TextPartModel(
              text:
                  "You are a financial assistant. Only reply to queries related to saving money, budgeting, or financial management. Keep your answers short and focused.",
            ),
          ],
        ),
      );

      // Step 2: Make the POST request
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyCZOrtazGRxU1nuSh6mqTxEgPTW6v0Y9NE',
        ),
        body: json.encode(
          {
            "contents": chats.map((e) => e.toMap()).toList(),
            "generationConfig": {
              "temperature": 0.7, // Balanced creativity
              "topK": 0,
              "topP": 0.95,
              "maxOutputTokens": 150, // Limit response length
              "stopSequences": []
            },
            "safetySettings": [
              {
                "category": "HARM_CATEGORY_HARASSMENT",
                "threshold": "BLOCK_MEDIUM_AND_ABOVE"
              },
              {
                "category": "HARM_CATEGORY_HATE_SPEECH",
                "threshold": "BLOCK_MEDIUM_AND_ABOVE"
              },
              {
                "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
                "threshold": "BLOCK_MEDIUM_AND_ABOVE"
              },
              {
                "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
                "threshold": "BLOCK_MEDIUM_AND_ABOVE"
              }
            ]
          },
        ),
      );

      // Step 3: Handle success response
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final candidates = responseBody['candidates'] as List<dynamic>;
        for (final candidate in candidates) {
          final chat = TextGenModel.fromMap(candidate);
          chats.add(chat);
        }
      } else {
        print("Error Code: ${response.statusCode}");
      }
    } catch (e) {
      log(e.toString());
      print("Error in catch block");
    }
  }
}
