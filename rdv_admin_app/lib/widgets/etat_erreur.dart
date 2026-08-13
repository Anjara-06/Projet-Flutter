import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class EtatErreur extends StatelessWidget {
  final String message;
  final VoidCallback onReessayer;

  const EtatErreur({
    super.key,
    required this.message,
    required this.onReessayer,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 40, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onReessayer,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
