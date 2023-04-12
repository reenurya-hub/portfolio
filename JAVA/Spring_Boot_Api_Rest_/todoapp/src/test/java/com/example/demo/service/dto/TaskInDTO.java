package com.example.demo.service.dto;

import java.time.LocalDateTime;




import lombok.Data;

@Data
public class TaskInDTO {
	private String title;
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public LocalDateTime getEta() {
		return eta;
	}
	public void setEta(LocalDateTime eta) {
		this.eta = eta;
	}
	private String description;
	private LocalDateTime eta;
}
