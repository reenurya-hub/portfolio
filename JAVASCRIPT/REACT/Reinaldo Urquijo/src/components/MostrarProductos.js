import React, {useState, useEffect} from 'react';
import axios from 'axios';

const endpoint=''

const MostrarProductos = () =>{

const [productos, setProductos] = useState([])

useEffect(() => { getTodos()  },[]   )

    const getTodos = async () => {
        
        const respuesta = await axios.get(`${endpoint}`);
        setProductos(respuesta )
    }

    const BorrarProductos = () => {

    }
    return(
    <div></div>
)
}