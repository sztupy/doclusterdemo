package dao;

import model.Todo;

import java.util.Collection;
import java.util.UUID;

public interface TodoDao {
    void removeAll();
    void remove(UUID id);
    Todo get(UUID id);
    Collection<Todo> getAll();
    void set(Todo todo);
}
