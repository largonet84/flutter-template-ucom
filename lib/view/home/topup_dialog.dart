// ignore_for_file: deprecated_member_use

import 'package:finpay/model/sistema_reservas.dart';
import 'package:finpay/api/local.db.service.dart';
import 'package:finpay/controller/dashboard_controller.dart';
import 'package:finpay/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget topupDialog(BuildContext context, Reserva reserva) {
  String calcularTiempo(DateTime desde, DateTime hasta) {
    Duration diferencia = hasta.difference(desde);
    int dias = diferencia.inDays;
    int horas = diferencia.inHours % 24;

    String diaTexto = dias == 1 ? 'Día' : 'Días';
    String horaTexto = horas == 1 ? 'Hora' : 'Horas';

    if (dias == 0) {
      return '$horas $horaTexto';
    }
    return '$dias $diaTexto y $horas $horaTexto';
  }

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            Text(
              "Confirmar Pago",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(width: 40), // Para balance en el Row
          ],
        ),
        const SizedBox(height: 20),
        _buildDetailRow(context, "Vehículo", reserva.chapaAuto),
        _buildDivider(context),
        _buildDetailRow(context, "Tiempo",
            calcularTiempo(reserva.horarioInicio, reserva.horarioSalida)),
        _buildDivider(context),
        _buildDetailRow(context, "Monto", "\$${reserva.monto}"),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          child: MaterialButton(
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
            onPressed: () async {
              // Cerrar diálogo inmediatamente para evitar problemas de UI
              Navigator.of(context).pop();
              
              try {
                // Guardar la actualización
                final db = LocalDBService();
                await db.update(
                  "reservas.json",
                  "codigoReserva",
                  reserva.codigoReserva,
                  {...reserva.toJson(), 'estadoReserva': 'PAGADO'}
                );
                
                // También guardar el registro de pago
                final pagos = await db.getAll("pagos.json");
                pagos.add({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'codigoReservaAsociada': reserva.codigoReserva,
                  'montoPagado': reserva.monto,
                  'fechaPago': DateTime.now().toIso8601String(),
                });
                await db.saveAll("pagos.json", pagos);
                
                // Mostrar mensaje de éxito
                Get.snackbar(
                  'Pago confirmado',
                  'Reserva #${reserva.codigoReserva} pagada exitosamente',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.withValues(alpha: 179),
                  colorText: Colors.white,
                );
                
                // Actualizar el estado de la reserva
                reserva.estadoReserva = "PAGADO";
                await db.update("reservas.json", "codigoReserva", reserva.codigoReserva, reserva.toJson());
                
                debugPrint("✅ Pago procesado exitosamente para reserva: ${reserva.codigoReserva}");
                
                // Actualizar explícitamente el dashboard después del pago
                if (Get.isRegistered<DashboardController>()) {
                  final dashboardController = Get.find<DashboardController>();
                  await dashboardController.fetchDashboardData();
                  debugPrint("🔄 Dashboard actualizado después del pago");
                }
                
                // Actualizar las listas de reservas en el HomeController
                if (Get.isRegistered<HomeController>()) {
                  final homeController = Get.find<HomeController>();
                  await homeController.refrescarDatos();
                  debugPrint("🔄 HomeController actualizado después del pago");
                }
                
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'No se pudo procesar el pago: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.withValues(alpha: 179),
                  colorText: Colors.white,
                );
              }
            },
            child: const Text(
              "Confirmar",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildDetailRow(BuildContext context, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.withValues(alpha: 179),
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    ),
  );
}

Widget _buildDivider(BuildContext context) {
  return const Divider(height: 1);
}

// Para mostrar el diálogo de pago, llama a mostrarDialogoPago(context, reserva) desde tu widget,
// asegurándote de tener acceso a un BuildContext y una instancia de Reserva.
// Ejemplo de uso dentro de un widget:
//
// ElevatedButton(
//   onPressed: () {
//     mostrarDialogoPago(context, reservaSeleccionada);
//   },
//   child: Text('Pagar'),
// )

void mostrarDialogoPago(BuildContext context, Reserva reserva) {
  Get.bottomSheet(
    topupDialog(context, reserva),
    isScrollControlled: true,
  );
}
