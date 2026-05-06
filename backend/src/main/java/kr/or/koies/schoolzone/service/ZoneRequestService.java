package kr.or.koies.schoolzone.service;

import kr.or.koies.schoolzone.dto.StatusChangeRequest;
import kr.or.koies.schoolzone.entity.RequestStatusHistory;
import kr.or.koies.schoolzone.entity.ZoneRequest;
import kr.or.koies.schoolzone.repository.RequestStatusHistoryRepository;
import kr.or.koies.schoolzone.repository.ZoneRequestRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class ZoneRequestService {
    private final ZoneRequestRepository zoneRequestRepository;
    private final RequestStatusHistoryRepository historyRepository;

    public Page<ZoneRequest> findAll(Pageable pageable) {
        return zoneRequestRepository.findAll(pageable);
    }

    public ZoneRequest findById(Long id) {
        return zoneRequestRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("학구 변경 요청을 찾을 수 없습니다."));
    }

    public ZoneRequest save(ZoneRequest request) {
        if (request.getProgressStatus() == null) request.setProgressStatus("등록");
        return zoneRequestRepository.save(request);
    }

    @Transactional
    public ZoneRequest changeStatus(Long requestId, StatusChangeRequest statusRequest) {
        ZoneRequest target = findById(requestId);
        String before = target.getProgressStatus();
        target.setProgressStatus(statusRequest.getAfterStatus());

        RequestStatusHistory history = new RequestStatusHistory();
        history.setRequestId(requestId);
        history.setBeforeStatus(before);
        history.setAfterStatus(statusRequest.getAfterStatus());
        history.setChangedBy(statusRequest.getChangedBy());
        history.setChangedByName(statusRequest.getChangedByName());
        history.setChangeReason(statusRequest.getChangeReason());
        history.setCreatedAt(LocalDateTime.now());
        historyRepository.save(history);

        return target;
    }
}
