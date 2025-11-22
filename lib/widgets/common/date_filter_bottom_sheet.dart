import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/connstants.dart';
import '../../l10n/app_localizations.dart';

enum DateFilterType { day, week, month, year, custom }

class DateFilterBottomSheet extends StatefulWidget {
  final DateFilterType initialFilterType;
  final DateTime? initialDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(
    DateFilterType filterType,
    DateTime? selectedDate,
    DateTime? startDate,
    DateTime? endDate,
  )
  onApply;

  const DateFilterBottomSheet({
    super.key,
    this.initialFilterType = DateFilterType.day,
    this.initialDate,
    this.startDate,
    this.endDate,
    required this.onApply,
  });

  @override
  State<DateFilterBottomSheet> createState() => _DateFilterBottomSheetState();
}

class _DateFilterBottomSheetState extends State<DateFilterBottomSheet> {
  late DateFilterType _selectedFilterType;
  late DateTime _currentDate;
  DateTime? _selectedDate;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _selectedFilterType = widget.initialFilterType;
    _currentDate = widget.initialDate ?? DateTime.now();
    _selectedDate = widget.initialDate;
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.filterBy,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Color(0xFF111827)),
                ),
              ],
            ),
          ),

          // Filter type tabs
          _buildFilterTabs(l10n),

          SizedBox(height: 20.h),

          // Content based on selected filter type
          _buildContent(l10n),

          SizedBox(height: 20.h),

          // Apply button
          Padding(
            padding: EdgeInsets.all(20.w),
            child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _applyFilter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.apply,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterTab(l10n.day, DateFilterType.day),
            SizedBox(width: 8.w),
            _buildFilterTab(l10n.week, DateFilterType.week),
            SizedBox(width: 8.w),
            _buildFilterTab(l10n.month, DateFilterType.month),
            SizedBox(width: 8.w),
            _buildFilterTab(l10n.year, DateFilterType.year),
            SizedBox(width: 8.w),
            _buildFilterTab(l10n.custom, DateFilterType.custom),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, DateFilterType type) {
    final isSelected = _selectedFilterType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20.r),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    switch (_selectedFilterType) {
      case DateFilterType.day:
        return _buildDaySelector(l10n);
      case DateFilterType.week:
        return _buildWeekSelector(l10n);
      case DateFilterType.month:
        return _buildMonthSelector(l10n);
      case DateFilterType.year:
        return _buildYearSelector(l10n);
      case DateFilterType.custom:
        return _buildCustomSelector(l10n);
    }
  }

  Widget _buildDaySelector(AppLocalizations l10n) {
    return Column(
      children: [
        // Month/Year navigation
        _buildMonthNavigation(),
        SizedBox(height: 16.h),
        // Calendar grid
        _buildCalendarGrid(),
      ],
    );
  }

  Widget _buildWeekSelector(AppLocalizations l10n) {
    return Column(
      children: [
        // Month/Year navigation
        _buildMonthNavigation(),
        SizedBox(height: 16.h),
        // Calendar grid with week selection
        _buildCalendarGrid(isWeekSelection: true),
      ],
    );
  }

  Widget _buildMonthSelector(AppLocalizations l10n) {
    return Column(
      children: [
        // Year navigation
        _buildYearNavigation(),
        SizedBox(height: 16.h),
        // Month grid
        _buildMonthGrid(),
      ],
    );
  }

  Widget _buildYearSelector(AppLocalizations l10n) {
    return Column(
      children: [
        // Year navigation
        _buildYearNavigation(),
        SizedBox(height: 16.h),
        // Year grid
        _buildYearGrid(),
      ],
    );
  }

  Widget _buildCustomSelector(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          // Date range inputs
          Row(
            children: [
              Expanded(
                child: _buildDateInput(
                  l10n.selectStartDate,
                  _startDate,
                  (date) => setState(() => _startDate = date),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildDateInput(
                  l10n.selectEndDate,
                  _endDate,
                  (date) => setState(() => _endDate = date),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Calendar for date selection
          _buildMonthNavigation(),
          SizedBox(height: 16.h),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _currentDate = DateTime(
                  _currentDate.year,
                  _currentDate.month - 1,
                );
              });
            },
            icon: const Icon(Icons.chevron_left, color: Color(0xFF111827)),
          ),
          Text(
            '${_getMonthName(_currentDate.month)} ${_currentDate.year}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          IconButton(
            onPressed: () {
              final nextDate = DateTime(
                _currentDate.year,
                _currentDate.month + 1,
              );
              if (nextDate.isBefore(
                DateTime.now().add(const Duration(days: 1)),
              )) {
                setState(() {
                  _currentDate = nextDate;
                });
              }
            },
            icon: const Icon(Icons.chevron_right, color: Color(0xFF111827)),
          ),
        ],
      ),
    );
  }

  Widget _buildYearNavigation() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _currentDate = DateTime(_currentDate.year - 1);
              });
            },
            icon: const Icon(Icons.chevron_left, color: Color(0xFF111827)),
          ),
          Text(
            '${_currentDate.year}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _currentDate = DateTime(_currentDate.year + 1);
              });
            },
            icon: const Icon(Icons.chevron_right, color: Color(0xFF111827)),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid({bool isWeekSelection = false}) {
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDayOfMonth = DateTime(
      _currentDate.year,
      _currentDate.month + 1,
      0,
    );
    final firstDayOfWeek = firstDayOfMonth.weekday;
    final firstWeekdayIndex = firstDayOfWeek % 7;

    List<Widget> dayWidgets = [];

    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstWeekdayIndex; i++) {
      dayWidgets.add(Container());
    }

    // Add days of the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_currentDate.year, _currentDate.month, day);
      final isSelected = _isDateSelected(date);
      final now = DateTime.now();
      final isFutureDate = date.isAfter(now);
      final isDisabled = isFutureDate;

      dayWidgets.add(
        GestureDetector(
          onTap: isDisabled ? null : () => _selectDate(date, isWeekSelection),
          child: Container(
            width: 40.w,
            height: 40.h,
            margin: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : isDisabled
                      ? Colors.grey.shade300
                      : const Color(0xFF111827),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          // Days of week header
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 8.h),
          // Calendar grid
          Wrap(children: dayWidgets),
        ],
      ),
    );
  }

  Widget _buildMonthGrid() {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final month = index + 1;
          final isSelected =
              _selectedDate?.month == month &&
              _selectedDate?.year == _currentDate.year;
          final isCurrentYear = _currentDate.year == now.year;
          final isFutureMonth = isCurrentYear && month > now.month;
          final isDisabled = isFutureMonth;

          return GestureDetector(
            onTap: isDisabled
                ? null
                : () {
                    setState(() {
                      _selectedDate = DateTime(_currentDate.year, month);
                    });
                  },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor
                    : isDisabled
                    ? Colors.grey.shade100
                    : Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: Text(
                  months[index],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : isDisabled
                        ? Colors.grey.shade300
                        : const Color(0xFF111827),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildYearGrid() {
    final currentYear = _currentDate.year;
    final years = List.generate(12, (index) => currentYear - 5 + index);
    final now = DateTime.now();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final year = years[index];
          final isSelected = _selectedDate?.year == year;
          final isFutureYear = year > now.year;
          final isDisabled = isFutureYear;

          return GestureDetector(
            onTap: isDisabled
                ? null
                : () {
                    setState(() {
                      _selectedDate = DateTime(year);
                    });
                  },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor
                    : isDisabled
                    ? Colors.grey.shade100
                    : Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: Text(
                  '$year',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : isDisabled
                        ? Colors.grey.shade300
                        : const Color(0xFF111827),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateInput(
    String label,
    DateTime? date,
    Function(DateTime?) onChanged,
  ) {
    return GestureDetector(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (selectedDate != null) {
          onChanged(selectedDate);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryColor),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          date != null ? '${date.day}/${date.month}/${date.year}' : label,
          style: TextStyle(
            fontSize: 14.sp,
            color: date != null
                ? const Color(0xFF111827)
                : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  void _selectDate(DateTime date, bool isWeekSelection) {
    setState(() {
      if (isWeekSelection) {
        // For week selection, select the entire week
        final weekdayIndex = date.weekday % 7;
        final startOfWeek = date.subtract(Duration(days: weekdayIndex));
        _startDate = startOfWeek;
        _endDate = startOfWeek.add(const Duration(days: 6));
        _selectedDate = date;
      } else {
        _selectedDate = date;
        _startDate = null;
        _endDate = null;
      }
    });
  }

  bool _isDateSelected(DateTime date) {
    if (_selectedDate != null &&
        _selectedDate!.day == date.day &&
        _selectedDate!.month == date.month &&
        _selectedDate!.year == date.year) {
      return true;
    }

    if (_startDate != null && _endDate != null) {
      return date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
          date.isBefore(_endDate!.add(const Duration(days: 1)));
    }

    return false;
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  void _applyFilter() {
    // Set appropriate dates based on filter type
    DateTime? finalDate;
    DateTime? finalStartDate;
    DateTime? finalEndDate;

    if (_selectedFilterType == DateFilterType.day && _selectedDate != null) {
      finalDate = _selectedDate;
      finalStartDate = null;
      finalEndDate = null;
    } else if (_selectedFilterType == DateFilterType.week &&
        _startDate != null &&
        _endDate != null) {
      finalDate = null;
      finalStartDate = _startDate;
      finalEndDate = _endDate;
    } else if (_selectedFilterType == DateFilterType.month &&
        _selectedDate != null) {
      // Use first and last day of selected month
      final firstDay = DateTime(_selectedDate!.year, _selectedDate!.month, 1);
      final lastDay = DateTime(
        _selectedDate!.year,
        _selectedDate!.month + 1,
        0,
      );
      finalDate = null;
      finalStartDate = firstDay;
      finalEndDate = lastDay;
    } else if (_selectedFilterType == DateFilterType.year &&
        _selectedDate != null) {
      // Use first and last day of selected year
      final firstDay = DateTime(_selectedDate!.year, 1, 1);
      final lastDay = DateTime(_selectedDate!.year, 12, 31);
      finalDate = null;
      finalStartDate = firstDay;
      finalEndDate = lastDay;
    } else if (_selectedFilterType == DateFilterType.custom) {
      finalDate = null;
      finalStartDate = _startDate;
      finalEndDate = _endDate;
    }

    widget.onApply(
      _selectedFilterType,
      finalDate,
      finalStartDate,
      finalEndDate,
    );
    Navigator.pop(context);
  }
}

// Helper function to show the date filter bottom sheet
void showDateFilterBottomSheet({
  required BuildContext context,
  DateFilterType initialFilterType = DateFilterType.day,
  DateTime? initialDate,
  DateTime? startDate,
  DateTime? endDate,
  required Function(
    DateFilterType filterType,
    DateTime? selectedDate,
    DateTime? startDate,
    DateTime? endDate,
  )
  onApply,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DateFilterBottomSheet(
      initialFilterType: initialFilterType,
      initialDate: initialDate,
      startDate: startDate,
      endDate: endDate,
      onApply: onApply,
    ),
  );
}
