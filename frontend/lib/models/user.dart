
class User {
  final String id, email, fullName, riskLevel, provider, role;
  final String? avatarUrl;
  final bool emailVerified;
  final int privacyScore;
  final String createdAt;
  const User({required this.id,required this.email,required this.fullName,required this.riskLevel,required this.provider,required this.role,this.avatarUrl,required this.emailVerified,required this.privacyScore,required this.createdAt});
  factory User.fromJson(Map<String,dynamic> j) => User(id:j['id']??'',email:j['email']??'',fullName:j['fullName']??'',riskLevel:j['riskLevel']??'MEDIUM',provider:j['provider']??'LOCAL',role:j['role']??'USER',avatarUrl:j['avatarUrl'],emailVerified:j['emailVerified']??false,privacyScore:j['privacyScore']??50,createdAt:j['createdAt']??'');
}

class AuthResponse {
  final String accessToken, refreshToken, tokenType;
  final int expiresIn;
  final User user;
  const AuthResponse({required this.accessToken,required this.refreshToken,required this.tokenType,required this.expiresIn,required this.user});
  factory AuthResponse.fromJson(Map<String,dynamic> j) => AuthResponse(accessToken:j['accessToken']??'',refreshToken:j['refreshToken']??'',tokenType:j['tokenType']??'Bearer',expiresIn:j['expiresIn']??86400,user:User.fromJson(j['user']??{}));
}
