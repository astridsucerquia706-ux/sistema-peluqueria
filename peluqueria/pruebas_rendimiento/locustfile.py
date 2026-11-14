import random
from locust import HttpUser, task, between


CORREO = "admin@peluqueria.test"
CONTRASENA = "Peluqueria2026"


class UsuarioBase(HttpUser):
    """Comportamiento común: cada usuario simulado inicia sesión al empezar."""
    abstract = True
    host = "http://127.0.0.1:8000"
    wait_time = between(1, 3)  

    def on_start(self):
        respuesta = self.client.post(
            "/api/login",
            json={"email": CORREO, "password": CONTRASENA},
            headers={"Accept": "application/json"},
        )
        token = respuesta.json()["token"]
        self.client.headers.update({
            "Authorization": f"Bearer {token}",
            "Accept": "application/json",
        })


class CargaNormal(UsuarioBase):
    """10 usuarios: consulta del listado y búsqueda de turnos."""

    @task(2)
    def listar_turnos(self):
        self.client.get("/api/appointments", name="GET /api/appointments")

    @task(1)
    def buscar_turnos(self):
        self.client.get("/api/appointments?q=Ana", name="GET /api/appointments?q=")


class CargaMedia(UsuarioBase):
    """50 usuarios: mezcla de consultas, creación y edición de registros."""

    def on_start(self):
        super().on_start()
        self.mis_clientes = []

    @task(3)
    def listar_turnos(self):
        self.client.get("/api/appointments", name="GET /api/appointments")

    @task(1)
    def crear_cliente(self):
        numero = random.randint(1000, 999999)
        respuesta = self.client.post(
            "/api/clients",
            json={"name": f"Cliente prueba {numero}", "phone": f"300{numero}"},
            name="POST /api/clients",
        )
        if respuesta.status_code == 201:
            self.mis_clientes.append(respuesta.json()["dato"]["id"])

    @task(1)
    def editar_cliente(self):
        if not self.mis_clientes:
            return
        cliente_id = random.choice(self.mis_clientes)
        self.client.put(
            f"/api/clients/{cliente_id}",
            json={"name": "Cliente editado", "phone": "3000000000"},
            name="PUT /api/clients/{id}",
        )


class CargaAlta(UsuarioBase):
    """100 usuarios: consulta del listado durante 2 minutos."""

    @task
    def listar_turnos(self):
        self.client.get("/api/appointments", name="GET /api/appointments")