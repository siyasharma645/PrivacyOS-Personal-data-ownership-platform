package com.privacyos.service;
import com.privacyos.dto.response.BreachRecordResponse;
import com.privacyos.entity.*;
import com.privacyos.exception.NotFoundException;
import com.privacyos.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.*;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Service @RequiredArgsConstructor
public class BreachService {
    private final BreachRecordRepository breachRepository;
    private final UserRepository userRepository;
    private final PrivacyEventService eventService;
    private final PrivacyScoreService scoreService;

    @Transactional(readOnly=true)
    public List<BreachRecordResponse> getBreaches(UUID userId){return breachRepository.findByUserIdOrderByBreachDateDesc(userId).stream().map(this::toResponse).collect(Collectors.toList());}

    @Transactional
    public BreachRecordResponse markRemediated(UUID id,UUID userId){
        var b=breachRepository.findById(id).filter(br->br.getUser().getId().equals(userId)).orElseThrow(()->new NotFoundException("Breach not found"));
        b.setRemediatedAt(Instant.now());breachRepository.save(b);scoreService.recalculateAndPersist(userId);return toResponse(b);
    }

    @Transactional
    public List<BreachRecordResponse> checkBreaches(UUID userId){
        User user=userRepository.findById(userId).orElseThrow();
        if(breachRepository.findByUserIdOrderByBreachDateDesc(userId).isEmpty()){
            var demo=BreachRecord.builder().user(user).breachName("DemoService").title("Demo Service").domain("demoservice.com").breachDate(LocalDate.of(2023,3,15)).dataClasses(new String[]{"Email addresses","Usernames","Passwords"}).pwnCount(1500000L).description("A demo breach for testing purposes.").verified(true).build();
            breachRepository.save(demo);
            eventService.recordEvent(userId,"BREACH_DETECTED",demo.getId(),"breach_record","New Breach Found: "+demo.getTitle(),"Your email was found in the "+demo.getTitle()+" data breach",EventSeverity.CRITICAL,null,null);
            scoreService.recalculateAndPersist(userId);
        }
        return getBreaches(userId);
    }

    public BreachRecordResponse toResponse(BreachRecord b){return BreachRecordResponse.builder().id(b.getId()).breachName(b.getBreachName()).title(b.getTitle()).domain(b.getDomain()).breachDate(b.getBreachDate()).dataClasses(b.getDataClasses()).pwnCount(b.getPwnCount()).description(b.getDescription()).logoPath(b.getLogoPath()).verified(b.isVerified()).sensitive(b.isSensitive()).remediated(b.getRemediatedAt()!=null).createdAt(b.getCreatedAt()).build();}
}
