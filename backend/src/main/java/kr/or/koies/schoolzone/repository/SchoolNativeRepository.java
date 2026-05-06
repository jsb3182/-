package kr.or.koies.schoolzone.repository;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;

/**
 * PostGIS 전용 SQL을 실행하는 저장소입니다.
 * 학교 X/Y 좌표가 저장되면 geom을 EPSG:5186 Point로 자동 생성합니다.
 */
@Repository
public class SchoolNativeRepository {
    @PersistenceContext
    private EntityManager em;

    public void updateGeomBySchoolId(Long schoolId, BigDecimal x, BigDecimal y) {
        em.createNativeQuery("""
            UPDATE tb_school
               SET geom = ST_SetSRID(ST_MakePoint(:x, :y), 5186)
             WHERE school_id = :schoolId
        """)
        .setParameter("x", x)
        .setParameter("y", y)
        .setParameter("schoolId", schoolId)
        .executeUpdate();
    }
}
