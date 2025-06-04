// ignore_for_file: deprecated_member_use

import 'package:finpay/api/local.db.service.dart';
import 'package:finpay/config/textstyle.dart';
import 'package:finpay/model/sistema_reservas.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopUpSCreen extends StatefulWidget {
  const TopUpSCreen({Key? key}) : super(key: key);

  @override
  State<TopUpSCreen> createState() => _TopUpSCreenState();
}

class _TopUpSCreenState extends State<TopUpSCreen> {
  List<Reserva> reservasPendientes = [];
  Reserva? reservaSeleccionada;

  @override
  void initState() {
    super.initState();
    cargarReservasPendientes();
  }

  Future<void> cargarReservasPendientes() async {
    final db = LocalDBService();
    final raw = await db.getAll("reservas.json");
    setState(() {
      reservasPendientes = raw
          .map<Reserva>((e) => Reserva.fromJson(e))
          .where((r) => r.estadoReserva == "PENDIENTE")
          .toList();
    });
  }

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

  // Opción 1: SnackBar
  void mostrarSnackBar(BuildContext context, String codigoReserva) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reserva número $codigoReserva pagada'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Opción 2: AlertDialog
  void mostrarAlertDialog(BuildContext context, String codigoReserva) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pago Exitoso'),
          content: Text('Reserva número $codigoReserva pagada'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Opción 3: GetX Snackbar
  void mostrarGetXSnackbar(String codigoReserva) {
    Get.snackbar(
      'Pago Exitoso',
      'Reserva número $codigoReserva pagada',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.isLightTheme == false
          ? HexColor('#15141f')
          : HexColor(AppTheme.primaryColorString!),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      "Pagar Reserva",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const Expanded(child: SizedBox()),
                    const Icon(Icons.arrow_back, color: Colors.transparent),
                  ],
                ),
              ),
              // Main Content
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Container(
                  height: Get.height - 107,
                  width: Get.width,
                  decoration: BoxDecoration(
                    color: AppTheme.isLightTheme == false
                        ? const Color(0xff211F32)
                        : Theme.of(context).appBarTheme.backgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          "Seleccione una reserva pendiente",
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<Reserva>(
                            isExpanded: true,
                            value: reservaSeleccionada,
                            hint: const Text('Seleccione una reserva'),
                            items: reservasPendientes.map((reserva) {
                              return DropdownMenuItem<Reserva>(
                                value: reserva,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Reserva: ${reserva.codigoReserva}'),
                                    Text(
                                      'Auto: ${reserva.chapaAuto} - \$${reserva.monto}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (Reserva? newValue) {
                              setState(() {
                                reservaSeleccionada = newValue;
                              });
                            },
                          ),
                        ),
                        if (reservaSeleccionada != null) ...[
                          const SizedBox(height: 20),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Detalles de la Reserva',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 10),
                                  Text('Auto: ${reservaSeleccionada!.chapaAuto}'),
                                  Text('Monto: \$${reservaSeleccionada!.monto}'),
                                  Text('Desde: ${reservaSeleccionada!.horarioInicio.toString().substring(0, 16)}'),
                                  Text('Hasta: ${reservaSeleccionada!.horarioSalida.toString().substring(0, 16)}'),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Duración: ${calcularTiempo(
                                      reservaSeleccionada!.horarioInicio,
                                      reservaSeleccionada!.horarioSalida,
                                    )}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Bottom Button
          if (reservaSeleccionada != null)
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 20,
                left: 20,
                right: 20,
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (reservaSeleccionada != null) {
                    // Actualizar el estado de la reserva
                    final db = LocalDBService();
                    final reservas = await db.getAll("reservas.json");
                    final index = reservas.indexWhere(
                      (r) => r['codigoReserva'] == reservaSeleccionada!.codigoReserva
                    );
                    
                    if (index != -1) {
                      reservas[index]['estadoReserva'] = 'PAGADO';
                      await db.saveAll("reservas.json", reservas);
                      
                      // Mostrar mensaje de éxito
                      mostrarSnackBar(context, reservaSeleccionada!.codigoReserva);
                      
                      // Esperar un momento antes de volver
                      await Future.delayed(const Duration(seconds: 2));
                      Navigator.pop(context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Pagar \$${reservaSeleccionada?.monto}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
