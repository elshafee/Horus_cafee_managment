import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/provider/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _roomController = TextEditingController();
  final _deptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _roomController.text = user?.primaryRoom ?? '';
    _deptController.text = user?.department ?? '';
  }

  @override
  void dispose() {
    _roomController.dispose();
    _deptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    Uint8List? imageBytes;
    if (user?.profileImage != null && user!.profileImage!.length > 50) {
      try {
        // Strip any potential headers (data:image/jpeg;base64,)
        String cleanBase64 = user.profileImage!.contains(',')
            ? user.profileImage!.split(',').last
            : user.profileImage!;

        imageBytes = base64Decode(cleanBase64.trim());
      } catch (e) {
        debugPrint("Image Decode Error: $e");
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => auth.logout().then(
              (_) => Navigator.pushReplacementNamed(context, '/login'),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 1. Profile Image Header with Network Image logic
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 65,
                        backgroundColor: const Color(
                          0xFFBB86FC,
                        ).withOpacity(0.1),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFF2C2C2C),
                          // Use MemoryImage for the decoded bytes
                          backgroundImage: imageBytes != null
                              ? MemoryImage(imageBytes!)
                              : null,
                          child: imageBytes == null
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: const Color(0xFFBB86FC),
                          radius: 20,
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.black,
                            ),
                            onPressed: () async {
                              // Trigger the picker we added to AuthProvider
                              await auth.pickAndUploadImage(context);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 2. Info Cards (Read Only)
                _buildInfoCard("Full Name", user?.name ?? "Staff Member"),
                _buildInfoCard("Employee ID", user?.employeeCode ?? "---"),

                const SizedBox(height: 20),
                const Divider(color: Colors.white10),
                const SizedBox(height: 20),

                // 3. Editable Fields
                _buildTextField("Department", _deptController, Icons.business),
                const SizedBox(height: 15),
                _buildTextField(
                  "Primary Delivery Room",
                  _roomController,
                  Icons.room,
                ),

                const SizedBox(height: 40),

                // 4. Save Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBB86FC),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                    ),
                    onPressed: auth.isLoading
                        ? null
                        : () async {
                            final success = await auth.updateProfile(
                              dept: _deptController.text,
                              room: _roomController.text,
                            );
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Profile Updated Successfully! ✅",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "SAVE CHANGES",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Loading Overlay
          if (auth.isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFBB86FC)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFBB86FC), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFFBB86FC), size: 20),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFBB86FC)),
        ),
      ),
    );
  }
}
