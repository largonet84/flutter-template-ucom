import 'package:flutter/material.dart';
import 'package:finpay/controller/home_controller.dart';
import 'package:get/get.dart';
import 'package:finpay/model/sistema_reservas.dart';
import 'package:finpay/api/local.db.service.dart';

class DashboardView extends StatefulWidget {
  final HomeController homeController;
  const DashboardView({Key? key, required this.homeController}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  List<Reserva> reservas = [];

  @override
  void initState() {
    super.initState();
    cargarReservas();
  }

  Future<void> cargarReservas() async {
    final db = LocalDBService();
    final raw = await db.getAll("reservas.json");
    setState(() {
      reservas = raw.map<Reserva>((e) => Reserva.fromJson(e)).toList();
    });
  }

  Future<void> eliminarReserva(String codigoReserva) async {
    final db = LocalDBService();
    final raw = await db.getAll("reservas.json");
    raw.removeWhere((e) => e['codigoReserva'] == codigoReserva);
    await db.saveAll("reservas.json", raw);
    await cargarReservas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: reservas.isEmpty
          ? const Center(child: Text('No hay reservas registradas'))
          : ListView.builder(
              itemCount: reservas.length,
              itemBuilder: (context, index) {
                final r = reservas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text('Reserva: ${r.codigoReserva}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Auto: ${r.chapaAuto}'),
                        Text('Estado: ${r.estadoReserva}'),
                        Text('Desde: ${r.horarioInicio}'),
                        Text('Hasta: ${r.horarioSalida}'),
                        Text('Monto: ${r.monto}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await eliminarReserva(r.codigoReserva);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
