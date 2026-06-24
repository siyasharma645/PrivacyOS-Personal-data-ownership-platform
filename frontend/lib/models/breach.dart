
class BreachRecord {
  final String id,breachName,title;
  final String? domain,breachDate,description,logoPath;
  final List<String> dataClasses;
  final int? pwnCount;
  final bool verified,sensitive,remediated;
  final String createdAt;
  const BreachRecord({required this.id,required this.breachName,required this.title,this.domain,this.breachDate,this.description,this.logoPath,required this.dataClasses,this.pwnCount,required this.verified,required this.sensitive,required this.remediated,required this.createdAt});
  factory BreachRecord.fromJson(Map<String,dynamic> j) => BreachRecord(id:j['id']??'',breachName:j['breachName']??'',title:j['title']??'',domain:j['domain'],breachDate:j['breachDate'],description:j['description'],logoPath:j['logoPath'],dataClasses:List<String>.from(j['dataClasses']??[]),pwnCount:j['pwnCount'],verified:j['verified']??true,sensitive:j['sensitive']??false,remediated:j['remediated']??false,createdAt:j['createdAt']??'');
}
