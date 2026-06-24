package com.privacyos.dto.response;
import lombok.Builder;
import java.util.List;
import java.util.Map;
@Builder
public record GraphResponse(List<GraphNode> nodes,List<GraphEdge> edges){
  @Builder public record GraphNode(String id,String type,String label,String riskLevel,Map<String,Object> data){}
  @Builder public record GraphEdge(String id,String source,String target,String label,String type){}
}
