
class PrivacyScoreData {
  final int score,permissionPenalty,breachPenalty,thirdPartyPenalty,sprawlPenalty,stalenessPenalty;
  final String riskLevel;
  final Map<String,int> breakdown;
  const PrivacyScoreData({required this.score,required this.permissionPenalty,required this.breachPenalty,required this.thirdPartyPenalty,required this.sprawlPenalty,required this.stalenessPenalty,required this.riskLevel,required this.breakdown});
  factory PrivacyScoreData.fromJson(Map<String,dynamic> j) => PrivacyScoreData(score:j['score']??50,permissionPenalty:j['permissionPenalty']??0,breachPenalty:j['breachPenalty']??0,thirdPartyPenalty:j['thirdPartyPenalty']??0,sprawlPenalty:j['sprawlPenalty']??0,stalenessPenalty:j['stalenessPenalty']??0,riskLevel:j['riskLevel']??'MEDIUM',breakdown:Map<String,int>.from((j['breakdown'] as Map? ?? {}).map((k,v)=>MapEntry(k as String,(v as num).toInt()))));
}
