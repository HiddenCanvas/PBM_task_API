import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() async {
    final name = _nameController.text.trim();
    final priceStr = _priceController.text.trim();
    final description = _descController.text.trim();

    if (name.isEmpty || priceStr.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi')),
      );
      return;
    }

    final price = int.tryParse(priceStr);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga harus berupa angka')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.addProduct(name, price, description);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil ditambahkan'),
          backgroundColor: Color(0xFF2D5A27),
        ),
      );
      // Kirim true supaya HomeScreen tahu harus refresh
      Navigator.pop(context, true);
    } catch (e) {
      print('ERROR addProduct: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: Text(
          'Tambah Produk',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2D5A27),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Masukkan Detail Produk',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D5A27),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Produk',
                prefixIcon: const Icon(Icons.shopping_bag_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2D5A27), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Harga (Rp)',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2D5A27), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Deskripsi Produk',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: Icon(Icons.description_outlined),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2D5A27), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5A27),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Simpan Produk',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}