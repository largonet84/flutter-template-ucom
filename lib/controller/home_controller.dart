// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/api/local.db.service.dart';
import 'package:finpay/model/sistema_reservas.dart';
import 'package:finpay/model/transaction_model.dart';
import 'package:finpay/config/textstyle.dart';
import 'package:finpay/config/images.dart';
import 'package:finpay/utils/utiles.dart';
import 'dart:math' as math;

class HomeController extends GetxController {
  List<TransactionModel> transactionList = List<TransactionModel>.empty().obs;
  RxBool isWeek = true.obs;
  RxBool isMonth = false.obs;
  RxBool isYear = false.obs;
  RxBool isAdd = false.obs;
  RxList<Pago> pagosPrevios = <Pago>[].obs;
  RxList<Reserva> reservasPagadasDelMes = <Reserva>[].obs;
  RxList<Reserva> reservasPendientes = <Reserva>[].obs;
  
  // Nuevas variables para estadísticas
  RxInt autosConReservasPendientes = 0.obs;
  RxInt autosConReservasPagadas = 0.obs;
  RxInt lugaresDisponibles = 0.obs;
  RxInt lugaresOcupados = 0.obs;

  @override
  void onInit() {
    super.onInit();
    customInit();
  }

  @override
  void onReady() {
    super.onReady();
    // Actualizar cada vez que la vista esté lista
    actualizarTodasLasReservas();
  }

  customInit() async {
    cargarPagosPrevios();
    await cargarReservasPagadasDelMes();
    await cargarReservasPendientes();
    await calcularEstadisticas();
    isWeek.value = true;
    isMonth.value = false;
    isYear.value = false;
    transactionList = [
      TransactionModel(
        Theme.of(Get.context!).textTheme.titleLarge!.color,
        DefaultImages.transaction4,
        "Apple Store",
        "iPhone 12 Case",
        "- \$120,90",
        "09:39 AM",
      ),
      TransactionModel(
        HexColor(AppTheme.primaryColorString!).withOpacity(0.10),
        DefaultImages.transaction3,
        "Ilya Vasil",
        "Wise • 5318",
        "- \$50,90",
        "05:39 AM",
      ),
      TransactionModel(
        Theme.of(Get.context!).textTheme.titleLarge!.color,
        "",
        "Burger King",
        "Cheeseburger XL",
        "- \$5,90",
        "09:39 AM",
      ),
      TransactionModel(
        HexColor(AppTheme.primaryColorString!).withOpacity(0.10),
        DefaultImages.transaction1,
        "Claudia Sarah",
        "Finpay Card • 5318",
        "- \$50,90",
        "04:39 AM",
      ),
    ];
  }

  Future<void> cargarPagosPrevios() async {
    final db = LocalDBService();
    final data = await db.getAll("pagos.json");

    pagosPrevios.value = data.map((json) => Pago.fromJson(json)).toList();
  }

  Future<void> cargarReservasPagadasDelMes() async {
    final db = LocalDBService();
    final data = await db.getAll("reservas.json");
    
    final todasLasReservas = data.map((json) => Reserva.fromJson(json)).toList();
    
    // Obtener el mes y año actual
    final ahora = DateTime.now();
    final inicioDelMes = DateTime(ahora.year, ahora.month, 1);
    final finDelMes = DateTime(ahora.year, ahora.month + 1, 0, 23, 59, 59);
    
    // Filtrar reservas pagadas del mes actual
    final reservasPagadas = todasLasReservas.where((reserva) {
      return reserva.estadoReserva == "PAGADO" &&
             reserva.horarioInicio.isAfter(inicioDelMes) &&
             reserva.horarioInicio.isBefore(finDelMes);
    }).toList();
    
    // Ordenar por fecha más reciente y tomar solo las últimas 3
    reservasPagadas.sort((a, b) => b.horarioInicio.compareTo(a.horarioInicio));
    
    reservasPagadasDelMes.value = reservasPagadas.take(3).toList();
    
    debugPrint("Reservas pagadas del mes: ${reservasPagadasDelMes.length}");
  }

  Future<void> cargarReservasPendientes() async {
    final db = LocalDBService();
    final data = await db.getAll("reservas.json");
    
    final todasLasReservas = data.map((json) => Reserva.fromJson(json)).toList();
    
    // Filtrar solo las reservas pendientes
    final pendientes = todasLasReservas.where((reserva) {
      return reserva.estadoReserva == "PENDIENTE";
    }).toList();
    
    // Ordenar por fecha más reciente y tomar solo las últimas 3
    pendientes.sort((a, b) => b.horarioInicio.compareTo(a.horarioInicio));
    
    reservasPendientes.value = pendientes.take(3).toList();
    
    debugPrint("Reservas pendientes: ${reservasPendientes.length}");
  }

  Future<void> calcularEstadisticas() async {
    final db = LocalDBService();
    
    try {
      // Obtener todas las reservas
      final reservasData = await db.getAll("reservas.json");
      final todasLasReservas = reservasData.map((json) => Reserva.fromJson(json)).toList();
      
      // Obtener todos los lugares de estacionamiento usando la estructura actual
      final lugaresData = await db.getAll("lugares.json");
      final totalLugares = lugaresData.length;
      
      // Calcular autos con reservas pendientes (únicos)
      final autosPendientes = todasLasReservas
          .where((r) => r.estadoReserva == "PENDIENTE")
          .map((r) => r.chapaAuto)
          .toSet();
      autosConReservasPendientes.value = autosPendientes.length;
      
      // Calcular autos con reservas pagadas (únicos)
      final autosPagados = todasLasReservas
          .where((r) => r.estadoReserva == "PAGADO")
          .map((r) => r.chapaAuto)
          .toSet();
      autosConReservasPagadas.value = autosPagados.length;
      
      // Calcular lugares ocupados basado en reservas activas del día actual
      final ahora = DateTime.now();
      final inicioDelDia = DateTime(ahora.year, ahora.month, ahora.day);
      final finDelDia = DateTime(ahora.year, ahora.month, ahora.day, 23, 59, 59);
      
      // Obtener reservas activas (que están en curso hoy)
      final reservasActivas = todasLasReservas.where((reserva) {
        // Verificar si la reserva está pagada o pendiente Y si está activa hoy
        final estaActiva = (reserva.estadoReserva == "PAGADO" || reserva.estadoReserva == "PENDIENTE") &&
               reserva.horarioInicio.isBefore(finDelDia) &&
               reserva.horarioSalida.isAfter(inicioDelDia);
        
        return estaActiva;
      }).toList();
      
      // Contar lugares únicos ocupados por reservas activas
      final lugaresOcupadosHoy = reservasActivas
          .where((r) => r.codigoLugar != null && r.codigoLugar!.isNotEmpty)
          .map((r) => r.codigoLugar!)
          .toSet()
          .length;
      
      // También verificar lugares marcados como "RESERVADO" u "OCUPADO" en el JSON
      final lugaresNoDisponibles = lugaresData.where((lugar) {
        final estado = lugar['estado']?.toString().toUpperCase() ?? 'DISPONIBLE';
        return estado == 'RESERVADO' || estado == 'OCUPADO';
      }).length;
      
      // Tomar el mayor entre las dos mediciones
      final lugaresOcupadosTotal = math.max(lugaresOcupadosHoy, lugaresNoDisponibles);
      
      lugaresOcupados.value = lugaresOcupadosTotal;
      lugaresDisponibles.value = totalLugares - lugaresOcupadosTotal;
      
      debugPrint("Estadísticas calculadas:");
      debugPrint("- Total de lugares: $totalLugares");
      debugPrint("- Autos con reservas pendientes: ${autosConReservasPendientes.value}");
      debugPrint("- Autos con reservas pagadas: ${autosConReservasPagadas.value}");
      debugPrint("- Lugares disponibles: ${lugaresDisponibles.value}");
      debugPrint("- Lugares ocupados: ${lugaresOcupados.value}");
      debugPrint("- Reservas activas hoy: ${reservasActivas.length}");
      
    } catch (e) {
      debugPrint("Error al calcular estadísticas: $e");
      // Valores por defecto en caso de error
      autosConReservasPendientes.value = 0;
      autosConReservasPagadas.value = 0;
      lugaresDisponibles.value = 6; // Basado en tu JSON actual
      lugaresOcupados.value = 0;
    }
  }

  // Nueva función para sincronizar el estado de los lugares con las reservas
  Future<void> sincronizarEstadosLugares() async {
    final db = LocalDBService();
    
    try {
      // Obtener datos actuales
      final reservasData = await db.getAll("reservas.json");
      final lugaresData = await db.getAll("lugares.json");
      
      final todasLasReservas = reservasData.map((json) => Reserva.fromJson(json)).toList();
      
      // Obtener reservas activas para hoy
      final ahora = DateTime.now();
      final inicioDelDia = DateTime(ahora.year, ahora.month, ahora.day);
      final finDelDia = DateTime(ahora.year, ahora.month, ahora.day, 23, 59, 59);
      
      final reservasActivas = todasLasReservas.where((reserva) {
        return (reserva.estadoReserva == "PAGADO" || reserva.estadoReserva == "PENDIENTE") &&
               reserva.horarioInicio.isBefore(finDelDia) &&
               reserva.horarioSalida.isAfter(inicioDelDia) &&
               reserva.codigoLugar != null;
      }).toList();
      
      final lugaresReservados = reservasActivas
          .map((r) => r.codigoLugar!)
          .toSet();
      
      // Actualizar el estado de cada lugar
      bool cambios = false;
      for (int i = 0; i < lugaresData.length; i++) {
        final codigoLugar = lugaresData[i]['codigoLugar'];
        final estadoActual = lugaresData[i]['estado']?.toString().toUpperCase() ?? 'DISPONIBLE';
        
        String nuevoEstado;
        if (lugaresReservados.contains(codigoLugar)) {
          nuevoEstado = 'RESERVADO';
        } else {
          nuevoEstado = 'DISPONIBLE';
        }
        
        if (estadoActual != nuevoEstado) {
          lugaresData[i]['estado'] = nuevoEstado;
          cambios = true;
        }
      }
      
      // Guardar cambios si los hay
      if (cambios) {
        await db.saveAll("lugares.json", lugaresData);
        debugPrint("Estados de lugares sincronizados");
      }
      
    } catch (e) {
      debugPrint("Error al sincronizar estados de lugares: $e");
    }
  }

  // Actualizar la función principal para incluir sincronización
  Future<void> actualizarTodasLasReservas() async {
    await cargarReservasPagadasDelMes();
    await cargarReservasPendientes();
    await sincronizarEstadosLugares(); // Sincronizar primero
    await calcularEstadisticas(); // Luego calcular estadísticas
  }

  // Función pública para forzar actualización desde otras pantallas
  Future<void> refrescarDatos() async {
    debugPrint("🔄 Refrescando datos del HomeController...");
    await actualizarTodasLasReservas();
  }
}
