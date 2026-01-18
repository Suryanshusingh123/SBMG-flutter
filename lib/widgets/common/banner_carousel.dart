import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({
    super.key,
    required this.imagePaths,
    this.height = 230,
    this.autoSlideInterval = const Duration(seconds: 3),
  });

  final List<String> imagePaths;
  final double height;
  final Duration autoSlideInterval;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  late List<String> _imagePaths;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _imagePaths = widget.imagePaths;
    // Initialize PageController with initial page in the middle for infinite scroll
    if (_imagePaths.isNotEmpty) {
      _pageController = PageController(initialPage: _imagePaths.length * 1000);
      _startAutoSlide();
    } else {
      _pageController = PageController();
    }
  }

  @override
  void didUpdateWidget(covariant BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.imagePaths, widget.imagePaths)) {
      _stopAutoSlide();
      setState(() {
        _imagePaths = widget.imagePaths;
        _currentIndex = 0;
      });
      if (_imagePaths.isNotEmpty) {
        _pageController.jumpToPage(_imagePaths.length * 1000);
        _startAutoSlide();
      }
    }
  }

  void _startAutoSlide() {
    if (_imagePaths.isEmpty || _imagePaths.length <= 1) return;
    
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(widget.autoSlideInterval, (timer) {
      if (_pageController.hasClients) {
        final nextPage = _pageController.page!.toInt() + 1;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = null;
  }

  @override
  void dispose() {
    _stopAutoSlide();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_imagePaths.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index % _imagePaths.length;
          });
          // Restart auto-slide timer when user manually swipes
          _stopAutoSlide();
          _startAutoSlide();
        },
        // Use a large itemCount to enable infinite scrolling
        itemCount: _imagePaths.length * 2000,
        itemBuilder: (context, index) {
          // Use modulo to loop through images infinitely
          final imageIndex = index % _imagePaths.length;
          return _buildBannerCard(_imagePaths[imageIndex]);
        },
      ),
    );
  }

  Widget _buildBannerCard(String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: Stack(
          children: [
            // Background Image or Gradient
            if (imagePath.isNotEmpty)
              Positioned.fill(child: Image.asset(imagePath, fit: BoxFit.cover))
            else
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        left: -30,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      // Decorative lines
                      Positioned(
                        top: 60,
                        right: 20,
                        child: Container(
                          width: 2,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        left: 20,
                        child: Container(
                          width: 2,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Dot Indicators inside banner
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _imagePaths.length,
                  (index) => _buildDotIndicator(index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentIndex == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentIndex == index
            ? Colors.white
            : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
