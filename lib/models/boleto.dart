import 'dart:convert';

class Boleto {
  final String id;
  final String codigoAlfanumerico;
  final DateTime fechaCompra;
  String estado;

  Boleto({
    required this.id,
    required this.codigoAlfanumerico,
    required this.fechaCompra,
    this.estado = 'Disponible',
  });

  factory Boleto.fromJson(Map<String, dynamic> json) {
    return Boleto(
      id: json['id'].toString(),
      codigoAlfanumerico: json['codigo_alfanumerico'],
      fechaCompra: DateTime.parse(json['fecha_compra']),
      estado: json['estado'] ?? 'Disponible',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo_alfanumerico': codigoAlfanumerico,
      'fecha_compra': fechaCompra.toIso8601String(),
      'estado': estado,
    };
  }
}
