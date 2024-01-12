package com.reuy.inyecdepend1.service.impl;

import com.reuy.inyecdepend1.repository.IDBUsuario;
import com.reuy.inyecdepend1.service.IUsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

@Service
public class UsuarioServiceImpl implements IUsuarioService {

    @Qualifier("usuario1")
    @Autowired
    private IDBUsuario ius;

    @Override
     public void registrar(String usuario) {
        ius.registrar(usuario);
    }
}
