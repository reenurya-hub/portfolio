package com.reuy.inyecdepend1;

import com.reuy.inyecdepend1.service.IUsuarioService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;

@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class })
public class InyecDepend1Application implements CommandLineRunner {

	@Autowired
	private IUsuarioService ius;
	private static Logger LOG = LoggerFactory.getLogger(InyecDepend1Application.class);

	public static void main(String[] args) {
		SpringApplication.run(InyecDepend1Application.class, args);
	}


	@Override
	public void run(String... args) throws Exception {
			ius.registrar("admin");
	}
}
