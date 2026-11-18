# Aplicación Flutter del blog

La aplicación conserva la estructura del proyecto de clase: `screens`, `services`, `models`, `widgets` y `pages`. La API se encuentra en `../../Flutter_LITIID/backend_API`.

Consulta el README de la raíz del repositorio para preparar MySQL, iniciar FastAPI y ejecutar Flutter. `API_BASE_URL` permite configurar el servidor sin escribir credenciales en el código.

```bash
flutter pub get
flutter run -d chrome --web-hostname=127.0.0.1 --web-port=8080 --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

Las pantallas de catálogo y prácticas se conservan como parte del material original. No forman parte del flujo principal del blog ni representan un sistema de pagos.
