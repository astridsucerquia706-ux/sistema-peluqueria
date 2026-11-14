import { useState } from 'react';


export default function CampoClave({ etiqueta, name, value, onChange }) {
  const [visible, setVisible] = useState(false);

  return (
    <label>
      {etiqueta}
      <div className="campo-clave">
        <input type={visible ? 'text' : 'password'} name={name} value={value} onChange={onChange} />
        <button type="button" className="secundario" onClick={() => setVisible(!visible)}>
          {visible ? 'Ocultar' : 'Mostrar'}
        </button>
      </div>
    </label>
  );
}