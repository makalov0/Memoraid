import 'package:flutter/material.dart';

/// วิดเจ็ตพื้นหลังแบบรูปทรงโค้ง (ตามภาพ bg.jpg)
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.topGap = 210,          // ระยะดันเนื้อหาให้พ้นส่วนโค้งด้านบน
    this.maxWidth = 420,
    this.horizontalPadding = 20,
  });

  final Widget child;
  final double topGap;
  final double maxWidth;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // พื้นหลังรูป
        Positioned.fill(
          child: Image.asset(
            'images/bg.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        // เนื้อหา
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding, topGap, horizontalPadding, 24,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
