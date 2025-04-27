import 'dart:ui';

import 'package:flutter/material.dart';

class HolidaysScreen extends StatelessWidget {
  const HolidaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Holiday> holidays = [
      Holiday('JAN', '1', 'New Year\'s Day', 'Wednesday', Colors.blue),
      Holiday('JAN', '14', 'Makar Sankranti / Pongal', 'Tuesday', Colors.blue),
      Holiday('JAN', '26', 'Republic Day', 'Sunday', Colors.blue),
      Holiday('MAY', '1', 'Labour Day', 'Thursday', Colors.purple),
      Holiday('AUG', '15', 'Independence Day', 'Friday', Colors.orange),
      Holiday('AUG', '27', 'Vinayaka Chaturthi', 'Wednesday', Colors.orange),
      Holiday('OCT', '2', 'Mahatma Gandhi Jayanti / Dussehra / Dasara', 'Thursday', Colors.purple),
      Holiday('OCT', '', 'Diwali / Deepavali', '', Colors.purple),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Holidays in 2025'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1C1C1E),
      ),
      backgroundColor: const Color(0xFF1C1C1E),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: holidays.length,
        separatorBuilder: (context, index) => const Divider(color: Colors.grey),
        itemBuilder: (context, index) {
          final holiday = holidays[index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: holiday.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Column(
                  children: [
                    Text(
                      holiday.month,
                      style: TextStyle(
                        color: holiday.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      holiday.date,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      holiday.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (holiday.day.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          holiday.day,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class Holiday {
  final String month;
  final String date;
  final String name;
  final String day;
  final Color color;

  Holiday(this.month, this.date, this.name, this.day, this.color);
}
