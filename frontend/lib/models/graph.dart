
class GraphNode {
  final String id,type,label,riskLevel;
  final Map<String,dynamic> data;
  const GraphNode({required this.id,required this.type,required this.label,required this.riskLevel,required this.data});
  factory GraphNode.fromJson(Map<String,dynamic> j) => GraphNode(id:j['id']??'',type:j['type']??'',label:j['label']??'',riskLevel:j['riskLevel']??'LOW',data:Map<String,dynamic>.from(j['data']??{}));
}

class GraphEdge {
  final String id,source,target,label,type;
  const GraphEdge({required this.id,required this.source,required this.target,required this.label,required this.type});
  factory GraphEdge.fromJson(Map<String,dynamic> j) => GraphEdge(id:j['id']??'',source:j['source']??'',target:j['target']??'',label:j['label']??'',type:j['type']??'');
}

class GraphData {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  const GraphData({required this.nodes,required this.edges});
  factory GraphData.fromJson(Map<String,dynamic> j) => GraphData(nodes:(j['nodes'] as List? ?? []).map((e)=>GraphNode.fromJson(e)).toList(),edges:(j['edges'] as List? ?? []).map((e)=>GraphEdge.fromJson(e)).toList());
}
