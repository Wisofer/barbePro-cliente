/// Utilidades para formatear valores monetarios redondeados a enteros
/// Todos los valores monetarios se redondean a números enteros sin decimales
class MoneyFormatter {
  /// Redondea un valor double a entero
  /// Ejemplo: 120.76 -> 121, 120.24 -> 120
  static int roundToInt(double value) {
    return value.round();
  }

  /// Convierte un valor double a double redondeado
  /// Útil para cálculos internos
  static double roundToDouble(double value) {
    return value.round().toDouble();
  }

  /// Formatea un valor como string sin decimales
  /// Ejemplo: 120.76 -> "121", 120.24 -> "120"
  static String format(double value) {
    return roundToInt(value).toString();
  }

  /// Formatea un valor con símbolo de córdobas (C$)
  /// Ejemplo: 120.76 -> "C$121"
  static String formatCordobas(double value) {
    return 'C\$${format(value)}';
  }

  /// Formatea un valor con símbolo de dólares ($)
  /// Los dólares mantienen decimales (NO se redondean)
  /// Ejemplo: 50.76 -> "$50.76", 21.5 -> "$21.50"
  static String formatDolares(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  /// Formatea un valor con símbolo según la moneda
  /// moneda puede ser "C$", "$", o "Ambos"
  /// Córdobas: se redondean a enteros
  /// Dólares: mantienen 2 decimales
  static String formatByMoneda(double value, String moneda) {
    if (moneda == r'$' || moneda == 'USD') {
      return formatDolares(value);
    }
    return formatCordobas(value);
  }

  /// Parsea un string a double y lo redondea
  /// Útil para inputs de usuario
  static double? parseAndRound(String? value) {
    if (value == null || value.isEmpty) return null;
    final parsed = double.tryParse(value);
    if (parsed == null) return null;
    return roundToDouble(parsed);
  }

  /// Formatea para mostrar tipo de cambio (puede tener decimales en TC)
  /// Pero para valores monetarios siempre se redondea
  static String formatTipoCambio(double value) {
    // El tipo de cambio se puede mostrar con 2 decimales
    // pero cuando se usa en cálculos se redondea el resultado
    return value.toStringAsFixed(2);
  }
}
