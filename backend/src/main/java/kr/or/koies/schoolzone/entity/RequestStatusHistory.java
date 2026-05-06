package kr.or.koies.schoolzone.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;

@Entity
@Getter @Setter
@Table(name = "tb_request_status_history")
public class RequestStatusHistory {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long historyId;
    private Long requestId;
    private String beforeStatus;
    private String afterStatus;
    private Long changedBy;
    private String changedByName;
    private String changeReason;
    private LocalDateTime createdAt;
}
