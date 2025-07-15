import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.padding,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null && !isLoading) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined 
                    ? theme.primaryColor 
                    : textColor ?? Colors.white,
              ),
            ),
          )
        else
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isOutlined 
                  ? theme.primaryColor 
                  : textColor ?? Colors.white,
            ),
          ),
      ],
    );

    Widget button = isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              minimumSize: Size(width ?? double.infinity, height),
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
              side: BorderSide(
                color: backgroundColor ?? theme.primaryColor,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: buttonChild,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? theme.primaryColor,
              foregroundColor: textColor ?? Colors.white,
              minimumSize: Size(width ?? double.infinity, height),
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: buttonChild,
          );

    return button;
  }
}

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? tooltip;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: iconColor ?? theme.primaryColor,
        ),
        tooltip: tooltip,
      ),
    );
  }
}

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextDecoration? decoration;

  const CustomTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? theme.primaryColor,
          fontSize: fontSize ?? 14,
          fontWeight: fontWeight ?? FontWeight.w500,
          decoration: decoration,
        ),
      ),
    );
  }
}
