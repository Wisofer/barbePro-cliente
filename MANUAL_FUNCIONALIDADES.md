# 📱 Manual de Funcionalidades - BarbeNic

**Sistema de gestión profesional para barberías**

---

## 📋 Índice

1. [Inicio de Sesión](#inicio-de-sesión)
2. [Dashboard (Inicio)](#dashboard-inicio)
3. [Citas](#citas)
4. [Servicios](#servicios)
5. [Finanzas](#finanzas)
6. [Código QR](#código-qr)
7. [Empleados](#empleados)
8. [Perfil](#perfil)
9. [Configuración](#configuración)
10. [Modo Demo](#modo-demo)
11. [Exportación de Datos](#exportación-de-datos)
12. [Reportes](#reportes)

---

## 🔐 Inicio de Sesión

### Funcionalidades
- **Login con email y contraseña**
  - Validación de campos requeridos
  - Manejo de errores de autenticación
  - Mensajes de error claros y específicos

- **Recordar credenciales**
  - Opción para guardar email y contraseña
  - Almacenamiento seguro en el dispositivo
  - Carga automática al abrir la app

- **Modo Demo**
  - Acceso sin credenciales reales
  - Enlace "Ver demo" en la pantalla de login
  - Permite explorar todas las funcionalidades con datos de prueba

- **Feedback de audio**
  - Sonido de éxito al iniciar sesión correctamente
  - Sonido de error si las credenciales son inválidas

---

## 📊 Dashboard (Inicio)

### Disponible solo para Barbero (Dueño)

El Dashboard proporciona una vista general del negocio con estadísticas en tiempo real:

#### Estadísticas Rápidas
- **Citas de hoy**: Número total de citas programadas para el día actual
- **Ingresos de hoy**: Total de ingresos generados en el día
- **Ingresos del mes**: Total de ingresos del mes actual
- **Egresos de hoy**: Total de gastos del día
- **Egresos del mes**: Total de gastos del mes actual

#### Estadísticas Adicionales
- **Total de servicios**: Cantidad de servicios activos
- **Total de clientes**: Número de clientes registrados
- **Total de empleados**: Cantidad de trabajadores activos

#### Próximas Citas
- Lista de citas próximas (no completadas ni canceladas)
- Información rápida: cliente, hora, servicios
- Navegación rápida a detalles de la cita
- Opción para ocultar citas específicas

#### Navegación Rápida
- Botones para acceder rápidamente a:
  - Citas
  - Servicios
  - Finanzas

---

## 📅 Citas

### Funcionalidades para Barbero y Empleado

#### Vista Principal de Citas
- **Pestañas de filtrado**:
  - **Hoy**: Citas del día actual
  - **Pendientes**: Citas que requieren confirmación
  - **Historial**: Todas las citas pasadas

- **Badge de notificaciones**:
  - Contador en el icono de "Citas" en el navbar
  - Muestra número de citas pendientes
  - Se actualiza automáticamente cuando:
    - La app vuelve al foreground
    - Se entra a la pantalla de citas
    - Se crea, actualiza o elimina una cita

- **Crear nueva cita**:
  - Botón "+" para crear citas manualmente
  - Formulario completo con:
    - Nombre del cliente
    - Teléfono del cliente
    - Selección de fecha
    - Selección de hora
    - Selección de uno o múltiples servicios
  - Las citas creadas manualmente se crean como **"Confirmadas"** automáticamente
  - Audio de éxito al crear exitosamente

#### Detalles de Cita
- **Información completa**:
  - Cliente (nombre y teléfono)
  - Fecha y hora
  - Servicios seleccionados
  - Precio total calculado automáticamente
  - Estado actual de la cita

- **Gestión de estados**:
  - **Pendiente** → **Confirmada**: Confirmar cita pendiente
  - **Confirmada** → **Completada**: Marcar como completada
  - Si se completa sin servicios, permite agregar servicios antes de completar
  - Audio de éxito al cambiar estado

- **Acciones disponibles**:
  - **Confirmar cita** (solo si está pendiente)
  - **Completar cita** (solo si está confirmada)
  - **Enviar WhatsApp** (solo Barbero, cuando se confirma una cita)
  - **Eliminar cita** (solo Barbero)
  - Audio de éxito/error según la operación

#### Estados de Citas
- **Pending (Pendiente)**: Cita creada por cliente, esperando confirmación
- **Confirmed (Confirmada)**: Cita confirmada por barbero/empleado
- **Completed (Completada)**: Cita finalizada
- **Cancelled (Cancelada)**: Cita cancelada

#### Filtros y Búsqueda
- Filtrado por fecha (Hoy)
- Filtrado por estado (Pendientes)
- Historial completo de todas las citas

---

## ✂️ Servicios

### Funcionalidades para Barbero

#### Gestión de Servicios
- **Crear servicio**:
  - Nombre del servicio
  - Precio (formato nicaragüense con separadores de miles)
  - Duración en minutos (opcional)
  - Estado activo/inactivo
  - Audio de éxito al crear

- **Editar servicio**:
  - Modificar todos los campos
  - Activar/desactivar servicio
  - Audio de éxito al actualizar

- **Eliminar servicio**:
  - Confirmación antes de eliminar
  - Solo Barbero puede eliminar

- **Lista de servicios**:
  - Vista de todos los servicios activos
  - Información: nombre, precio formateado, duración
  - Acceso rápido para editar o eliminar

### Funcionalidades para Empleado
- **Solo lectura**: Los empleados pueden ver los servicios pero no crearlos, editarlos o eliminarlos

---

## 💰 Finanzas

### Disponible para Barbero y Empleado

#### Vista Principal de Finanzas
- **Resumen financiero**:
  - Ingresos del mes actual
  - Egresos del mes actual
  - Ganancia neta del mes
  - Totales históricos (ingresos, egresos, ganancia neta)

- **Accesos rápidos**:
  - Botón para ver **Ingresos**
  - Botón para ver **Egresos**

#### Gestión de Ingresos
- **Crear ingreso**:
  - Monto del ingreso
  - Descripción
  - Categoría (opcional)
  - Fecha
  - Audio de éxito al crear

- **Lista de ingresos**:
  - Vista paginada de todos los ingresos
  - Filtrado por rango de fechas
  - Formato de dinero nicaragüense (separadores de miles)
  - Información: monto, descripción, categoría, fecha

#### Gestión de Egresos (Gastos)
- **Crear egreso**:
  - Monto del gasto
  - Descripción
  - Categoría (opcional)
  - Fecha
  - Audio de éxito al crear

- **Editar egreso**:
  - Modificar todos los campos
  - Audio de éxito al actualizar

- **Lista de egresos**:
  - Vista paginada de todos los egresos
  - Filtrado por rango de fechas
  - Formato de dinero nicaragüense
  - Información: monto, descripción, categoría, fecha

#### Formato de Dinero
- Todos los valores monetarios se muestran en formato nicaragüense:
  - Separador de miles: coma (`,`)
  - Separador de decimales: punto (`.`)
  - Símbolo: C$ (Córdobas)
  - Ejemplo: C$21,000

---

## 📱 Código QR

### Disponible solo para Barbero

#### Generación de QR
- **Código QR personalizado**:
  - Generado automáticamente para cada barbero
  - Contiene URL única para agendar citas
  - Visualización en pantalla completa

#### Compartir QR
- **Compartir código QR**:
  - Botón para compartir el QR
  - Genera imagen PNG del código
  - Comparte por WhatsApp, email, redes sociales, etc.
  - Incluye mensaje con nombre del barbero y URL

#### Uso del QR
- Los clientes escanean el código QR
- Son dirigidos a una página web donde pueden:
  - Ver información del barbero
  - Agendar citas directamente
  - Seleccionar servicios
  - Elegir fecha y hora

---

## 👥 Empleados

### Disponible solo para Barbero

#### Gestión de Empleados
- **Crear empleado**:
  - Nombre completo
  - Email (único)
  - Contraseña
  - Teléfono (opcional)
  - Estado activo/inactivo
  - Audio de éxito al crear

- **Editar empleado**:
  - Modificar nombre
  - Actualizar teléfono
  - Activar/desactivar empleado
  - Audio de éxito al actualizar

- **Eliminar empleado**:
  - Desactivar empleado (no se elimina físicamente)
  - Confirmación antes de desactivar

- **Lista de empleados**:
  - Vista de todos los empleados
  - Información: nombre, email, teléfono, estado
  - Indicador visual de estado (activo/inactivo)

#### Permisos de Empleados
Los empleados pueden:
- ✅ Ver y gestionar citas (crear, confirmar, completar)
- ✅ Ver servicios (solo lectura)
- ✅ Ver y gestionar finanzas (ingresos y egresos)
- ✅ Ver su perfil personal
- ❌ NO pueden eliminar citas
- ❌ NO pueden crear/editar/eliminar servicios
- ❌ NO pueden gestionar otros empleados
- ❌ NO pueden acceder al Dashboard
- ❌ NO pueden ver/exportar reportes
- ❌ NO pueden acceder al código QR

---

## 👤 Perfil

### Funcionalidades Comunes (Barbero y Empleado)

#### Información del Perfil
- **Datos personales**:
  - Nombre completo
  - Email
  - Teléfono
  - Nombre del negocio (solo Barbero)

- **Editar perfil**:
  - Modificar nombre
  - Actualizar teléfono
  - Cambiar nombre del negocio (solo Barbero)
  - Audio de éxito al actualizar

#### Cambiar Contraseña
- Formulario seguro para cambiar contraseña
- Validación de contraseña actual
- Confirmación de nueva contraseña
- Audio de éxito al cambiar

#### Opciones Adicionales (Solo Barbero)
- **Código QR**: Acceso directo al código QR
- **URL Pública**: Ver y copiar URL pública del perfil
- **Exportar Datos**: Generar reportes y backups
- **Reportes de Empleados**: Ver estadísticas por empleado

---

## ⚙️ Configuración

### Disponible para Barbero y Empleado

#### Apariencia
- **Modo Oscuro/Claro**:
  - Switch para activar/desactivar modo oscuro
  - Cambio inmediato en toda la aplicación
  - Persistencia de preferencia

#### Notificaciones
- **Notificaciones Push**: 
  - Disponible próximamente
  - Preparado para futuras implementaciones

- **Sonidos**:
  - Switch para activar/desactivar sonidos
  - Controla todos los audios de la aplicación
  - Estado: "Activados" / "Desactivados"
  - Cambio inmediato sin reiniciar la app
  - Persistencia de preferencia

#### Idioma
- **Idioma de la Aplicación**:
  - Actualmente: Español
  - Preparado para futuras traducciones

---

## 🎮 Modo Demo

### Funcionalidades
- **Acceso sin credenciales**:
  - Enlace "Ver demo" en la pantalla de login
  - No requiere registro ni login

- **Datos de prueba**:
  - Citas de ejemplo
  - Servicios de ejemplo
  - Datos financieros de ejemplo
  - Empleados de ejemplo

- **Funcionalidad completa**:
  - Todas las pantallas disponibles
  - Todas las operaciones funcionan con datos mock
  - Perfecto para demostraciones y pruebas

- **Indicador visual**:
  - Banner "Modo Demo" en la pantalla de perfil
  - Opción "Salir del Demo" para volver al login

---

## 📤 Exportación de Datos

### Disponible solo para Barbero

#### Tipos de Reportes
1. **Reporte de Citas**:
   - Exporta todas las citas del mes
   - Formatos disponibles: CSV, Excel, PDF

2. **Reporte Financiero**:
   - Exporta ingresos y egresos
   - Formatos disponibles: CSV, Excel, PDF

3. **Reporte de Clientes**:
   - Exporta lista de clientes
   - Formatos disponibles: CSV, Excel, PDF

4. **Backup Completo**:
   - Exporta todos los datos del negocio
   - Formato: JSON
   - Incluye: citas, servicios, finanzas, clientes, empleados

#### Proceso de Exportación
- Seleccionar tipo de reporte
- Elegir formato (CSV, Excel, PDF)
- Generación automática del archivo
- Compartir archivo por WhatsApp, email, etc.
- Mensaje de éxito al completar

---

## 📊 Reportes

### Disponible solo para Barbero

#### Reportes de Empleados
- **Reporte de Citas por Empleado**:
  - Filtrar por empleado específico
  - Filtrar por rango de fechas
  - Estadísticas de citas por trabajador

- **Reporte de Ingresos por Empleado**:
  - Ingresos generados por cada empleado
  - Filtrar por rango de fechas
  - Comparación entre empleados

- **Reporte de Egresos por Empleado**:
  - Gastos asociados a cada empleado
  - Filtrar por rango de fechas

- **Reporte de Actividad**:
  - Actividad general del negocio
  - Estadísticas consolidadas

---

## 🎵 Sistema de Audios

### Funcionalidades
- **Sonidos de éxito**:
  - Se reproducen cuando operaciones se completan exitosamente
  - Ejemplos: crear cita, confirmar cita, crear servicio, etc.

- **Sonidos de error**:
  - Se reproducen cuando ocurren errores
  - Ejemplos: error de conexión, validación fallida, etc.

- **Control desde Configuración**:
  - Switch para activar/desactivar todos los sonidos
  - Cambio inmediato sin reiniciar
  - Persistencia de preferencia

---

## 🔔 Notificaciones Visuales

### Badge de Citas Pendientes
- **Contador en el navbar**:
  - Muestra número de citas pendientes
  - Actualización automática cuando:
    - La app vuelve al foreground
    - Se entra a la pantalla de citas
    - Se crea, actualiza o elimina una cita

---

## 📱 Características Técnicas

### Diseño Responsivo
- **Adaptación a diferentes tamaños de pantalla**:
  - Pantallas pequeñas (< 360px)
  - Pantallas medianas (360px - 600px)
  - Pantallas grandes (> 600px)
  - Ajuste automático de:
    - Tamaños de fuente
    - Espaciados y padding
    - Tamaños de iconos
    - Distribución de elementos

### Formato de Dinero
- **Formato nicaragüense**:
  - Separador de miles: coma (`,`)
  - Separador de decimales: punto (`.`)
  - Símbolo: C$ (Córdobas)
  - Implementado en:
    - Dashboard
    - Citas
    - Servicios
    - Finanzas

### Roles y Permisos
- **Barbero (Dueño)**:
  - Acceso completo a todas las funcionalidades
  - Gestión de empleados
  - Dashboard y reportes
  - Código QR y exportación

- **Empleado**:
  - Gestión de citas (crear, confirmar, completar)
  - Ver servicios (solo lectura)
  - Gestión de finanzas
  - Ver perfil personal
  - Acceso limitado según permisos

---

## 🚀 Funcionalidades Adicionales

### WhatsApp Integration
- **Enviar confirmación por WhatsApp**:
  - Disponible solo para Barbero
  - Se ofrece automáticamente al confirmar una cita
  - Genera mensaje pre-formateado con detalles de la cita
  - Abre WhatsApp con el mensaje listo para enviar

### Historial de Citas
- **Vista completa del historial**:
  - Todas las citas pasadas
  - Filtrado y búsqueda
  - Información detallada de cada cita

### Actualización en Tiempo Real
- **Refresh automático**:
  - Pull-to-refresh en todas las pantallas principales
  - Actualización al volver al foreground
  - Sincronización automática de datos

---

## 📝 Notas Importantes

### Citas Manuales
- Las citas creadas manualmente por barbero o empleado se crean automáticamente como **"Confirmadas"**
- Esto es porque el barbero/empleado está confirmando la cita al crearla

### Persistencia de Datos
- Todas las preferencias se guardan localmente
- Modo oscuro/claro
- Sonidos activados/desactivados
- Credenciales guardadas (si se selecciona)

### Seguridad
- Autenticación con JWT tokens
- Almacenamiento seguro de credenciales
- Validación de permisos por rol
- Manejo seguro de errores

---

## 🎯 Resumen de Funcionalidades por Rol

### Barbero (Dueño) - Acceso Completo
✅ Dashboard con estadísticas
✅ Gestión completa de citas (crear, editar, eliminar, confirmar, completar)
✅ Gestión completa de servicios (crear, editar, eliminar)
✅ Gestión completa de finanzas (ingresos y egresos)
✅ Gestión de empleados (crear, editar, desactivar)
✅ Código QR para clientes
✅ Exportación de datos y reportes
✅ Reportes de empleados
✅ Configuración completa

### Empleado - Acceso Limitado
✅ Gestión de citas (crear, confirmar, completar) - NO puede eliminar
✅ Ver servicios (solo lectura)
✅ Gestión de finanzas (ingresos y egresos)
✅ Ver perfil personal
✅ Configuración básica
❌ NO Dashboard
❌ NO Gestión de servicios
❌ NO Gestión de empleados
❌ NO Código QR
❌ NO Exportación de datos
❌ NO Reportes

---

**BarbeNic** - Sistema completo de gestión para barberías profesionales.

