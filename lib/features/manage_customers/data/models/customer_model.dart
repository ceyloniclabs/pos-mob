import 'package:pos/features/manage_customers/domain/entities/customer.dart';

class CustomerModel extends Customer {
  CustomerModel({
    super.id,
    required super.countryId,
    required super.name,
    required super.phone,
    required super.email,
    super.address,
    super.profilePhoto,
    required super.customerType,
    required super.gender,
    super.nic,
    super.passportId,
    super.documentPhotoUrl,
    required super.membershipLevel,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        id: json['id'] is int
            ? json['id']
            : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
        countryId: json['country_id'] is int
            ? json['country_id']
            : (json['country_id'] != null
                ? (int.tryParse(json['country_id'].toString()) ?? 0)
                : 0),
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        address: json['address'],
        profilePhoto: json['profile_photo'],
        customerType: json['customer_type'] ?? '',
        gender: json['gender'] ?? '',
        nic: json['nic'],
        passportId: json['passport_id'],
        documentPhotoUrl: json['document_photo_url'],
        membershipLevel: json['membership_level'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'country_id': countryId,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'profile_photo': profilePhoto,
        'customer_type': customerType,
        'gender': gender,
        'nic': nic,
        'passport_id': passportId,
        'document_photo_url': documentPhotoUrl,
        'membership_level': membershipLevel,
      };

  CustomerModel copyWith({
    int? id,
    int? countryId,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? profilePhoto,
    String? customerType,
    String? gender,
    String? nic,
    String? passportId,
    String? documentPhotoUrl,
    String? membershipLevel,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      countryId: countryId ?? this.countryId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      customerType: customerType ?? this.customerType,
      gender: gender ?? this.gender,
      nic: nic ?? this.nic,
      passportId: passportId ?? this.passportId,
      documentPhotoUrl: documentPhotoUrl ?? this.documentPhotoUrl,
      membershipLevel: membershipLevel ?? this.membershipLevel,
    );
  }
}
