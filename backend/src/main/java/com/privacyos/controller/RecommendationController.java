package com.privacyos.controller;
import com.privacyos.dto.response.PrivacyRecommendationResponse;
import com.privacyos.entity.User;
import com.privacyos.service.RecommendationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController @RequestMapping("/api/v1/recommendations") @RequiredArgsConstructor
public class RecommendationController {
    private final RecommendationService recommendationService;
    @GetMapping public ResponseEntity<List<PrivacyRecommendationResponse>> list(@AuthenticationPrincipal User u){return ResponseEntity.ok(recommendationService.getRecommendations(u.getId()));}
    @PostMapping("/{id}/complete") public ResponseEntity<PrivacyRecommendationResponse> complete(@PathVariable UUID id,@AuthenticationPrincipal User u){return ResponseEntity.ok(recommendationService.complete(id,u.getId()));}
    @PostMapping("/{id}/dismiss") public ResponseEntity<PrivacyRecommendationResponse> dismiss(@PathVariable UUID id,@AuthenticationPrincipal User u){return ResponseEntity.ok(recommendationService.dismiss(id,u.getId()));}
    @PostMapping("/generate") public ResponseEntity<Void> generate(@AuthenticationPrincipal User u){recommendationService.generateRecommendations(u.getId());return ResponseEntity.ok().build();}
}
