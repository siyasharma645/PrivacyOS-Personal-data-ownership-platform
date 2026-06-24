
class PrivacyRecommendation {
  final String id,type,priority,title,description,status,actionLabel;
  final String? actionUrl,relatedAccountId,relatedAccountProvider,createdAt;
  final int expectedScoreImprovement;
  const PrivacyRecommendation({required this.id,required this.type,required this.priority,required this.title,required this.description,required this.status,required this.actionLabel,this.actionUrl,this.relatedAccountId,this.relatedAccountProvider,this.createdAt,required this.expectedScoreImprovement});
  factory PrivacyRecommendation.fromJson(Map<String,dynamic> j) => PrivacyRecommendation(id:j['id']??'',type:j['type']??'',priority:j['priority']??'MEDIUM',title:j['title']??'',description:j['description']??'',status:j['status']??'PENDING',actionLabel:j['actionLabel']??'Take Action',actionUrl:j['actionUrl'],relatedAccountId:j['relatedAccountId'],relatedAccountProvider:j['relatedAccountProvider'],createdAt:j['createdAt'],expectedScoreImprovement:j['expectedScoreImprovement']??0);
}
