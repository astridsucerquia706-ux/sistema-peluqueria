import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import Login from './pages/Login';
import Registro from './pages/Registro';
import Layout from './components/Layout';
import Clientes from './pages/Clientes';
import Turnos from './pages/Turnos';
import AgendarTurno from './pages/AgendarTurno';
import Servicios from './pages/Servicios';
import Estilistas from './pages/Estilistas';

function RutaPrivada({ children }) {
  const token = localStorage.getItem('token');
  return token ? children : <Navigate to="/login" />;
}

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/" element={<RutaPrivada><Layout /></RutaPrivada>}>
          <Route index element={<Navigate to="/turnos" />} />
          <Route path="turnos" element={<Turnos />} />
          <Route path="turnos/nuevo" element={<AgendarTurno />} />
          <Route path="turnos/:id/editar" element={<AgendarTurno />} />
          <Route path="clientes" element={<Clientes />} />
          <Route path="servicios" element={<Servicios />} />
          <Route path="estilistas" element={<Estilistas />} />
          <Route path="usuarios" element={<Registro />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}