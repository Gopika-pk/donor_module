import 'package:flutter/material.dart';
import 'donate_money_page.dart';

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

  // ---------- DEFAULT CAMP REQUESTS ----------
  final List<Map<String, dynamic>> requests = [
    {
      "item": "Rice",
      "category": "Food",
      "priority": "Low",
      "required": 500,
      "current": 200,
      "unit": "kg",
      "updated": "10 Jan 2025, 6:23 PM",
    },
    {
      "item": "Drinking Water",
      "category": "Water",
      "priority": "Medium",
      "required": 2000,
      "current": 1000,
      "unit": "liters",
      "updated": "10 Jan 2025, 6:23 PM",
    },
  ];

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

          Text(
            "Remaining: $remaining ${r["unit"]}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Text(
            "Last updated: ${r["updated"]}",
            style: const TextStyle(fontSize: 11, color: Colors.grey),
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
