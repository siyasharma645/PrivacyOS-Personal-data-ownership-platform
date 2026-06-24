package com.privacyos.controller;
import com.privacyos.entity.User;
import com.privacyos.service.AiAssistantService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController @RequestMapping("/api/v1/ai") @RequiredArgsConstructor
public class AiController {
    private final AiAssistantService aiService;
    @PostMapping("/chat") public ResponseEntity<Map<String,String>> chat(@AuthenticationPrincipal User u,@RequestBody Map<String,Object> body){
        String msg=(String)body.get("message");
        List<Map<String,String>> history=(List<Map<String,String>>)body.getOrDefault("history",List.of());
        return ResponseEntity.ok(Map.of("response",aiService.chat(u.getId(),msg,history)));
    }
    @PostMapping("/explain/permission/{id}") public ResponseEntity<Map<String,String>> explain(@PathVariable UUID id,@AuthenticationPrincipal User u){
        return ResponseEntity.ok(Map.of("explanation",aiService.explainPermission(u.getId(),id)));
    }
}
