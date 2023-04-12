package com.example.demo.service;

import org.springframework.stereotype.Service;
import com.example.demo.service.dto.TaskInDTO;
import com.example.demo.mapper.TaskInDTOToTask;
import com.example.demo.persistence.entity.Task;
import com.example.demo.persistence.repository.TaskRepository;

@Service
public class TaskService {
    private final TaskRepository repository;
    private final TaskInDTOToTask mapper;
	
	public TaskService(TaskRepository repository, TaskInDTOToTask mapper) {
		this.repository = repository;
		this.mapper = mapper;
	}
	
	public Task createTask(TaskInDTO taskInDTO) {
		Task task = mapper.map(taskInDTO);
		return this.repository.save(task);
	
	}
	
	
}
