package kr.or.koies.schoolzone.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;

@Entity
@Getter @Setter
@Table(name = "tb_notice")
public class Notice {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long noticeId;
    private String title;
    private String content;
    private Long writerId;
    private String writerName;
    private String noticeType;
    private String fixedYn;
    private Integer viewCount;
    private String useYn = "Y";
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
