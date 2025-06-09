import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/api/local.db.service.dart';
import 'package:finpay/model/sistema_reservas.dart';

class DashboardController extends GetxController {
  final db = LocalDBService();
  
  // Variables observables
  RxBool isLoading = false.obs;
  RxDouble totalBalance = 0.0.obs;
  RxList<Reserva> reservasPendientes = <Reserva>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      
      // Obtener todas las reservas
      final rawReservas = await db.getAll("reservas.json");
      if (rawReservas.isEmpty) {
        debugPrint("No hay reservas encontradas");
        reservasPendientes.clear();
        totalBalance.value = 0;
        return;
      }
      
      // Convertir y filtrar solo las pendientes
      final List<Reserva> todasLasReservas = rawReservas
          .map((e) => Reserva.fromJson(e))
          .toList();
      
      debugPrint("Total de reservas: ${todasLasReservas.length}");
      
      final pendientes = todasLasReservas
          .where((reserva) => reserva.estadoReserva == "PENDIENTE")
          .toList();
      
      debugPrint("Reservas pendientes: ${pendientes.length}");
      
      // Actualizar la lista
      reservasPendientes.value = pendientes;
      
      // Calcular balance total
      double total = 0;
      for (var reserva in pendientes) {
        total += reserva.monto;
      }
      totalBalance.value = total;
      
    } catch (e) {
      debugPrint("Error al cargar dashboard: $e");
      Get.snackbar(
        'Error',
        'No se pudieron cargar los datos del dashboard: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 179),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Método para actualizar una reserva específica
  Future<void> actualizarEstadoReserva(String codigoReserva, String nuevoEstado) async {
    try {
      // Obtener la reserva actual
      final rawReservas = await db.getAll("reservas.json");
      final index = rawReservas.indexWhere((r) => r['codigoReserva'] == codigoReserva);
      
      if (index >= 0) {
        // Actualizar el estado
        final reserva = {...rawReservas[index], 'estadoReserva': nuevoEstado};
        await db.update("reservas.json", "codigoReserva", codigoReserva, reserva);
        
        // Recargar datos
        await fetchDashboardData();
      }
    } catch (e) {
      debugPrint("Error al actualizar reserva: $e");
    }
  }
}