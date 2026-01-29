import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../shared/models/car.dart';
import '../../services/car_service.dart';
import '../../providers/inventory_provider.dart';
import '../../shared/widgets/common/premium_button.dart';
import '../../shared/widgets/common/premium_text_field.dart';
import '../../shared/widgets/common/premium_dropdown.dart';
import '../../shared/widgets/common/section_label.dart';
import '../../shared/widgets/layout/premium_app_bar.dart';

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
      appBar: PremiumAppBar(
        title: isEditing ? 'EDIT VEHICLE' : 'NEW ACQUISITION',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel(title: 'VEHICLE IDENTITY'),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    PremiumTextField(
                      label: 'Brand',
                      controller: _brandController,
                      hintText: 'e.g. BRABUS',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Brand is required' : null,
                    ),
                    const SizedBox(height: 16),
                    PremiumTextField(
                      label: 'Model Designation',
                      controller: _modelController,
                      hintText: 'e.g. ROCKET 1000',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Model is required' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              const SectionLabel(title: 'SPECIFICATIONS & STATUS'),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: PremiumTextField(
                            label: 'Year',
                            controller: _yearController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            hintText: '2024',
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
                          child: PremiumTextField(
                            label: 'Price (USD)',
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            hintText: '500000',
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (double.tryParse(v) == null) {
                                return 'Invalid Amount';
                              }
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
                          child: PremiumDropdown(
                            label: 'Category',
                            value: _categoryController.text,
                            items: _categoryOptions,
                            onChanged: (val) =>
                                setState(() => _categoryController.text = val!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: PremiumDropdown(
                            label: 'Status',
                            value: _statusController.text,
                            items: _statusOptions,
                            onChanged: (val) =>
                                setState(() => _statusController.text = val!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              const SectionLabel(title: 'MEDIA ASSETS'),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    PremiumTextField(
                      label: 'Image URL',
                      controller: _imageUrlController,
                      hintText: 'https://...',
                      maxLines: 2,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Image URL is required';
                        }
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
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.grey[900],
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: PremiumButton(
                  text: isEditing ? 'UPDATE MASTERPIECE' : 'ADD TO COLLECTION',
                  onPressed: _submit,
                  isLoading: _isLoading,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
