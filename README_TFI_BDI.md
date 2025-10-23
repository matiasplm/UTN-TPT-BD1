# <img src="https://bignews.ar/wp-content/uploads/2023/05/utn-nacional.jpg" width="200"></h2>
#  Trabajo Final Integrador – Bases de Datos I

![MySQL](https://img.shields.io/badge/DB-MySQL-informational?style=flat&logo=mysql&color=4479A1)
![SQL](https://img.shields.io/badge/Language-SQL-blue?style=flat&logo=databricks)

> Este repositorio contiene el **Trabajo Final Integrador** de la materia **Bases de Datos I (UTN)**.  
> Incluye todos los scripts SQL, el PDF de documentación y el enlace al video de exposición del proyecto.

> 🎥 **Presentación en video:** 
---

## 📁 Estructura del proyecto

```plaintext
TFI_BDI_ComisionX_GrupoY_Apellidos/
├── 01_esquema.sql             # Definición de tablas, claves PK/FK, dominios y constraints
├── 02_catalogos.sql           # Inserciones básicas en tablas de referencia / catálogos
├── 03_carga_masiva.sql        # Carga masiva idempotente (10k clientes, 50k ventas)
├── 04_indices.sql             # Creación de índices simples y compuestos
├── 05_consultas.sql           # Consultas con y sin índice, mediciones de tiempos
├── 05_01_explain.sql          # Planes de ejecución (EXPLAIN ANALYZE)
├── 06_vistas.sql              # Vistas resumen de ventas (por cliente/año)
├── 07_seguridad.sql           # Usuarios, roles, privilegios, y pruebas de restricciones
├── 08_transacciones.sql       # Transacciones y control de errores
├── 09_concurrencia_guiada.sql # Pruebas de concurrencia y aislamiento (deadlocks)
├── README.md                  # Este archivo (documentación del proyecto)
├── "Trabajo Final Integrador - Bases de Datos I.pdf"  # Documento final con evidencias y anexo IA
└── video_link.txt             # Enlace al video (si se entrega fuera del PDF)
```

---

## ⚙️ Tecnologías utilizadas

- **Base de datos:** MySQL 8.0 (compatible con 5.7+)
- **Lenguaje:** SQL estándar
- **Herramientas:** MySQL Workbench / DBeaver
- **Codificación:** UTF-8 (utf8mb4_general_ci)

---

## 🚀 Ejecución y pruebas

1. Crear la base de datos:

   ```sql
   CREATE DATABASE tp_integrador_bd1 CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
   USE tp_integrador_bd1;
   ```

2. Ejecutar los scripts **en orden numérico**:

   ```plaintext
   01_esquema.sql
   02_catalogos.sql
   03_carga_masiva.sql
   04_indices.sql
   05_consultas.sql
   05_01_explain.sql
   06_vistas.sql
   07_seguridad.sql
   08_transacciones.sql
   09_concurrencia_guiada.sql
   ```

3. Validar resultados:
   - Contar registros (`SELECT COUNT(*) FROM ...;`)
   - Revisar tiempos de ejecución en `05_consultas.sql`
   - Verificar uso de índices con `05_01_explain.sql`
   - Confirmar roles y restricciones de seguridad en `07_seguridad.sql`

---

## 📊 Resultados y evidencias

- **Carga masiva:**  
  10 000 clientes, 10 000 perfiles y 50 000 ventas generadas automáticamente.

- **Optimización:**  
  Comparaciones de rendimiento *con y sin índices* (Etapa 3) muestran reducciones de tiempo de hasta **85 %** en consultas de rango.

- **Integridad y seguridad:**  
  Constraints CHECK, FK, PK validados con inserciones erróneas.  
  Roles de usuario con permisos limitados.

- **Concurrencia:**  
  Simulación de deadlocks y niveles de aislamiento (`READ COMMITTED`, `REPEATABLE READ`).

---

## 🤝 Integrantes

| Nombre | Rol / Aporte |
|--------|---------------|
| **[Danilo Peirano]** | Modelado lógico y DER |
| **[Pérez Lucio]** | Carga masiva y consultas |
| **[Pérez Leandro]** | Índices y optimización |
| **[Valentin Piñeyro]** | Seguridad, transacciones y concurrencia |
| **Comisión:** 5 | **Grupo:** Y |

> 📹 Presentación en video:

---

## 📄 Licencia y uso

Proyecto académico para la **Universidad Tecnológica Nacional**  
Materia: **Bases de Datos I**  
Año: **2025**

Este material se distribuye con fines educativos.  
Los scripts son reproducibles en MySQL y pueden adaptarse para otros motores de BD.

---

> **Repositorio del trabajo:**  
> [https://github.com/matiasplm/UTN-TPT-BD1.git]
