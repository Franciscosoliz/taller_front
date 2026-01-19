🛠️ Taller V8 - Sistema de Gestión AutomotrizTaller V8 es una solución integral para talleres mecánicos que combina una potente interfaz de administración para el personal técnico y una plataforma de consulta transparente para el cliente. La aplicación consume una API REST desarrollada en Django y ofrece una experiencia de usuario industrial y moderna.

🎯 Objetivos del Proyecto Cumplidos
Navegación Híbrida: Pantallas públicas para clientes y privadas para staff.
Autenticación Robusta: Manejo de sesiones persistentes con shared_preferences y tokens de seguridad.
Control de Acceso por Roles (RBAC): Bifurcación de rutas basada en el atributo is_staff.
Experiencia de Usuario (UX): Uso de gráficos dinámicos (fl_chart), visualización 3D (model_viewer_plus) y mapas (Maps_flutter).
Gestión Documental: Generación de reportes de servicio en PDF y apertura de archivos locales.
🔑 Credenciales de Prueba y Roles
Para validar el sistema de control de acceso, utilice las siguientes credenciales conectadas a la API real:
Rol Usuario Contraseña 
Pantalla de Destino Administrador (Staff)

francisco francisco15 

Dashboard de Gestión (HomeTaller)
Usuario (Cliente)

esteban programacion

Consulta de Estado de Vehículo

⚙️ Configuración y APILa aplicación está configurada para conectarse al siguiente entorno:
Base URL: https://soliz-francisco-taller-mecanico-api.desarrollo-software.xyz/api
Endpoints principales: /ordenes/, /detalles/, /clientes/.

🚀 Instalación y ComandosSiga estos pasos para ejecutar el proyecto en su entorno local:
Clonar el Repositorio:

git clone https://github.com/tu-usuario/taller_pro.git
cd taller_pro

Instalar Dependencias:

Este comando descargará todos los paquetes necesarios (http, provider, firebase, etc.):

flutter pub get


Configurar Firebase (Opcional):
Asegúrese de tener el archivo google-services.json en android/app/ para las notificaciones push.

Ejecutar la App:

flutter run


📦 Dependencias Clave
El proyecto utiliza las siguientes librerías para cumplir con los requerimientos:
Core: http, provider, shared_preferences.UI/UX: google_fonts, animate_do, fl_chart.Avanzado: model_viewer_plus (Modelos 3D), 
Maps_flutter (Geolocalización).Servicios: firebase_messaging (Notificaciones), pdf & open_filex (Reportes).

🏗️ Estructura de DirectoriosPlaintextlib/
├── api/            # Servicios de conexión y lógica de tokens
├── models/         # Clases de datos (Orden, Reparacion, Usuario)
├── services/       # Lógica de negocio (PDF, Firebase, Maps)
├── ui/
│   ├── screens/    # Pantallas principales (Login, Home, Public)
│   └── widgets/    # Componentes de UI (MetalBackground, IndustrialRefresh)
└── main.dart       # Inicialización y ruteo principal

📡 Conexión a la API (Headers)Para las peticiones privadas, la app inyecta automáticamente el token de sesión:Dart// Ejemplo de implementación en ApiService
headers: {
  'Authorization': 'Token ${prefs.getString('token')}',
  'Content-Type': 'application/json; charset=UTF-8',
}