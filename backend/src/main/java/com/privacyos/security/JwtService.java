package com.privacyos.security;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;
import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.function.Function;

@Slf4j @Component
public class JwtService {
    @Value("${jwt.secret}") private String secret;
    @Value("${jwt.expiration}") private long expiration;
    private SecretKey getSigningKey(){
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }
    public String generateToken(UserDetails u){return generateToken(new HashMap<>(),u);}
    public String generateToken(Map<String,Object> extra,UserDetails u){
        return Jwts.builder().claims(extra).subject(u.getUsername())
            .issuedAt(new Date()).expiration(new Date(System.currentTimeMillis()+expiration))
            .signWith(getSigningKey()).compact();
    }
    public boolean isTokenValid(String token,UserDetails u){
        return extractUsername(token).equals(u.getUsername())&&!isTokenExpired(token);}
    public String extractUsername(String token){return extractClaim(token,Claims::getSubject);}
    public <T> T extractClaim(String token,Function<Claims,T> fn){return fn.apply(extractAllClaims(token));}
    private boolean isTokenExpired(String token){return extractClaim(token,Claims::getExpiration).before(new Date());}
    private Claims extractAllClaims(String token){
        return Jwts.parser().verifyWith(getSigningKey()).build().parseSignedClaims(token).getPayload();}
}