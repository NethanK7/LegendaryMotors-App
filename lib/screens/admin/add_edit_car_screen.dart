import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/models/car.dart';
import '../../services/car_service.dart';
import '../../providers/inventory_provider.dart';

class AddEditCarScreen extends StatefulWidget {
  final int? carId;
  final Car? car;

  const AddEditCarScreen({super.key, this.carId, this.car});

  @override
  State<AddEditCarScreen> createState() => _AddEditCarScreenState();
}

class _AddEditCarScreenState extends State<AddEditCarScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late TextEditingController _statusController;
  late TextEditingController _imageUrlController;

  bool _isLoading = false;

  // Predefined options
  final List<String> _statusOptions = ['Available', 'Reserved', 'Sold'];
  final List<String> _categoryOptions = [
    'Supercar',
    'SUV',
    'Sedan',
    'Coupe',
    'Convertible',
    'Luxury',
  ];

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(text: widget.car?.brand ?? '');
    _modelController = TextEditingController(text: widget.car?.model ?? '');
    _yearController = TextEditingController(
      text: widget.car?.year.toString() ?? '',
    );
    _priceController = TextEditingController(
      text: widget.car?.price.toString() ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.car?.category ?? 'Supercar',
    );
    _statusController = TextEditingController(
      text: widget.car?.status ?? 'Available',
    );
    // Ensure status/category match available options or default to first
    if (!_statusOptions.contains(_statusController.text)) {
      _statusController.text = _statusOptions.first;
    }
    if (!_categoryOptions.contains(_categoryController.text)) {
      _categoryController.text = _categoryOptions.first;
    }

    _imageUrlController = TextEditingController(
      text: widget.car?.imageUrl ?? '',
    );
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _statusController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final carData = {
      'brand': _brandController.text.trim(),
      'model': _modelController.text.trim(),
      'year': int.tryParse(_yearController.text.trim()) ?? 2024,
      'price':
          double.tryParse(_priceController.text.replaceAll(',', '').trim()) ??
          0.0,
      'category': _categoryController.text,
      'status': _statusController.text,
      'image_url': _imageUrlController.text.trim(),
      'specs': {}, // Default empty specs for now, extend if needed
    };

    try {
      if (widget.carId != null) {
        // Update
        await Provider.of<CarService>(
          context,
          listen: false,
        ).updateCar(widget.carId!, carData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Car updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Provider.of<InventoryProvider>(
            context,
            listen: false,
          ).fetchInventory(); // Refresh main list
          context.pop(true); // Return true to indicate update
        }
      } else {
        // Create
        await Provider.of<CarService>(
          context,
          listen: false,
        ).createCar(carData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Car created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Provider.of<InventoryProvider>(
            context,
            listen: false,
          ).fetchInventory(); // Refresh main list
          context.pop(true); // Return true to indicate creation
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.carId != null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          isEditing ? 'EDIT VEHICLE' : 'NEW ACQUISITION',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.0,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('VEHICLE IDENTITY'),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Brand',
                controller: _brandController,
                placeholder: 'e.g. BRABUS',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Brand is required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Model Designation',
                controller: _modelController,
                placeholder: 'e.g. ROCKET 1000',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Model is required' : null,
              ),

              const SizedBox(height: 32),
              _buildSectionHeader('SPECIFICATIONS & STATUS'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Year',
                      controller: _yearController,
                      isNumber: true,
                      placeholder: '2024',
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final n = int.tryParse(v);
                        if (n == null || n < 1900 || n > 2100) {
                          return 'Invalid Year';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      label: 'Price (USD)',
                      controller: _priceController,
                      isNumber: true,
                      placeholder: '500000',
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid Amount';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Category',
                      value: _categoryController.text,
                      items: _categoryOptions,
                      onChanged: (val) =>
                          setState(() => _categoryController.text = val!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Status',
                      value: _statusController.text,
                      items: _statusOptions,
                      onChanged: (val) =>
                          setState(() => _statusController.text = val!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              _buildSectionHeader('MEDIA ASSETS'),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Image URL',
                controller: _imageUrlController,
                placeholder: 'https://...',
                maxLines: 2,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Image URL is required';
                  if (!v.startsWith('http')) return 'Must be a valid URL';
                  return null;
                },
              ),
              if (_imageUrlController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _imageUrlController.text,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[900],
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE30613),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEditing
                              ? 'UPDATE MASTERPIECE'
                              : 'ADD TO COLLECTION',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: const Color(0xFFE30613),
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(color: Colors.white24, height: 1),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isNumber = false,
    String? placeholder,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            color: Colors.grey[400],
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          inputFormatters: isNumber
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: GoogleFonts.inter(color: Colors.white24),
            filled: true,
            fillColor: const Color(0xFF111111),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFE30613)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            color: Colors.grey[400],
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: items.contains(value) ? value : items.first,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: GoogleFonts.inter(color: Colors.white)),
                ),
              )
              .toList(),
          onChanged: onChanged,
          dropdownColor: const Color(0xFF111111),
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF111111),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFE30613)),
            ),
          ),
        ),
      ],
    );
  }
}
