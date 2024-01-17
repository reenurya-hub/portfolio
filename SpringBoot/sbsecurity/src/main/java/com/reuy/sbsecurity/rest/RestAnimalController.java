package com.reuy.sbsecurity.rest;

import com.reuy.sbsecurity.entity.Animal;
import com.reuy.sbsecurity.repository.IAnimalRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/animales")
public class RestAnimalController {
    @Autowired
    private IAnimalRepo repo;
    @GetMapping
    public List<Animal> listar(){
        return repo.findAll();

    }

}
