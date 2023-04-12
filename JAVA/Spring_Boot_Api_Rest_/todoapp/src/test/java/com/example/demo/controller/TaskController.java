package com.example.demo.controller;


import org.springframework.web.bind.annotation.*;



import com.example.demo.persistence.entity.Task;
import com.example.demo.service.TaskService;
import com.example.demo.service.dto.TaskInDTO;

@RestController
@RequestMapping("/tasks")
public class TaskController {
	// Controller layer only communicates with Service layer
	private final TaskService taskService;

    public TaskController(TaskService taskService) {
        this.taskService = taskService;
    }

    @PostMapping
    public Task createTask(@RequestBody TaskInDTO taskInDTO) {
       return this.taskService.createTask(taskInDTO);
    }
    

}
