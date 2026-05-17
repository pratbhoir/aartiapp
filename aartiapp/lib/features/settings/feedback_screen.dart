import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations_ext.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/feedback_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/theme_aware_colors.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../providers/app_providers.dart';

/// Feedback form for devotional content issues, bugs, and suggestions.
const int _feedbackMessageMaxLength = 1000;
const String _feedbackTypeIncorrectLyrics = 'Incorrect Lyrics';
const String _feedbackTypeTranslationIssue = 'Translation Issue';
const String _feedbackTypeFeatureRequest = 'Feature Request';
const String _feedbackTypeBugReport = 'Bug Report';
const String _feedbackTypeGeneralFeedback = 'General Feedback';

class FeedbackScreen extends ConsumerStatefulWidget {
  /// Creates the feedback screen.
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  static const List<String> _feedbackTypes = <String>[
    _feedbackTypeIncorrectLyrics,
    _feedbackTypeTranslationIssue,
    _feedbackTypeFeatureRequest,
    _feedbackTypeBugReport,
    _feedbackTypeGeneralFeedback,
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _selectedType = _feedbackTypes.first;
  bool _isSubmitting = false;
  bool _didSubmit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.trackScreen(
        '/feedback',
        title: context.l10n.feedbackScreenTitle,
      );
      //AnalyticsService.trackEvent('feedback_screen_viewed', path: '/feedback');
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> feedbackTypeLabels = <String, String>{
      for (final String type in _feedbackTypes) type: _feedbackTypeLabel(context, type),
    };
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double keyboardInset = mediaQuery.viewInsets.bottom;
    final double screenBodyHeight =
        mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom -
        AppSpacing.md -
        AppSpacing.lg;
    final double formCardHeight =
        (screenBodyHeight - AppSpacing.touchTarget - AppSpacing.xl).clamp(
          420.0,
          760.0,
        );

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg + keyboardInset,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _BackButton(onTap: () => Navigator.of(context).maybePop()),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      context.l10n.feedbackScreenTitle,
                      style: AppTypography.serifBody(
                        size: 24,
                        color: context.textPrimary,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                height: formCardHeight,
                child: _didSubmit
                    ? _FeedbackSuccessCard(onReset: _resetForm)
                    : _FeedbackFormCard(
                        formKey: _formKey,
                        selectedType: _selectedType,
                        emailController: _emailController,
                        messageController: _messageController,
                        isSubmitting: _isSubmitting,
                        feedbackTypeLabels: feedbackTypeLabels,
                        onTypeSelected: (String value) {
                          if (value != _selectedType) {
                            AnalyticsService.trackEvent(
                              'feedback_type_selected',
                              data: <String, Object>{'feedback_type': value},
                              path: '/feedback',
                            );
                          }
                          setState(() => _selectedType = value);
                        },
                        onSubmit: _submit,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate() || _isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(feedbackServiceProvider)
          .submit(
            feedbackType: _selectedType,
            message: _messageController.text,
            email: _emailController.text,
          );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _didSubmit = true;
      });
    } on FeedbackSubmissionException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _isSubmitting = false);
      SnackBarHelper.showError(
        context,
        _localizedSubmissionError(context, error.message),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _isSubmitting = false);
      SnackBarHelper.showError(context, context.l10n.feedbackErrorGeneric);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _emailController.clear();
    _messageController.clear();
    setState(() {
      _selectedType = _feedbackTypes.first;
      _didSubmit = false;
      _isSubmitting = false;
    });
  }

  String _feedbackTypeLabel(BuildContext context, String type) {
    final l10n = context.l10n;
    switch (type) {
      case _feedbackTypeTranslationIssue:
        return l10n.feedbackTypeTranslationIssue;
      case _feedbackTypeFeatureRequest:
        return l10n.feedbackTypeFeatureRequest;
      case _feedbackTypeBugReport:
        return l10n.feedbackTypeBugReport;
      case _feedbackTypeGeneralFeedback:
        return l10n.feedbackTypeGeneralFeedback;
      case _feedbackTypeIncorrectLyrics:
      default:
        return l10n.feedbackTypeIncorrectLyrics;
    }
  }

  String _localizedSubmissionError(BuildContext context, String rawMessage) {
    final l10n = context.l10n;
    final String normalized = rawMessage.toLowerCase();
    if (normalized.contains('timed out')) {
      return l10n.feedbackErrorTimeout;
    }

    final RegExpMatch? statusMatch = RegExp(r'status\s+(\d+)').firstMatch(
      rawMessage,
    );
    if (statusMatch != null) {
      final int? statusCode = int.tryParse(statusMatch.group(1) ?? '');
      if (statusCode != null) {
        return l10n.feedbackErrorServer(statusCode);
      }
    }

    return l10n.feedbackErrorGeneric;
  }
}

class _FeedbackFormCard extends StatelessWidget {
  const _FeedbackFormCard({
    required this.formKey,
    required this.selectedType,
    required this.emailController,
    required this.messageController,
    required this.isSubmitting,
    required this.feedbackTypeLabels,
    required this.onTypeSelected,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final String selectedType;
  final TextEditingController emailController;
  final TextEditingController messageController;
  final bool isSubmitting;
  final Map<String, String> feedbackTypeLabels;
  final ValueChanged<String> onTypeSelected;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: formKey,
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.contentPadding),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          border: Border.all(color: context.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Text(
            //   'Share what needs attention',
            //   style: AppTypography.serifBody(
            //     size: 20,
            //     color: context.textPrimary,
            //   ).copyWith(fontWeight: FontWeight.w600),
            // ),
            // const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.feedbackGuidance,
              style: AppTypography.body(size: 14, color: context.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.feedbackCategoryLabel,
              style: AppTypography.label(color: context.textCaption),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: feedbackTypeLabels.entries.map((entry) {
                final String type = entry.key;
                final bool isSelected = type == selectedType;
                return _FeedbackTypeChip(
                  label: entry.value,
                  isSelected: isSelected,
                  onTap: () => onTypeSelected(type),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lgWide),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: AppTypography.body(size: 14, color: context.textPrimary),
              decoration: InputDecoration(
                labelText: l10n.feedbackEmailLabel,
                hintText: l10n.feedbackEmailHint,
                hintStyle: AppTypography.body(
                  size: 14,
                  color: context.textCaption,
                ).copyWith(fontStyle: FontStyle.italic),
                floatingLabelStyle: AppTypography.body(
                  size: 13,
                  color: AppColors.saffronDark,
                  weight: FontWeight.w500,
                ),
                labelStyle: AppTypography.body(
                  size: 14,
                  color: context.textSecondary,
                ),
              ),
              validator: (value) => _validateEmail(context, value),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: TextFormField(
                controller: messageController,
                expands: true,
                minLines: null,
                maxLines: null,
                maxLength: _feedbackMessageMaxLength,
                textAlignVertical: TextAlignVertical.top,
                style: AppTypography.body(size: 14, color: context.textPrimary),
                decoration: InputDecoration(
                  labelText: l10n.feedbackMessageLabel,
                  hintText: l10n.feedbackMessageHint,
                  alignLabelWithHint: true,
                  hintStyle: AppTypography.body(
                    size: 14,
                    color: context.textCaption,
                  ).copyWith(fontStyle: FontStyle.italic),
                  floatingLabelStyle: AppTypography.body(
                    size: 13,
                    color: AppColors.saffronDark,
                    weight: FontWeight.w500,
                  ),
                  labelStyle: AppTypography.body(
                    size: 14,
                    color: context.textSecondary,
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                ),
                validator: (value) => _validateMessage(context, value),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: AppSpacing.touchTarget,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  side: BorderSide(
                    color: context.borderSubtle.withValues(alpha: 0.85),
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppSpacing.buttonRadius,
                    ),
                  ),
                ),
                onPressed: isSubmitting ? null : onSubmit,
                child: isSubmitting
                    ? SizedBox(
                        width: AppSpacing.lg,
                        height: AppSpacing.lg,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            context.surface,
                          ),
                        ),
                      )
                    : Text(
                        l10n.feedbackSubmitButton,
                        style: AppTypography.body(
                          size: 14,
                          color: AppColors.white,
                          weight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateEmail(BuildContext context, String? value) {
    final String trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }

    final RegExp emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(trimmed)) {
      return context.l10n.feedbackValidationEmail;
    }
    return null;
  }

  String? _validateMessage(BuildContext context, String? value) {
    final String trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return context.l10n.feedbackValidationMessageRequired;
    }
    if (trimmed.length > _feedbackMessageMaxLength) {
      return context.l10n.feedbackValidationMessageTooLong(
        _feedbackMessageMaxLength,
      );
    }
    return null;
  }
}

class _FeedbackSuccessCard extends StatelessWidget {
  const _FeedbackSuccessCard({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.contentPadding),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        border: Border.all(color: context.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: AppSpacing.touchTarget + AppSpacing.sm,
              height: AppSpacing.touchTarget + AppSpacing.sm,
              decoration: BoxDecoration(
                color: AppColors.saffronGlow,
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: AppSpacing.xxl,
                color: AppColors.saffronDark,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.feedbackSuccessTitle,
            textAlign: TextAlign.center,
            style: AppTypography.serifBody(
              size: 20,
              color: context.textPrimary,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.feedbackSuccessDescription,
            textAlign: TextAlign.center,
            style: AppTypography.body(size: 14, color: context.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: AppSpacing.touchTarget,
            child: OutlinedButton(
              onPressed: onReset,
              child: Text(
                l10n.feedbackSuccessResetButton,
                style: AppTypography.body(
                  size: 14,
                  color: context.textPrimary,
                  weight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackTypeChip extends StatelessWidget {
  const _FeedbackTypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: AppTypography.body(
          size: 12,
          color: isSelected ? AppColors.saffronDark : context.textPrimary,
          weight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
      backgroundColor: context.surface,
      selectedColor: AppColors.saffronGlow,
      side: BorderSide(
        color: isSelected ? AppColors.saffronDark : context.border,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxs,
        vertical: AppSpacing.xxs,
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.commonBack,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Container(
          width: AppSpacing.touchTarget,
          height: AppSpacing.touchTarget,
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: context.borderSubtle),
          ),
          child: Icon(Icons.arrow_back_rounded, color: context.textPrimary),
        ),
      ),
    );
  }
}
