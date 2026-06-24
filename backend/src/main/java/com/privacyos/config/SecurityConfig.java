package com.privacyos.config;
import com.privacyos.security.JwtAuthenticationFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.*;
import org.springframework.security.authentication.*;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.*;
import java.util.*;

@Configuration @EnableWebSecurity @EnableMethodSecurity @RequiredArgsConstructor
public class SecurityConfig {
    private final JwtAuthenticationFilter jwtFilter;
    private final UserDetailsService userDetailsService;
    @Value("${app.cors.allowed-origins}") private String allowedOrigins;

    @Bean public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http.csrf(AbstractHttpConfigurer::disable)
            .cors(c->c.configurationSource(corsConfigurationSource()))
            .sessionManagement(s->s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(a->a
                .requestMatchers("/api/v1/auth/**","/actuator/**").permitAll()
                .anyRequest().authenticated())
            .authenticationProvider(authenticationProvider())
            .addFilterBefore(jwtFilter,UsernamePasswordAuthenticationFilter.class)
            .build();
    }
    @Bean public CorsConfigurationSource corsConfigurationSource(){
        CorsConfiguration c=new CorsConfiguration();
        c.setAllowedOrigins(Arrays.asList(allowedOrigins.split(",")));
        c.setAllowedMethods(List.of("GET","POST","PUT","DELETE","PATCH","OPTIONS"));
        c.setAllowedHeaders(List.of("*"));
        c.setAllowCredentials(true);
        c.setMaxAge(3600L);
        UrlBasedCorsConfigurationSource s=new UrlBasedCorsConfigurationSource();
        s.registerCorsConfiguration("/api/**",c);
        return s;
    }
    @Bean public AuthenticationProvider authenticationProvider(){
        DaoAuthenticationProvider p=new DaoAuthenticationProvider();
        p.setUserDetailsService(userDetailsService);
        p.setPasswordEncoder(passwordEncoder());
        return p;
    }
    @Bean public AuthenticationManager authenticationManager(AuthenticationConfiguration c) throws Exception{return c.getAuthenticationManager();}
    @Bean public PasswordEncoder passwordEncoder(){return new BCryptPasswordEncoder(12);}
}