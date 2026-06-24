# TFI - Base de Datos II (Parte 2) - UTN

## 📋 Integrantes

-   **Nicolás Olima**
-   **Nicolás Pannunzio**

----------

## 🚀 Descripción del Proyecto

Este módulo corresponde a la **Parte 2** del Trabajo Final Integrador. Consiste en la conexión funcional y desarrollo de un flujo CRUD básico utilizando el **Driver Nativo de MongoDB** para Node.js, interactuando directamente con nuestro clúster remoto en la nube de **MongoDB Atlas**.

El modelo de negocio está basado en nuestro sistema de **App de Delivery** (`app_delivery`), aplicando reglas de negocio validadas en la primera etapa, como el control de esquemas y la persistencia basada en baja lógica.

----------

## 🛠️ Tecnologías y Herramientas

-   **Backend:** Node.js (v22+)
-   **Base de Datos:** MongoDB Atlas (Clúster Cloud)
-   **Herramienta de Resguardo:** MongoDB Database Tools (`mongodump` nativo)
-   **Conector:** Driver Nativo de MongoDB (`mongodb`)
-   **Seguridad:** Variables de Entorno (`dotenv`)

----------

## 📁 Estructura del Repositorio

```text
SCRIPT-PARTE2-OLIMA_PANNUNZIO/
├── node_modules/         # Dependencias de Node (Ignorado en Git)
├── resguardos_tpi/       # Carpetas de backups locales por fecha (Ignorado en Git)
├── .env                  # Credenciales protegidas (Ignorado en Git)
├── .gitignore            # Exclusiones de Git
├── app_delivery.js       # Script principal con Conexión y CRUD (Bloque 1)
├── backup.bat            # Script ejecutable de automatización del resguardo nativo (Bloque 2)
├── package-lock.json     # Historial de versiones del ecosistema Node
├── package.json          # Configuración del proyecto y scripts
└── README.md             # Documentación del proyecto e Informe Técnico

```

----------

## ⚙️ Configuración y Ejecución

### Variables de entorno

Crear un archivo `.env` en la raíz del proyecto con el siguiente contenido:

```env
MONGO_URI=mongodb+srv://<usuario>:<contraseña>@<cluster>.mongodb.net/app_delivery

```

### Bloque 1 — Ejecutar el CRUD

```bash
node app_delivery.js

```

El script se conecta al clúster, ejecuta las cuatro operaciones en secuencia (CREATE → READ → UPDATE → DELETE lógico) y cierra la conexión automáticamente.

### Bloque 2 — Ejecutar el Resguardo

```bat
backup.bat

```

El script lee el usuario desde el `.env`, solicita la contraseña de forma interactiva, crea la carpeta `resguardos_tpi\dd-MM-yyyy\` y descarga la base de datos completa mediante `mongodump`.

----------


## 📊 Análisis RTO/RPO

| Métrica | Valor estimado | Justificación |
| :--- | :--- | :--- |
| **RPO** (Recovery Point Objective) | ~24 horas | El script está diseñado para ejecutarse una vez por día. La pérdida máxima de datos equivale a las transacciones del último día. |
| **RTO** (Recovery Time Objective) | ~15-30 minutos | El tiempo de recuperación depende del tamaño de la base y la velocidad de red. Con `mongorestore` apuntando al mismo clúster, el proceso es directo. |

Para reducir el RPO en un sistema productivo real, se podría aumentar la frecuencia de ejecución del script (vía Task Scheduler en Windows) o complementar con los backups automáticos de Atlas.

----------

## 💬 Conclusión: Desafíos en la Comunicación Cliente-Servidor

La implementación de esta segunda etapa nos permitió consolidar el flujo completo de comunicación entre una aplicación Node.js y un motor NoSQL alojado en la nube.

El principal desafío fue comprender que la conexión a MongoDB Atlas no es instantánea ni garantizada: el cliente establece un canal TLS cifrado contra el clúster remoto, y cualquier error en la cadena de conexión (URI malformada, IP no autorizada en el Network Access, credenciales incorrectas) se manifiesta como un fallo silencioso o un timeout difícil de diagnosticar. Esto nos llevó a implementar el bloque `try/catch/finally` de forma explícita, garantizando que el cliente siempre cierre la conexión incluso ante errores críticos.

Otro aprendizaje importante fue el manejo del tipo `ObjectId`. MongoDB genera identificadores binarios de 12 bytes que, al viajar entre capas, se representan como strings hexadecimales. Intentar buscar un documento pasando el ID como string sin convertirlo con `new ObjectId()` devuelve cero resultados sin lanzar ningún error, lo que puede confundirse fácilmente con un problema de datos. Entender esta distinción fue clave para que el UPDATE y el DELETE lógico funcionaran correctamente.

Finalmente, el diseño del script de resguardo reforzó la idea de que la seguridad no es un paso opcional: almacenar credenciales en variables de entorno y solicitar la contraseña de forma interactiva en lugar de hardcodearla en el script son decisiones que, en un entorno real, marcan la diferencia entre un sistema auditable y uno vulnerable.
