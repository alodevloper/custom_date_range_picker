import 'custom_calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDateRangePicker extends StatefulWidget {
  final DateTime minimumDate;
  final DateTime maximumDate;
  final bool barrierDismissible;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Color primaryColor;
  final Color backgroundColor;
  final Function(DateTime, DateTime) onApplyClick;
  final Function() onCancelClick;

  /// Added locale field
  final String locale;

  const CustomDateRangePicker({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    required this.primaryColor,
    required this.backgroundColor,
    required this.onApplyClick,
    this.barrierDismissible = true,
    required this.minimumDate,
    required this.maximumDate,
    required this.onCancelClick,
    this.locale = 'en', // default to English
  });

  @override
  CustomDateRangePickerState createState() => CustomDateRangePickerState();
}

class CustomDateRangePickerState extends State<CustomDateRangePicker>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  DateTime? startDate;
  DateTime? endDate;

  bool get isArabic => widget.locale.startsWith('ar');

  @override
  void initState() {
    animationController =
        AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
    animationController?.forward();
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    final format = DateFormat('EEE, dd MMM', widget.locale);
    return format.format(date);
  }

  @override
  Widget build(BuildContext context) {
    // Localized labels
    final fromLabel = isArabic ? 'من' : 'From';
    final toLabel = isArabic ? 'إلى' : 'To';
    final applyLabel = isArabic ? 'تطبيق' : 'Apply';
    final cancelLabel = isArabic ? 'إلغاء' : 'Cancel';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Center(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onTap: () {
              if (widget.barrierDismissible) {
                Navigator.pop(context);
              }
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.2),
                        offset: const Offset(4, 4),
                        blurRadius: 8.0,
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                    onTap: () {},
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    fromLabel,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    startDate != null
                                        ? formatDate(startDate!)
                                        : '--/-- ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 74,
                              width: 1,
                              color: Theme.of(context).dividerColor,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    toLabel,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    endDate != null
                                        ? formatDate(endDate!)
                                        : '--/-- ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const Divider(height: 1),
                        CustomCalendar(
                          minimumDate: widget.minimumDate,
                          maximumDate: widget.maximumDate,
                          initialEndDate: widget.initialEndDate,
                          initialStartDate: widget.initialStartDate,
                          primaryColor: widget.primaryColor,
                          startEndDateChange:
                              (DateTime startDateData, DateTime endDateData) {
                            setState(() {
                              startDate = startDateData;
                              endDate = endDateData;
                            });
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 16, top: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(24.0)),
                                  ),
                                  child: OutlinedButton(
                                    style: ButtonStyle(
                                      side: WidgetStateProperty.all(
                                          BorderSide(color: widget.primaryColor)),
                                      shape: WidgetStateProperty.all(
                                        const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(24.0)),
                                        ),
                                      ),
                                      backgroundColor: WidgetStateProperty.all(
                                          widget.primaryColor),
                                    ),
                                    onPressed: () {
                                      widget.onCancelClick();
                                      Navigator.pop(context);
                                    },
                                    child: Center(
                                      child: Text(
                                        cancelLabel,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(24.0)),
                                  ),
                                  child: OutlinedButton(
                                    style: ButtonStyle(
                                      side: WidgetStateProperty.all(
                                          BorderSide(color: widget.primaryColor)),
                                      shape: WidgetStateProperty.all(
                                        const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(24.0)),
                                        ),
                                      ),
                                      backgroundColor: WidgetStateProperty.all(
                                          widget.primaryColor),
                                    ),
                                    onPressed: () {
                                      if (startDate != null && endDate != null) {
                                        widget.onApplyClick(startDate!, endDate!);
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: Center(
                                      child: Text(
                                        applyLabel,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Function to show picker dialog
void showCustomDateRangePicker(
  BuildContext context, {
  required bool dismissible,
  required DateTime minimumDate,
  required DateTime maximumDate,
  DateTime? startDate,
  DateTime? endDate,
  required Function(DateTime startDate, DateTime endDate) onApplyClick,
  required Function() onCancelClick,
  required Color backgroundColor,
  required Color primaryColor,
  String? fontFamily,
  String locale = 'en',
}) {
  FocusScope.of(context).requestFocus(FocusNode());

  showDialog<dynamic>(
    context: context,
    builder: (BuildContext context) => CustomDateRangePicker(
      barrierDismissible: dismissible,
      backgroundColor: backgroundColor,
      primaryColor: primaryColor,
      minimumDate: minimumDate,
      maximumDate: maximumDate,
      initialStartDate: startDate,
      initialEndDate: endDate,
      onApplyClick: onApplyClick,
      onCancelClick: onCancelClick,
      locale: locale,
    ),
  );
}
