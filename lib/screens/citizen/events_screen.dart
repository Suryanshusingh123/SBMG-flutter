import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../config/connstants.dart';
import '../../services/api_services.dart';
import '../../providers/citizen_bookmarks_provider.dart';
import '../../models/event_model.dart';
import '../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final ApiService _apiService = ApiService();
  List<Event> _events = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final events = await _apiService.getEvents(limit: 1000); // Fetch all events
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load events: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _showEventDetails(Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Event Image
                Container(
                  height: 200.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                    child: event.media.isNotEmpty
                        ? Image.network(
                            ApiConstants.getMediaUrl(event.media.first.mediaUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/eventbanner.png',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/eventbanner.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                // Event Details
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                event.title,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.grey.shade600),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 18.sp,
                              color: const Color(0xFF009B56),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                '${_formatDate(event.startTime)} - ${_formatDate(event.endTime)}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (event.description != null && event.description!.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          Text(
                            event.description!,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF111827),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d yyyy').format(date);
  }

  Widget _buildEventCard(Event event) {
    return GestureDetector(
      onTap: () => _showEventDetails(event),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Banner
            Container(
              height: 120.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: event.media.isNotEmpty
                          ? Image.network(
                              ApiConstants.getMediaUrl(event.media.first.mediaUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/eventbanner.png',
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.asset(
                              'assets/images/eventbanner.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                    // Bookmark Button
                    Positioned(
                      top: 12.h,
                      right: 12.w,
                      child: Consumer<BookmarksProvider>(
                        builder: (context, bookmarksProvider, child) {
                          final isBookmarked = bookmarksProvider.isEventBookmarked(event.id);
                          return GestureDetector(
                            onTap: () {
                              bookmarksProvider.toggleEventBookmark(event.id, !isBookmarked);
                            },
                            child: Container(
                              width: 40.w,
                              height: 40.h,
                              decoration: BoxDecoration(
                                color: isBookmarked
                                    ? const Color(0xFF009B56)
                                    : Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: isBookmarked
                                    ? Colors.white
                                    : const Color(0xFF4CAF50),
                                size: 20.sp,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Event Details
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2C3E50),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 110.w),
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Color(0xFF009B56),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                '${_formatDate(event.startTime)} - ${_formatDate(event.endTime)}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (event.description != null && event.description!.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(
                      event.description!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.events,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF009B56)),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16.h),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: _loadEvents,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF009B56),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _events.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
                          SizedBox(height: 16.h),
                          Text(
                            l10n.noEventsAvailable,
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadEvents,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          return _buildEventCard(_events[index]);
                        },
                      ),
                    ),
    );
  }
}
