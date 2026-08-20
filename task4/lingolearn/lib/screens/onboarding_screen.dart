import 'package:flutter/material.dart';
import 'home_screen.dart';
class OnboardingScreen extends StatefulWidget {
  final Future<void> Function() onFinished;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  const OnboardingScreen({
    super.key,
    required this.onFinished,
    required this.isDarkMode,
    required this.onToggleTheme,
  });
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}
class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.menu_book_rounded,
      'title': 'Build Your Vocabulary',
      'description': 'Learn new words and build your vocabulary step by step.',
    },
    {
      'icon': Icons.quiz_rounded,
      'title': 'Practice With Quizzes',
      'description': 'Test yourself with quizzes and improve your language skills.',
    },
    {
      'icon': Icons.trending_up_rounded,
      'title': 'Track Your Progress',
      'description': 'Keep track of your learning progress and see your improvement.',
    },
  ];
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  Future<void> _finish() async {
    await widget.onFinished();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          isDarkMode: widget.isDarkMode,
          onToggleTheme: widget.onToggleTheme,
        ),
      ),
    );
  }
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }
  void _skip() {
    _finish();
  }
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _skip,
                child: Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 30,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color:colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page['icon'] as IconData,
                            size: 75,
                            color: colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 45),
                        Text(
                          page['title'] as String,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          page['description'] as String,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length, (index) {
                  final isSelected = index == _currentPage;
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 250),
                    margin: EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    width: isSelected ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 25,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton(
                  onPressed: _nextPage,
                  child: Text(_currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                  ),
                ),
              ),
            ),
            SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}