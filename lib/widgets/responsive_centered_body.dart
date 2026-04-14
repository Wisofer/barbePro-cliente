import 'package:flutter/material.dart';
import '../utils/responsive_breakpoints.dart';

/// Envuelve el hijo en un ancho máximo centrado en tablets y pantallas anchas.
/// En móviles el hijo ocupa todo el ancho (sin cambiar el aspecto actual).
class ResponsiveCenteredBody extends StatelessWidget {
  const ResponsiveCenteredBody({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.maxContentWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        if (!context.shouldConstrainContentWidth || w <= maxWidth) {
          return child;
        }
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        );
      },
    );
  }
}
