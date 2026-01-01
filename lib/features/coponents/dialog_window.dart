import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> showEditBaseUrlDialog(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final controller = TextEditingController(
    text: prefs.getString('base_url') ?? 'http://192.168.0.194:5000',
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.settings_ethernet, size: 26),
            SizedBox(width: 10),
            Text("Server Configuration"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter the local Flask server URL:",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: "http://192.168.x.x:5000",
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text("Save"),
            onPressed: () async {
              final url = controller.text.trim();

              if (!url.startsWith("http://") && !url.startsWith("https://")) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Invalid URL format"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              await prefs.setString('base_url', url);

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Server URL updated successfully"),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      );
    },
  );
}
