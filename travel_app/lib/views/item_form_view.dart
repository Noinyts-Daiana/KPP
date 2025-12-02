import 'dart:io'; 
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/manage_item_bloc.dart';
import '../bloc/item_list_bloc.dart';
import '../models/travel_models.dart';
import '../repositories/items_repository.dart';

const Color primaryColor = Color(0xFF0D47A1);
const Color accentColor = Color(0xFFF5F5F5);

class ItemFormView extends StatefulWidget {
  final Item? initialItem;
  const ItemFormView({super.key, this.initialItem});

  @override
  State<ItemFormView> createState() => _ItemFormViewState();
}

class _ItemFormViewState extends State<ItemFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    if (widget.initialItem != null) {
      _nameController.text = widget.initialItem!.name;
      _categoryController.text = widget.initialItem!.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final repository = context.read<ItemsRepository>();
        final userId = FirebaseAuth.instance.currentUser!.uid;
        return ManageItemBloc(repository, userId);
      },
      child: BlocListener<ManageItemBloc, ManageItemState>(
        listener: (context, state) {
          if (state is ManageItemSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(widget.initialItem == null ? 'Річ створено!' : 'Річ оновлено!')),
            );
            context.read<ItemListBloc>().add(FetchItemsEvent());
            Navigator.pop(context);
          } else if (state is ManageItemFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Помилка: ${state.error}')),
            );
          }
        },
        child: Builder(
          builder: (innerContext) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(innerContext).viewInsets.bottom + 20,
                  left: 20,
                  right: 20,
                  top: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.initialItem == null ? 'НОВА РІЧ' : 'РЕДАГУВАННЯ РЕЧІ',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                    const SizedBox(height: 20),
                    _buildImagePicker(),
                    _buildTextField(_nameController, 'Назва речі', 'Обов\'язкове поле'),
                    _buildTextField(_categoryController, 'Категорія', 'Обов\'язкове поле'),
                    const SizedBox(height: 20),
                    _buildButtons(innerContext),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    Widget display;
    if (_pickedImage != null) {
      if (kIsWeb) {
        display = Image.network(_pickedImage!.path, height: 150, fit: BoxFit.cover);
      } else {
        display = Image.file(File(_pickedImage!.path), height: 150, fit: BoxFit.cover);
      }
    } else if (widget.initialItem?.imageUrl != null) {
      display = Image.network(widget.initialItem!.imageUrl!, height: 150, fit: BoxFit.cover);
    } else {
      display = const Icon(Icons.image, size: 80);
    }

    return GestureDetector(
      onTap: () async {
        final picked = await _picker.pickImage(source: ImageSource.gallery);
        if (picked != null) {
          setState(() => _pickedImage = picked);
        }
      },
      child: Container(
        height: 150,
        color: Colors.grey[200],
        child: Center(child: display),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String validationMsg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: accentColor.withOpacity(0.5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (v) => v == null || v.isEmpty ? validationMsg : null,
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    final bloc = context.read<ManageItemBloc>();
    final isProcessing = context.select((ManageItemBloc b) => b.state is ManageItemProcessing);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: isProcessing ? null : () => Navigator.pop(context),
          child: const Text('СКАСУВАТИ', style: TextStyle(color: primaryColor)),
        ),
        ElevatedButton(
          onPressed: isProcessing
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    final item = Item(
                      id: widget.initialItem?.id ?? '',
                      name: _nameController.text,
                      category: _categoryController.text,
                      isPacked: widget.initialItem?.isPacked ?? false,
                    );
                  
                    bloc.add(SaveItemEvent(
                      item, 
                      isNew: widget.initialItem == null, 
                      imageFile: _pickedImage 
                    ));
                  }
                },
          child: isProcessing
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(widget.initialItem == null ? 'ДОДАТИ' : 'ЗБЕРЕГТИ'),
        ),
      ],
    );
  }
}