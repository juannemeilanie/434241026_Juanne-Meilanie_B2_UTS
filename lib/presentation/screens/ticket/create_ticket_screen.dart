import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() =>
      _CreateTicketScreenState();
}

class _CreateTicketScreenState
    extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];

  String _category = 'Hardware';
  String _priority = 'medium';

  bool _isLoading = false;

  Future<void> pickImage(ImageSource source) async {
    final img = await _picker.pickImage(source: source);

    if (img != null) {
      setState(() => _images.add(img));
    }
  }

  void removeImage(int i) {
    setState(() => _images.removeAt(i));
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    final ticketProv = context.read<TicketProvider>();

    final attachments = _images.map((e) => e.path).toList();

    final ticket = await ticketProv.createTicket(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category,
      priority: _priority,
      userId: user.id,
      userName: user.name,
      attachments: attachments,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tiket ${ticket.id} berhasil dibuat')),
    );

    context.pop();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Hardware',
      'Software',
      'Jaringan',
      'Akun'
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Tiket')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration:
                const InputDecoration(labelText: 'Judul'),
                validator: (v) =>
                v!.isEmpty ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration:
                const InputDecoration(labelText: 'Deskripsi'),
                validator: (v) =>
                v!.isEmpty ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField(
                value: _category,
                items: categories
                    .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _category = v!),
                decoration:
                const InputDecoration(labelText: 'Kategori'),
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField(
                value: _priority,
                items: ['low', 'medium', 'high']
                    .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _priority = v!),
                decoration:
                const InputDecoration(labelText: 'Prioritas'),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () =>
                        pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera),
                    label: const Text('Camera'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () =>
                        pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.image),
                    label: const Text('Gallery'),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                children: List.generate(_images.length, (i) {
                  final img = _images[i];

                  return Stack(
                    children: [
                      kIsWeb
                          ? Image.network(
                        img.path,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                          : Image.file(
                        File(img.path),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),

                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.red, size: 16),
                          onPressed: () => removeImage(i),
                        ),
                      )
                    ],
                  );
                }),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isLoading ? null : submit,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Kirim'),
              )
            ],
          ),
        ),
      ),
    );
  }
}