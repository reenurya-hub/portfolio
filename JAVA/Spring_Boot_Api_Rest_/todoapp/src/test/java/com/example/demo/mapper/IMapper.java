package com.example.demo.mapper;

public interface IMapper<I, O> {
	O map(I in);
}
