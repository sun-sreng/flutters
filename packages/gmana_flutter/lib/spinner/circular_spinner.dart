import 'package:flutter/material.dart';

class CircularSpinner extends StatelessWidget {
  const CircularSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 10.0),
      child: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.purple),
      ),
    );
  }
}
