import 'package:flutter/material.dart';

/// Puntos de ruptura compartidos (teléfono / tablet / ancho útil).
abstract final class AppBreakpoints {
  static const double compactWidth = 360;
  static const double tabletWidth = 600;
  static const double largeWidth = 840;

  /// Ancho máximo del contenido centrado en tablet y escritorio estrecho.
  static const double maxContentWidth = 720;
}

extension ResponsiveContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  /// Pantallas muy estrechas (p. ej. algunos Android compactos).
  bool get isCompactWidth => screenWidth < AppBreakpoints.compactWidth;

  /// Entre compact y tablet.
  bool get isComfortableWidth =>
      screenWidth >= AppBreakpoints.compactWidth &&
      screenWidth < AppBreakpoints.tabletWidth;

  /// Tablet en portrait o teléfono landscape ancho.
  bool get isExpandedWidth => screenWidth >= AppBreakpoints.tabletWidth;

  /// Tablet clásico: lado corto >= 600 (iPad, tablets Android).
  bool get isTabletLike =>
      screenSize.shortestSide >= AppBreakpoints.tabletWidth;

  /// Debe limitar ancho y centrar contenido (tablet / ventanas anchas).
  bool get shouldConstrainContentWidth =>
      isTabletLike || screenWidth >= AppBreakpoints.tabletWidth;
}
