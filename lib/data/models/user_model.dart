import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String email;
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  @JsonKey(name: 'session_time')
  final String? sessionTime;
  final List<dynamic> role;
  @JsonKey(name: 'company_id')
  final int? companyId;
  @JsonKey(name: 'company_permission')
  final List<CompanyPermission> companyPermissions;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.sessionTime,
    required this.role,
    this.companyId,
    required this.companyPermissions,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

@JsonSerializable()
class CompanyPermission {
  final int id;
  final String name;
  final List<String> permissions;

  CompanyPermission({
    required this.id,
    required this.name,
    required this.permissions,
  });

  factory CompanyPermission.fromJson(Map<String, dynamic> json) =>
      _$CompanyPermissionFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyPermissionToJson(this);
}

@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'token_type')
  final String tokenType;
  final UserModel user;
  final List<Company> company;

  AuthResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
    required this.company,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class Company {
  final int id;
  @JsonKey(name: 'company_name')
  final String companyName;
  @JsonKey(name: 'company_email')
  final String companyEmail;
  final Phone phone;
  @JsonKey(name: 'registration_no')
  final String registrationNo;
  @JsonKey(name: 'business_name')
  final String businessName;
  final Currency currency;
  final Country country;
  final String logo;
  @JsonKey(name: 'receipt_logo')
  final String receiptLogo;

  Company({
    required this.id,
    required this.companyName,
    required this.companyEmail,
    required this.phone,
    required this.registrationNo,
    required this.businessName,
    required this.currency,
    required this.country,
    required this.logo,
    required this.receiptLogo,
  });

  factory Company.fromJson(Map<String, dynamic> json) =>
      _$CompanyFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyToJson(this);
}

@JsonSerializable()
class Phone {
  final String primary;
  final String business;

  Phone({
    required this.primary,
    required this.business,
  });

  factory Phone.fromJson(Map<String, dynamic> json) =>
      _$PhoneFromJson(json);

  Map<String, dynamic> toJson() => _$PhoneToJson(this);
}

@JsonSerializable()
class Currency {
  final int id;
  final String name;
  final String code;
  final String symbol;

  Currency({
    required this.id,
    required this.name,
    required this.code,
    required this.symbol,
  });

  factory Currency.fromJson(Map<String, dynamic> json) =>
      _$CurrencyFromJson(json);

  Map<String, dynamic> toJson() => _$CurrencyToJson(this);
}

@JsonSerializable()
class Country {
  final int id;
  final String name;
  final String code;
  @JsonKey(name: 'region_id')
  final int regionId;
  @JsonKey(name: 'country_code')
  final String countryCode;

  Country({
    required this.id,
    required this.name,
    required this.code,
    required this.regionId,
    required this.countryCode,
  });

  factory Country.fromJson(Map<String, dynamic> json) =>
      _$CountryFromJson(json);

  Map<String, dynamic> toJson() => _$CountryToJson(this);
} 