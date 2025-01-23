import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  CustomButton({
    required this.onPressed,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).buttonTheme.colorScheme?.primary, 
        foregroundColor: textColor ?? Theme.of(context).buttonTheme.colorScheme?.onPrimary,     
        side: borderColor != null ? BorderSide(color: borderColor!) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
      ),
      child: Text(text, style: TextStyle(fontSize: 18)),
    );
  }
}