package service;

import com.datastax.driver.core.Cluster;
import com.datastax.driver.core.Session;
import com.sun.jersey.api.core.ResourceConfig;
import com.sun.jersey.server.linking.LinkFilter;
import dao.TodoDaoCassandraImpl;
import io.dropwizard.Application;
import io.dropwizard.Configuration;
import io.dropwizard.setup.Bootstrap;
import io.dropwizard.setup.Environment;
import org.eclipse.jetty.servlets.CrossOriginFilter;
import resources.TodoResource;

import javax.servlet.DispatcherType;
import javax.servlet.FilterRegistration;
import java.util.EnumSet;

public class TodoApplication extends Application<Configuration> {

    public static void main(String[] args) throws Exception {
        new TodoApplication().run(new String[]{"server", "src/main/resources/config.yaml"});
    }

    @Override
    public void initialize(Bootstrap<Configuration> bootstrap) {
    }

    @Override
    public void run(Configuration configuration, Environment environment) throws Exception {
        try {
          String contactPoint = System.getenv("CASSANDRA_CONTACT_POINT");

          Cluster cluster = Cluster.builder().addContactPoint(contactPoint).build();
          Session session = cluster.connect();
          session.execute("CREATE KEYSPACE IF NOT EXISTS todos WITH replication = {'class':'SimpleStrategy','replication_factor':3}");
          session.close();
          session = cluster.connect("todos");

          environment.jersey().register(new TodoResource(new TodoDaoCassandraImpl(session)));

          environment.jersey().property(ResourceConfig.PROPERTY_CONTAINER_RESPONSE_FILTERS, LinkFilter.class);
          addCorsHeader(environment);
        } catch (Exception e) {
          e.printStackTrace();
          System.exit(0);
        }
    }

    private void addCorsHeader(Environment environment) {
        FilterRegistration.Dynamic filter = environment.servlets().addFilter("CORS", CrossOriginFilter.class);
        filter.addMappingForUrlPatterns(EnumSet.allOf(DispatcherType.class), true, "/*");
        filter.setInitParameter("allowedOrigins", "*");
        filter.setInitParameter("allowedMethods", "GET,PUT,POST,DELETE,OPTIONS,HEAD,PATCH");
    }
}
