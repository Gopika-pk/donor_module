import 'package:flutter/material.dart';
import 'donate_money_page.dart';
import '../services/api_service.dart';

const Color primaryColor = Color(0xFF1E88E5);
const double headerHeight = 200;

// ---------------- HEADER CLIPPER ----------------
class CustomHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ---------------- DONOR DASHBOARD ----------------
class DonorDashboard extends StatefulWidget {
  const DonorDashboard({super.key});

  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  String selectedCamp = "Camp Alpha";

  // ---------- DEFAULT CAMPS ----------
  final List<String> camps = [
    "Camp Alpha",
    "Camp Beta",
    "Camp Gamma",
  ];

  bool isLoading = true;
  List<Map<String, dynamic>> requests = [];

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    try {
      final data = await ApiService.getCampRequests();
      setState(() {
        requests = data.map((r) {
          final required = r["requiredQty"] ?? 0;
          final remaining = r["remainingQty"] ?? 0;
          final current = required - remaining;
          
          // Format date
          String updated = "Recently";
          if (r["updatedAt"] != null) {
             final date = DateTime.parse(r["updatedAt"]);
             updated = "${date.day}/${date.month}/${date.year}"; 
          }

          return {
            "id": r["_id"], // Keep ID for donation
            "item": r["itemName"] ?? "Unknown",
            "category": r["category"] ?? "General",
            "priority": r["priority"] ?? "Medium",
            "required": required,
            "current": current,
            "unit": r["unit"] ?? "units",
            "updated": updated,
            "campId": r["campId"] // Store campId for filtering if needed
          };
        }).toList().cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching requests: $e")),
      );
    }
  }

  void _showDonateDialog(Map<String, dynamic> request) {
    final TextEditingController qtyController = TextEditingController();
    final int remaining = request["required"] - request["current"];
    final String unit = request["unit"];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Donate ${request['item']}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Required: $remaining $unit"),
              const SizedBox(height: 10),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Quantity to Donate",
                  suffixText: unit,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final String input = qtyController.text.trim();
                if (input.isEmpty) return;

                final int? qty = int.tryParse(input);
                if (qty == null || qty <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a valid quantity")),
                  );
                  return;
                }

                if (qty > remaining) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Quantity exceeds requirement")),
                  );
                  return;
                }

                Navigator.pop(context); // Close dialog

                // Call API
                try {
                  await ApiService.donateItem(request["id"], qty);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Donation successful! Thank you.")),
                  );
                  fetchRequests(); // Refresh list
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text("Donate", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ---------- DEFAULT CAMPS ----------

  // ---------------- HEADER ----------------
  Widget buildHeader() {
    return ClipPath(
      clipper: CustomHeaderClipper(),
      child: Container(
        height: headerHeight,
        color: primaryColor,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.volunteer_activism, color: Colors.white, size: 50),
            SizedBox(height: 10),
            Text(
              "Donate Now",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- TAG BADGE ----------------
  Widget tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ---------------- REQUEST CARD ----------------
  Widget requestCard(Map<String, dynamic> r) {
    final remaining = r["required"] - r["current"];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                r["item"],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  tag(r["category"], Colors.orange),
                  const SizedBox(width: 6),
                  tag(
                    r["priority"],
                    r["priority"] == "High"
                        ? Colors.red
                        : Colors.orange,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Current: ${r["current"]} ${r["unit"]}"),
              Text("Required: ${r["required"]} ${r["unit"]}"),
            ],
          ),


          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Remaining: $remaining ${r["unit"]}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Last updated: ${r["updated"]}",
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _showDonateDialog(r),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text("Donate", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- MAIN UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          buildHeader(),
          Padding(
            padding: const EdgeInsets.only(top: headerHeight - 30),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // CAMP DROPDOWN
                  DropdownButtonFormField<String>(
                    value: selectedCamp,
                    decoration: InputDecoration(
                      hintText: "Choose a Camp",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: camps
                        .map(
                          (camp) => DropdownMenuItem(
                        value: camp,
                        child: Text(camp),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCamp = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Current Inventory",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (requests.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("No inventory requests found."),
                    ))
                  else
                    ...requests.map(requestCard).toList(),

                  const SizedBox(height: 30),

                  // DONATE INVENTORY
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Donate Inventory",
                        style:
                        TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // DONATE MONEY
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                            const DonateMoneyPage(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Donate Money",
                        style: TextStyle(
                          fontSize: 16,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
