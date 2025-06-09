import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:finpay/controller/dashboard_controller.dart';
import 'package:finpay/controller/tab_controller.dart';
import 'package:finpay/model/sistema_reservas.dart';
import 'package:finpay/utils/utiles.dart';
import '../../config/textstyle.dart';
import '../home/topup_dialog.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late DashboardController controller;
  
  @override
  void initState() {
    super.initState();
    controller = Get.find<DashboardController>();
    // Forzar una actualización cuando se carga la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDashboardData();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor(AppTheme.primaryColorString!),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Usar el TabScreenController para cambiar a la pestaña Home
            if (Get.isRegistered<TabScreenController>()) {
              final tabController = Get.find<TabScreenController>();
              tabController.pageIndex.value = 0; // Cambiar a la pestaña Home
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              controller.fetchDashboardData();
            },
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Obx(() => controller.isLoading.value 
        ? const Center(child: CircularProgressIndicator())
        : _buildDashboardContent(context)
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    return Obx(() {
      if (controller.reservasPendientes.isEmpty) {
        return const Center(
          child: Text(
            'No tienes reservas pendientes',
            style: TextStyle(fontSize: 16),
          )
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.reservasPendientes.length,
        itemBuilder: (context, index) {
          final reserva = controller.reservasPendientes[index];
          return _buildReservaCard(context, reserva);
        }
      );
    });
  }

  Widget _buildReservaCard(BuildContext context, Reserva reserva) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.withValues(alpha: 26),
                  child: const Icon(Icons.car_rental, color: Colors.blue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Reserva #${reserva.codigoReserva}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Vehículo: ${reserva.chapaAuto}",
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 51),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "PENDIENTE",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Fecha",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      UtilesApp.formatearFechaDdMMAaaa(reserva.horarioInicio),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Duración",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _calcularDuracion(reserva.horarioInicio, reserva.horarioSalida),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Monto",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₲ ${UtilesApp.formatearGuaranies(reserva.monto.toInt())}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Colors.green
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.bottomSheet(
                    topupDialog(context, reserva),
                    isScrollControlled: true,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor(AppTheme.primaryColorString!),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Pagar ahora"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calcularDuracion(DateTime inicio, DateTime fin) {
    final diferencia = fin.difference(inicio);
    final horas = diferencia.inHours;
    final minutos = diferencia.inMinutes % 60;
    
    if (horas == 0) {
      return '$minutos min';
    } else if (minutos == 0) {
      return '$horas h';
    } else {
      return '$horas h $minutos min';
    }
  }
}
