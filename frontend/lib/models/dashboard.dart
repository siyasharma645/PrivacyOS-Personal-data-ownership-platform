
class ScoreDataPoint {
  final String date; final int score;
  const ScoreDataPoint({required this.date,required this.score});
  factory ScoreDataPoint.fromJson(Map<String,dynamic> j) => ScoreDataPoint(date:j['date']??'',score:j['score']??0);
}

class DashboardData {
  final int privacyScore,previousScore,scoreChange;
  final String riskLevel;
  final int connectedAccounts,activePermissions,highRiskPermissions,unresolvedBreaches,pendingRecommendations;
  final List<ScoreDataPoint> scoreHistory;
  const DashboardData({required this.privacyScore,required this.previousScore,required this.scoreChange,required this.riskLevel,required this.connectedAccounts,required this.activePermissions,required this.highRiskPermissions,required this.unresolvedBreaches,required this.pendingRecommendations,required this.scoreHistory});
  factory DashboardData.fromJson(Map<String,dynamic> j) => DashboardData(
    privacyScore:j['privacyScore']??50,previousScore:j['previousScore']??50,scoreChange:j['scoreChange']??0,
    riskLevel:j['riskLevel']??'MEDIUM',connectedAccounts:j['connectedAccounts']??0,
    activePermissions:j['activePermissions']??0,highRiskPermissions:j['highRiskPermissions']??0,
    unresolvedBreaches:j['unresolvedBreaches']??0,pendingRecommendations:j['pendingRecommendations']??0,
    scoreHistory:(j['scoreHistory'] as List? ?? []).map((e)=>ScoreDataPoint.fromJson(e)).toList());
}
