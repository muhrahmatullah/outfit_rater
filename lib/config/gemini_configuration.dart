import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:outfit_rater/util/constant.dart';
import 'package:outfit_rater/model/rating.dart';

class GeminiConfiguration {
  static GeminiConfiguration? _instance;
  late final GenerativeModel _generativeModel;

  GeminiConfiguration._privateConstructor() {
    _generativeModel = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: Constant.API_KEY,
      generationConfig: GenerationConfig(
        temperature: 0.8,
        topK: 32,
        topP: 1,
        maxOutputTokens: 4096,
      ),
    );
  }

  static GeminiConfiguration get instance {
    _instance ??= GeminiConfiguration._privateConstructor();
    return _instance!;
  }

  String get mainPrompt {
    return '''
You are  world-renowned fashion designer with an uncanny ability to intuit a person's essence from their clothes. People travel from across the globe to have you analyze their outfit and provide insights into their personality, motivations, and even hidden potential.
you're sole job to only focus on the outfit. make sure that you only rate human outfits, not animals or objects.

Last, you should rate the outfit from 1 to 10 and give the following thing as part of the result:
- name: the name that describes the outfit
- short descriptions, only one sentence
- personality: personality based on the outfit, only 4-5 words
- motivations, only one sentence
- hidden potential, only one sentence
- score: based on all the points above, calculate the final score ( 1/10)

return the result in Json using the following structure, make sure that the description, personality, motivation and hidden potential is short
    ''';
  }

  final String format = '''
  {
  "name": \$name,
  "description": \$description,
  "personality": \$personality,
  "motivations": \$motivation,
  "hidden_potential": \$hidden_potential,
  "score": \$score
}

all fields except score should be String, score is type of int
make sure to only return json without additional text
  ''';

  Future<Rating> generateRating(XFile image) async {
    final imagePart = DataPart('image/jpeg', await image.readAsBytes());
    final input = [
      Content.multi([imagePart, TextPart(mainPrompt), TextPart(format)])
    ];
    final response = await _generativeModel.generateContent(input);
    final result = response.text;
    try {
      final Map<String, dynamic> json = jsonDecode(result ?? '');
      final rating = Rating.fromJson(json);
      return rating;
    } catch (e) {
      return Rating(
        name: 'Unknown',
        description: result ?? '',
        personality: 'Unknown',
        motivations: 'Unknown',
        hiddenPotential: 'Unknown',
        score: 0,
      );
    }
  }
}
