import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/analytics.dart';
import 'package:managementt/admin/employee_dashboard.dart';
import 'package:managementt/admin/main_dashboard.dart';
import 'package:managementt/admin/profile.dart';
import 'package:managementt/admin/project_dashboard.dart';
import 'package:managementt/components/dashboard_bottom_nav.dart';
import 'package:managementt/controller/admin_nav_controller.dart';

class AdminWrapper extends StatelessWidget {
  AdminWrapper({super.key});

  final AdminNavController navController = Get.put(AdminNavController());

  final List<Widget> _pages = [
    const AdminDashboard(),
    ProjectDashboard(),
    EmployeeDashboard(),
    const Analytics(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        extendBody: true,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: KeyedSubtree(
            key: ValueKey<int>(navController.currentIndex.value),
            child: _pages[navController.currentIndex.value],
          ),
        ),
        bottomNavigationBar: const DashboardBottomNav(),
      ),
    );
  }
}
