// ignore_for_file: deprecated_member_use

import 'package:card_swiper/card_swiper.dart';
import 'package:finpay/config/images.dart';
import 'package:finpay/config/textstyle.dart';
import 'package:finpay/controller/home_controller.dart';
import 'package:finpay/controller/reserva_controller.dart';
import 'package:finpay/model/sistema_reservas.dart'; // Asegúrate de que la clase Reserva esté definida aquí
import 'package:finpay/utils/utiles.dart';
import 'package:finpay/view/home/top_up_screen.dart';
import 'package:finpay/view/home/widget/circle_card.dart';
import 'package:finpay/view/home/widget/custom_card.dart';
import 'package:finpay/view/reservas/reservas_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:finpay/view/home/topup_dialog.dart'; // Añadir este import

class HomeView extends StatelessWidget {
  final HomeController homeController;

  const HomeView({Key? key, required this.homeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.isLightTheme == false
          ? const Color(0xff15141F)
          : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Good morning",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                    ),
                    Text(
                      "Usuario",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Botón de actualización
                    IconButton(
                      onPressed: () async {
                        await homeController.refrescarDatos();
                        Get.snackbar(
                          'Actualizado',
                          'Los datos se han actualizado correctamente',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.green.withValues(alpha: 179),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      icon: Icon(
                        Icons.refresh,
                        color: HexColor(AppTheme.primaryColorString!),
                      ),
                    ),
                    Container(
                      height: 28,
                      width: 69,
                      decoration: BoxDecoration(
                        color: const Color(0xffF6A609).withValues(alpha: 26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            DefaultImages.ranking,
                          ),
                          Text(
                            "Gold",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: const Color(0xffF6A609),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: Image.asset(
                        DefaultImages.avatar,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await homeController.refrescarDatos();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {
                        Get.to(const TopUpSCreen(),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 500));
                      },
                      child: circleCard(
                        image: DefaultImages.topup,
                        title: "Pagar",
                      ),
                    ),
                    InkWell(
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {},
                      child: circleCard(
                        image: DefaultImages.withdraw,
                        title: "Withdraw",
                      ),
                    ),
                    InkWell(
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {
                        Get.to(
                          () => ReservaScreen(),
                          binding: BindingsBuilder(() {
                            Get.delete<
                                ReservaController>(); // 🔥 elimina instancia previa

                            Get.create(() => ReservaController());
                          }),
                          transition: Transition.downToUp,
                          duration: const Duration(milliseconds: 500),
                        );
                      },
                      child: circleCard(
                        image: DefaultImages.transfer,
                        title: "Reservar",
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 30),
                
                // Nueva sección de resumen estadístico
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.isLightTheme == false
                          ? const Color(0xff211F32)
                          : const Color(0xffFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff000000).withValues(alpha: 26),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Resumen del día",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 20),
                          // Grid de estadísticas
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  title: "Reservas Pendientes",
                                  value: homeController.autosConReservasPendientes,
                                  icon: Icons.schedule,
                                  color: Colors.orange,
                                  subtitle: "vehículos",
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  title: "Reservas Pagadas",
                                  value: homeController.autosConReservasPagadas,
                                  icon: Icons.check_circle,
                                  color: Colors.green,
                                  subtitle: "vehículos",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  title: "Lugares Disponibles",
                                  value: homeController.lugaresDisponibles,
                                  icon: Icons.local_parking,
                                  color: Colors.blue,
                                  subtitle: "espacios",
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  title: "Lugares Ocupados",
                                  value: homeController.lugaresOcupados,
                                  icon: Icons.local_parking,
                                  color: Colors.red,
                                  subtitle: "espacios",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Sección de reservas pagadas
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.isLightTheme == false
                          ? const Color(0xff211F32)
                          : const Color(0xffFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff000000).withValues(alpha: 26),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Reservas pagadas - ${_getNombreMesActual()}",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              Text(
                                "Ver todas",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: HexColor(AppTheme.primaryColorString!),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(() {
                          if (homeController.reservasPagadasDelMes.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 48,
                                    color: Colors.grey.withValues(alpha: 128),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "No hay reservas pagadas este mes",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: Colors.grey.withValues(alpha: 179),
                                          fontSize: 14,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          return Column(
                            children: homeController.reservasPagadasDelMes.map((reserva) {
                              return _buildReservaPagadaCard(context, reserva);
                            }).toList(),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Nueva sección de reservas pendientes
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 50),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.isLightTheme == false
                          ? const Color(0xff211F32)
                          : const Color(0xffFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff000000).withValues(alpha: 26),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Reservas pendientes",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              Text(
                                "Ver todas",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: HexColor(AppTheme.primaryColorString!),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(() {
                          if (homeController.reservasPendientes.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.schedule_outlined,
                                    size: 48,
                                    color: Colors.grey.withValues(alpha: 128),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "No hay reservas pendientes de pago",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: Colors.grey.withValues(alpha: 179),
                                          fontSize: 14,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          return Column(
                            children: homeController.reservasPendientes.map((reserva) {
                              return _buildReservaPendienteCard(context, reserva);
                            }).toList(),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
          ),
        ],
      ),
    );
  }

  // Función auxiliar para obtener el nombre del mes actual
  String _getNombreMesActual() {
    final meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return meses[DateTime.now().month - 1];
  }

  // Widget para mostrar cada reserva pagada
  Widget _buildReservaPagadaCard(BuildContext context, Reserva reserva) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.isLightTheme == false
            ? const Color(0xff15141F)
            : Colors.grey.withValues(alpha: 13), // 0.05 * 255
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 51), // 0.2 * 255
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // Icono de estado
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 26), // 0.1 * 255
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Información de la reserva
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Reserva #${reserva.codigoReserva.substring(reserva.codigoReserva.length - 6)}",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 26), // 0.1 * 255
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "PAGADO",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Vehículo: ${reserva.chapaAuto}",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.grey.withValues(alpha: 179),
                        fontSize: 14,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      UtilesApp.formatearFechaDdMMAaaa(reserva.horarioInicio),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Colors.grey.withValues(alpha: 179),
                            fontSize: 12,
                          ),
                    ),
                    Text(
                      "₲ ${UtilesApp.formatearGuaranies(reserva.monto.toInt())}",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Nuevo widget para mostrar cada reserva pendiente
  Widget _buildReservaPendienteCard(BuildContext context, Reserva reserva) {
    return GestureDetector(
      onTap: () {
        // Navegar directamente al diálogo de pago
        Get.bottomSheet(
          topupDialog(context, reserva),
          isScrollControlled: true,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.isLightTheme == false
              ? const Color(0xff15141F)
              : Colors.grey.withValues(alpha: 13),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.orange.withValues(alpha: 102), // Borde naranja para pendientes
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icono de estado
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 26),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.schedule,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Información de la reserva
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Reserva #${reserva.codigoReserva.substring(reserva.codigoReserva.length - 6)}",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "PENDIENTE",
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Vehículo: ${reserva.chapaAuto}",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.grey.withValues(alpha: 179),
                          fontSize: 14,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        UtilesApp.formatearFechaDdMMAaaa(reserva.horarioInicio),
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Colors.grey.withValues(alpha: 179),
                              fontSize: 12,
                            ),
                      ),
                      Row(
                        children: [
                          Text(
                            "₲ ${UtilesApp.formatearGuaranies(reserva.monto.toInt())}",
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.grey.withValues(alpha: 179),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Nuevo widget para mostrar cada estadística
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required RxInt value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.isLightTheme == false
            ? const Color(0xff15141F)
            : Colors.grey.withValues(alpha: 13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 51),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => Text(
                "${value.value}",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: color,
                    ),
              )),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.grey.withValues(alpha: 179),
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
