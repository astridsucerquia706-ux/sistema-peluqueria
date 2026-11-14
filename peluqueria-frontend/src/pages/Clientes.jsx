import { useEffect, useState } from 'react';
import api, { mensajeError } from '../api';

const formularioVacio = { name: '', phone: '', email: '' };

export default function Clientes() {
  const [clientes, setClientes] = useState([]);
  const [busqueda, setBusqueda] = useState('');
  const [form, setForm] = useState(formularioVacio);
  const [editandoId, setEditandoId] = useState(null);
  const [mensaje, setMensaje] = useState('');
  const [error, setError] = useState('');

  
  async function cargarClientes(texto = '') {
    try {
      const respuesta = await api.get('/clients', { params: { q: texto } });
      setClientes(respuesta.data.datos);
    } catch (err) {
      setError(mensajeError(err));
    }
  }

  
  useEffect(() => {
    cargarClientes();
  }, []);

  function cambiarCampo(e) {
    setForm({ ...form, [e.target.name]: e.target.value });
  }

  function limpiarFormulario() {
    setForm(formularioVacio);
    setEditandoId(null);
  }

  
  async function guardar(e) {
    e.preventDefault();
    setMensaje('');
    setError('');
    try {
      if (editandoId) {
        await api.put(`/clients/${editandoId}`, form);
        setMensaje('Cliente actualizado correctamente');
      } else {
        await api.post('/clients', form);
        setMensaje('Cliente creado correctamente');
      }
      limpiarFormulario();
      cargarClientes(busqueda);
    } catch (err) {
      setError(mensajeError(err));
    }
  }

  function editar(cliente) {
    setForm({ name: cliente.name, phone: cliente.phone, email: cliente.email ?? '' });
    setEditandoId(cliente.id);
    setMensaje('');
    setError('');
  }

 
  async function eliminar(cliente) {
    if (!window.confirm(`¿Está seguro de eliminar a ${cliente.name}?`)) return;
    setMensaje('');
    setError('');
    try {
      await api.delete(`/clients/${cliente.id}`);
      setMensaje('Cliente eliminado correctamente');
      cargarClientes(busqueda);
    } catch (err) {
      setError(mensajeError(err));
    }
  }

  function buscar(e) {
    e.preventDefault();
    cargarClientes(busqueda);
  }

  return (
    <section>
      <h1>Clientes</h1>

      {mensaje && <p className="alerta exito">{mensaje}</p>}
      {error && <p className="alerta error">{error}</p>}

      <form className="tarjeta formulario" onSubmit={guardar}>
        <h2>{editandoId ? 'Editar cliente' : 'Nuevo cliente'}</h2>
        <label>
          Nombre
          <input name="name" value={form.name} onChange={cambiarCampo} />
        </label>
        <label>
          Teléfono
          <input name="phone" value={form.phone} onChange={cambiarCampo} />
        </label>
        <label>
          Correo (opcional)
          <input name="email" type="email" value={form.email} onChange={cambiarCampo} />
        </label>
        <div className="acciones">
          <button type="submit">{editandoId ? 'Guardar cambios' : 'Crear cliente'}</button>
          {editandoId && (
            <button type="button" className="secundario" onClick={limpiarFormulario}>Cancelar</button>
          )}
        </div>
      </form>

      <form className="buscador" onSubmit={buscar}>
        <input
          placeholder="Buscar por nombre…"
          aria-label="Buscar cliente por nombre"
          value={busqueda}
          onChange={(e) => setBusqueda(e.target.value)}
        />
        <button type="submit">Buscar</button>
      </form>

      <div className="tarjeta">
        <table>
          <thead>
            <tr>
              <th>Nombre</th>
              <th>Teléfono</th>
              <th>Correo</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            {clientes.map((cliente) => (
              <tr key={cliente.id}>
                <td>{cliente.name}</td>
                <td>{cliente.phone}</td>
                <td>{cliente.email || '—'}</td>
                <td className="acciones">
                  <button className="secundario" onClick={() => editar(cliente)}>Editar</button>
                  <button className="peligro" onClick={() => eliminar(cliente)}>Eliminar</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {clientes.length === 0 && <p className="vacio">No hay clientes para mostrar.</p>}
      </div>
    </section>
  );
}