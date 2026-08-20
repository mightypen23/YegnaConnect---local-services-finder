import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key, this.width = 190});
  final double width;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        'assets/branding/yegna_connect_logo.svg',
        width: width,
        fit: BoxFit.contain,
      );
}

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final bool outlined;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final content = icon == null
        ? Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon!,
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.green,
                side: const BorderSide(color: AppTheme.green),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: content,
            )
          : FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.greenLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: content,
            ),
    );
  }
}

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.controller,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  final String label;
  final IconData icon;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.muted, fontSize: 14),
        prefixIcon: Icon(icon, size: 20, color: AppTheme.muted),
      ),
    );
  }
}
