import 'package:flutter/material.dart';

class HauLogoWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsets? padding;

  const HauLogoWidget({
    super.key,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 70.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/images/hau_logo.png',
          width: width ?? 212.97,
          height: height ?? 200.0,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width ?? 212.97,
              height: height ?? 200.0,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.school,
                size: 50,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }
}