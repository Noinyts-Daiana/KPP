// lib/views/item_list_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../bloc/item_list_bloc.dart';
import '../bloc/item_list_state.dart';
import '../models/travel_models.dart';
import '../repositories/items_repository.dart';
import 'item_form_view.dart'; // 👈 Нова форма

const Color primaryColor = Color(0xFF0D47A1); 
const Color accentColor = Color(0xFFF5F5F5); 

class ItemListView extends StatelessWidget {
  const ItemListView({super.key});

  // 🛠️ ВИПРАВЛЕНО: Виклик реальної форми
  void _showItemForm(BuildContext context, {Item? item}) {
    final itemsRepository = context.read<ItemsRepository>(); 
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return RepositoryProvider.value(
          value: itemsRepository,
          child: ItemFormView(initialItem: item),
        );
      },
    );
  }

  Widget _buildItemListItem(BuildContext context, Item item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 0),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
        ),
        subtitle: Text(
          'Категорія: ${item.category} (${item.isPacked ? 'ЗІБРАНО' : 'ПОТРІБНО'})',
          style: TextStyle(color: item.isPacked ? Colors.green : Colors.redAccent, fontSize: 12),
        ),
        onTap: () => _showItemForm(context, item: item),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: primaryColor), onPressed: () => _showItemForm(context, item: item)),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LIST OF ITEMS', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.add_box_outlined), onPressed: () => _showItemForm(context)),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/HomeScreenBack.jpg'), 
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken),
          ),
        ),
        child: BlocBuilder<ItemListBloc, ItemState>(
          builder: (context, state) { 
            
            final itemListBloc = context.read<ItemListBloc>(); 
            
            if (state is ItemLoadingState && state.data.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: primaryColor));
            }

            if (state is ItemErrorState && state.data.isEmpty) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                   decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Помилка завантаження речей!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      Text(state.error),
                      ElevatedButton(
                        onPressed: () => itemListBloc.add(const FetchItemsEvent()), 
                        child: const Text('СПРОБУВАТИ ЩЕ'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state.data.isNotEmpty) {
              return ListView.builder(
                itemCount: state.data.length,
                itemBuilder: (context, index) => _buildItemListItem(context, state.data[index]),
              );
            }

            return const Center(
              child: Text('Список речей порожній.', style: TextStyle(color: Colors.white, fontSize: 16)),
            );
          },
        ),
      ),
    );
  }
}