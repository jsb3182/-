package kr.or.koies.schoolzone.common;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 프론트엔드가 항상 같은 구조로 응답을 받을 수 있도록 만든 공통 응답 객체입니다.
 */
@Getter
@AllArgsConstructor
public class ApiResponse<T> {
    private boolean success;
    private String message;
    private T data;

    public static <T> ApiResponse<T> ok(T data) {
        return new ApiResponse<>(true, "OK", data);
    }

    public static <T> ApiResponse<T> fail(String message) {
        return new ApiResponse<>(false, message, null);
    }
}
