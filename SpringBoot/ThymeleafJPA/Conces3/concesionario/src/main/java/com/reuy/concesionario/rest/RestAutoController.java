package com.reuy.concesionario.rest;

import com.reuy.concesionario.model.Auto;
import com.reuy.concesionario.repo.IAutoRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/autos")
public class RestAutoController {
    @Autowired
    private IAutoRepo repo;
    @GetMapping
    public List<Auto> listar(){
        return repo.findAll();

    }

    @PostMapping
    public void insertar(@RequestBody Auto auto){
        repo.save(auto);
    }
}
