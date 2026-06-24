
class PrivacyEvent {
  final String id,eventType,title,description,severity;
  final String? entityType,createdAt;
  final int? scoreBefore,scoreAfter;
  const PrivacyEvent({required this.id,required this.eventType,required this.title,required this.description,required this.severity,this.entityType,this.createdAt,this.scoreBefore,this.scoreAfter});
  factory PrivacyEvent.fromJson(Map<String,dynamic> j) => PrivacyEvent(id:j['id']??'',eventType:j['eventType']??'',title:j['title']??'',description:j['description']??'',severity:j['severity']??'INFO',entityType:j['entityType'],createdAt:j['createdAt'],scoreBefore:j['scoreBefore'],scoreAfter:j['scoreAfter']);
}

class EventPage {
  final List<PrivacyEvent> content;
  final int totalElements,totalPages,number;
  const EventPage({required this.content,required this.totalElements,required this.totalPages,required this.number});
  factory EventPage.fromJson(Map<String,dynamic> j) => EventPage(content:(j['content'] as List? ?? []).map((e)=>PrivacyEvent.fromJson(e)).toList(),totalElements:j['totalElements']??0,totalPages:j['totalPages']??1,number:j['number']??0);
}
