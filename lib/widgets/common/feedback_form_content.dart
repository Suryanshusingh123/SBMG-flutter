import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/connstants.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_services.dart';

class FeedbackFormContent extends StatefulWidget {
  final Map<String, dynamic>? existingFeedback;
  final bool isPublicUser;
  final void Function(bool isUpdate) onSuccess;
  /// If provided, called before submit to check auth. When false, [onAuthRequired] is called.
  final bool Function()? checkAuth;
  final VoidCallback? onAuthRequired;

  const FeedbackFormContent({
    super.key,
    required this.existingFeedback,
    required this.isPublicUser,
    required this.onSuccess,
    this.checkAuth,
    this.onAuthRequired,
  });

  @override
  State<FeedbackFormContent> createState() => _FeedbackFormContentState();
}

class _FeedbackFormContentState extends State<FeedbackFormContent> {
  late TextEditingController _feedbackController;
  late int _selectedRating;
  final _isSubmitting = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    final existing = widget.existingFeedback;
    _feedbackController = TextEditingController(
      text: existing?['comment']?.toString() ?? '',
    );
    final apiRating = (existing?['rating'] ?? 1) as num;
    _selectedRating = (apiRating.toInt() - 1).clamp(0, 4);
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  bool get _hasExistingFeedback => widget.existingFeedback != null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.giveUsFeedback,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 24.sp),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Text(
              AppLocalizations.of(context)!.howWasYourExperience,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                final emojis = ['😢', '😞', '😐', '🙂', '😄'];
                final isSelected = _selectedRating == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRating = index),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: isSelected
                          ? const Color(0xFFD1FAE5)
                          : Colors.transparent,
                    ),
                    child: Text(
                      emojis[index],
                      style: TextStyle(fontSize: 32.sp),
                    ),
                  ),
                );
              }),
            ),
            if (_selectedRating == -1)
              Text(
                AppLocalizations.of(context)!.chooseYourExperience,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            SizedBox(height: 24.h),
            Text(
              AppLocalizations.of(context)!.enterFeedback,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: TextField(
                controller: _feedbackController,
                maxLines: 4,
                maxLength: 100,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.enterFeedback,
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12.w),
                  counterText: '${_feedbackController.text.length}/100',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            SizedBox(height: 24.h),
            ValueListenableBuilder<bool>(
              valueListenable: _isSubmitting,
              builder: (context, submitting, _) => SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          if (_selectedRating == -1) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.pleaseRateYourExperience,
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          if (widget.checkAuth != null &&
                              !widget.checkAuth!()) {
                            widget.onAuthRequired?.call();
                            return;
                          }
                          _isSubmitting.value = true;
                          try {
                            if (_hasExistingFeedback) {
                              await ApiService().updateFeedback(
                                comment: _feedbackController.text.trim(),
                                rating: _selectedRating,
                                isPublicUser: widget.isPublicUser,
                              );
                            } else {
                              await ApiService().submitFeedback(
                                comment: _feedbackController.text.trim(),
                                rating: _selectedRating,
                                isPublicUser: widget.isPublicUser,
                              );
                            }
                            if (!context.mounted) return;
                            widget.onSuccess(_hasExistingFeedback);
                          } catch (e) {
                            _isSubmitting.value = false;
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Failed to submit feedback: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    submitting
                        ? AppLocalizations.of(context)!.loading
                        : _hasExistingFeedback
                            ? AppLocalizations.of(context)!.updateYourFeedback
                            : AppLocalizations.of(context)!.submit,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
