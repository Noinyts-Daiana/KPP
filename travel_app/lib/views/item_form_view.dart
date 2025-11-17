// lib/views/item_form_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 👈 ДОДАНО: Потрібен для UID
import '../bloc/manage_item_bloc.dart';
import '../bloc/item_list_bloc.dart';
import '../models/travel_models.dart';
import '../repositories/items_repository.dart';

const Color primaryColor = Color(0xFF0D47A1); 
const Color accentColor = Color(0xFFF5F5F5); 

class ItemFormView extends StatelessWidget {
  final Item? initialItem;
  // ❌ ВИДАЛЕНО: 'currentUserId' (беремо з FirebaseAuth)

  ItemFormView({super.key, this.initialItem});

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();

  void _initControllers() {
    if (initialItem != null) {
      _nameController.text = initialItem!.name;
      _categoryController.text = initialItem!.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    _initControllers();

    return BlocProvider(
      // 👇 ВИПРАВЛЕНО: Тепер передаємо 2 аргументи
      create: (providerContext) {
        final repository = providerContext.read<ItemsRepository>();
        final userId = FirebaseAuth.instance.currentUser!.uid; // Отримуємо UID
        return ManageItemBloc(repository, userId);
      },
      child: BlocListener<ManageItemBloc, ManageItemState>(
        listener: (listenerContext, state) {
          if (state is ManageItemSuccess) {
            ScaffoldMessenger.of(listenerContext).showSnackBar(
              SnackBar(content: Text(initialItem == null ? 'Річ створено!' : 'Річ оновлено!')),
            );
            listenerContext.read<ItemListBloc>().add(const FetchItemsEvent());
            Navigator.of(listenerContext).pop();
          } else if (state is ManageItemFailure) {
            ScaffoldMessenger.of(listenerContext).showSnackBar(
              SnackBar(content: Text('Помилка: ${state.error}')),
            );
          }
        },
        child: Builder( 
          builder: (builderContext) {
            return Container(
              height: MediaQuery.of(builderContext).size.height * 0.8, 
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(builderContext).viewInsets.bottom + 20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      initialItem == null ? 'НОВА РІЧ' : 'РЕДАГУВАННЯ РЕЧІ',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(_nameController, 'Назва речі (ITEM NAME)', 'Обов\'язкове поле'),
                    _buildTextField(_categoryController, 'Категорія (CATEGORY)', 'Обов\'язкове поле'),
                    const Spacer(), // Займає вільний простір
                    _buildActionButtons(builderContext),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String validationMessage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: accentColor.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validationMessage;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final bloc = context.read<ManageItemBloc>();
    final isProcessing = context.select((ManageItemBloc b) => b.state is ManageItemProcessing);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: isProcessing ? null : () => Navigator.pop(context),
          child: const Text('СКАСУВАТИ', style: TextStyle(color: primaryColor)),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: isProcessing ? null : () {
            if (_formKey.currentState!.validate()) {
              final itemToSave = Item(
                id: initialItem?.id ?? '',
                name: _nameController.text,
                category: _categoryController.text,
                isPacked: initialItem?.isPacked ?? false,
              );
              bloc.add(SaveItemEvent(itemToSave, isNew: initialItem == null));
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          child: isProcessing 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(initialItem == null ? 'ДОДАТИ' : 'ЗБЕРЕГТИ'),
        ),
      ],
    );
  }
}