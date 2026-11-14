# Sistema de gestión de citas – Peluquería

Aplicación web para gestionar las citas de una peluquería. 

**Autora:** Astrid Yulieth Sucerquia
**Asignaturas:** Ingeniería de Software · Bases de Datos — Institución Universitaria Pascual Bravo, 2026

---

## Funcionalidades

- Inicio y cierre de sesión; un usuario con sesión activa puede registrar nuevos usuarios.
- Gestión de clientes, servicios (con categoría, precio y duración) y estilistas (servicios que realizan y horarios).
- Agendar, editar, cancelar (con confirmación) y marcar como atendidos los turnos.
- Validaciones del negocio: el estilista debe estar activo, trabajar en ese horario, realizar los servicios pedidos y no tener otro turno que se cruce.
- Búsqueda de turnos por cliente o por fecha.
- Registro de pagos (incluido pago mixto) y control del saldo pendiente.
- Exportación de los turnos a CSV.
- Auditoría automática de los turnos mediante triggers de MySQL.

## Tecnologías

| Parte | Tecnología |
| --- | --- |
| Backend (API REST) | PHP 8.3 · Laravel 9 · Laravel Sanctum (tokens) |
| Base de datos | MySQL (Laragon) |
| Frontend | React · Vite · axios · react-router-dom |
| Pruebas de API | REST Client (VS Code), archivo `pruebas.http` |
| Pruebas de rendimiento | Locust (Python) |

## Estructura del repositorio

```
sistema-peluqueria/
├── peluqueria/            # Backend: Laravel (API, migraciones, triggers, procedimiento)
│   ├── app/Models/        # Modelos
│   ├── app/Http/Controllers/
│   ├── routes/api.php     # Rutas de la API
│   ├── database/migrations/
│   ├── database/seeders/  # Datos de prueba
│   ├── pruebas.http       # Casos de prueba de la API
│   ├── pruebas_rendimiento/locustfile.py
│   └── backups/           # Copia de seguridad de la base de datos
└── peluqueria-frontend/   # Frontend: React
    └── src/
        ├── pages/         # Pantallas
        └── components/    # Componentes reutilizables
```

---

## Instrucciones de despliegue (instalación local)

### 1. Requisitos previos

- **Laragon** (incluye PHP 8.x, MySQL, Composer y Git).
- **Node.js 20.19 o superior** (se recomienda la versión LTS de [nodejs.org](https://nodejs.org)).
- Opcional, para las pruebas de rendimiento: **Python 3.10 o superior**.

### 2. Descargar el proyecto

En la terminal de Laragon:

```
cd C:\
git clone https://github.com/astridsucerquia706-ux/sistema-peluqueria.git
cd sistema-peluqueria
```

### 3. Crear la base de datos

Con Laragon encendido (**Iniciar todo**), abre HeidiSQL y crea una base de datos vacía llamada **`peluqueria`**.

### 4. Configurar e instalar el backend

```
cd peluqueria
composer install
copy .env.example .env
php artisan key:generate
```

Abre el archivo `.env` y deja la conexión así (no se suben contraseñas al repositorio):

```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=peluqueria
DB_USERNAME=root
DB_PASSWORD=
```

Crea las tablas, los triggers, el procedimiento almacenado y los datos de prueba:

```
php artisan migrate --seed
```

### 5. Instalar el frontend

En otra terminal, desde la carpeta del repositorio:

```
cd peluqueria-frontend
npm install
```

### 6. Ejecutar

Se necesitan **dos terminales abiertas al mismo tiempo**:

| Terminal | Carpeta | Comando |
| --- | --- | --- |
| Backend | `peluqueria` | `php artisan serve` |
| Frontend | `peluqueria-frontend` | `npm run dev` |

Abre en el navegador **http://localhost:5173**.

> El frontend se conecta a la API en `http://127.0.0.1:8000/api`, así que el backend debe correr en el puerto 8000 (el que usa `php artisan serve` por defecto).

### 7. Usuario de prueba

| Correo | Contraseña |
| --- | --- |
| admin@peluqueria.test | Peluqueria2026 |

Es un usuario **solo de prueba**, creado por `database/seeders/DatabaseSeeder.php`.

---

## Base de datos

- **13 tablas**, creadas con migraciones de Laravel y normalizadas hasta tercera forma normal. El diagrama entidad-relación se entrega aparte.
- **Triggers** `trg_appointments_after_insert` y `trg_appointments_after_update`: registran en la tabla `audits` cada creación, modificación, cancelación o atención de un turno.
- **Procedimiento almacenado con cursor** `sp_ingresos_por_estilista`: suma los ingresos de cada estilista en un rango de fechas.

```sql
CALL sp_ingresos_por_estilista('2026-11-01', '2026-11-30');
```

### Copia de seguridad y restauración

Desde la carpeta `peluqueria`, en la terminal de Laragon:

```
mysqldump -u root --routines --triggers --result-file=backups\backup_peluqueria.sql peluqueria
```

Para restaurar:

```
mysql -u root peluqueria -e "source backups/backup_peluqueria.sql"
```

---

## Pruebas

- **Casos de prueba de la API:** archivo `peluqueria/pruebas.http`. Se ejecutan con la extensión REST Client de VS Code (**Send Request**), empezando por la prueba A3 (inicio de sesión), que obtiene el token para las demás.
- **Pruebas de rendimiento:** archivo `peluqueria/pruebas_rendimiento/locustfile.py`, con tres escenarios (10, 50 y 100 usuarios).

```
pip install locust
cd peluqueria\pruebas_rendimiento
locust -f locustfile.py CargaNormal
```

Luego se abre http://localhost:8089. Los otros escenarios son `CargaMedia` y `CargaAlta`.

> Para las pruebas de carga se aumentó el límite de solicitudes de Laravel de 60 a 10000 por minuto en `app/Providers/RouteServiceProvider.php`, porque todos los usuarios simulados usan la misma cuenta. En producción se debe dejar en 60.

## Documentación

Los requerimientos, casos de prueba, resultados de rendimiento, diseño de la API, control de cambios y artefactos de Scrum están en el libro de Excel del proyecto.
