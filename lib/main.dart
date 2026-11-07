import 'package:flutter/material.dart';

import 'screens/room_list_screen.dart';

void main() => runApp(const RoomControlApp());

class const RoomControlApp({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room Control',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const RoomListScreen(),
    );
  }
}
