package resources;

import io.dropwizard.jersey.PATCH;
import io.dropwizard.jersey.params.UUIDParam;
import model.Todo;
import dao.TodoDao;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import java.util.Collection;
import java.util.UUID;

@Path("/todo")
@Produces(MediaType.APPLICATION_JSON)
public class TodoResource {

    private final TodoDao todoDao;

    public TodoResource(TodoDao todoDao) {
        this.todoDao = todoDao;
    }

    @GET
    public Collection<Todo> get() {
        return todoDao.getAll();
    }

    @GET
    @Path("{id}")
    public Todo getById(@PathParam("id") UUIDParam id) {
        return todoDao.get(id.get());
    }

    @POST
    public Todo addTodos(Todo todo) {
        todo.setId(UUID.randomUUID());
        todo.setCompleted(false);
        todoDao.set(todo);
        return todo;
    }

    @DELETE
    public void delete() {
        todoDao.removeAll();
    }

    @DELETE
    @Path("{id}")
    public void deleteById(@PathParam("id") UUIDParam id) {
        todoDao.remove(id.get());
    }

    @PATCH
    @Path("{id}")
    public Todo edit(@PathParam("id") UUIDParam id, Todo patch) {
        Todo todo = todoDao.get(id.get());
        Todo patchedTodo = todo.patchFrom(patch);
        todoDao.set(patchedTodo);
        return patchedTodo;
    }
}
