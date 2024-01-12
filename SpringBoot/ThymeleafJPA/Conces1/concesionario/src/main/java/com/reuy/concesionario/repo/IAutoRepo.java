package com.reuy.concesionario.repo;

import com.reuy.concesionario.model.Auto;
import org.springframework.data.jpa.repository.JpaRepository;

public interface IAutoRepo extends JpaRepository<Auto, Integer> {

}
