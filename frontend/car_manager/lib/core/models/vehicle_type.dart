import 'package:flutter/material.dart';

/// Tipurile de vehicule si cum arata fiecare.
///
/// Aceeasi lista exista si pe server, in `app/core/vehicles.py`, care respinge
/// orice valoare din afara ei. Sunt sase valori care nu se schimba des; un
/// endpoint care sa le serveasca ar fi mai mult ceremonial decat folos.
///
/// Ordinea de aici e ordinea din selector: de la cel mai des intalnit la cel
/// mai rar.
enum VehicleType {
  car('masina', 'Masina', Icons.directions_car),
  // Scuterele intra tot aici: sunt prea putine ca sa merite o iconita proprie,
  // iar cea cu doua roti le acopera pe amandoua fara sa induca in eroare.
  motorcycle('motocicleta', 'Motocicleta / scuter', Icons.two_wheeler),
  truck('camion', 'Camion', Icons.local_shipping),
  semi('tir', 'TIR', Icons.rv_hookup),
  machinery('utilaj', 'Utilaj', Icons.agriculture),
  other('altul', 'Alt vehicul', Icons.commute);

  const VehicleType(this.value, this.label, this.icon);

  /// Valoarea trimisa serverului. Nu se traduce si nu se schimba.
  final String value;

  /// Ce citeste utilizatorul.
  final String label;

  final IconData icon;

  /// Tipul trimis de server. Orice necunoscut devine masina: in cel mai rau caz
  /// omul vede iconita gresita si o corecteaza, in loc sa ramana lista fara
  /// iconite.
  static VehicleType from(String? value) {
    for (final type in VehicleType.values) {
      if (type.value == value) return type;
    }
    return VehicleType.car;
  }
}
