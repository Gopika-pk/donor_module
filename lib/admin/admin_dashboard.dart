import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'services/admin_session.dart';
import 'screens/admin_create_camp.dart';
import '../screens/role_selection_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Map<String, dynamic>> camps = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCamps();
  }

  Future<void> _loadCamps() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse("http://10.49.2.38:5000/api/admin/camps"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          camps = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load camps");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading camps: $e")),
        );
      }
    }
  }

  Future<void> _logout() async {
    await AdminSession.clearSession();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
    );
  }

  void _showCredentialsDialog(Map<String, dynamic> camp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                camp["campName"] ?? "Camp Details",
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow("Camp ID", camp["campId"]),
              _buildDetailRow("Camp Name", camp["campName"]),
              _buildDetailRow("Manager", camp["managerName"]),
              _buildDetailRow("Location", camp["location"] ?? "N/A"),
              _buildDetailRow("Contact", camp["contactNumber"] ?? "N/A"),
              const Divider(height: 24),
              const Text(
                "Login Credentials:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildDetailRow("Email", camp["email"]),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, color: Colors.red, size: 20),
                    const SizedBox(width: 10),
                    const Text(
                      "Password: ",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Text(
                      "Stored in database",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "💡 Password is stored in database. Check MongoDB or backend logs if needed.",
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value ?? "N/A",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCamps,
              child: camps.isEmpty
                  ? const Center(
                      child: Text("No camps registered yet"),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: camps.length,
                      itemBuilder: (context, index) {
                        final camp = camps[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red,
                              child: Text(
                                camp["campId"].toString().substring(4),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              camp["campName"] ?? "Unknown",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Manager: ${camp['managerName']}"),
                                Text("Email: ${camp['email']}"),
                                Text("Location: ${camp['location'] ?? 'N/A'}"),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // Show full credentials dialog
                              _showCredentialsDialog(camp);
                            },
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminCreateCamp()),
          );
          _loadCamps(); // Refresh list after creating camp
        },
        backgroundColor: Colors.red,
        icon: const Icon(Icons.add),
        label: const Text("Add New Camp"),
      ),
    );
  }
}
