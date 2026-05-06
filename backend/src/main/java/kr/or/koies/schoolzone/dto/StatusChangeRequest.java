package kr.or.koies.schoolzone.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class StatusChangeRequest {
    @NotBlank
    private String afterStatus;
    private Long changedBy;
    private String changedByName;
    private String changeReason;
}
