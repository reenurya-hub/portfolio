package com.reuy.sp_empleados.controller;

import com.reuy.sp_empleados.service.EmpleadoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/empleado")
public class EmpleadoController {

    @Autowired
    private EmpleadoService empleadoService;

    @PostMapping("/getNombreEmpleado")
    public String getEmployeeNameById(@RequestBody Integer empId) {
        return empleadoService.getEmployeeNamebyId(empId);
    }
}