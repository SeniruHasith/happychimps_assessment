// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num).toInt(),
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  email: json['email'] as String,
  phoneNumber: json['phone_number'] as String,
  sessionTime: json['session_time'] as String?,
  role: json['role'] as List<dynamic>,
  companyId: (json['company_id'] as num?)?.toInt(),
  companyPermissions:
      (json['company_permission'] as List<dynamic>)
          .map((e) => CompanyPermission.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'email': instance.email,
  'phone_number': instance.phoneNumber,
  'session_time': instance.sessionTime,
  'role': instance.role,
  'company_id': instance.companyId,
  'company_permission': instance.companyPermissions,
};

CompanyPermission _$CompanyPermissionFromJson(Map<String, dynamic> json) =>
    CompanyPermission(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      permissions:
          (json['permissions'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
    );

Map<String, dynamic> _$CompanyPermissionToJson(CompanyPermission instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'permissions': instance.permissions,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  accessToken: json['access_token'] as String,
  tokenType: json['token_type'] as String,
  user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
  company:
      (json['company'] as List<dynamic>)
          .map((e) => Company.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'user': instance.user,
      'company': instance.company,
    };

Company _$CompanyFromJson(Map<String, dynamic> json) => Company(
  id: (json['id'] as num).toInt(),
  companyName: json['company_name'] as String,
  companyEmail: json['company_email'] as String,
  phone: Phone.fromJson(json['phone'] as Map<String, dynamic>),
  registrationNo: json['registration_no'] as String,
  businessName: json['business_name'] as String,
  currency: Currency.fromJson(json['currency'] as Map<String, dynamic>),
  country: Country.fromJson(json['country'] as Map<String, dynamic>),
  logo: json['logo'] as String,
  receiptLogo: json['receipt_logo'] as String,
);

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
  'id': instance.id,
  'company_name': instance.companyName,
  'company_email': instance.companyEmail,
  'phone': instance.phone,
  'registration_no': instance.registrationNo,
  'business_name': instance.businessName,
  'currency': instance.currency,
  'country': instance.country,
  'logo': instance.logo,
  'receipt_logo': instance.receiptLogo,
};

Phone _$PhoneFromJson(Map<String, dynamic> json) => Phone(
  primary: json['primary'] as String,
  business: json['business'] as String,
);

Map<String, dynamic> _$PhoneToJson(Phone instance) => <String, dynamic>{
  'primary': instance.primary,
  'business': instance.business,
};

Currency _$CurrencyFromJson(Map<String, dynamic> json) => Currency(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  code: json['code'] as String,
  symbol: json['symbol'] as String,
);

Map<String, dynamic> _$CurrencyToJson(Currency instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'code': instance.code,
  'symbol': instance.symbol,
};

Country _$CountryFromJson(Map<String, dynamic> json) => Country(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  code: json['code'] as String,
  regionId: (json['region_id'] as num).toInt(),
  countryCode: json['country_code'] as String,
);

Map<String, dynamic> _$CountryToJson(Country instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'code': instance.code,
  'region_id': instance.regionId,
  'country_code': instance.countryCode,
};
