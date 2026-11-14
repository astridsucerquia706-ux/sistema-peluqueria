import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import api, { mensajeError } from '../api';

// Da formato de pesos colombianos: 25000 → $25.000
function pesos(valor) {
  return '$' + new Intl.NumberFormat('es-CO').format(Number(valor));
}

// Total del turno: suma del precio histórico de sus servicios
function totalTurno(turno) {
  return turno.services.reduce((suma, s) => suma + Number(s.pivot.price), 0);
}

// Lo que ya se pagó del turno
function pagadoTurno(turno) {
  return turno.payments.reduce((suma, p) => suma + Number(p.amount), 0);
}

export default function Turnos() {
  const [turnos, setTurnos] = useState([]);
  const [metodos, setMetodos] = useState([]);
  const [busqueda, setBusqueda] = useState('');
  const [fecha, setFecha] = useState('');
  const [turnoPago, setTurnoPago] = useState(null);
  const [pago, setPago] = useState({ payment_method_id: '', amount: '' });
  const [mensaje, setMensaje] = useState('');
  const [error, setError] = useState('');

  // Trae los turnos de la API (GET /appointments?q=...&date=...)
  async function cargarTurnos() {
    try {
      const respuesta = await api.get('/appointments', { params: { q: busqueda, date: fecha } });
      setTurnos(respuesta.data.datos);
    } catch (err) {
      setError(mensajeError(err));
    }
  }

  // Al abrir la pantalla: turnos y métodos de pago
  useEffect(() => {
    cargarTurnos();
    api.get('/payment-methods')
      .then((respuesta) => setMetodos(respuesta.data.datos))
      .catch((err) => setError(mensajeError(err)));
  }, []);

  function limpiarMensajes() {
    setMensaje('');
    setError('');
  }

  function buscar(e) {
    e.preventDefault();
    limpiarMensajes();
    cargarTurnos();
  }

  // Cancelar (DELETE): el turno no se borra, cambia a "cancelado"
  async function cancelar(turno) {
    if (!window.confirm(`¿Está seguro de cancelar el turno de ${turno.client.name}?`)) return;
    limpiarMensajes();
    try {
      await api.delete(`/appointments/${turno.id}`);
      setMensaje('Turno cancelado correctamente');
      cargarTurnos();
    } catch (err) {
      setError(mensajeError(err));
    }
  }

  // Marcar como atendido (PATCH)
  async function atender(turno) {
    limpiarMensajes();
    try {
      await api.patch(`/appointments/${turno.id}/attend`);
      setMensaje('Turno marcado como atendido');
      cargarTurnos();
    } catch (err) {
      setError(mensajeError(err));
    }
  }

  // ---------- Pagos (RF-07) ----------

  function abrirPago(turno) {
    limpiarMensajes();
    setTurnoPago(turno);
    setPago({ payment_method_id: '', amount: totalTurno(turno) - pagadoTurno(turno) });
  }

  function nombreMetodo(id) {
    const metodo = metodos.find((m) => m.id === id);
    return metodo ? metodo.name : '';
  }

  // Registrar pago (POST /payments); Laravel valida que no supere el saldo
  async function registrarPago(e) {
    e.preventDefault();
    limpiarMensajes();
    try {
      const respuesta = await api.post('/payments', { appointment_id: turnoPago.id, ...pago });
      setMensaje(`Pago registrado. Saldo pendiente: ${pesos(respuesta.data.saldo_pendiente)}`);
      setTurnoPago(null);
      cargarTurnos();
    } catch (err) {
      setError(mensajeError(err));
    }
  }

  // Exportar a CSV: descarga el archivo que genera Laravel
  async function exportarCSV() {
    try {
      const respuesta = await api.get('/appointments/export', { responseType: 'blob' });
      const url = URL.createObjectURL(respuesta.data);
      const enlace = document.createElement('a');
      enlace.href = url;
      enlace.download = 'turnos.csv';
      enlace.click();
      URL.revokeObjectURL(url);
    } catch (err) {
      setError('No se pudo exportar el archivo');
    }
  }

  return (
    <section>
      <div className="encabezado">
        <h1>Turnos</h1>
        <div className="acciones">
          <button className="secundario" onClick={exportarCSV}>Exportar CSV</button>
          <Link className="boton" to="/turnos/nuevo">+ Agendar turno</Link>
        </div>
      </div>

      {mensaje && <p className="alerta exito">{mensaje}</p>}
      {error && <p className="alerta error">{error}</p>}

      {turnoPago && (
        <form className="tarjeta formulario" onSubmit={registrarPago}>
          <h2>Registrar pago</h2>
          <p className="ayuda">
            {turnoPago.client.name} · {turnoPago.date} · {turnoPago.time.slice(0, 5)}
          </p>
          <p className="resumen">
            Total {pesos(totalTurno(turnoPago))} · Pagado {pesos(pagadoTurno(turnoPago))} ·{' '}
            <strong>Saldo {pesos(totalTurno(turnoPago) - pagadoTurno(turnoPago))}</strong>
          </p>
          {turnoPago.payments.length > 0 && (
            <ul className="lista-pagos">
              {turnoPago.payments.map((p) => (
                <li key={p.id}>{nombreMetodo(p.payment_method_id)}: {pesos(p.amount)}</li>
              ))}
            </ul>
          )}
          <div className="dos-columnas">
            <label>
              Método de pago
              <select
                value={pago.payment_method_id}
                onChange={(e) => setPago({ ...pago, payment_method_id: e.target.value })}
              >
                <option value="">Selecciona</option>
                {metodos.map((m) => (
                  <option key={m.id} value={m.id}>{m.name}</option>
                ))}
              </select>
            </label>
            <label>
              Valor
              <input
                type="number"
                min="1"
                value={pago.amount}
                onChange={(e) => setPago({ ...pago, amount: e.target.value })}
              />
            </label>
          </div>
          <div className="acciones">
            <button type="submit">Registrar pago</button>
            <button type="button" className="secundario" onClick={() => setTurnoPago(null)}>Cerrar</button>
          </div>
        </form>
      )}

      <form className="filtros" onSubmit={buscar}>
        <input
          placeholder="Buscar por cliente…"
          aria-label="Buscar por nombre del cliente"
          value={busqueda}
          onChange={(e) => setBusqueda(e.target.value)}
        />
        <input
          type="date"
          aria-label="Filtrar por fecha"
          value={fecha}
          onChange={(e) => setFecha(e.target.value)}
        />
        <button type="submit">Buscar</button>
      </form>

      <div className="tarjeta">
        <table>
          <thead>
            <tr>
              <th>Fecha</th>
              <th>Hora</th>
              <th>Cliente</th>
              <th>Estilista</th>
              <th>Servicios</th>
              <th>Total</th>
              <th>Saldo</th>
              <th>Estado</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            {turnos.map((turno) => {
              const total = totalTurno(turno);
              const saldo = total - pagadoTurno(turno);
              return (
                <tr key={turno.id}>
                  <td>{turno.date}</td>
                  <td>{turno.time.slice(0, 5)}</td>
                  <td>{turno.client.name}</td>
                  <td>{turno.stylist.name}</td>
                  <td>{turno.services.map((s) => s.name).join(', ')}</td>
                  <td>{pesos(total)}</td>
                  <td>
                    {turno.status === 'cancelado' ? '—' : saldo === 0 ? 'Pagado ✓' : pesos(saldo)}
                  </td>
                  <td><span className={`estado estado-${turno.status}`}>{turno.status}</span></td>
                  <td className="acciones">
                    {turno.status === 'pendiente' && (
                      <>
                        <Link className="boton boton-secundario" to={`/turnos/${turno.id}/editar`}>Editar</Link>
                        <button onClick={() => atender(turno)}>Atender</button>
                        <button className="peligro" onClick={() => cancelar(turno)}>Cancelar</button>
                      </>
                    )}
                    {turno.status === 'atendido' && saldo > 0 && (
                      <button onClick={() => abrirPago(turno)}>Registrar pago</button>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
        {turnos.length === 0 && <p className="vacio">No hay turnos para mostrar.</p>}
      </div>
    </section>
  );
}