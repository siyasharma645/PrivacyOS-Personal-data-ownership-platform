package com.privacyos.controller;
import com.privacyos.dto.response.*;
import com.privacyos.entity.User;
import com.privacyos.service.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController @RequestMapping("/api/v1/dashboard") @RequiredArgsConstructor
public class DashboardController {
    private final DashboardService dashboardService;
    private final PrivacyScoreService scoreService;
    @GetMapping public ResponseEntity<DashboardResponse> get(@AuthenticationPrincipal User u){return ResponseEntity.ok(dashboardService.getDashboard(u.getId()));}
    @GetMapping("/score") public ResponseEntity<PrivacyScoreResponse> score(@AuthenticationPrincipal User u){return ResponseEntity.ok(scoreService.getScore(u.getId()));}
    @PostMapping("/score/recalculate") public ResponseEntity<PrivacyScoreResponse> recalc(@AuthenticationPrincipal User u){scoreService.recalculateAndPersist(u.getId());return ResponseEntity.ok(scoreService.getScore(u.getId()));}
}
