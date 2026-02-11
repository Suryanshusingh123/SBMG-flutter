import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config/connstants.dart';
import '../l10n/app_localizations.dart';

/// Read-only bottom sheet showing supervisor resolution message and image.
/// Used when the user taps "Resolved" on the complaint timeline.
class ResolutionDetailsSheet extends StatelessWidget {
  final String? resolutionComment;
  final String? resolutionImageUrl;

  const ResolutionDetailsSheet({
    super.key,
    this.resolutionComment,
    this.resolutionImageUrl,
  });

  /// Extracts resolution comment and image URL from complaint API data.
  /// Resolution comment: from [RESOLVED] comment text (tag stripped).
  /// Resolution image: media uploaded around resolved_at (includes supervisor
  /// flow where image is uploaded before resolve, so we consider media within
  /// 10 min before or any time after resolved_at).
  static ({String? resolutionComment, String? resolutionImageUrl}) extract(
    Map<String, dynamic>? complaintData,
  ) {
    if (complaintData == null) return (resolutionComment: null, resolutionImageUrl: null);

    final comments = complaintData['comments'] as List<dynamic>? ?? [];
    final media = complaintData['media'] as List<dynamic>? ?? [];
    final resolvedAt = complaintData['resolved_at'] as String?;

    // Resolution comment: [RESOLVED] comment, latest first
    String? resolutionComment;
    String? effectiveResolvedAt = resolvedAt;
    final resolvedComments = comments.where((c) {
      final t = (c['comment'] as String? ?? '').toUpperCase();
      return t.contains('[RESOLVED]');
    }).toList();
    if (resolvedComments.isNotEmpty) {
      resolvedComments.sort((a, b) {
        final aD = DateTime.tryParse(a['commented_at'] ?? '');
        final bD = DateTime.tryParse(b['commented_at'] ?? '');
        if (aD == null || bD == null) return 0;
        return bD.compareTo(aD);
      });
      resolutionComment = resolvedComments.first['comment'] as String?;
      effectiveResolvedAt ??= resolvedComments.first['commented_at'] as String?;
    }

    // Resolution image: media around effectiveResolvedAt
    // - uploaded_at > effectiveResolvedAt, or
    // - uploaded_at in [effectiveResolvedAt - 10 min, effectiveResolvedAt]
    //   (supervisor uploads image before calling resolve)
    String? resolutionImageUrl;
    if (effectiveResolvedAt != null && media.isNotEmpty) {
      final ref = DateTime.tryParse(effectiveResolvedAt);
      if (ref != null) {
        final before = ref.subtract(const Duration(minutes: 10));
        final resolutionMedia = media.where((m) {
          final up = DateTime.tryParse(m['uploaded_at'] as String? ?? '') ??
              DateTime.tryParse(m['created_at'] as String? ?? '');
          if (up == null) return false;
          // Include: after ref, or in [ref-10min, ref] (supervisor uploads before resolve)
          return up.isAfter(ref) ||
              (!up.isBefore(before) && !up.isAfter(ref));
        }).toList();
        // Prefer after ref; else closest before ref
        resolutionMedia.sort((a, b) {
          final aUp = DateTime.tryParse(a['uploaded_at'] as String? ?? '') ??
              DateTime.tryParse(a['created_at'] as String? ?? '');
          final bUp = DateTime.tryParse(b['uploaded_at'] as String? ?? '') ??
              DateTime.tryParse(b['created_at'] as String? ?? '');
          if (aUp == null || bUp == null) return 0;
          return bUp.compareTo(aUp);
        });
        if (resolutionMedia.isNotEmpty) {
          final m = resolutionMedia.first;
          resolutionImageUrl = m['media_url'] as String?;
        }
      }
    }

    return (resolutionComment: resolutionComment, resolutionImageUrl: resolutionImageUrl);
  }

  /// Shows the resolution details sheet. Extracts data from [complaintData].
  static void show(BuildContext context, Map<String, dynamic>? complaintData) {
    final data = extract(complaintData);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ResolutionDetailsSheet(
        resolutionComment: data.resolutionComment,
        resolutionImageUrl: data.resolutionImageUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = resolutionImageUrl != null && resolutionImageUrl!.isNotEmpty;
    final hasMessage = resolutionComment != null &&
        resolutionComment!.replaceAll('[RESOLVED]', '').trim().isNotEmpty;
    final hasAny = hasImage || hasMessage;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.resolution,
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              if (hasAny) ...[
                if (hasImage)
                  Container(
                    width: double.infinity,
                    height: 200.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.network(
                        ApiConstants.getMediaUrl(resolutionImageUrl!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade100,
                          child: Center(
                            child: Icon(Icons.broken_image,
                                color: Colors.grey, size: 50.sp),
                          ),
                        ),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: Colors.grey.shade100,
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        },
                      ),
                    ),
                  ),
                if (hasImage && hasMessage) SizedBox(height: 16.h),
                if (hasMessage)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      resolutionComment!.replaceAll('[RESOLVED]', '').trim(),
                      style: TextStyle(
                        fontFamily: 'Noto Sans',
                        fontSize: 14.sp,
                        color: const Color(0xFF374151),
                        height: 1.5,
                      ),
                    ),
                  ),
              ] else
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.noResolutionDetailsAvailable,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
