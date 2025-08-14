import 'package:flutter/material.dart';
import '../home/home_view.dart';
import '../monitoring/monitoring_view.dart';
import '../data_hama/data_hama_view.dart';
import '../education/education_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({Key? key}) : super(key: key);

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeView(),
    MonitoringView(),
    DataHamaView(),
    EducationView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            )
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.green[700],
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
            selectedFontSize: screenWidth < 400 ? 10 : 12,
            unselectedFontSize: screenWidth < 400 ? 10 : 12,
            iconSize: screenWidth < 400 ? 20 : 24,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.wifi_tethering),
                activeIcon: Icon(Icons.wifi_tethering_rounded),
                label: 'Monitoring',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bug_report_outlined),
                activeIcon: Icon(Icons.bug_report),
                label: 'Data Hama',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.cast_for_education_outlined),
                activeIcon: Icon(Icons.cast_for_education),
                label: 'Edukasi',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
