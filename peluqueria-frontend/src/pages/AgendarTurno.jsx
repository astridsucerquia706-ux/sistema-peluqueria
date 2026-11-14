import { useEffect, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import api, { mensajeError } from '../api';

function pesos(valor) {
  return '$' + new Intl.NumberFormat('es-CO').format(Number(valor));
}

export default function AgendarTurno() {
  const { id } = useParams(); // 
  const editando = Boolean(id);

  const [clientes, setClientes] = useState([]);
  const [estilistas, setEstilistas] = useState([]);
  const [form, setForm] = useState({ client_id: '', stylist_id: '', date: '', time: '', notes: '' });
  const [serviciosElegidos, setServiciosElegidos] = useState([]);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  
  useEffect(() => {
    async function cargarDatos() {
      try {
        const [resClientes, resEstilistas] = await Promise.all([
          api.get('/clients'),
          api.get('/stylists'),
        ]);
        setClientes(resClientes.data.datos);
        setEstilistas(resEstilistas.data.datos.filter((e) => e.active));

        if (editando) {
          const resTurno = await api.get(`/appointments/${id}`);
          const turno = resTurno.data.dato;
          setForm({
            client_id: String(turno.client_id),
            stylist_id: String(turno.stylist_id),
            date: turno.date,
            time: turno.time.slice(0, 5),
            notes: turno.notes ?? '',
          });
          setServiciosElegidos(turno.services.map((s) => s.id));
        }
      } catch (err) {
        setError(mensajeError(err));
      }
    }
    cargarDatos();
  }, [id]);

  
  const estilista = estilistas.find((e) => e.id === Number(form.stylist_id));
  const servicios = estilista ? estilista.services : [];
  const elegidos = servicios.filter((s) => serviciosElegidos.includes(s.id));
  const total = elegidos.reduce((suma, s) => suma + Number(s.price), 0);
  const duracion = elegidos.reduce((suma, s) => suma + s.duration_minutes, 0);

  function cambiarCampo(e) {
    setForm({ ...form, [e.target.name]: e.target.value });
  }

  function cambiarEstilista(e) {
    setForm({ ...form, stylist_id: e.target.value });
    setServiciosElegidos([]);
  }

  function marcarServicio(idServicio) {
    if (serviciosElegidos.includes(idServicio)) {
      setServiciosElegidos(serviciosElegidos.filter((x) => x !== idServicio));
    } else {
      setServiciosElegidos([...serviciosElegidos, idServicio]);
    }
  }

 
  async function guardar(e) {
    e.preventDefault();
    setError('');
    const datos = { ...form, service_ids: serviciosElegidos };
    try {
      if (editando) {
        await api.put(`/appointments/${id}`, datos);
      } else {
        await api.post('/appointments', datos);
      }
      navigate('/turnos');
    } catch (err) {
      setError(mensajeError(err));
    }
  }

  return (
    <section>
      <div className="encabezado">
        <h1>{editando ? 'Editar turno' : 'Agendar turno'}</h1>
        <Link to="/turnos">← Volver a turnos</Link>
      </div>

      {error && <p className="alerta error">{error}</p>}

      <form className="tarjeta formulario" onSubmit={guardar}>
        <label>
          Cliente
          <select name="client_id" value={form.client_id} onChange={cambiarCampo}>
            <option value="">Selecciona un cliente</option>
            {clientes.map((c) => (
              <option key={c.id} value={c.id}>{c.name}</option>
            ))}
          </select>
        </label>

        <label>
          Estilista
          <select name="stylist_id" value={form.stylist_id} onChange={cambiarEstilista}>
            <option value="">Selecciona un estilista</option>
            {estilistas.map((e) => (
              <option key={e.id} value={e.id}>{e.name}</option>
            ))}
          </select>
        </label>

        {estilista && (
          <p className="ayuda">
            Horario: {estilista.schedules
              .map((h) => `${h.day_of_week} ${h.start_time.slice(0, 5)}–${h.end_time.slice(0, 5)}`)
              .join(' · ')}
          </p>
        )}

        <fieldset className="servicios">
          <legend>Servicios</legend>
          {!estilista && <p className="ayuda">Primero selecciona un estilista.</p>}
          {servicios.map((s) => (
            <label key={s.id} className="opcion">
              <input
                type="checkbox"
                checked={serviciosElegidos.includes(s.id)}
                onChange={() => marcarServicio(s.id)}
              />
              {s.name} · {s.duration_minutes} min · {pesos(s.price)}
            </label>
          ))}
        </fieldset>

        <div className="dos-columnas">
          <label>
            Fecha
            <input type="date" name="date" value={form.date} onChange={cambiarCampo} />
          </label>
          <label>
            Hora
            <input type="time" name="time" value={form.time} onChange={cambiarCampo} />
          </label>
        </div>

        <label>
          Observaciones (opcional)
          <input name="notes" value={form.notes} onChange={cambiarCampo} />
        </label>

        {elegidos.length > 0 && (
          <p className="resumen">
            Total: <strong>{pesos(total)}</strong> · Duración: <strong>{duracion} min</strong>
          </p>
        )}

        <button type="submit">{editando ? 'Guardar cambios' : 'Agendar turno'}</button>
      </form>
    </section>
  );
}