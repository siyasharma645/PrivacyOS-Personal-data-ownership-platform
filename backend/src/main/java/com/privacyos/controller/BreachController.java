package com.privacyos.controller;
import com.privacyos.dto.response.BreachRecordResponse;
import com.privacyos.entity.User;
import com.privacyos.service.BreachService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController @RequestMapping("/api/v1/breaches") @RequiredArgsConstructor
public class BreachController {
    private final BreachService breachService;
    @GetMapping public ResponseEntity<List<BreachRecordResponse>> list(@AuthenticationPrincipal User u){return ResponseEntity.ok(breachService.getBreaches(u.getId()));}
    @PostMapping("/check") public ResponseEntity<List<BreachRecordResponse>> check(@AuthenticationPrincipal User u){return ResponseEntity.ok(breachService.checkBreaches(u.getId()));}
    @PostMapping("/{id}/remediate") public ResponseEntity<BreachRecordResponse> remediate(@PathVariable UUID id,@AuthenticationPrincipal User u){return ResponseEntity.ok(breachService.markRemediated(id,u.getId()));}
}
