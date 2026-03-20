import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/aarti_item.dart';

class FocusModeOverlay extends StatelessWidget {
  final AartiItem aarti;
  final VoidCallback onClose;

  const FocusModeOverlay(
      {super.key, required this.aarti, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: AppColors.ink,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SADHANA MODE',
                          style: AppTextStyles.label(
                            size: 10,
                            color: AppColors.ink3,
                          ),
                        ),
                        Text(
                          aarti.title,
                          style: AppTextStyles.body(
                            size: 13,
                            color: AppColors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: AppColors.ink3, size: 20),
                      onPressed: onClose,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ब्रह्मा, विष्णु, सदाशिव',
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.white.withValues(alpha: 0.3),
                            height: 2.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'ॐ जय शिव ओंकारा',
                          style: TextStyle(
                            fontSize: 28,
                            color: AppColors.saffronLight,
                            fontWeight: FontWeight.w400,
                            height: 2.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'स्वामी जय शिव ओंकारा',
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.white.withValues(alpha: 0.3),
                            height: 2.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'अर्द्धांगी धारा',
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.white.withValues(alpha: 0.2),
                            height: 2.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
