package dao;

import model.Todo;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class TodoDaoMemoryImpl implements TodoDao {
    private final Map<UUID, Todo> todos;

    public TodoDaoMemoryImpl() {
        todos = new HashMap<>();
    }

    @Override
    public void removeAll() {
        todos.clear();
    }

    @Override
    public void remove(UUID id) {
        todos.remove(id);
    }

    @Override
    public Todo get(UUID id) {
        return todos.get(id);
    }

    @Override
    public Collection<Todo> getAll() {
        return todos.values();
    }

    @Override
    public void set(Todo todo) {
        todos.put(todo.getId(), todo);
    }
}
