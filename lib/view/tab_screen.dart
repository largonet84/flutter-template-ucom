import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/controller/home_controller.dart';
import 'package:finpay/controller/dashboard_controller.dart';
import 'package:finpay/controller/tab_controller.dart';
import 'package:finpay/view/home/home_view.dart';
import 'package:finpay/view/dashboard/dashboard_view.dart';
import 'package:finpay/view/profile/setting_screen.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({super.key});

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  late HomeController homeController;
  late TabScreenController tabController;
  late List<Widget> _pages;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    
    // Crear los controladores si no existen
    if (!Get.isRegistered<HomeController>()) {
      homeController = Get.put(HomeController(), permanent: true);
    } else {
      homeController = Get.find<HomeController>();
    }
    
    // Asegurarse que el DashboardController también esté disponible
    if (!Get.isRegistered<DashboardController>()) {
      Get.put(DashboardController(), permanent: true);
    }
    
    // Crear o encontrar el TabScreenController
    if (!Get.isRegistered<TabScreenController>()) {
      tabController = Get.put(TabScreenController(), permanent: true);
    } else {
      tabController = Get.find<TabScreenController>();
    }
    
    _pages = [
      HomeView(homeController: homeController),
      const DashboardView(),
      const SettingScreen()
    ];
    
    // Escuchar cambios en el índice de la pestaña
    ever(tabController.pageIndex, (index) {
      if (mounted) {
        setState(() {
          _currentIndex = index as int;
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Colores para íconos activo/inactivo
    final activeColor = Theme.of(context).primaryColor;
    final inactiveColor = activeColor.withValues(alpha: 102);

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          // Actualizar tanto el estado local como el controlador
          setState(() {
            _currentIndex = index;
          });
          tabController.pageIndex.value = index;
          
          // Si cambia a la pestaña Home (índice 0), actualizar datos
          if (index == 0 && Get.isRegistered<HomeController>()) {
            final homeController = Get.find<HomeController>();
            await homeController.refrescarDatos();
          }
          
          // Si cambia a la pestaña Dashboard (índice 1), actualizar datos
          if (index == 1 && Get.isRegistered<DashboardController>()) {
            final dashboardController = Get.find<DashboardController>();
            await dashboardController.fetchDashboardData();
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home,
                color: _currentIndex == 0 ? activeColor : inactiveColor),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard,
                color: _currentIndex == 1 ? activeColor : inactiveColor),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person,
                color: _currentIndex == 2 ? activeColor : inactiveColor),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
