package com.privacyos.controller;
import com.privacyos.dto.response.GraphResponse;
import com.privacyos.entity.User;
import com.privacyos.service.GraphService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController @RequestMapping("/api/v1/graph") @RequiredArgsConstructor
public class GraphController {
    private final GraphService graphService;
    @GetMapping public ResponseEntity<GraphResponse> get(@AuthenticationPrincipal User u){return ResponseEntity.ok(graphService.buildGraph(u.getId()));}
}
