import 'package:flutter/material.dart';

class WorkroomScreen extends StatelessWidget {
  const WorkroomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '작업실',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}
