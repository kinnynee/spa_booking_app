import 'package:flutter/material.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch hẹn của tôi'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Nội dung lịch hẹn sẽ hiển thị ở đây'),
      ),
    );
  }
}
