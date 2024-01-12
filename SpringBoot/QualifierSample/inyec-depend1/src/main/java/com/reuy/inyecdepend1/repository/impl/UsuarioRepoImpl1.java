package com.reuy.inyecdepend1.repository.impl;
import com.reuy.inyecdepend1.InyecDepend1Application;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.reuy.inyecdepend1.repository.IDBUsuario;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Repository;

@Repository
@Qualifier("usuario1")
public class UsuarioRepoImpl1 implements IDBUsuario {

    private static Logger LOG = LoggerFactory.getLogger(InyecDepend1Application.class);
    @Override
    public void registrar(String usuario) {
        LOG.info("Se registro el usuario 1" + usuario);
    }
}
