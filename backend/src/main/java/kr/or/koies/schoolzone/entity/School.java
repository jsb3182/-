package kr.or.koies.schoolzone.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Getter @Setter
@Table(name = "tb_school")
public class School {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long schoolId;
    private String schoolCode;
    private String schoolName;
    private String schoolLevel;
    private String establishType;
    private String operationStatus;
    private String educationOffice;
    private String supportOffice;
    private String roadAddress;
    private String jibunAddress;

    /** EPSG:5186 X 좌표입니다. 미터 단위 좌표로 저장합니다. */
    private BigDecimal xCoord;

    /** EPSG:5186 Y 좌표입니다. 미터 단위 좌표로 저장합니다. */
    private BigDecimal yCoord;

    /**
     * geom은 PostGIS에서 직접 관리합니다.
     * JPA에서 Geometry 타입 매핑이 필요하면 Hibernate Spatial + JTS Point로 확장하세요.
     */
    private String useYn = "Y";
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
