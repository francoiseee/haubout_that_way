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
      child: SizedBox(
        width: width ?? 212.97,
        height: height ?? 200.0,
        child: Image.asset(
          'assets/images/hau_logo.png',
          fit: BoxFit.contain, // show the whole logo without cropping
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.transparent,
              alignment: Alignment.center,
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