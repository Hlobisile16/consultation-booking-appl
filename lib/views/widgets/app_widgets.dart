import 'package:flutter/material.dart';
import 'package:mobile_app/theme/app_theme.dart';

// A raised, softly shadowed card
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(26);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: radius,
        boxShadow: AppShadows.soft,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

// Small uppercase label with wide letter spacing
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 2.4,
        fontWeight: FontWeight.w600,
        color: AppColors.muted,
      ),
    );
  }
}

// Logo and app name shown at the top of the login and registration screens
class AuthHeader extends StatelessWidget {
  final String subtitle;
  const AuthHeader({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.moss, AppColors.sage],
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: AppShadows.soft,
          ),
          child: const Icon(Icons.event_available, color: AppColors.ivory, size: 36),
        ),
        const SizedBox(height: 18),
        const Text(
          'CONSULT / BOOK',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w300,
            letterSpacing: 5,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 3.2,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

// Filled pill button with an arrow. Pass onPressed: null to disable it
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon = Icons.arrow_forward,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed == null ? null : (loading ? () {} : onPressed),
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.ivory,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, size: 18),
                  ],
                ],
              ),
      ),
    );
  }
}

// Outlined pill button
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const SecondaryButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(onPressed: onPressed, child: Text(label)),
    );
  }
}

// Pill-shaped segmented tabs
class SegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isSelected = i == selected;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 11),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.sage : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.ivory : AppColors.muted,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Notification toast with a round icon, a title, a message and a close button
void showAppToast(
  BuildContext context,
  String message, {
  bool error = false,
  String? title,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      duration: const Duration(seconds: 4),
      content: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: error ? AppColors.dangerTint : AppColors.mist,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: error ? const Color(0x66B5574B) : const Color(0x66687F6E),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: error ? AppColors.danger : AppColors.sage,
                shape: BoxShape.circle,
              ),
              child: Icon(
                error ? Icons.priority_high : Icons.check,
                color: AppColors.ivory,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title ?? (error ? 'Something went wrong' : 'All set!'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: messenger.hideCurrentSnackBar,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 18, color: AppColors.muted),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
// A row with a round icon, a small uppercase label and a value
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.mist,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 19, color: AppColors.sage),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10.5,
                    letterSpacing: 1.8,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}