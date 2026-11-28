package vn.order_tracking.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;

import java.util.List;

@Getter
@JsonInclude(JsonInclude.Include.NON_EMPTY)
@JsonPropertyOrder({
        "meta",
        "data"
})
public class BaseResponse<T> {

    private T data;
    private final Metadata meta = new Metadata();

    public static <T> BaseResponse<T> ofSuccess() {
        BaseResponse<T> response = new BaseResponse<>();
        response.meta.setCode(HttpStatus.OK.value());
        return response;
    }

    public static <T> BaseResponse<T> ofSuccess(T data) {
        BaseResponse<T> response = new BaseResponse<>();
        response.data = data;
        response.meta.setCode(HttpStatus.OK.value());
        return response;
    }

    public static <T> BaseResponse<List<T>> ofSuccess(Page<T> page) {
        BaseResponse<List<T>> response = new BaseResponse<>();
        response.data = page.getContent();
        response.meta.setPage(page.getNumber());
        response.meta.setSize(page.getSize());
        response.meta.setTotal(page.getTotalElements());
        response.meta.setCode(HttpStatus.OK.value());
        return response;
    }

    public static <T> BaseResponse<T> ofMessage(String message) {
        BaseResponse<T> response = new BaseResponse<>();
        response.meta.setCode(HttpStatus.OK.value());
        response.meta.setMessage(message);
        return response;
    }

    public static <T> BaseResponse<T> ofCreated(T data) {
        BaseResponse<T> response = new BaseResponse<>();
        response.data = data;
        response.meta.setCode(HttpStatus.CREATED.value());
        return response;
    }

    public static <T> BaseResponse<T> ofDeleteSuccess() {
        BaseResponse<T> response = new BaseResponse<>();
        response.meta.setCode(HttpStatus.NO_CONTENT.value());
        return response;
    }

    public static <T> BaseResponse<T> ofError(HttpStatus status, String message) {
        BaseResponse<T> response = new BaseResponse<>();
        response.meta.setCode(status.value());
        response.meta.setMessage(message);
        return response;
    }

    @Getter
    @Setter
    @JsonInclude(JsonInclude.Include.NON_EMPTY)
    public static class Metadata {
        private Integer code;
        private Integer page;
        private Integer size;
        private Long total;
        private String message;
    }
}