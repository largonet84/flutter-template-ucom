import 'package:flutter/material.dart';
import 'package:finpay/controller/home_controller.dart';

class DashboardView extends StatelessWidget {
  final HomeController homeController;
  const DashboardView({Key? key, required this.homeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ejemplo de contenido de Dashboard (puede ajustarse según necesidades)
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: Text(
          'Contenido del Dashboard',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
