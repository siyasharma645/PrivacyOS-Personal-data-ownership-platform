package com.privacyos.security;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.*;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import java.io.IOException;

@Slf4j @Component @RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    private final JwtService jwtService;
    private final UserDetailsService userDetailsService;
    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest req,@NonNull HttpServletResponse res,@NonNull FilterChain chain) throws ServletException,IOException {
        String auth=req.getHeader("Authorization");
        if(auth==null||!auth.startsWith("Bearer ")){chain.doFilter(req,res);return;}
        try{
            String jwt=auth.substring(7);
            String email=jwtService.extractUsername(jwt);
            if(email!=null&&SecurityContextHolder.getContext().getAuthentication()==null){
                UserDetails u=userDetailsService.loadUserByUsername(email);
                if(jwtService.isTokenValid(jwt,u)){
                    UsernamePasswordAuthenticationToken t=new UsernamePasswordAuthenticationToken(u,null,u.getAuthorities());
                    t.setDetails(new WebAuthenticationDetailsSource().buildDetails(req));
                    SecurityContextHolder.getContext().setAuthentication(t);
                }
            }
        }catch(Exception e){log.debug("JWT validation failed: {}",e.getMessage());}
        chain.doFilter(req,res);
    }
}