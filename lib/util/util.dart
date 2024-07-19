import 'package:flutter/material.dart';

mixin Utility {
  static void showNoObjectFoundSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 6),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void dismissDialog(BuildContext context) {
    Navigator.pop(context);
  }

  static void showLoadingDialog(BuildContext context, {String message = "Loading..."}) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing the dialog by tapping outside of it
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Makes the dialog to fit its content
              children: [
                const CircularProgressIndicator(), // Loading spinner
                const SizedBox(height: 15), // Adds space between spinner and text
                Text(message), // Displays the loading message
              ],
            ),
          ),
        );
      },
    );
  }
}