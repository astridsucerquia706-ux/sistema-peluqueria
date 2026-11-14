import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api, { mensajeError } from '../api';
import CampoClave from '../components/CampoClave';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  async function iniciarSesion(e) {
    e.preventDefault();
    setError('');
    try {
      const respuesta = await api.post('/login', { email, password });
      localStorage.setItem('token', respuesta.data.token);
      localStorage.setItem('usuario', JSON.stringify(respuesta.data.usuario));
      navigate('/');
    } catch (err) {
      setError(mensajeError(err));
    }
  }

  return (
    <div className="login">
      <form className="tarjeta formulario" onSubmit={iniciarSesion}>
        <div className="login-marca">
          <h1>Peluquería</h1>
          <p>Sistema de gestión de citas</p>
        </div>

        
        {error && <p className="alerta error">{error}</p>}

        <label>
          Correo electrónico
          <input
            type="email"
            placeholder="Ingresa tu correo electrónico"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
        </label>
        <CampoClave
          etiqueta="Contraseña"
          name="password"
          placeholder="Ingresa tu contraseña"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
        <button type="submit">Iniciar sesión</button>
      </form>
    </div>
  );
}