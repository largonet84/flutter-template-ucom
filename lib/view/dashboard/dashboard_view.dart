import 'package:finpay/controller/home_controller.dart';
import 'package:finpay/utils/utiles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardView extends StatelessWidget {
  final HomeController homeController;

  const DashboardView({Key? key, required this.homeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pagos previos",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            ...homeController.pagosPrevios.map((pago) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: Text("Reserva: ${pago.codigoReservaAsociada}"),
                  subtitle: Text("Fecha: ${UtilesApp.formatearFechaDdMMAaaa(pago.fechaPago)}"),
                  trailing: Text("- ${UtilesApp.formatearGuaranies(pago.montoPagado)} ₲"),
                ),
              );
            }).toList(),
          ],
        );
      }),
    );
  }
}
