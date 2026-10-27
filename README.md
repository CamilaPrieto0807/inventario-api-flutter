# Sistema de gestión de inventario

Solución de inventario formada por una API REST en Node.js/Express con SQLite y una aplicación Flutter. Los productos se guardan en la base de datos; la aplicación consulta y modifica los registros directamente mediante Dio.

## Requisitos

- Node.js 18 o superior y npm.
- Flutter stable y Dart.
- Android Studio/emulador, un dispositivo conectado o un navegador.

## Backend

```powershell
cd backend
npm install
npm start
```

La API escucha en `http://localhost:3000`. SQLite crea `backend/inventario.sqlite` automáticamente y la primera ejecución inserta diez productos de demostración. La ruta de la base se puede cambiar con `DB_STORAGE`; el puerto, con `PORT`.

Para desarrollo automático: `npm run dev`. Para ejecutar las pruebas de integración: `npm test`.

### Endpoints

Todos los endpoints utilizan JSON y el prefijo `/api`.

| Método | Ruta | Respuesta |
|---|---|---|
| GET | `/api/productos` | Lista de productos (`200`) |
| GET | `/api/productos/:id` | Detalle (`200`) o producto inexistente (`404`) |
| POST | `/api/productos` | Producto creado (`201`) |
| PUT | `/api/productos/:id` | Producto actualizado (`200`) |
| DELETE | `/api/productos/:id` | Confirmación de eliminación (`200`) |

El producto contiene `id`, `nombre`, `codigo`, `descripcion`, `precio`, `cantidad` y `categoria`. Nombre, código, categoría, precio y cantidad son obligatorios; el código no se puede repetir, y el precio y la cantidad deben ser mayores o iguales a cero. Los errores de validación devuelven `422`.

Ejemplo de creación:

```http
POST /api/productos
Content-Type: application/json
```

```json
{
  "nombre": "Té verde",
  "codigo": "BEB-011",
  "descripcion": "Caja por 20 unidades",
  "precio": 6800,
  "cantidad": 15,
  "categoria": "Bebidas"
}
```

Respuesta (`201`):

```json
{
  "id": 11,
  "nombre": "Té verde",
  "codigo": "BEB-011",
  "descripcion": "Caja por 20 unidades",
  "precio": "6800.00",
  "cantidad": 15,
  "categoria": "Bebidas"
}
```

## Aplicación Flutter

La app usa Dio para las peticiones, go_router para navegar y flutter_dotenv para obtener la URL de la API. Sus responsabilidades están separadas en `lib/models`, `lib/services`, `lib/state`, `lib/screens` y `lib/widgets`.

La configuración local está en `app_flutter/.env`:

```dotenv
API_BASE_URL=http://10.0.2.2:3000/api
```

`10.0.2.2` permite que el emulador Android acceda al `localhost` del computador. Si ejecutas Flutter en Windows o navegador, cambia el valor a `http://localhost:3000/api`. En un teléfono físico, utiliza la IP local del computador, por ejemplo `http://192.168.1.20:3000/api`, y asegúrate de que ambos dispositivos estén en la misma red. iOS restringe HTTP sin cifrar por ATS: usa un endpoint HTTPS en iOS.

Inicia el backend y, en otra terminal:

```powershell
cd app_flutter
flutter pub get
flutter run
```

El Dashboard calcula productos, unidades y valor total usando los registros obtenidos por la API. La sección Productos permite listar, consultar, registrar, editar y eliminar, e informa los errores de comunicación y validación.

Verifica el análisis estático y los tests con:

```powershell
cd app_flutter
flutter analyze
flutter test
```

## Estructura

```text
backend/       API Express, modelo Sequelize, SQLite y pruebas de integración
app_flutter/   Aplicación Flutter y configuración de la URL de API
```

## Despliegue y demostración

El proyecto está preparado para ejecución local. No se ha configurado un proveedor de despliegue ni se incluye un enlace público. Para desplegarlo, configura `PORT` y una ubicación persistente para `DB_STORAGE`; luego actualiza `API_BASE_URL` con la URL HTTPS de la API.

El video explicativo requerido por la actividad debe grabarse y compartirse por el equipo. Se recomienda mostrar las pruebas de API, las capas de Flutter, las cinco operaciones CRUD y que los registros sigan presentes después de reiniciar el backend.
