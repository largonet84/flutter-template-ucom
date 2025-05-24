import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/controller/home_controller.dart';
import 'package:finpay/view/home/home_view.dart';
import 'package:finpay/view/dashboard/dashboard_view.dart';
import 'package:finpay/view/card/card_view.dart';
import 'package:finpay/view/profile/profile_view.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({Key? key}) : super(key: key);

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  late HomeController homeController;
  late List<Widget> _tabs;
  int _currentIndex = 0;

@override
void initState() {
  super.initState();

  // Registrar el controlador si aún no existe
  if (!Get.isRegistered<HomeController>()) {
    Get.put(HomeController());
  }

  homeController = Get.find<HomeController>();

  _tabs = [
    HomeView(homeController: homeController),
    DashboardView(homeController: homeController),
    CardView(),
    ProfileView(),
  ];
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white.withOpacity(0.4)),
            activeIcon: const Icon(Icons.home, color: Colors.white),
            label: "home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, color: Colors.white.withOpacity(0.4)),
            activeIcon: const Icon(Icons.bar_chart, color: Colors.white),
            label: "statistics",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card, color: Colors.white.withOpacity(0.4)),
            activeIcon: const Icon(Icons.credit_card, color: Colors.white),
            label: "card",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.white.withOpacity(0.4)),
            activeIcon: const Icon(Icons.person, color: Colors.white),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}
