import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/utils/app_theme.dart';
import '../../../core/utils/storage_utils.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final int initialPage;

  const OnboardingScreen({super.key, this.initialPage = 0});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;
  bool _isLoading = false;
  int _currentPage = 0;

  // Onboarding content - exact match with reference implementation
  final List<String> titles = ['Invest', 'Pay', 'Seedit'];
  final List<String> descriptions = [
    'Your gateway to financial growth and prosperity. Start your investment journey with us today.',
    'Grow your wealth with our diverse investment options. Smart investments for a better future.',
    'Fast, secure, and reliable payment methods. Your money is always safe with us.',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
    _currentPage = widget.initialPage;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Set loading state
  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  // Handle navigation on the last page - exact match with reference
  Future<void> _handleLastPageNavigation() async {
    _setLoading(true);

    try {
      // Check if the widget is still mounted before updating state or navigating
      if (!mounted) return;

      // Mark onboarding as completed and navigate to sign-in screen
      await StorageUtils.setOnboardingCompleted(true);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/sign-in');
      }
    } finally {
      // Ensure loading is set to false if the widget is still mounted
      if (mounted) {
        _setLoading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // PageView for the background and content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: titles.length,
            itemBuilder: (context, index) {
              return _buildPage(
                context,
                titles[index],
                descriptions[index],
                'assets/images/img_onboarding_${index + 1}.png',
              );
            },
          ),

          // Page indicators at top center
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                titles.length,
                (index) => _buildDot(index == _currentPage),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage(
    BuildContext context,
    String title,
    String description,
    String imagePath,
  ) {
    return Stack(
      children: [
        // Background image
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback if image is not found
              return Container(
                color: Colors.grey.shade100,
                child: Center(
                  child: Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.grey.shade300,
                  ),
                ),
              );
            },
          ),
        ),

        // Content overlay - white rounded box with text and button
        Positioned(
          bottom: 50, // Position at the bottom with some margin
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 40, // Increased from 24 to 40
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                // Navigation button
                Column(
                  children: [
                    // Arrow button for all pages
                    GestureDetector(
                      onTap: () {
                        final isLastPage = _currentPage == titles.length - 1;
                        if (isLastPage) {
                          // Navigate to sign-in on last page
                          _handleLastPageNavigation();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Transform.rotate(
                          angle: 3.14159, // Rotate 180 degrees for right arrow
                          child: SvgPicture.asset(
                            'assets/images/svg/img_arrow_left.svg',
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              AppTheme.primaryColor,
                              BlendMode.srcIn,
                            ),
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to icon if SVG is not found
                              return const Icon(
                                Icons.arrow_forward,
                                color: AppTheme.primaryColor,
                                size: 24,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: isActive ? 10 : 8,
      width: isActive ? 10 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryColor : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
