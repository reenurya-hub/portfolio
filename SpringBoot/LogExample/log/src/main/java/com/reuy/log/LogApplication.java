package com.reuy.log;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;

@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class })
public class LogApplication  implements CommandLineRunner {

	private static Logger LOG =LoggerFactory.getLogger(LogApplication.class);

	public static void main(String[] args) {
		SpringApplication.run(LogApplication.class, args);
	}


	@Override
	public void run(String... args) throws Exception {
		//System.out.println("Hola desde spring boot");
		LOG.info("Hola desde spring boot");
		LOG.warn("Mensaje warning");
		LOG.error("Mensaje error");

	}
}
