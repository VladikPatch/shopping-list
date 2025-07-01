import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/providers/grocery_list_provider.dart';

class GroceriesList extends ConsumerStatefulWidget {
  const GroceriesList({super.key});

  @override
  ConsumerState<GroceriesList> createState() => _GroceriesListState();
}

class _GroceriesListState extends ConsumerState<GroceriesList> {
  @override
  Widget build(BuildContext context) {
    final List<GroceryItem> groceryItems = ref.watch(
      groceryListProvider,
    );

    return ListView.builder(
      itemCount: groceryItems.length,
      itemBuilder: (context, index) {
        final item = groceryItems[index];
        return _buildDismissible(item);
      },
    );
  }

  Widget _buildDismissible(GroceryItem item) {
    return Dismissible(
      key: ValueKey(item.id),
      background: Container(
        color: Theme.of(context).colorScheme.error,
      ),
      onDismissed: (direction) => ref
          .read(groceryListProvider.notifier)
          .deleteItem(id: item.id),
      direction: DismissDirection.endToStart,
      child: _buildGroceryItem(item),
    );
  }

  Widget _buildGroceryItem(GroceryItem item) {
    return ListTile(
      leading: Container(
        decoration: BoxDecoration(
          color: item.category.color,
          shape: BoxShape.circle,
        ),
        width: 8,
        height: 8,
      ),
      title: Text(item.name),
      trailing: Text(item.quantity.toString()),
    );
  }
}
