import 'package:archify/services/database/day/day_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DayCodePage extends StatefulWidget {
  final String dayId;

  const DayCodePage({super.key, required this.dayId});

  @override
  State<DayCodePage> createState() => _DayCodePageState();
}

class _DayCodePageState extends State<DayCodePage> {
  late final DayProvider _dayProvider;

  @override
  void initState() {
    super.initState();

    _dayProvider = Provider.of<DayProvider>(context, listen: false);

    _loadDay();
  }

  Future<void> _loadDay() async {
    await _dayProvider.loadDay(widget.dayId);
  }

  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<DayProvider>(context);
    final day = listeningProvider.day;

    return Consumer<DayProvider>(
      builder: (context, provider, child) => provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Scaffold(
              body: Center(
                child: Text(day == null ? 'Loading...' : day.code),
              ),
            ),
    );
  }
}
