package dao;

import com.datastax.driver.core.ResultSet;
import com.datastax.driver.core.Row;
import com.datastax.driver.core.Session;
import com.google.common.collect.ImmutableMap;
import model.Todo;

import java.net.URI;
import java.util.*;

public class TodoDaoCassandraImpl implements TodoDao {
    private final Session session;

    private final String CREATE_TABLE_STMT = "CREATE TABLE IF NOT EXISTS todos (\n" +
            "        id uuid PRIMARY KEY,\n" +
            "        title text,\n" +
            "        norder int,\n" +
            "        completed boolean,\n" +
            "        url text\n" +
            "    )";

    private final String DELETE_ALL_STMT = "TRUNCATE todos";
    private final String DELETE_STMT = "DELETE FROM todos WHERE id = :id";
    private final String SET_STMT = "INSERT INTO todos (id, title, norder, completed, url) VALUES (:id, :title, :norder, :completed, :url)";
    private final String GET_ALL = "SELECT * from todos";
    private final String GET_ONE = "SELECT * from todos WHERE id = :id";

    public TodoDaoCassandraImpl(Session session) {
        this.session = session;
        session.execute(CREATE_TABLE_STMT);
    }

    @Override
    public void removeAll() {
        session.execute(DELETE_ALL_STMT);
    }

    @Override
    public void remove(UUID id) {
        session.execute(DELETE_STMT, ImmutableMap.of("id", id));
    }

    @Override
    public Todo get(UUID id) {
        ResultSet resultSet = session.execute(GET_ONE, ImmutableMap.of("id", id));
        Row row = resultSet.one();
        return extractFromRow(row);
    }

    @Override
    public Collection<Todo> getAll() {
        ResultSet resultSet = session.execute(GET_ALL);

        List<Todo> results = new ArrayList<>();

        for (Row row : resultSet) {
            results.add(extractFromRow(row));
        }

        return results;
    }

    @Override
    public void set(Todo todo) {
        Map<String, Object> params = new HashMap<>();
        params.put("id", todo.getId());
        params.put("title", todo.getTitle());
        params.put("norder", todo.getOrder());
        params.put("completed", todo.getCompleted());
        params.put("url", todo.getUrl());

        session.execute(SET_STMT, params);
    }

    private Todo extractFromRow(Row row) {
        if (row==null) {
            return null;
        }

        Todo todo = new Todo();
        todo.setId(row.getUUID("id"));
        todo.setTitle(row.getString("title"));
        String url = row.getString("url");
        if (url != null) {
            todo.setUrl(URI.create(url));
        }
        todo.setCompleted(row.getBool("completed"));
        todo.setOrder(row.getInt("norder"));
        return todo;
    }
}
