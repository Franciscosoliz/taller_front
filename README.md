# 🛠️ Taller V8 - Sistema de Gestión Automotriz

**Taller V8** es una solución integral para talleres mecánicos que combina una potente interfaz de administración para el personal técnico y una plataforma de consulta transparente para el cliente.

La aplicación consume una **API REST desarrollada en Django** y ofrece una experiencia de usuario **industrial y moderna**, pensada tanto para staff como para clientes finales.

---

## 🎯 Objetivos del Proyecto Cumplidos

- 🔀 **Navegación Híbrida**  
  Pantallas públicas para clientes y privadas para el staff.

- 🔐 **Autenticación Robusta**  
  Manejo de sesiones persistentes con `shared_preferences` y tokens de seguridad.

- 🧩 **Control de Acceso por Roles (RBAC)**  
  Bifurcación de rutas basada en el atributo `is_staff`.

- 🎨 **Experiencia de Usuario (UX)**  
  Uso de gráficos dinámicos (`fl_chart`), visualización 3D (`model_viewer_plus`) y mapas (`maps_flutter`).

- 📄 **Gestión Documental**  
  Generación de reportes de servicio en PDF y apertura de archivos locales.

---

## 🔑 Credenciales de Prueba y Roles

Para validar el sistema de control de acceso, utilice las siguientes credenciales conectadas a la **API real**:

### 👨‍💼 Administrador (Staff)
- **Usuario:** francisco  
- **Contraseña:** francisco15  
- **Pantalla de destino:** Dashboard de Gestión (HomeTaller)

### 🚗 Usuario (Cliente)
- **Usuario:** esteban  
- **Contraseña:** programacion  
- **Pantalla de destino:** Consulta de Estado de Vehículo

---

## ⚙️ Configuración y API

La aplicación está configurada para conectarse al siguiente entorno:

- **Base URL:**  
https://soliz-francisco-taller-mecanico-api.desarrollo-software.xyz/api

yaml
Copiar código

- **Endpoints principales:**  
- `/ordenes/`
- `/detalles/`
- `/clientes/`

---

## 🚀 Instalación y Comandos

Siga estos pasos para ejecutar el proyecto en su entorno local:

### 1️⃣ Clonar el repositorio
```bash
git clone https://github.com/tu-usuario/taller_pro.git
cd taller_pro
2️⃣ Instalar dependencias
Este comando descargará todos los paquetes necesarios (http, provider, firebase, etc.):

bash
Copiar código
flutter pub get
3️⃣ Configurar Firebase (Opcional)
Asegúrese de tener el archivo:

bash
Copiar código
android/app/google-services.json
Esto es necesario para las notificaciones push.

4️⃣ Ejecutar la aplicación
bash
Copiar código
flutter run
📦 Dependencias Clave
El proyecto utiliza las siguientes librerías principales:

🔧 Core
http

provider

shared_preferences

🎨 UI / UX
google_fonts

animate_do

fl_chart

🚀 Avanzado
model_viewer_plus (Modelos 3D)

maps_flutter (Geolocalización)

🔔 Servicios
firebase_messaging (Notificaciones)

pdf

open_filex (Reportes)

🏗️ Estructura de Directorios
plaintext
Copiar código
lib/
├── api/            # Servicios de conexión y manejo de tokens
├── models/         # Clases de datos (Orden, Reparacion, Usuario)
├── services/       # Lógica de negocio (PDF, Firebase, Maps)
├── ui/
│   ├── screens/    # Pantallas principales (Login, Home, Public)
│   └── widgets/    # Componentes de UI (MetalBackground, IndustrialRefresh)
└── main.dart       # Inicialización y ruteo principal
📡 Conexión a la API (Headers)
Para las peticiones privadas, la app inyecta automáticamente el token de sesión:

dart
Copiar código
// Ejemplo de implementación en ApiService
headers: {
  'Authorization': 'Token ${prefs.getString('token')}',
  'Content-Type': 'application/json; charset=UTF-8',
}
📌 Notas Finales
Proyecto desarrollado con Flutter

Arquitectura modular y escalable

Enfocado en entornos reales de producción

✨ Autor: Francisco Soliz

yaml
Copiar código

---

Si quieres, en el siguiente paso puedo:
- 🔥 Ajustarlo para **presentación universitaria**
- 🧪 Agregar sección de **testing**
- 📸 Incluir **capturas de pantalla**
- 🏷️ Optimizarlo para que se vea 🔝 en GitHub

Tú dime 😉