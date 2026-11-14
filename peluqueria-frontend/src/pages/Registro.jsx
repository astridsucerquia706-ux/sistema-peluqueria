import { useState } from 'react';
import api, { mensajeError } from '../api';
import CampoClave from '../components/CampoClave';

const formularioVacio = { name: '', email: '', password: '', role_id: '2' };

export default function Registro() {
  const [form, setForm] = useState(formularioVacio);
  const [mensaje, setMensaje] = useState('');
  const [error, setError] = useState('');

  function cambiarCampo(e) {
    setForm({ ...form, [e.target.name]: e.target.value });
  }

  async function registrar(e) {
    e.preventDefault();
    setMensaje('');
    setError('');
    try {
      await api.post('/register', form);
      setMensaje(`Usuario ${form.name} registrado correctamente`);
      setForm(formularioVacio);
    } catch (err) {
      setError(mensajeError(err));
    }
  }

  return (
    <section>
      <h1>Usuarios</h1>

      {mensaje && <p className="alerta exito">{mensaje}</p>}
      {error && <p className="alerta error">{error}</p>}

      <form className="tarjeta formulario" onSubmit={registrar}>
        <h2>Registrar empleado</h2>
        <label>
          Nombre
          <input name="name" value={form.name} onChange={cambiarCampo} />
        </label>
        <label>
          Correo
          <input name="email" type="email" value={form.email} onChange={cambiarCampo} />
        </label>
        <CampoClave
          etiqueta="Contraseña (mínimo 8 caracteres)"
          name="password"
          value={form.password}
          onChange={cambiarCampo}
        />
        <label>
          Rol
          <select name="role_id" value={form.role_id} onChange={cambiarCampo}>
            <option value="2">Recepcionista</option>
            <option value="3">Estilista</option>
          </select>
        </label>
        <button type="submit">Registrar usuario</button>
      </form>
    </section>
  );
}