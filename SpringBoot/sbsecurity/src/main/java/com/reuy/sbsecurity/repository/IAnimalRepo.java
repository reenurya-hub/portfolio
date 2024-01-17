package com.reuy.sbsecurity.repository;

import com.reuy.sbsecurity.entity.Animal;
import org.springframework.data.jpa.repository.JpaRepository;

public interface IAnimalRepo extends JpaRepository<Animal, Integer> {

}
