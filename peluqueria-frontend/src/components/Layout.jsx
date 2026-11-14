import { NavLink, Outlet, useNavigate } from 'react-router-dom';
import api from '../api';

export default function Layout() {
  const navigate = useNavigate();
  const usuario = JSON.parse(localStorage.getItem('usuario') || '{}');

  async function cerrarSesion() {
    try {
      await api.post('/logout');
    } catch (e) {
      
    }
    localStorage.removeItem('token');
    localStorage.removeItem('usuario');
    navigate('/login');
  }

  return (
    <div className="layout">
      <aside className="menu">
        <h2>Peluquería</h2>
        <nav>
          <NavLink to="/turnos">Turnos</NavLink>
          <NavLink to="/clientes">Clientes</NavLink>
          <NavLink to="/servicios">Servicios</NavLink>
          <NavLink to="/estilistas">Estilistas</NavLink>
          <NavLink to="/usuarios">Usuarios</NavLink>
        </nav>
        <div className="usuario">
          <span>{usuario.name}</span>
          <button className="secundario" onClick={cerrarSesion}>Cerrar sesión</button>
        </div>
      </aside>
      <main className="contenido">
        <Outlet />
      </main>
    </div>
  );
}