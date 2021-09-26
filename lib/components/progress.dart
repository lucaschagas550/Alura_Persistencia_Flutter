import 'package:flutter/material.dart';

class Progress extends StatelessWidget {
  final String message;

  Progress({this.message = 'Loading'});

  @override
  Widget build(BuildContext context) {
    return Center(
      // loading no centro da tela
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Text(message),
        ],
      ),
    );
  }
}
