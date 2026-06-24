package com.privacyos.service;
import com.privacyos.dto.response.PrivacyEventResponse;
import com.privacyos.entity.*;
import com.privacyos.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.UUID;

@Service @RequiredArgsConstructor
public class PrivacyEventService {
    private final PrivacyEventRepository eventRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly=true)
    public Page<PrivacyEventResponse> getTimeline(UUID userId,int page,int size){
        return eventRepository.findByUserIdOrderByCreatedAtDesc(userId,PageRequest.of(page,size)).map(this::toResponse);
    }

    @Transactional
    public void recordEvent(UUID userId,String type,UUID entityId,String entityType,String title,String description,EventSeverity severity,Integer scoreBefore,Integer scoreAfter){
        eventRepository.save(PrivacyEvent.builder().user(userRepository.getReferenceById(userId)).eventType(type).entityId(entityId).entityType(entityType).title(title).description(description).severity(severity).scoreBefore(scoreBefore).scoreAfter(scoreAfter).build());
    }

    private PrivacyEventResponse toResponse(PrivacyEvent e){
        return PrivacyEventResponse.builder().id(e.getId()).eventType(e.getEventType()).entityType(e.getEntityType()).title(e.getTitle()).description(e.getDescription()).severity(e.getSeverity()).scoreBefore(e.getScoreBefore()).scoreAfter(e.getScoreAfter()).createdAt(e.getCreatedAt()).build();
    }
}
