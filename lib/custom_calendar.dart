import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class CustomCalendar extends StatefulWidget {
  final DateTime? minimumDate;
  final DateTime? maximumDate;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Color primaryColor;
  final Function(DateTime, DateTime)? startEndDateChange;

  /// Added locale field
  final String locale;

  const CustomCalendar({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    this.startEndDateChange,
    this.minimumDate,
    this.maximumDate,
    required this.primaryColor,
    this.locale = 'en', // default English
  });

  @override
  CustomCalendarState createState() => CustomCalendarState();
}

class CustomCalendarState extends State<CustomCalendar> {
  List<DateTime> dateList = <DateTime>[];
  DateTime currentMonthDate = DateTime.now();
  DateTime? startDate;
  DateTime? endDate;

  bool get isArabic => widget.locale.startsWith('ar');

  @override
  void initState() {
    setListOfDate(currentMonthDate);
    if (widget.initialStartDate != null) startDate = widget.initialStartDate;
    if (widget.initialEndDate != null) endDate = widget.initialEndDate;
    super.initState();
  }

  void setListOfDate(DateTime monthDate) {
    dateList.clear();
    final DateTime newDate = DateTime(monthDate.year, monthDate.month, 0);
    int previousMonthDay = 0;
    if (newDate.weekday < 7) {
      previousMonthDay = newDate.weekday;
      for (int i = 1; i <= previousMonthDay; i++) {
        dateList.add(newDate.subtract(Duration(days: previousMonthDay - i)));
      }
    }
    for (int i = 0; i < (42 - previousMonthDay); i++) {
      dateList.add(newDate.add(Duration(days: i + 1)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _arrowButton(
                    isArabic
                        ? Icons.keyboard_arrow_right
                        : Icons.keyboard_arrow_left,
                    onTap: () {
                      setState(() {
                        currentMonthDate = DateTime(
                            currentMonthDate.year, currentMonthDate.month, 0);
                        setListOfDate(currentMonthDate);
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      intl.DateFormat('MMMM, yyyy', widget.locale)
                          .format(currentMonthDate),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _arrowButton(
                    isArabic
                        ? Icons.keyboard_arrow_left
                        : Icons.keyboard_arrow_right,
                    onTap: () {
                      setState(() {
                        currentMonthDate = DateTime(currentMonthDate.year,
                            currentMonthDate.month + 2, 0);
                        setListOfDate(currentMonthDate);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(children: getDaysNameUI()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(children: getDaysNoUI()),
          ),
        ],
      ),
    );
  }

  Widget _arrowButton(IconData icon, {required VoidCallback onTap}) {
    return Container(
      height: 38,
      width: 38,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(24.0)),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(24.0)),
          onTap: onTap,
          child: Icon(icon, color: Colors.grey),
        ),
      ),
    );
  }

  List<Widget> getDaysNameUI() {
    final List<Widget> listUI = <Widget>[];
    for (int i = 0; i < 7; i++) {
      listUI.add(
        Expanded(
          child: Center(
            child: Text(
              intl.DateFormat('EEE', widget.locale).format(dateList[i]),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: widget.primaryColor,
              ),
            ),
          ),
        ),
      );
    }
    return listUI;
  }

  List<Widget> getDaysNoUI() {
    final List<Widget> noList = <Widget>[];
    int count = 0;
    for (int i = 0; i < dateList.length / 7; i++) {
      final List<Widget> listUI = <Widget>[];
      for (int j = 0; j < 7; j++) {
        final DateTime date = dateList[count];
        listUI.add(
          Expanded(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                children: <Widget>[
                  _buildDateBackground(date),
                  _buildDateButton(date),
                  _buildTodayIndicator(date),
                ],
              ),
            ),
          ),
        );
        count += 1;
      }
      noList.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: listUI,
      ));
    }
    return noList;
  }

  Widget _buildDateBackground(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Container(
        decoration: BoxDecoration(
          color: startDate != null && endDate != null
              ? (getIsItStartAndEndDate(date) || getIsInRange(date))
                  ? widget.primaryColor.withValues(alpha: 0.4)
                  : Colors.transparent
              : Colors.transparent,
          borderRadius: BorderRadius.only(
            bottomLeft: isStartDateRadius(date)
                ? const Radius.circular(24.0)
                : Radius.zero,
            topLeft: isStartDateRadius(date)
                ? const Radius.circular(24.0)
                : Radius.zero,
            topRight: isEndDateRadius(date)
                ? const Radius.circular(24.0)
                : Radius.zero,
            bottomRight: isEndDateRadius(date)
                ? const Radius.circular(24.0)
                : Radius.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildDateButton(DateTime date) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(32.0)),
        onTap: () => _handleDateTap(date),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              color: getIsItStartAndEndDate(date)
                  ? widget.primaryColor
                  : Colors.transparent,
              borderRadius: const BorderRadius.all(Radius.circular(32.0)),
              border: Border.all(
                color: getIsItStartAndEndDate(date)
                    ? Colors.white
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: getIsItStartAndEndDate(date)
                  ? [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.6),
                        blurRadius: 4,
                        offset: const Offset(0, 0),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: getIsItStartAndEndDate(date)
                      ? Colors.white
                      : currentMonthDate.month == date.month
                          ? widget.primaryColor
                          : Colors.grey.withValues(alpha: 0.6),
                  fontSize: MediaQuery.of(context).size.width > 360 ? 18 : 16,
                  fontWeight: getIsItStartAndEndDate(date)
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayIndicator(DateTime date) {
    return Positioned(
      bottom: 9,
      right: 0,
      left: 0,
      child: Container(
        height: 6,
        width: 6,
        decoration: BoxDecoration(
          color: DateTime.now().day == date.day &&
                  DateTime.now().month == date.month &&
                  DateTime.now().year == date.year
              ? getIsInRange(date)
                  ? Colors.white
                  : widget.primaryColor
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  void _handleDateTap(DateTime date) {
    if (currentMonthDate.month == date.month) {
      if (_isWithinRange(date)) onDateClick(date);
    }
  }

  bool _isWithinRange(DateTime date) {
    if (widget.minimumDate != null && widget.maximumDate != null) {
      final minDate = widget.minimumDate!.subtract(const Duration(days: 1));
      final maxDate = widget.maximumDate!.add(const Duration(days: 1));
      return date.isAfter(minDate) && date.isBefore(maxDate);
    } else if (widget.minimumDate != null) {
      return date
          .isAfter(widget.minimumDate!.subtract(const Duration(days: 1)));
    } else if (widget.maximumDate != null) {
      return date.isBefore(widget.maximumDate!.add(const Duration(days: 1)));
    }
    return true;
  }

  bool getIsInRange(DateTime date) =>
      startDate != null &&
      endDate != null &&
      date.isAfter(startDate!) &&
      date.isBefore(endDate!);

  bool getIsItStartAndEndDate(DateTime date) =>
      (startDate != null && _isSameDate(date, startDate!)) ||
      (endDate != null && _isSameDate(date, endDate!));

  bool isStartDateRadius(DateTime date) =>
      (startDate != null && _isSameDate(date, startDate!)) || date.weekday == 1;

  bool isEndDateRadius(DateTime date) =>
      (endDate != null && _isSameDate(date, endDate!)) || date.weekday == 7;

  bool _isSameDate(DateTime a, DateTime b) =>
      a.day == b.day && a.month == b.month && a.year == b.year;

  void onDateClick(DateTime date) {
    if (startDate == null) {
      startDate = date;
    } else if (startDate != date && endDate == null) {
      endDate = date;
    } else if (_isSameDate(startDate!, date)) {
      startDate = null;
    } else if (endDate != null && _isSameDate(endDate!, date)) {
      endDate = null;
    }

    if (startDate == null && endDate != null) {
      startDate = endDate;
      endDate = null;
    }

    if (startDate != null && endDate != null && !endDate!.isAfter(startDate!)) {
      final temp = startDate!;
      startDate = endDate;
      endDate = temp;
    }

    setState(() {
      if (widget.startEndDateChange != null &&
          startDate != null &&
          endDate != null) {
        widget.startEndDateChange!(startDate!, endDate!);
      }
    });
  }
}
