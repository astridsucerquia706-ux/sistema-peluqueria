import { useEffect, useState } from 'react';
import api, { mensajeError } from '../api';

const dias = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
const formularioVacio = { name: '', phone: '', active: true, service_ids: [] };
const horarioVacio = { stylist_id: '', day_of_week: 'lunes', start_time: '', end_time: '' };

export default function Estilistas() {
  const [estilistas, setEstilistas] = useState([]);
  const [servicios, setServicios] = useState([]);
  const [form, setForm] = useState(formularioVacio);
  const [editandoId, setEditandoId] = useState(null);
  const [horario, setHorario] = useState(horarioVacio);
  const [mensaje, setMensaje] = useState('');
  const [error, setError] = useState('');

  
  async function cargarDatos() {
    try {
      const [resEstilistas, resServicios] = await Promise.all([
        api.get('/stylists'),
        api.get('/services'),
      ]);
      setEstilistas(resEstilistas.data.datos);
      setServicios(resServicios.data.datos);
    } catch (err) {
      setError(mensajeError(err));
    }
  }

  useEffect(() => {
    cargarDatos();
  }, []);

  function limpiarMensajes() {
    setMensaje('');
    setError('');
  }

  

  function cambiarCampo(e) {
    setForm({ ...form, [e.target.name]: e.target.value });
  }

  function marcarServicio(id) {
    const ids = form.service_ids.includes(id)
      ? form.service_ids.filter((x) => x !== id)
      : [...form.service_ids, id];
    setForm({ ...form, service_ids: ids });
  }

  function limpiarFormulario() {
    setForm(formularioVacio);
    setEditandoId(null);
  }

  
  async function guardar(e) {
    e.preventDefault();
    limpiarMensajes();
    try {
      if (editandoId) {
        await api.put(`/stylists/${editandoId}`, form);
        setMensaje('Estilista actualizado correctamente');
      } else {
        await api.post('/stylists', form);
        setMensaje('Estilista creado correctamente');
      }
      limpiarFormulario();
      cargarDatos();
    } catch (err) {
      setError(mensajeError(err));
    }
  }

  function editar(estilista) {
    setForm({
      name: estilista.name,
      phone: estilista.phone,
      active: Boolean(estilista.active),
      service_ids: estilista.services.map((s) => s.id),
    });
    setEditandoId(estilista.id);
    limpiarMensajes();
  }

  // Si el estilista ya tiene turnos, Laravel no deja borrarlo (se debe desactivar)
  async function eliminar(estilista) {
    if (!window.confirm(`¿Está seguro de eliminar a ${estilista.name}?`)) return;
    limpiarMensajes();
    try {
      await api.delete(`/stylists/${estilista.id}`);
      setMensaje('Estilista eliminado correctamente');
      cargarDatos();
    } catch (err) {
      setError(mensajeError(err));
    }
  }

  

  function cambiarHorario(e) {
    setHorario({ ...horario, [e.target.name]: e.target.value });
  }

  async function guardarHorario(e) {
    e.preventDefault();
    limpiarMensajes();
    try {
      await api.post('/schedules', horario);
      setMensaje('Horario agregado correctamente');
      setHorario({ ...horario, start_time: '', end_time: '' });
      cargarDatos();
    } catch (err) {
      setError(mensajeError(err));
    }
  }

  async function eliminarHorario(h) {
    if (!window.confirm(`¿Eliminar el horario del ${h.day_of_week}?`)) return;
    limpiarMensajes();
    try {
      await api.delete(`/schedules/${h.id}`);
      setMensaje('Horario eliminado correctamente');
      cargarDatos();
    } catch (err) {
      setError(mensajeError(err));
    }
  }

  return (
    <section>
      <h1>Estilistas</h1>

      {mensaje && <p className="alerta exito">{mensaje}</p>}
      {error && <p className="alerta error">{error}</p>}

      <div className="dos-tarjetas">
        <form className="tarjeta formulario" onSubmit={guardar}>
          <h2>{editandoId ? 'Editar estilista' : 'Nuevo estilista'}</h2>
          <label>
            Nombre
            <input name="name" value={form.name} onChange={cambiarCampo} />
          </label>
          <label>
            Teléfono
            <input name="phone" value={form.phone} onChange={cambiarCampo} />
          </label>
          <label className="opcion">
            <input
              type="checkbox"
              checked={form.active}
              onChange={(e) => setForm({ ...form, active: e.target.checked })}
            />
            Activo (puede recibir turnos)
          </label>
          <fieldset className="servicios">
            <legend>Servicios que realiza</legend>
            {servicios.map((s) => (
              <label key={s.id} className="opcion">
                <input
                  type="checkbox"
                  checked={form.service_ids.includes(s.id)}
                  onChange={() => marcarServicio(s.id)}
                />
                {s.name}
              </label>
            ))}
          </fieldset>
          <div className="acciones">
            <button type="submit">{editandoId ? 'Guardar cambios' : 'Crear estilista'}</button>
            {editandoId && (
              <button type="button" className="secundario" onClick={limpiarFormulario}>Cancelar</button>
            )}
          </div>
        </form>

        <form className="tarjeta formulario" onSubmit={guardarHorario}>
          <h2>Agregar horario</h2>
          <label>
            Estilista
            <select name="stylist_id" value={horario.stylist_id} onChange={cambiarHorario}>
              <option value="">Selecciona un estilista</option>
              {estilistas.map((e) => (
                <option key={e.id} value={e.id}>{e.name}</option>
              ))}
            </select>
          </label>
          <label>
            Día
            <select name="day_of_week" value={horario.day_of_week} onChange={cambiarHorario}>
              {dias.map((d) => (
                <option key={d} value={d}>{d}</option>
              ))}
            </select>
          </label>
          <div className="dos-columnas">
            <label>
              Desde
              <input type="time" name="start_time" value={horario.start_time} onChange={cambiarHorario} />
            </label>
            <label>
              Hasta
              <input type="time" name="end_time" value={horario.end_time} onChange={cambiarHorario} />
            </label>
          </div>
          <button type="submit">Agregar horario</button>
        </form>
      </div>

      <div className="tarjeta">
        <table>
          <thead>
            <tr>
              <th>Nombre</th>
              <th>Teléfono</th>
              <th>Servicios</th>
              <th>Horario</th>
              <th>Estado</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            {estilistas.map((estilista) => (
              <tr key={estilista.id}>
                <td>{estilista.name}</td>
                <td>{estilista.phone}</td>
                <td>{estilista.services.map((s) => s.name).join(', ') || '—'}</td>
                <td>
                  {estilista.schedules.length === 0 && '—'}
                  {estilista.schedules.map((h) => (
                    <div key={h.id} className="horario">
                      {h.day_of_week} {h.start_time.slice(0, 5)}–{h.end_time.slice(0, 5)}
                      <button
                        className="mini"
                        aria-label={`Eliminar horario del ${h.day_of_week}`}
                        onClick={() => eliminarHorario(h)}
                      >
                        ×
                      </button>
                    </div>
                  ))}
                </td>
                <td>
                  <span className={`estado ${estilista.active ? 'estado-atendido' : 'estado-cancelado'}`}>
                    {estilista.active ? 'Activo' : 'Inactivo'}
                  </span>
                </td>
                <td className="acciones">
                  <button className="secundario" onClick={() => editar(estilista)}>Editar</button>
                  <button className="peligro" onClick={() => eliminar(estilista)}>Eliminar</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {estilistas.length === 0 && <p className="vacio">No hay estilistas para mostrar.</p>}
      </div>
    </section>
  );
}