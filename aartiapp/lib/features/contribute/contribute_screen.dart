import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/aarti_app_bar.dart';

class ContributeScreen extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  const ContributeScreen({super.key, required this.onOpenDrawer});

  @override
  State<ContributeScreen> createState() => _ContributeScreenState();
}

class _ContributeScreenState extends State<ContributeScreen> {
  int _privacyMode = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: AartiAppBar(onMenuTap: widget.onOpenDrawer),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CONTRIBUTE',
                      style:
                          AppTextStyles.label(size: 10, color: AppColors.ink3)),
                  const SizedBox(height: 6),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 34,
                        fontWeight: FontWeight.w300,
                        color: AppColors.ink,
                      ),
                      children: [
                        TextSpan(text: 'Add an '),
                        TextSpan(
                          text: 'Aarti',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: AppColors.saffron,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Share a prayer with the community or keep it for yourself',
                    style:
                        AppTextStyles.body(size: 13, color: AppColors.ink3),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 60),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _FormField(
                    label: 'Deity Name',
                    hint: 'e.g. Ganesha, Shiva, Lakshmi…'),
                const SizedBox(height: 18),
                _FormField(
                    label: 'Aarti Title (English)',
                    hint: 'e.g. Jai Ganesh Deva'),
                const SizedBox(height: 18),
                _FormField(
                  label: 'Title in Devanagari',
                  hint: 'e.g. जय गणेश देव',
                ),
                const SizedBox(height: 18),
                _FormField(
                  label: 'Lyrics (Devanagari)',
                  hint: 'ॐ जय जगदीश हरे…',
                  maxLines: 6,
                ),
                const SizedBox(height: 18),
                _FormField(
                    label: 'Audio URL (optional)', hint: 'https://…'),
                const SizedBox(height: 24),

                // Privacy
                Text('VISIBILITY',
                    style:
                        AppTextStyles.label(size: 10, color: AppColors.ink3)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _PrivacyOption(
                        title: 'Private',
                        subtitle: 'Only visible to you',
                        isSelected: _privacyMode == 0,
                        onTap: () => setState(() => _privacyMode = 0),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PrivacyOption(
                        title: 'Submit for Review',
                        subtitle: 'Added to global library if approved',
                        isSelected: _privacyMode == 1,
                        onTap: () => setState(() => _privacyMode = 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submit
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_privacyMode == 0
                            ? 'Aarti saved privately.'
                            : 'Aarti submitted for review. 🙏'),
                        backgroundColor: AppColors.ink,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Submit Aarti'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w400),
                    elevation: 0,
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final int maxLines;

  const _FormField({
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: AppTextStyles.label(size: 10, color: AppColors.ink3)),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: maxLines,
          style: AppTextStyles.body(size: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body(size: 14, color: AppColors.ink3),
            filled: true,
            fillColor: AppColors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.stone3),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.stone3),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.saffron, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrivacyOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PrivacyOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.saffronGlow : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.saffron : AppColors.stone3,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: AppTextStyles.body(
                    size: 13,
                    color: AppColors.ink,
                    weight: FontWeight.w400)),
            const SizedBox(height: 2),
            Text(subtitle,
                style:
                    AppTextStyles.body(size: 11, color: AppColors.ink3)),
          ],
        ),
      ),
    );
  }
}
