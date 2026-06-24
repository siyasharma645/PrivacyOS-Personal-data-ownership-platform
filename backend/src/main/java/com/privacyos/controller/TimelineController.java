package com.privacyos.controller;
import com.privacyos.dto.response.PrivacyEventResponse;
import com.privacyos.entity.User;
import com.privacyos.service.PrivacyEventService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController @RequestMapping("/api/v1/timeline") @RequiredArgsConstructor
public class TimelineController {
    private final PrivacyEventService eventService;
    @GetMapping public ResponseEntity<Page<PrivacyEventResponse>> get(@AuthenticationPrincipal User u,@RequestParam(defaultValue="0")int page,@RequestParam(defaultValue="20")int size){return ResponseEntity.ok(eventService.getTimeline(u.getId(),page,size));}
}
