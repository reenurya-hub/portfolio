package com.reuy.mssql.prueba.repository;

import com.reuy.mssql.prueba.entity.Employee;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.query.Procedure;
import org.springframework.data.repository.query.Param;

public interface EmployeesRepository extends JpaRepository<Employee, Integer> {
    @Procedure(name = "employee.sp_select_employee")
    String getEmployeeNamebyId(@Param("empid") Integer empid);
}
