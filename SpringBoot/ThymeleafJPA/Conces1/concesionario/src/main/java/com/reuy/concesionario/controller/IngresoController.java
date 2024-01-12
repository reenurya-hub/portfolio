package com.reuy.concesionario.controller;

import com.reuy.concesionario.model.Auto;
import com.reuy.concesionario.repo.IAutoRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class IngresoController {

    @Autowired
    private IAutoRepo repo;


    @GetMapping("/ingreso-web")
    public String ingreso(@RequestParam(name="name", required=false, defaultValue="Usuario1") String name, Model model) {

        Auto a = new Auto();
        a.setMarca("Mazda");
        a.setModelo(2023);
        a.setValor(45000000);
        repo.save(a);

        model.addAttribute("name", name);
        return "ingreso-web";
    }
}
