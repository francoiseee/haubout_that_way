import 'package:flutter/material.dart';
import 'package:hau_navigation_app/core/theme/app_theme.dart';
import 'package:hau_navigation_app/widgets/hau_logo.dart';

/// A reusable custom app bar widget for HAU navigation app
/// 
/// This widget provides a consistent navigation bar design across the app
/// with HAU branding, curved bottom corners, and customizable options.
/// 
/// Example usage:
/// ```dart
/// // Basic usage with default settings
/// appBar: const CustomAppBar(),
/// 
/// // With custom title and actions
/// appBar: CustomAppBar(
///   title: 'Custom Page Title',
///   actions: [
///     IconButton(
///       icon: const Icon(Icons.settings, color: Colors.white),
///       onPressed: () => _openSettings(),
///     ),
///   ],
/// ),
/// 
/// // Without back button
/// appBar: const CustomAppBar(
///   showBackButton: false,
/// ),
/// ```
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final List<Widget>? actions;
  final double height;

  const CustomAppBar({
    super.key,
    this.title = 'HAUbout That Way',
    this.onBackPressed,
    this.showBackButton = true,
    this.actions,
    this.height = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.primaryRed,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button or empty space
                if (showBackButton)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: onBackPressed ?? () => Navigator.pop(context),
                  )
                else
                  const SizedBox(width: 48),
                
                // Title with logo
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const HauLogoWidget(
                      width: 40,
                      height: 40,
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                // Actions or empty space to balance
                if (actions != null && actions!.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!,
                  )
                else
                  const SizedBox(width: 48), // Same width as IconButton
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}