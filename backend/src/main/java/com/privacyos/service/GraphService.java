package com.privacyos.service;
import com.privacyos.dto.response.GraphResponse;
import com.privacyos.entity.*;
import com.privacyos.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.*;

@Service @RequiredArgsConstructor
public class GraphService {
    private final UserRepository userRepository;
    private final ConnectedAccountRepository accountRepository;

    @Cacheable(value="graph",key="#userId")
    @Transactional(readOnly=true)
    public GraphResponse buildGraph(UUID userId){
        User user=userRepository.findById(userId).orElseThrow();
        var accounts=accountRepository.findByUserIdOrderByCreatedAtDesc(userId);
        List<GraphResponse.GraphNode> nodes=new ArrayList<>();
        List<GraphResponse.GraphEdge> edges=new ArrayList<>();
        String uid="user-"+userId;
        nodes.add(GraphResponse.GraphNode.builder().id(uid).type("USER").label(user.getFullName()!=null?user.getFullName():user.getEmail()).riskLevel(user.getRiskLevel().name()).data(Map.of("email",user.getEmail(),"score",user.getPrivacyScore())).build());
        Set<String> cats=new HashSet<>();
        for(var a:accounts){
            String aid="account-"+a.getId();
            nodes.add(GraphResponse.GraphNode.builder().id(aid).type("ACCOUNT").label(a.getProvider()).riskLevel(a.getRiskContribution()>=15?"HIGH":a.getRiskContribution()>=8?"MEDIUM":"LOW").data(Map.of("provider",a.getProvider(),"email",a.getProviderEmail()!=null?a.getProviderEmail():"","status",a.getStatus(),"permCount",a.getPermissions().size())).build());
            edges.add(GraphResponse.GraphEdge.builder().id("e-user-"+a.getId()).source(uid).target(aid).label("CONNECTED_TO").type("connection").build());
            for(var p:a.getPermissions().stream().filter(pp->pp.getRevokedAt()==null).toList()){
                String pid="perm-"+p.getId();
                nodes.add(GraphResponse.GraphNode.builder().id(pid).type("PERMISSION").label(p.getDisplayName()!=null?p.getDisplayName():p.getScopeName()).riskLevel(p.getRiskLevel().name()).data(Map.of("scope",p.getScopeName(),"category",p.getCategory()!=null?p.getCategory():"","sensitive",p.isSensitive())).build());
                edges.add(GraphResponse.GraphEdge.builder().id("e-ap-"+p.getId()).source(aid).target(pid).label("HAS_PERMISSION").type("permission").build());
                if(p.getDataTypes()!=null)for(var dt:p.getDataTypes()){
                    String cid="cat-"+dt.replaceAll("\\s+","_").toLowerCase();
                    if(cats.add(cid))nodes.add(GraphResponse.GraphNode.builder().id(cid).type("DATA_CATEGORY").label(dt).riskLevel("LOW").data(Map.of("type",dt)).build());
                    edges.add(GraphResponse.GraphEdge.builder().id("e-pc-"+p.getId()+"-"+cid).source(pid).target(cid).label("EXPOSES").type("exposure").build());
                }
            }
        }
        return GraphResponse.builder().nodes(nodes).edges(edges).build();
    }
}
