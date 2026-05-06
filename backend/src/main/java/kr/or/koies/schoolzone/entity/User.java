package kr.or.koies.schoolzone.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;

@Entity
@Getter @Setter
@Table(name = "tb_user")
public class User {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long userId;
    private String loginId;
    private String password;
    private String userName;
    private String role;
    private String departmentName;
    private String email;
    private String phoneNumber;
    private String useYn = "Y";
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
