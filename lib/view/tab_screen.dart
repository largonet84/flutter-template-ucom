import 'package:flutter/material.dart';
import 'package:finpay/controller/home_controller.dart';
import 'package:finpay/view/home/home_view.dart';
import 'package:finpay/view/dashboard/dashboard_view.dart';
import 'package:finpay/view/profile/setting_screen.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({Key? key}) : super(key: key);

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  late HomeController homeController;
  late List<Widget> _pages;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    homeController = HomeController();
    _pages = [
      HomeView(homeController: homeController),
      DashboardView(homeController: homeController),
      SettingScreen()  // Pantalla de perfil/ajustes, sin controller compartido
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Colores para íconos activo/inactivo (ejemplo usando el tema actual)
    final activeColor = Theme.of(context).primaryColor;
    final inactiveColor = activeColor.withOpacity(0.4);

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: _currentIndex == 0 ? activeColor : inactiveColor),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard, color: _currentIndex == 1 ? activeColor : inactiveColor),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: _currentIndex == 2 ? activeColor : inactiveColor),
            label: 'Perfil',  // traducido de "profile" a "Perfil"
          ),
        ],
      ),
    );
  }
}
