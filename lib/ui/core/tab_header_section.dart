import 'package:flutter/material.dart';

class TabHeaderSection extends StatelessWidget {
  const TabHeaderSection({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                height: 22.5 / 18,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.45,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
