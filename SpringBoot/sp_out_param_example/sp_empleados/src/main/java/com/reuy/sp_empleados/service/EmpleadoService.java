package com.reuy.sp_empleados.service;

import com.reuy.sp_empleados.repository.EmpleadosRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class EmpleadoService {

    @Autowired
    private EmpleadosRepository empRepository;

    @Transactional
    public String getEmployeeNamebyId(Integer Id) {
        return empRepository.getEmployeeNamebyId(Id);
    }
}
