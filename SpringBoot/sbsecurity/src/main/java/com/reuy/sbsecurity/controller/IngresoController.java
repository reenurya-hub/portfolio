package com.reuy.sbsecurity.controller;

import com.reuy.sbsecurity.repository.IAnimalRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class IngresoController {
    @Autowired
    private IAnimalRepo repo;

    @GetMapping("/listanimal")
    public String listar( Model entity) {
        entity.addAttribute("animal", repo.findAll());
        return "listanimal";
    }


}
