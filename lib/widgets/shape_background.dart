import 'package:flutter/material.dart';

enum CornerSide { left, right }

/// พื้นหลังหัวสีน้ำเงิน + เนื้อหาฟ้าเทา พร้อมมุมโค้งซ้าย/ขวา
/// เวอร์ชันใหม่: ใช้ AutoScaleFitter วัดขนาดจริงของคอนเทนต์
/// แล้วสเกลให้พอดีกับพื้นที่ (ไม่ต้องเดาเลข, ไม่ overflow)
class ShapeBackground extends StatelessWidget {
  const ShapeBackground({
    super.key,
    required this.child,
    this.corner = CornerSide.left,
    this.headerColor = const Color(0xFF0A2230), // navy
    this.bodyColor   = const Color(0xFFA9BCCF), // steel

    // รูปร่างพื้นหลัง (สเกลตามความสูงจอเล็กน้อย)
    this.headerBase  = 190,
    this.radiusBase  = 80,
    this.overlapBase = 64,

    // พื้นที่วางคอนเทนต์
    this.maxWidth    = 420,
    this.hPad        = 20,
    this.topPadBase  = 24,
    this.bottomPadBase = 24,

    // คงไว้เพื่อ compatibility (โหมดใหม่ไม่ใช้ค่านี้แล้ว)
    this.designContentHeight = 520,

    this.showTitle = true,
  });

  final Widget child;
  final CornerSide corner;
  final Color headerColor, bodyColor;

  final double headerBase, radiusBase, overlapBase;
  final double maxWidth, hPad;
  final double topPadBase, bottomPadBase;
  final double designContentHeight; // not used in AutoScale mode
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;

    // สเกลฐานเล็กน้อยตามความสูงจอ (กัน UI ใหญ่ไปบนจอเตี้ย)
    final baseScale = (screenH / 800).clamp(0.80, 1.00);
    double s(double v) => v * baseScale;

    final headerH = s(headerBase);
    final radius  = s(radiusBase);
    final overlap = s(overlapBase);
    final topPad  = s(topPadBase);
    final btmPad  = s(bottomPadBase);

    return Stack(
      children: [
        // แถบหัวกรมท่า
        Container(height: headerH, width: double.infinity, color: headerColor),

        if (showTitle)
          Positioned(
            left: s(24), top: s(36),
            child: Text(
              'Memoraid',
              style: TextStyle(
                color: Colors.white, fontSize: s(36), fontWeight: FontWeight.w700,
              ),
            ),
          ),

        // พื้นที่คอนเทนต์ + มุมโค้ง
        Positioned.fill(
          top: headerH - overlap,
          child: Container(
            decoration: BoxDecoration(
              color: bodyColor,
              borderRadius: BorderRadius.only(
                topLeft:  corner == CornerSide.left  ? Radius.circular(radius) : Radius.zero,
                topRight: corner == CornerSide.right ? Radius.circular(radius) : Radius.zero,
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPad, topPad, hPad, btmPad),
                child: _AutoScaleFitter(
                  maxWidth: maxWidth,
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// วัด "ขนาดจริง" ของ child ก่อน (ด้วย Offstage + GlobalKey)
/// แล้วสเกล child ให้พอดีกับพื้นที่ที่ LayoutBuilder ให้มา
/// - ไม่ overflow
/// - ไม่ต้องตั้ง design height
class _AutoScaleFitter extends StatefulWidget {
  const _AutoScaleFitter({
    required this.child,
    required this.maxWidth,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final Alignment alignment;

  @override
  State<_AutoScaleFitter> createState() => _AutoScaleFitterState();
}

class _AutoScaleFitterState extends State<_AutoScaleFitter> {
  final GlobalKey _measureKey = GlobalKey();
  Size? _naturalSize;

  void _readSizePostFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _measureKey.currentContext;
      if (ctx == null) return;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) return;
      final sz = box.size;
      if (_naturalSize != sz) {
        setState(() => _naturalSize = sz);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _readSizePostFrame();

    return LayoutBuilder(
      builder: (context, cons) {
        final maxW = cons.maxWidth < widget.maxWidth ? cons.maxWidth : widget.maxWidth;

        // วัดขนาดจริงด้วย Offstage (ไม่แสดง แต่ layout เกิด)
        final measure = Offstage(
          offstage: true,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: KeyedSubtree(
              key: _measureKey,
              child: widget.child,
            ),
          ),
        );

        // ถ้ายังไม่รู้ขนาดจริง: แทรกตัววัด + กันวาร์ปด้วย placeholder โปร่งใส
        if (_naturalSize == null) {
          return Stack(
            children: [
              measure,
              Align(
                alignment: widget.alignment,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW),
                  child: Opacity(opacity: 0.0, child: widget.child),
                ),
              ),
            ],
          );
        }

        // คำนวณสเกลจากพื้นที่จริง
        final nat = _naturalSize!;
        final availH = cons.maxHeight;
        final availW = maxW;
        final scaleH = availH / nat.height;
        final scaleW = availW / nat.width;
        final scale  = [1.0, scaleH, scaleW].reduce((a, b) => a < b ? a : b); // min(1, scaleH, scaleW)

        return Align(
          alignment: widget.alignment,
          child: SizedBox(
            width: maxW,
            height: nat.height * scale,                // จองพื้นที่เท่าที่สเกลแล้ว
            child: Transform.scale(
              scale: scale,
              alignment: widget.alignment,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}
