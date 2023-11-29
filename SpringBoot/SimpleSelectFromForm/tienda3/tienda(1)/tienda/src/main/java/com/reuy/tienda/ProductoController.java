package com.reuy.tienda;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;
import java.util.Map;
import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping("/productos")
public class ProductoController {

    private final ProductoService productoService;

    @Autowired
    public ProductoController(ProductoService productoService) {
        this.productoService = productoService;
    }

    //@GetMapping("/productos/descripcion")
    //@PostMapping("/descripcion")
    @GetMapping("/descripcion/{id}")
    public String obtenerDescripcionPorId(@PathVariable String id) {
        int num_id;
        num_id = Integer.parseInt(id.toString());

        return productoService.getProductos(num_id);
    }

}
