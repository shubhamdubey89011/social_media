import 'package:flutter/material.dart';

class CircularNotchedShape extends NotchedShape {
  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest)) {
      return Path()..addRect(host);
    }

    final notchRadius = guest.width / 2.0;
    final notchCenter = guest.center;

    return Path()
      ..moveTo(host.left, host.top)
      ..lineTo(notchCenter.dx - notchRadius, host.top)
      ..arcToPoint(
        Offset(notchCenter.dx + notchRadius, host.top),
        radius: Radius.circular(notchRadius),
        clockwise: false,
      )
      ..lineTo(host.right, host.top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();
  }
}
