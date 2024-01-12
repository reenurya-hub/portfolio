package com.reuy.mssql.prueba.service;

import com.reuy.mssql.prueba.repository.EmployeesRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class EmployeeService {


    @Autowired
    private EmployeesRepository  empRepository;
    @Transactional
    public String getEmployeeNamebyId(Integer empid) {
        return empRepository.getEmployeeNamebyId(empid);
    }

}
