// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/providers/grocery_list_provider.dart';
import 'package:shopping_list_app/views/add_new_item_view.dart';
import 'package:shopping_list_app/widgets/groceries_list.dart';

class GroceriesView extends ConsumerStatefulWidget {
  const GroceriesView({super.key});

  @override
  ConsumerState<GroceriesView> createState() => _GroceriesViewState();
}

class _GroceriesViewState extends ConsumerState<GroceriesView> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(groceryListProvider.notifier).getAllItems();
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _navigateToAddNewItemView() async {
    await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (context) => AddNewItemView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<GroceryItem> groceryItems = ref.watch(
      groceryListProvider,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Groceries'),
        actions: [
          IconButton(
            onPressed: _navigateToAddNewItemView,
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? LoadingState()
          : (groceryItems.isEmpty ? EmptyState() : GroceriesList()),
    );
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Align(
        alignment: Alignment.topCenter,
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 30,
        horizontal: 90,
      ),
      child: Text(
        'Add new item by clicking +, button',
        style: TextStyle(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withAlpha(220),
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
