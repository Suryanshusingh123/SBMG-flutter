import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable dropdown field that shows a loading indicator and is disabled while data is being fetched
class LoadingDropdownField<T> extends StatelessWidget {
  final String label;
  final String? value;
  final String placeholder;
  final List<T> items;
  final String Function(T) itemBuilder;
  final ValueChanged<T?> onChanged;
  final bool isLoading;
  final String? Function(T?)? validator;
  final bool enabled;

  const LoadingDropdownField({
    super.key,
    required this.label,
    this.value,
    required this.placeholder,
    required this.items,
    required this.itemBuilder,
    required this.onChanged,
    this.isLoading = false,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<T>(
          value: value as T?,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14.sp,
            ),
            filled: true,
            fillColor: isLoading || !enabled
                ? Colors.grey.shade100
                : Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF009B56)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
            suffixIcon: isLoading
                ? Padding(
                    padding: EdgeInsets.all(12.w),
                    child: SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF009B56),
                        ),
                      ),
                    ),
                  )
                : const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF6B7280),
                    size: 20,
                  ),
          ),
          items: isLoading
              ? null
              : items.map((T item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      itemBuilder(item),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  );
                }).toList(),
          onChanged: (isLoading || !enabled) ? null : onChanged,
          validator: validator,
        ),
      ],
    );
  }
}

