enum BackendProviderType { firebase, laravel }

enum CustomerType {
  local('local'),
  foreigner('foreigner');

  final String value;
  const CustomerType(this.value);
}

enum GenderType {
  male('male'),
  female('female'),
  other('other');

  final String value;
  const GenderType(this.value);
}

enum MembershipLevel {
  bronze('bronze'),
  silver('silver'),
  gold('gold'),
  platinum('platinum');

  final String value;
  const MembershipLevel(this.value);
}

enum RentItemType {
  surfboard('surf_board'),
  accessories('accessories');

  final String value;
  const RentItemType(this.value);
}

enum RentItemStatus {
  available('available'),
  notAvailable('not_available'),
  damage('damage');

  final String value;
  const RentItemStatus(this.value);
}

enum RentalStatus {
  started('started'),
  notStarted('not_started');

  final String value;
  const RentalStatus(this.value);
}

enum RentalEntryStatus {
  pending('pending'),
  returned('returned'),
  damaged('damaged');

  final String value;
  const RentalEntryStatus(this.value);
}

enum RentalEntryUpdateStatus {
  returned('returned'),
  damaged('damaged');

  final String value;
  const RentalEntryUpdateStatus(this.value);
}

enum RepairStatus {
  pending('pending'),
  inProgress('in_progress'),
  completed('completed'),
  cancelled('cancelled');

  final String value;
  const RepairStatus(this.value);
}

enum StaffRole {
  all('all'),
  admin('admin'),
  staff('staff');

  final String value;
  const StaffRole(this.value);
}

enum StaffStatus {
  all('all'),
  active('active'),
  inactive('inactive');

  final String value;
  const StaffStatus(this.value);
}

enum CustomerFilterType {
  all('all'),
  local('local'),
  foreigner('foreigner');

  final String value;
  const CustomerFilterType(this.value);
}

enum MembershipFilterLevel {
  all('all'),
  bronze('bronze'),
  silver('silver'),
  gold('gold'),
  platinum('platinum');

  final String value;
  const MembershipFilterLevel(this.value);
}

enum GiftVoucherStatus {
  all('all'),
  active('active'),
  inactive('inactive');

  final String value;
  const GiftVoucherStatus(this.value);
}

enum PromoCodeStatus {
  all('all'),
  active('active'),
  inactive('inactive');

  final String value;
  const PromoCodeStatus(this.value);
}

enum SurfboardType {
  shortboard('shortboard', 'Shortboard'),
  longboard('longboard', 'Longboard'),
  funboard('funboard', 'Funboard'),
  fish('fish', 'Fish'),
  gun('gun', 'Gun'),
  hybrid('hybrid', 'Hybrid');

  final String value;
  final String label;
  const SurfboardType(this.value, this.label);

  static SurfboardType? fromValue(String? val) {
    if (val == null) return null;
    for (final type in SurfboardType.values) {
      if (type.value.toLowerCase() == val.toLowerCase()) {
        return type;
      }
    }
    return null;
  }
}

