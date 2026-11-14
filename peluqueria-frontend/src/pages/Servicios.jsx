import { useEffect, useState } from 'react';
import api, { mensajeError } from '../api';

function pesos(valor) {
  return '$' + new Intl.NumberFormat('es-CO').format(Number(valor));
}

const formularioVacio = { category_id: '', name: '', price: '', duration_minutes: '' };

export default function Servicios() {
  const [servicios, setServicios] = useState([]);
  const [categorias, setCategorias] = useState([]);
  const [form, setForm] = useState(formularioVacio);
  const [editandoId, setEditandoId] = useState(null);
  const [mensaje, setMensaje] = useState('');
  const [error, setError] = useState('');

  
  async function cargarDatos() {
    try {
      const [resServicios, resCategorias] = await Promise.all([
        api.get('/services'),
        api.get('/categories'),
      ]);
      setServicios(resServicios.data.datos);
      setCategorias(resCategorias.data.datos);
    } catch (err) {
      setError(mensajeError(err));
    }
  }

  useEffect(() => {
    cargarDatos();
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
        await api.put(`/services/${editandoId}`, form);
        setMensaje('Servicio actualizado correctamente');
      } else {
        await api.post('/services', form);
        setMensaje('Servicio creado correctamente');
      }
      limpiarFormulario();
      cargarDatos();
    } catch (err) {
      setError(mensajeError(err));
    }
  }

  function editar(servicio) {
    setForm({
      category_id: servicio.category_id,
      name: servicio.name,
      price: Number(servicio.price),
      duration_minutes: servicio.duration_minutes,
    });
    setEditandoId(servicio.id);
    setMensaje('');
    setError('');
  }

  // Elimina (DELETE); Laravel no deja borrar servicios que ya se usaron en turnos
  async function eliminar(servicio) {
    if (!window.confirm(`¿Está seguro de eliminar el servicio ${servicio.name}?`)) return;
    setMensaje('');
    setError('');
    try {
      await api.delete(`/services/${servicio.id}`);
      setMensaje('Servicio eliminado correctamente');
      cargarDatos();
    } catch (err) {
      setError(mensajeError(err));
    }
  }

  return (
    <section>
      <h1>Servicios</h1>

      {mensaje && <p className="alerta exito">{mensaje}</p>}
      {error && <p className="alerta error">{error}</p>}

      <form className="tarjeta formulario" onSubmit={guardar}>
        <h2>{editandoId ? 'Editar servicio' : 'Nuevo servicio'}</h2>
        <label>
          Nombre
          <input name="name" value={form.name} onChange={cambiarCampo} />
        </label>
        <label>
          Categoría
          <select name="category_id" value={form.category_id} onChange={cambiarCampo}>
            <option value="">Selecciona una categoría</option>
            {categorias.map((c) => (
              <option key={c.id} value={c.id}>{c.name}</option>
            ))}
          </select>
        </label>
        <div className="dos-columnas">
          <label>
            Precio
            <input name="price" type="number" min="0" value={form.price} onChange={cambiarCampo} />
          </label>
          <label>
            Duración (minutos)
            <input name="duration_minutes" type="number" min="1" value={form.duration_minutes} onChange={cambiarCampo} />
          </label>
        </div>
        <div className="acciones">
          <button type="submit">{editandoId ? 'Guardar cambios' : 'Crear servicio'}</button>
          {editandoId && (
            <button type="button" className="secundario" onClick={limpiarFormulario}>Cancelar</button>
          )}
        </div>
      </form>

      <div className="tarjeta">
        <table>
          <thead>
            <tr>
              <th>Servicio</th>
              <th>Categoría</th>
              <th>Precio</th>
              <th>Duración</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            {servicios.map((servicio) => (
              <tr key={servicio.id}>
                <td>{servicio.name}</td>
                <td>{servicio.category.name}</td>
                <td>{pesos(servicio.price)}</td>
                <td>{servicio.duration_minutes} min</td>
                <td className="acciones">
                  <button className="secundario" onClick={() => editar(servicio)}>Editar</button>
                  <button className="peligro" onClick={() => eliminar(servicio)}>Eliminar</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {servicios.length === 0 && <p className="vacio">No hay servicios para mostrar.</p>}
      </div>
    </section>
  );
}