# Aplicación Flutter de inventario

Aplicación para consultar y administrar productos mediante la API REST del repositorio. Usa Dio, go_router y flutter_dotenv.

Desde la raíz del repositorio, inicia `backend` con `npm start`; después ejecuta:

```powershell
cd app_flutter
flutter pub get
flutter run
```

La URL está en `.env`. El valor incluido (`http://10.0.2.2:3000/api`) corresponde al emulador Android. Para navegador o Windows usa `http://localhost:3000/api`; en un dispositivo físico usa la IP local del computador. En iOS configura un endpoint HTTPS para evitar las restricciones ATS de HTTP.

Consulta el [README principal](../README.md) para instrucciones de la API, endpoints y validaciones.
