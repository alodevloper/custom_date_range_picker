import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' as intl;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    initializeDateFormatting('en', null),
    initializeDateFormatting('ar', null),
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isArabic = true;
  bool isDarkMode = false;

  void toggleLanguage() {
    setState(() {
      isArabic = !isArabic;
    });
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Date Range Picker Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: MyHomePage(
        isArabic: isArabic,
        isDarkMode: isDarkMode,
        onLanguageToggle: toggleLanguage,
        onThemeToggle: toggleTheme,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final bool isArabic;
  final bool isDarkMode;
  final VoidCallback onLanguageToggle;
  final VoidCallback onThemeToggle;

  const MyHomePage({
    super.key,
    required this.isArabic,
    required this.isDarkMode,
    required this.onLanguageToggle,
    required this.onThemeToggle,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = widget.isArabic ? 'ar' : 'en';

    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isArabic ? 'منتقي نطاق التاريخ' : 'Date Range Picker'),
          actions: [
            IconButton(
              icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: widget.onThemeToggle,
            ),
            TextButton(
              onPressed: widget.onLanguageToggle,
              child: Text(
                widget.isArabic ? 'EN' : 'AR',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                widget.isArabic ? 'اختر نطاق التاريخ' : 'Choose a date Range',
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
              ),
              const SizedBox(height: 20),
              Text(
                '${startDate != null ? intl.DateFormat("dd, MMM", locale).format(startDate!) : '-'} / ${endDate != null ? intl.DateFormat("dd, MMM", locale).format(endDate!) : '-'}',
                style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showCustomDateRangePicker(
              context,
              dismissible: true,
              minimumDate: DateTime.now().subtract(const Duration(days: 30)),
              maximumDate: DateTime.now().add(const Duration(days: 30)),
              endDate: endDate,
              startDate: startDate,
              locale: locale,
              backgroundColor: widget.isDarkMode ? const Color(0xFF1A1C1E) : Colors.white,
              primaryColor: Colors.green,
              onApplyClick: (start, end) {
                setState(() {
                  endDate = end;
                  startDate = start;
                });
              },
              onCancelClick: () {
                setState(() {
                  endDate = null;
                  startDate = null;
                });
              },
            );
          },
          tooltip: 'choose date Range',
          child: const Icon(Icons.calendar_today_outlined),
        ),
      ),
    );
  }
}
