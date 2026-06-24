package com.privacyos.service;
import com.privacyos.entity.ConnectedAccount;
import com.privacyos.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j @Service @RequiredArgsConstructor
public class AiAssistantService {
    private final UserRepository userRepository;
    private final ConnectedAccountRepository accountRepository;
    private final BreachRecordRepository breachRepository;
    private final PermissionRepository permissionRepository;
    private final WebClient.Builder webClientBuilder;
    @Value("${app.anthropic.api-key}") private String apiKey;
    @Value("${app.anthropic.base-url}") private String baseUrl;
    @Value("${app.anthropic.model}") private String model;

    public String chat(UUID userId,String message,List<Map<String,String>> history){
        String ctx=buildContext(userId);
        List<Map<String,Object>> msgs=new ArrayList<>();
        history.forEach(h->msgs.add(Map.of("role",h.get("role"),"content",h.get("content"))));
        msgs.add(Map.of("role","user","content",message));
        try{
            var res=webClientBuilder.baseUrl(baseUrl).build().post().uri("/messages")
                .header("x-api-key",apiKey).header("anthropic-version","2023-06-01")
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(Map.of("model",model,"max_tokens",1024,"system",buildSystemPrompt(ctx),"messages",msgs))
                .retrieve().bodyToMono(Map.class).block();
            if(res!=null&&res.containsKey("content")){
                var content=(List<Map<String,Object>>)res.get("content");
                if(!content.isEmpty())return (String)content.get(0).get("text");
            }
        }catch(Exception e){log.warn("Anthropic API failed: {}",e.getMessage());}
        return getFallback(message,userId);
    }

    public String explainPermission(UUID userId,UUID permId){
        var p=permissionRepository.findById(permId).orElse(null);
        if(p==null)return "Permission not found.";
        return chat(userId,"Explain this permission in plain English for a non-technical user: Scope="+p.getScopeName()+", Provider="+p.getAccount().getProvider()+", Description="+p.getDescription()+" Keep it under 100 words.",List.of());
    }

    private String buildContext(UUID userId){
        try{
            var u=userRepository.findById(userId).orElseThrow();
            var accts=accountRepository.findByUserIdOrderByCreatedAtDesc(userId).stream().map(ConnectedAccount::getProvider).collect(Collectors.joining(", "));
            long b=breachRepository.countByUserIdAndRemediatedAtIsNull(userId);
            var hr=permissionRepository.findByAccountUserIdAndRiskLevelOrderByRiskLevelDesc(userId,com.privacyos.entity.RiskLevel.HIGH);
            return String.format("User: %s | Score: %d/100 (%s) | Accounts: %s | Breaches: %d | High-risk perms: %d",u.getEmail(),u.getPrivacyScore(),u.getRiskLevel(),accts.isEmpty()?"none":accts,b,hr.size());
        }catch(Exception e){return "Score: unknown";}
    }

    private String buildSystemPrompt(String ctx){return "You are PrivacyOS Assistant, an expert AI privacy advisor. Help users understand their digital privacy, explain permissions in plain language, and give actionable advice.\n\nUser context: "+ctx+"\n\nBe concise (under 200 words). Ground answers in the user's actual data.";}

    private String getFallback(String msg,UUID userId){
        String lower=msg.toLowerCase();
        try{
            var u=userRepository.findById(userId).orElseThrow();
            long b=breachRepository.countByUserIdAndRemediatedAtIsNull(userId);
            if(lower.contains("score")||lower.contains("risk"))return String.format("Your privacy score is **%d/100** (%s risk). You have %d unresolved breach%s. Review your high-risk permissions to improve your score.",u.getPrivacyScore(),u.getRiskLevel(),b,b==1?"":"es");
            if(lower.contains("breach"))return String.format("You have **%d unresolved breach%s**. For each breach, change your password and enable 2FA immediately.",b,b==1?"":"es");
        }catch(Exception ignored){}
        return "I'm here to help with your privacy! Ask me about your privacy score, connected accounts, permissions, breaches, or general privacy best practices.";
    }
}
