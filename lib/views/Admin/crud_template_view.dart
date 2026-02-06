import 'package:flutter/material.dart';

class CrudTemplateView extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailingText;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CrudTemplateView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trailingText,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitle),
            const SizedBox(height: 4),
            Text(trailingText, style: const TextStyle(color: Color(0xFFC2185B), fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Hapus Data?"),
                    content: const Text("Data yang dihapus tidak bisa dikembalikan."),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          onDelete();
                        },
                        child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}