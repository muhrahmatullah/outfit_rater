import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:outfit_rater/config/gemini_configuration.dart';
import 'package:outfit_rater/model/rating.dart';
import 'package:outfit_rater/util/util.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  Rating? _rating;

  void _showOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select an Option'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a Picture'),
                  onTap: () {
                    pickImageFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.browse_gallery),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    pickImageFromGallery();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit rater'),
      ),
      body: _image != null && _rating != null
          ? _buildBody(_rating!)
          : const Center(
              child: Text('Let\'s rate your outfit today!'),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showOptionsDialog,
        tooltip: 'Options',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(Rating rating) {
    // Define a Color palette for better visual harmony
    Color primaryTextColor = Colors.indigo.shade600;
    Color secondaryTextColor = Colors.indigo.shade400;
    Color accentColor = Colors.amber.shade600;

    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Improved Image presentation
            _image != null
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                    child: Container(
                      height: 600, // Adjusted for a better aspect ratio
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.file(
                          File(_image!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                : Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: const Icon(Icons.photo, size: 100, color: Colors.grey),
                ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Outfit Name: ${rating.name}',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryTextColor),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Short Description: ${rating.description}',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 16, color: secondaryTextColor),
                      ),
                      const SizedBox(height: 8,),
                      Text(
                        'Motivations: ${rating.motivations}',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 16, color: secondaryTextColor),
                      ),
                      const SizedBox(height: 8,),
                      Text(
                        'Hidden Potential: ${rating.hiddenPotential}',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 16, color: secondaryTextColor),
                      ),
                      const SizedBox(height: 8,),
                      Text(
                        'Personality: ${rating.personality}',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 16, color: secondaryTextColor),
                      ),
                      const SizedBox(height: 8,),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Score: ${rating.score} / 10',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: accentColor),
              ),
            ),
            const SizedBox(height: 8,),
          ],
        ),
      ),
    );
  }

  void renderData(
    XFile image,
    Rating rating,
  ) {
    setState(() {
      _image = image;
      _rating = rating;
    });
  }

  Future<void> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await generateRating(image);
    }
  }

  Future<void> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await generateRating(image);
    }
  }

  Future<void> generateRating(XFile image) async {
    Utility.showLoadingDialog(context);
    final response = await GeminiConfiguration.instance.generateRating(image);
    if (response.name != 'Unknown') {
      renderData(image, response);
    } else {
      Utility.showNoObjectFoundSnackBar(context, response.description);
    }
    Utility.dismissDialog(context);
  }


}
