import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key});

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  // Use local network IP
  final String _baseUrl = "http://10.49.2.38:5000/camp-request/donations";
  final String _campId = "CAMP001"; // Hardcoded for now
  
  List<dynamic> donations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDonations();
  }

  Future<void> _fetchDonations() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/$_campId"));

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            donations = jsonDecode(response.body);
            isLoading = false;
          });
        }
      } else {
        throw Exception("Failed to load donations");
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donations Received"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
               setState(() => isLoading = true);
               _fetchDonations();
            },
          )
        ],
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : donations.isEmpty
          ? const Center(child: Text("No donations received yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: donations.length,
              itemBuilder: (context, index) {
                final d = donations[index];
                return donationCard(
                  context,
                  donor: d["donorName"] ?? "Anonymous",
                  item: d["itemName"] ?? "Unknown",
                  promisedQty: "${d["quantity"]} ${d["unit"] ?? ""}",
                  status: d["status"] ?? "Received",
                );
              },
            ),
    );
  }

  Widget donationCard(
      BuildContext context, {
        required String donor,
        required String item,
        required String promisedQty,
        required String status,
      }) {
  
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              donor,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text("Item: $item"),
            Text("Quantity: $promisedQty"),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(status),
                  backgroundColor: Colors.green.shade100,
                  labelStyle: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
