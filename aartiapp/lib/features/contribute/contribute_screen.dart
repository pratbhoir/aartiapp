import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/aarti_app_bar.dart';

/// My Personal Collection — saves private Aartis locally.
/// "Submit for Review" is deferred to backend phase.
class ContributeScreen extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  const ContributeScreen({super.key, required this.onOpenDrawer});

  @override
  State<ContributeScreen> createState() => _ContributeScreenState();
}

class _ContributeScreenState extends State<ContributeScreen> {
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
                  Text('MY COLLECTION',
                      style:
                          AppTextStyles.label(size: 10, color: AppColors.ink3)),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.displayLarge(context).copyWith(
                        fontSize: 34,
                      ),
                      children: const [
                        TextSpan(text: 'Personal '),
                        TextSpan(
                          text: 'Collection',
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
                    'Save private Aartis for your personal devotion',
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
                const SizedBox(height: 24),

                // Save button — private only in v1
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Aarti saved to your collection.'),
                        backgroundColor: AppColors.ink,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  icon: const Icon(Icons.save_outlined, size: 16),
                  label: const Text('Save to My Collection'),
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
