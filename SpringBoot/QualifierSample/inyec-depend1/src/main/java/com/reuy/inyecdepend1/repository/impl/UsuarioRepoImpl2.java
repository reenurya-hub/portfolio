package com.reuy.inyecdepend1.repository.impl;

import com.reuy.inyecdepend1.InyecDepend1Application;
import com.reuy.inyecdepend1.repository.IDBUsuario;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Repository;

@Repository
@Qualifier("usuario2")
public class UsuarioRepoImpl2 implements IDBUsuario {

    private static Logger LOG = LoggerFactory.getLogger(InyecDepend1Application.class);
    @Override
    public void registrar(String usuario) {
        LOG.info("Se registro el usuario 2 " + usuario);
    }
}
