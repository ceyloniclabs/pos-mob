class ActivityActionOption {
  final String value;
  final String label;

  const ActivityActionOption({
    required this.value,
    required this.label,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityActionOption && value == other.value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => label;
}

class ActivityStaffOption {
  final int id;
  final String name;
  final String email;
  final String role;

  const ActivityStaffOption({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityStaffOption && id == other.id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '$name (${role.toUpperCase()})';
}
