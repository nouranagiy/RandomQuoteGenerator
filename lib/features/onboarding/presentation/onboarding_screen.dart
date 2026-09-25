import 'package:flutter/material.dart';
import 'package:quoteflow/core/constants/app_constants.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/core/localization/l10n.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/core/utils/prefs.dart';
import 'package:quoteflow/features/onboarding/presentation/onboarding_controls.dart';
import 'package:quoteflow/features/onboarding/presentation/onboarding_page_content.dart';
import 'package:quoteflow/features/onboarding/presentation/onboarding_visual_panel.dart';
import 'package:quoteflow/shared/widgets/app_status_banner.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  bool _isCompleting = false;
  bool _showSaveError = false;

  List<_OnboardingPage> _buildPages(L10n l10n) {
    return [
      _OnboardingPage(
        icon: Icons.explore_rounded,
        title: l10n.onboardingTitle1,
        description: l10n.onboardingDesc1,
        accent: OnboardingVisualAccent.primary,
      ),
      _OnboardingPage(
        icon: Icons.bookmark_rounded,
        title: l10n.onboardingTitle2,
        description: l10n.onboardingDesc2,
        accent: OnboardingVisualAccent.secondary,
      ),
      _OnboardingPage(
        icon: Icons.ios_share_rounded,
        title: l10n.onboardingTitle3,
        description: l10n.onboardingDesc3,
        accent: OnboardingVisualAccent.tertiary,
      ),
    ];
  }

  Future<void> _complete() async {
    if (_isCompleting) return;
    setState(() {
      _isCompleting = true;
      _showSaveError = false;
    });

    var saved = false;
    try {
      final prefs = await Prefs.instance;
      saved = await prefs.setBool(
        AppConstants.prefsKeyOnboardingCompleted,
        true,
      );
    } catch (_) {
      saved = false;
    }

    if (!mounted) return;
    if (!saved) {
      setState(() {
        _isCompleting = false;
        _showSaveError = true;
      });
      return;
    }
    widget.onComplete();
  }

  void _advance(int pageCount) {
    if (_currentPage >= pageCount - 1) {
      _complete();
      return;
    }
    _controller.nextPage(
      duration: AppMotion.relaxed,
      curve: AppMotion.standardCurve,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pages = _buildPages(l10n);
    final maxWidth = MediaQuery.sizeOf(context).width >= AppBreakpoints.expanded
        ? AppSizes.contentMaxWidth
        : AppSizes.onboardingMaxWidth;
    final isLast = _currentPage >= pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    OnboardingHeader(
                      tagline: l10n.inspireYourDay,
                      skipLabel: l10n.skip,
                      onSkip: _isCompleting ? null : _complete,
                    ),
                    if (_showSaveError) ...[
                      const SizedBox(height: AppSpacing.md),
                      AppStatusBanner(
                        type: AppStatusBannerType.error,
                        title: l10n.error,
                        message: l10n.preferenceSaveError,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: pages.length,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                        },
                        itemBuilder: (context, index) {
                          final page = pages[index];
                          return OnboardingPageContent(
                            title: page.title,
                            description: page.description,
                            icon: page.icon,
                            accent: page.accent,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OnboardingFooter(
                      pageLabels: pages.map((page) => page.title).toList(),
                      currentPage: _currentPage,
                      actionLabel: isLast ? l10n.done : l10n.next,
                      doneIcon: Icons.check_rounded,
                      onPressed: _isCompleting
                          ? null
                          : () => _advance(pages.length),
                      isLoading: _isCompleting,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final OnboardingVisualAccent accent;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
  });
}
