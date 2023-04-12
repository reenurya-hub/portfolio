package com.example.demo.persistence.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.demo.persistence.entity.Task;

public interface TaskRepository extends JpaRepository<Task, Long>{

}
