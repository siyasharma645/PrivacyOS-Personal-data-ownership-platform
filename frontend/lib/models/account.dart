
class Permission {
  final String id,accountId,scopeName,displayName,description,riskLevel,category;
  final List<String> dataTypes;
  final bool revocable,sensitive;
  final String grantedAt;
  const Permission({required this.id,required this.accountId,required this.scopeName,required this.displayName,required this.description,required this.riskLevel,required this.category,required this.dataTypes,required this.revocable,required this.sensitive,required this.grantedAt});
  factory Permission.fromJson(Map<String,dynamic> j) => Permission(id:j['id']??'',accountId:j['accountId']??'',scopeName:j['scopeName']??'',displayName:j['displayName']??'',description:j['description']??'',riskLevel:j['riskLevel']??'LOW',category:j['category']??'',dataTypes:List<String>.from(j['dataTypes']??[]),revocable:j['revocable']??true,sensitive:j['sensitive']??false,grantedAt:j['grantedAt']??'');
}

class ConnectedAccount {
  final String id,provider,providerEmail,displayName,status;
  final String? avatarUrl;
  final int riskContribution,permissionCount,highRiskCount;
  final List<String> scopes;
  final List<Permission> permissions;
  final String? lastSyncedAt,createdAt;
  const ConnectedAccount({required this.id,required this.provider,required this.providerEmail,required this.displayName,required this.status,this.avatarUrl,required this.riskContribution,required this.permissionCount,required this.highRiskCount,required this.scopes,required this.permissions,this.lastSyncedAt,this.createdAt});
  factory ConnectedAccount.fromJson(Map<String,dynamic> j) => ConnectedAccount(id:j['id']??'',provider:j['provider']??'',providerEmail:j['providerEmail']??'',displayName:j['displayName']??'',status:j['status']??'ACTIVE',avatarUrl:j['avatarUrl'],riskContribution:j['riskContribution']??0,permissionCount:j['permissionCount']??0,highRiskCount:j['highRiskCount']??0,scopes:List<String>.from(j['scopes']??[]),permissions:(j['permissions'] as List? ?? []).map((e)=>Permission.fromJson(e)).toList(),lastSyncedAt:j['lastSyncedAt'],createdAt:j['createdAt']);
}
