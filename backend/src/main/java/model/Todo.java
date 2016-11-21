package model;

import com.sun.jersey.server.linking.Ref;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import resources.TodoResource;

import java.net.URI;
import java.util.UUID;

@Getter
@Setter
@EqualsAndHashCode
@NoArgsConstructor
public class Todo {

    private String title;
    private UUID id;
    private Boolean completed;
    private Integer order;
    @Ref(resource = TodoResource.class, style = Ref.Style.ABSOLUTE, method = "getById")
    private URI url;

    public void setId(UUID id){
        this.id = id;
    }

    public Todo patchFrom(Todo patch) {

        if (patch.completed != null) {
            completed = patch.completed;
        }

        if (patch.title != null) {
            title = patch.title;
        }

        if (patch.order != null) {
            order = patch.order;
        }

        return this;
    }

    public void setCompleted(boolean completed) {
        this.completed = completed;
    }
}
