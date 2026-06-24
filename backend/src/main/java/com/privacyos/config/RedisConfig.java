package com.privacyos.config;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.*;
import org.springframework.data.redis.cache.*;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.*;
import java.time.Duration;
import java.util.*;

@Configuration @EnableCaching
public class RedisConfig {
    @Bean public RedisTemplate<String,Object> redisTemplate(RedisConnectionFactory f){
        RedisTemplate<String,Object> t=new RedisTemplate<>();
        t.setConnectionFactory(f);
        t.setKeySerializer(new StringRedisSerializer());
        t.setHashKeySerializer(new StringRedisSerializer());
        t.setValueSerializer(jsonSerializer());
        t.setHashValueSerializer(jsonSerializer());
        t.afterPropertiesSet();
        return t;
    }
    @Bean public CacheManager cacheManager(RedisConnectionFactory f){
        RedisCacheConfiguration def=RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofMinutes(5))
            .serializeValuesWith(RedisSerializationContext.SerializationPair.fromSerializer(jsonSerializer()));
        Map<String,RedisCacheConfiguration> cfg=new HashMap<>();
        cfg.put("privacy-score",def.entryTtl(Duration.ofMinutes(5)));
        cfg.put("graph",def.entryTtl(Duration.ofMinutes(10)));
        cfg.put("dashboard",def.entryTtl(Duration.ofMinutes(3)));
        return RedisCacheManager.builder(f).cacheDefaults(def).withInitialCacheConfigurations(cfg).build();
    }
    private Jackson2JsonRedisSerializer<Object> jsonSerializer(){
        ObjectMapper m=new ObjectMapper();
        m.registerModule(new JavaTimeModule());
        m.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
        m.activateDefaultTyping(m.getPolymorphicTypeValidator(),ObjectMapper.DefaultTyping.NON_FINAL);
        return new Jackson2JsonRedisSerializer<>(m,Object.class);
    }
}