package kr.or.koies.schoolzone.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Getter @Setter
@Table(name = "tb_school_zone_request")
public class ZoneRequest {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long requestId;
    private String requestNo;
    private String applyNo;
    private String registerType;
    private String registerDetail;
    private String zoneName;
    private String announcedZoneName;
    private String educationOffice;
    private String supportOffice;
    private String schoolLevel;
    private String zoneType;
    private LocalDate registerDate;
    private String effectiveMonth;
    private String progressStatus;
    private Long workerId;
    private String workerName;
    private String departmentName;
    private String managerName;
    private String phoneNumber;
    private String email;
    private String requestContent;
    private String sourceUrl;
    private String workMemo;
    private String reviewMemo;
    private String useYn = "Y";
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
