import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/item_list_bloc.dart';
import '../models/travel_models.dart';
import '../repositories/items_repository.dart';
import 'item_form_view.dart';

const Color primaryColor = Color(0xFF0D47A1);

class ItemListView extends StatelessWidget {
  final String userId;
  const ItemListView({super.key, required this.userId});

  void _showItemForm(BuildContext context, {Item? item}) {
    final repository = context.read<ItemsRepository>();
    final itemListBloc = context.read<ItemListBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return MultiBlocProvider(
          providers: [
            RepositoryProvider.value(value: repository),
            BlocProvider.value(value: itemListBloc),
          ],
          child: ItemFormView(initialItem: item),
        );
      },
    );
  }

  Widget _buildItemTile(BuildContext context, Item item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white.withOpacity(0.9), 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), 
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 0),
        leading: item.imageUrl != null 
            ? Image.network(item.imageUrl!, width: 50, height: 50, fit: BoxFit.cover) 
            : const Icon(Icons.image, color: primaryColor),
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
        subtitle: Text(
          'Категорія: ${item.category}', 
          style: const TextStyle(color: Colors.grey)
        ),
        onTap: () => _showItemForm(context, item: item),
      
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ItemListBloc(context.read<ItemsRepository>(), userId)..add(FetchItemsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('LIST OF ITEMS', style: TextStyle(color: Colors.white)), 
          backgroundColor: primaryColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_box_outlined, color: Colors.white), 
              onPressed: () => _showItemForm(context)
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white), 
              onPressed: () => Navigator.pop(context)
            ),
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
              if (state is ItemLoadingState && state.data.isEmpty) return const Center(child: CircularProgressIndicator(color: primaryColor));
              
              if (state is ItemErrorState && state.data.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Помилка завантаження речей!',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      Text(state.error, style: const TextStyle(color: Colors.white)),
                      ElevatedButton(
                        onPressed: () => context.read<ItemListBloc>().add(FetchItemsEvent()),
                        child: const Text('СПРОБУВАТИ ЩЕ'),
                      ),
                    ],
                  ),
                );
              }
              
              if (state.data.isNotEmpty) {
                return ListView.builder(
                  itemCount: state.data.length,
                  itemBuilder: (context, index) => _buildItemTile(context, state.data[index]),
                );
              }
              
              return const Center(
                  child: Text('Список речей порожній',
                      style: TextStyle(color: Colors.white, fontSize: 16))); 
            },
          ),
        ),
      ),
    );
  }
}