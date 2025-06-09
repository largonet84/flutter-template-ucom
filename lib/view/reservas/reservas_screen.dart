import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:finpay/controller/reserva_controller.dart';
import 'package:finpay/model/sistema_reservas.dart';
import 'package:finpay/utils/utiles.dart';
import '../../widgets/loading_overlay.dart';
import '../../config/textstyle.dart';
import 'package:finpay/view/tab_screen.dart';

class ReservaScreen extends StatefulWidget {
  const ReservaScreen({super.key});

  @override
  State<ReservaScreen> createState() => _ReservaScreenState();
}

class _ReservaScreenState extends State<ReservaScreen> {
  final controller = Get.put(ReservaController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reservar lugar")),
      body: Obx(() => LoadingOverlay(
        isLoading: controller.isLoading.value,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Seleccionar auto",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                _buildAutoSelector(),
                const Text("Seleccionar piso",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<Piso>(
                  isExpanded: true,
                  value: controller.pisoSeleccionado.value,
                  hint: const Text("Seleccionar piso"),
                  onChanged: (p) => controller.seleccionarPiso(p!),
                  items: controller.pisos
                      .map((p) => DropdownMenuItem(
                          value: p, child: Text(p.descripcion)))
                      .toList(),
                ),
                const SizedBox(height: 16),
                const Text("Seleccionar lugar",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: GestureDetector(
                    onTapDown: (_) => HapticFeedback.selectionClick(),
                    child: GridView.count(
                      crossAxisCount: 5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: controller.lugaresDisponibles
                          .where((l) =>
                              l.codigoPiso ==
                              controller.pisoSeleccionado.value?.codigo)
                          .map((lugar) {
                        final seleccionado =
                            lugar == controller.lugarSeleccionado.value;
                        final color = lugar.estado == "RESERVADO"
                            ? Colors.red
                            : seleccionado
                                ? Colors.green
                                : Colors.grey.shade300;

                        return GestureDetector(
                          onTap: lugar.estado == "DISPONIBLE"
                              ? () => controller.lugarSeleccionado.value = lugar
                              : null,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: color,
                              border: Border.all(
                                  color: seleccionado
                                      ? Colors.green.shade700
                                      : Colors.black12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              lugar.codigoLugar,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lugar.estado == "reservado"
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Seleccionar horarios",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          // Verificar mounted aquí
                          if (!mounted) return;
                          if (date == null) return;
                          
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          // Verificar mounted nuevamente después de la segunda operación asíncrona
                          if (!mounted) return;
                          if (time == null) return;
                          
                          controller.horarioInicio.value = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        },
                        icon: const Icon(Icons.access_time),
                        label: Obx(() => Text(
                              controller.horarioInicio.value == null
                                  ? "Inicio"
                                  : "${UtilesApp.formatearFechaDdMMAaaa(controller.horarioInicio.value!)} ${TimeOfDay.fromDateTime(controller.horarioInicio.value!).format(context)}",
                            )),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: controller.horarioInicio.value ??
                                DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 30)),
                          );
                          if (!mounted) return;
                          if (date == null) return;
                          
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (!mounted) return;
                          if (time == null) return;
                          
                          controller.horarioSalida.value = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        },
                        icon: const Icon(Icons.timer_off),
                        label: Obx(() => Text(
                              controller.horarioSalida.value == null
                                  ? "Salida"
                                  : "${UtilesApp.formatearFechaDdMMAaaa(controller.horarioSalida.value!)} ${TimeOfDay.fromDateTime(controller.horarioSalida.value!).format(context)}",
                            )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Duración rápida",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [1, 2, 4, 6, 8].map((horas) {
                    final seleccionada =
                        controller.duracionSeleccionada.value == horas;
                    return ChoiceChip(
                      label: Text("$horas h"),
                      selected: seleccionada,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      onSelected: (_) {
                        controller.duracionSeleccionada.value = horas;
                        final inicio =
                            controller.horarioInicio.value ?? DateTime.now();
                        controller.horarioInicio.value = inicio;
                        controller.horarioSalida.value =
                            inicio.add(Duration(hours: horas));
                      },
                    );
                  }).toList(),
                ),
                Obx(() {
                  final inicio = controller.horarioInicio.value;
                  final salida = controller.horarioSalida.value;

                  if (inicio == null || salida == null) return const SizedBox();

                  final minutos = salida.difference(inicio).inMinutes;
                  final horas = minutos / 60;
                  final monto = (horas * 10000).round();

                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: Text(
                      "Monto estimado: ₲${UtilesApp.formatearGuaranies(monto)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      final confirmada = await controller.confirmarReserva();

                      if (!mounted) return;

                      if (confirmada) {
                        Get.snackbar(
                          "Reserva",
                          "Reserva realizada con éxito",
                          snackPosition: SnackPosition.BOTTOM,
                        );

                        await Future.delayed(const Duration(milliseconds: 2000));
                        
                        if (!mounted) return;
                        
                        // Cambiar la navegación para usar el constructor directamente
                        Get.offAll(() => const TabScreen());
                      } else {
                        Get.snackbar(
                          "Error",
                          "Verificá que todos los campos estén completos",
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red.shade100,
                          colorText: Colors.red.shade900,
                        );
                      }
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Confirmar Reserva",
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildAutoSelector() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        border: Border.all(
          color: controller.autoSeleccionado.value != null 
            ? Get.theme.primaryColor 
            : Colors.grey,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<Auto>(
        isExpanded: true,
        value: controller.autoSeleccionado.value,
        hint: const Text("Seleccionar auto"),
        onChanged: (auto) {
          controller.autoSeleccionado.value = auto;
        },
        items: controller.autosCliente.map((a) {
          final nombre = "${a.chapa} - ${a.marca} ${a.modelo}";
          return DropdownMenuItem(value: a, child: Text(nombre));
        }).toList(),
      ),
    );
  }
}