import 'package:flutter/material.dart';

Widget buildButtonTile(IconData icon, String title, VoidCallback onTap) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 6),
    child: Material(
      color: Colors.grey[850],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        splashColor: Colors.white24,
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
        ),
      ),
    ),
  );
}
