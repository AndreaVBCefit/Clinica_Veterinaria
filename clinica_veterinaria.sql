-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 02-12-2024 a las 07:12:14
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `clinica_veterinaria`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ProgramarCita` (IN `p_id_mascota` INT, IN `p_fecha` DATE, IN `p_hora` TIME, IN `p_motivo` VARCHAR(225), IN `p_observaciones` TEXT)   BEGIN
    INSERT INTO Citas (id_mascota, fecha, hora, motivo, observaciones)
    VALUES (p_id_mascota, p_fecha, p_hora, p_motivo, p_observaciones);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RegistrarMascota` (IN `p_nombre` VARCHAR(100), IN `p_especie` VARCHAR(50), IN `p_raza` VARCHAR(50), IN `p_edad` INT, IN `p_id_dueño` INT)   BEGIN
    INSERT INTO Mascotas (nombre, especie, raza, edad, id_dueño)
    VALUES (p_nombre, p_especie, p_raza, p_edad, p_id_dueño);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RegistrarTratamiento` (IN `p_id_mascota` INT, IN `p_fecha_consulta` DATE, IN `p_motivo_consulta` VARCHAR(225), IN `p_diagnostico` TEXT, IN `p_tratamiento ` TEXT, IN `p_observaciones` TEXT)   BEGIN
    INSERT INTO HistorialMedico (id_mascota, fecha_consulta, motivo_consulta, diagnostico, tratamiento, observaciones)
    VALUES (p_id_mascota, p_fecha_consulta, p_motivo_consulta, p_diagnostico, p_tratamiento, p_observaciones);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RegistrarVacunacion` (IN `p_id_mascota` INT, IN `p_nombre_vacuna` VARCHAR(100), IN `p_fecha_vacunacion` DATE, IN `p_proxima_vacunacion` DATE)   BEGIN
    INSERT INTO Vacunaciones (id_mascota, nombre_vacuna, fecha_vacunacion, proxima_vacunacion)
    VALUES (p_id_mascota, p_nombre_vacuna, p_fecha_vacunacion, p_proxima_vacunacion);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `alertas`
--

CREATE TABLE `alertas` (
  `id_alerta` int(11) NOT NULL,
  `mensaje` varchar(255) DEFAULT NULL,
  `fecha_alerta` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `citas`
--

CREATE TABLE `citas` (
  `id_cita` int(11) NOT NULL,
  `id_mascota` int(11) DEFAULT NULL,
  `fecha` date NOT NULL,
  `hora` time NOT NULL,
  `motivo` varchar(255) DEFAULT NULL,
  `observaciones` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `dueños`
--

CREATE TABLE `dueños` (
  `id_dueño` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `telefono` varchar(15) DEFAULT NULL,
  `correo_electronico` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `gestionmedicamentos`
--

CREATE TABLE `gestionmedicamentos` (
  `id_gestion` int(11) NOT NULL,
  `id_mascota` int(11) DEFAULT NULL,
  `id_medicamento` int(11) DEFAULT NULL,
  `fecha_administracion` date NOT NULL,
  `dosis` varchar(50) DEFAULT NULL,
  `observaciones` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `gestionmedicamentos`
--
DELIMITER $$
CREATE TRIGGER `control_stock_medicamentos` AFTER INSERT ON `gestionmedicamentos` FOR EACH ROW BEGIN
    DECLARE cantidad_disponible INT;

    -- Obtiene la cantidad actual disponible del medicamento.
    SELECT cantidad_disponible INTO cantidad_disponible
    FROM Medicamentos
    WHERE id_medicamento = NEW.id_medicamento;

    -- Verifica si hay suficiente stock para la administración.
    IF cantidad_disponible >= NEW.dosis THEN
        -- Actualiza el stock después de la administración del medicamento.
        UPDATE Medicamentos
        SET cantidad_disponible = cantidad_disponible - NEW.dosis
        WHERE id_medicamento = NEW.id_medicamento;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente para la administración del medicamento';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historialcambios`
--

CREATE TABLE `historialcambios` (
  `id_cambio` int(11) NOT NULL,
  `id_historial` int(11) DEFAULT NULL,
  `fecha_cambio` date DEFAULT NULL,
  `motivo_cambio` varchar(255) DEFAULT NULL,
  `usuario` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historialmedico`
--

CREATE TABLE `historialmedico` (
  `id_historial` int(11) NOT NULL,
  `id_mascota` int(11) DEFAULT NULL,
  `fecha_consulta` date NOT NULL,
  `motivo_consulta` varchar(255) DEFAULT NULL,
  `diagnostico` text DEFAULT NULL,
  `tratamiento` text DEFAULT NULL,
  `observaciones` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `historialmedico`
--
DELIMITER $$
CREATE TRIGGER `registrar_cambio_historial` AFTER UPDATE ON `historialmedico` FOR EACH ROW BEGIN
    INSERT INTO HistorialCambios (
        id_historial, fecha_cambio, motivo_cambio, usuario
    )
    VALUES (
        NEW.id_historial, CURDATE(), 'Actualización de historial médico', 'UsuarioActual'
    );
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mascotas`
--

CREATE TABLE `mascotas` (
  `id_mascota` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `especie` varchar(50) DEFAULT NULL,
  `raza` varchar(50) DEFAULT NULL,
  `edad` int(11) DEFAULT NULL,
  `id_dueño` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `mascotas`
--

INSERT INTO `mascotas` (`id_mascota`, `nombre`, `especie`, `raza`, `edad`, `id_dueño`) VALUES
(1, 'CREATE PROCEDURE RegistrarMascota(\r\n    IN p_nombre VARCHAR(100),\r\n    IN p_especie VARCHAR(50),\r\n  ', NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `medicamentos`
--

CREATE TABLE `medicamentos` (
  `id_medicamento` int(11) NOT NULL,
  `nombre_medicamento` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `fecha_vencimiento` date DEFAULT NULL,
  `cantidad_disponible` int(11) DEFAULT NULL,
  `precio` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vacunaciones`
--

CREATE TABLE `vacunaciones` (
  `id_vacunacion` int(11) NOT NULL,
  `id_mascota` int(11) DEFAULT NULL,
  `nombre_vacuna` varchar(100) DEFAULT NULL,
  `fecha_vacunacion` date NOT NULL,
  `proxima_vacunacion` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `vacunaciones`
--
DELIMITER $$
CREATE TRIGGER `alerta_proxima_vacunacion` AFTER INSERT ON `vacunaciones` FOR EACH ROW BEGIN
    DECLARE dias_diferencia INT;

    -- Calcula la diferencia en días entre la fecha de la próxima vacunación y la fecha actual.
    SET dias_diferencia = DATEDIFF(NEW.proxima_vacunacion, CURDATE());

    -- Verifica si la próxima vacunación es dentro de 7 días.
    IF dias_diferencia BETWEEN 0 AND 7 THEN
        INSERT INTO Alertas (mensaje, fecha_alerta)
        VALUES (CONCAT('La mascota con ID ', NEW.id_mascota, ' tiene una vacunación próxima en ', NEW.proxima_vacunacion), CURDATE());
    END IF;
END
$$
DELIMITER ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `alertas`
--
ALTER TABLE `alertas`
  ADD PRIMARY KEY (`id_alerta`);

--
-- Indices de la tabla `citas`
--
ALTER TABLE `citas`
  ADD PRIMARY KEY (`id_cita`),
  ADD KEY `id_mascota` (`id_mascota`);

--
-- Indices de la tabla `dueños`
--
ALTER TABLE `dueños`
  ADD PRIMARY KEY (`id_dueño`);

--
-- Indices de la tabla `gestionmedicamentos`
--
ALTER TABLE `gestionmedicamentos`
  ADD PRIMARY KEY (`id_gestion`),
  ADD KEY `id_mascota` (`id_mascota`),
  ADD KEY `id_medicamento` (`id_medicamento`);

--
-- Indices de la tabla `historialcambios`
--
ALTER TABLE `historialcambios`
  ADD PRIMARY KEY (`id_cambio`);

--
-- Indices de la tabla `historialmedico`
--
ALTER TABLE `historialmedico`
  ADD PRIMARY KEY (`id_historial`),
  ADD KEY `id_mascota` (`id_mascota`);

--
-- Indices de la tabla `mascotas`
--
ALTER TABLE `mascotas`
  ADD PRIMARY KEY (`id_mascota`),
  ADD KEY `id_dueño` (`id_dueño`);

--
-- Indices de la tabla `medicamentos`
--
ALTER TABLE `medicamentos`
  ADD PRIMARY KEY (`id_medicamento`);

--
-- Indices de la tabla `vacunaciones`
--
ALTER TABLE `vacunaciones`
  ADD PRIMARY KEY (`id_vacunacion`),
  ADD KEY `id_mascota` (`id_mascota`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `alertas`
--
ALTER TABLE `alertas`
  MODIFY `id_alerta` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `citas`
--
ALTER TABLE `citas`
  MODIFY `id_cita` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `dueños`
--
ALTER TABLE `dueños`
  MODIFY `id_dueño` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `gestionmedicamentos`
--
ALTER TABLE `gestionmedicamentos`
  MODIFY `id_gestion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `historialcambios`
--
ALTER TABLE `historialcambios`
  MODIFY `id_cambio` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `historialmedico`
--
ALTER TABLE `historialmedico`
  MODIFY `id_historial` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `mascotas`
--
ALTER TABLE `mascotas`
  MODIFY `id_mascota` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `medicamentos`
--
ALTER TABLE `medicamentos`
  MODIFY `id_medicamento` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `vacunaciones`
--
ALTER TABLE `vacunaciones`
  MODIFY `id_vacunacion` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `citas`
--
ALTER TABLE `citas`
  ADD CONSTRAINT `citas_ibfk_1` FOREIGN KEY (`id_mascota`) REFERENCES `mascotas` (`id_mascota`);

--
-- Filtros para la tabla `gestionmedicamentos`
--
ALTER TABLE `gestionmedicamentos`
  ADD CONSTRAINT `gestionmedicamentos_ibfk_1` FOREIGN KEY (`id_mascota`) REFERENCES `mascotas` (`id_mascota`),
  ADD CONSTRAINT `gestionmedicamentos_ibfk_2` FOREIGN KEY (`id_medicamento`) REFERENCES `medicamentos` (`id_medicamento`);

--
-- Filtros para la tabla `historialmedico`
--
ALTER TABLE `historialmedico`
  ADD CONSTRAINT `historialmedico_ibfk_1` FOREIGN KEY (`id_mascota`) REFERENCES `mascotas` (`id_mascota`);

--
-- Filtros para la tabla `mascotas`
--
ALTER TABLE `mascotas`
  ADD CONSTRAINT `mascotas_ibfk_1` FOREIGN KEY (`id_dueño`) REFERENCES `dueños` (`id_dueño`);

--
-- Filtros para la tabla `vacunaciones`
--
ALTER TABLE `vacunaciones`
  ADD CONSTRAINT `vacunaciones_ibfk_1` FOREIGN KEY (`id_mascota`) REFERENCES `mascotas` (`id_mascota`);

DELIMITER $$
--
-- EVENTOS Recordatorio Citas
--
CREATE DEFINER=`root`@`localhost` EVENT `RecordatorioCitasProximas` 
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO BEGIN
    DECLARE fecha_actual DATE;
    SET fecha_actual = CURDATE();

    -- Inserta un recordatorio para citas próximas en los próximos 7 días.
    INSERT INTO Alertas (mensaje, fecha_alerta)
    SELECT 
        CONCAT('La mascota con ID ', id_mascota, ' tiene una cita programada para ', fecha, ' a las ', hora),
        fecha_actual
    FROM Citas
    WHERE fecha BETWEEN fecha_actual AND DATE_ADD(fecha_actual, INTERVAL 7 DAY);
END$$

DELIMITER ;
COMMIT;

--
-- EVENTOS Calendario de vacunacion
--
CREATE DEFINER=`root`@`localhost` EVENT `ActualizacionCalendarioVacunacion` 
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DECLARE fecha_actual DATE;
    SET fecha_actual = CURDATE();

    -- Actualiza la tabla de vacunaciones para recordar la próxima fecha de vacunación.
    UPDATE Vacunaciones
    SET proxima_vacunacion = DATE_ADD(fecha_vacunacion, INTERVAL 1 YEAR)
    WHERE proxima_vacunacion <= DATE_ADD(fecha_actual, INTERVAL 30 DAY);
END;

--
-- EVENTOS Reporte Mensual Tratamiento
--
CREATE DEFINER=`root`@`localhost` EVENT `ReporteMensualTratamientos`
ON SCHEDULE
    EVERY 1 MONTH
    STARTS '2024-12-01 00:00:00'
DO
BEGIN
    DECLARE fecha_actual DATE;
    SET fecha_actual = CURDATE();

    -- Inserta un reporte mensual con los detalles de los tratamientos realizados.
    INSERT INTO ReportesTratamientos (id_mascota, fecha_consulta, motivo_consulta, diagnostico, tratamiento, observaciones, fecha_reporte)
    SELECT id_mascota, fecha_consulta, motivo_consulta, diagnostico, tratamiento, observaciones, fecha_actual
    FROM HistorialMedico
    WHERE MONTH(fecha_consulta) = MONTH(fecha_actual) AND YEAR(fecha_consulta) = YEAR(fecha_actual);
END;

--
-- HABILITAR EVENTO - se peude borrar
--
SET GLOBAL event_scheduler = ON;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
