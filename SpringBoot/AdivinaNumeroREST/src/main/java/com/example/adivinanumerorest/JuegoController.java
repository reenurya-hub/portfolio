package com.example.adivinanumerorest;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/game")
public class JuegoController {

    private int numeroAdivinar;
    private int intentos;

    @GetMapping("/start")
    public String startGame() {
        numeroAdivinar = generateRandomNumber();
        intentos = 0;
        return "Un nuevo juego ha iniciado! Adivina un número entre el 1 y el 100.";
    }

    @PostMapping("/guess")
    public String makeGuess(@RequestParam int guess) {
        intentos++;

        if (guess < 1 || guess > 100) {
            return "Por favor ingrese un número entre el 1 y el 100.";
        }

        if (guess < numeroAdivinar) {
            return "Trata un número más alto.";
        } else if (guess > numeroAdivinar) {
            return "Trata un número más bajo.";
        } else {
            return "Felicidades! Has adivinado el número en " + intentos + " intentos.";
        }
    }

    private int generateRandomNumber() {
        return (int) (Math.random() * 100) + 1;
    }
}
