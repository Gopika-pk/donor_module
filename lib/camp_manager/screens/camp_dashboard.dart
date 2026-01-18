import 'package:flutter/material.dart';
import 'create_request_screen.dart';
import 'camp_inventory_screen.dart';
import 'donations_screen.dart';

class CampDashboard extends StatelessWidget {
  const CampDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Camp Manager"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            dashboardCard(
              context,
              icon: Icons.add_box,
              title: "Create Request",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateRequestScreen(),
                ),
              ),
            ),
            dashboardCard(
              context,
              icon: Icons.inventory,
              title: "Camp Inventory",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CampInventoryScreen(),
                ),
              ),
            ),
            dashboardCard(
              context,
              icon: Icons.volunteer_activism,
              title: "Donations Received",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DonationsScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dashboardCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
}
