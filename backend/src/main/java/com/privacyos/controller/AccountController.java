package com.privacyos.controller;
import com.privacyos.dto.response.*;
import com.privacyos.entity.User;
import com.privacyos.service.AccountService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController @RequestMapping("/api/v1/accounts") @RequiredArgsConstructor
public class AccountController {
    private final AccountService accountService;
    @GetMapping public ResponseEntity<List<ConnectedAccountResponse>> list(@AuthenticationPrincipal User u){return ResponseEntity.ok(accountService.getAccounts(u.getId()));}
    @GetMapping("/{id}") public ResponseEntity<ConnectedAccountResponse> get(@PathVariable UUID id,@AuthenticationPrincipal User u){return ResponseEntity.ok(accountService.getAccount(id,u.getId()));}
    @DeleteMapping("/{id}") public ResponseEntity<Void> disconnect(@PathVariable UUID id,@AuthenticationPrincipal User u){accountService.disconnectAccount(id,u.getId());return ResponseEntity.noContent().build();}
    @PostMapping("/{id}/sync") public ResponseEntity<ConnectedAccountResponse> sync(@PathVariable UUID id,@AuthenticationPrincipal User u){return ResponseEntity.ok(accountService.syncAccount(id,u.getId()));}
    @GetMapping("/{id}/permissions") public ResponseEntity<List<PermissionResponse>> perms(@PathVariable UUID id,@AuthenticationPrincipal User u){return ResponseEntity.ok(accountService.getPermissions(id,u.getId()));}
    @DeleteMapping("/permissions/{pid}") public ResponseEntity<Void> revoke(@PathVariable UUID pid,@AuthenticationPrincipal User u){accountService.revokePermission(pid,u.getId());return ResponseEntity.noContent().build();}
}
