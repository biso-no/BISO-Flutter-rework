import 'package:equatable/equatable.dart';

class ValidationResultModel extends Equatable {
  final bool ok;
  final String result; // 'VALID' or 'INVALID'
  final MemberInfo? member;
  final ValidationMeta? meta;
  final String? error;
  final String? code;

  const ValidationResultModel({
    required this.ok,
    required this.result,
    this.member,
    this.meta,
    this.error,
    this.code,
  });

  factory ValidationResultModel.fromJson(Map<String, dynamic> json) {
    return ValidationResultModel(
      ok: json['ok'] as bool,
      result: json['result'] as String? ?? 'INVALID',
      member: json['member'] != null
          ? MemberInfo.fromJson(json['member'] as Map<String, dynamic>)
          : null,
      meta: json['meta'] != null
          ? ValidationMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
      error: json['error'] as String?,
      code: json['code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ok': ok,
      'result': result,
      if (member != null) 'member': member!.toJson(),
      if (meta != null) 'meta': meta!.toJson(),
      if (error != null) 'error': error,
      if (code != null) 'code': code,
    };
  }

  ValidationResultModel copyWith({
    bool? ok,
    String? result,
    MemberInfo? member,
    ValidationMeta? meta,
    String? error,
    String? code,
  }) {
    return ValidationResultModel(
      ok: ok ?? this.ok,
      result: result ?? this.result,
      member: member ?? this.member,
      meta: meta ?? this.meta,
      error: error ?? this.error,
      code: code ?? this.code,
    );
  }

  @override
  List<Object?> get props => [ok, result, member, meta, error, code];
}

class MemberInfo extends Equatable {
  final String displayName;
  final String? photoUrl;
  final String membershipName;
  final String? expiresAt;

  const MemberInfo({
    required this.displayName,
    this.photoUrl,
    required this.membershipName,
    this.expiresAt,
  });

  factory MemberInfo.fromJson(Map<String, dynamic> json) {
    return MemberInfo(
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      membershipName: json['membershipName'] as String,
      expiresAt: json['expiresAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'membershipName': membershipName,
      if (expiresAt != null) 'expiresAt': expiresAt,
    };
  }

  MemberInfo copyWith({
    String? displayName,
    String? photoUrl,
    String? membershipName,
    String? expiresAt,
  }) {
    return MemberInfo(
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      membershipName: membershipName ?? this.membershipName,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  List<Object?> get props => [displayName, photoUrl, membershipName, expiresAt];
}

class ValidationMeta extends Equatable {
  final String checkedAt;
  final String tokenExp;
  final String jti;

  const ValidationMeta({
    required this.checkedAt,
    required this.tokenExp,
    required this.jti,
  });

  factory ValidationMeta.fromJson(Map<String, dynamic> json) {
    return ValidationMeta(
      checkedAt: json['checkedAt'] as String,
      tokenExp: json['tokenExp'] as String,
      jti: json['jti'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'checkedAt': checkedAt, 'tokenExp': tokenExp, 'jti': jti};
  }

  ValidationMeta copyWith({String? checkedAt, String? tokenExp, String? jti}) {
    return ValidationMeta(
      checkedAt: checkedAt ?? this.checkedAt,
      tokenExp: tokenExp ?? this.tokenExp,
      jti: jti ?? this.jti,
    );
  }

  @override
  List<Object?> get props => [checkedAt, tokenExp, jti];
}
