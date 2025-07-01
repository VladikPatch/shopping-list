import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';

class GroceryFormNotifier extends StateNotifier<void> {
  GroceryFormNotifier() : super(null);

  GroceryItem? add({
    required GlobalKey<FormState> formKey,
    required String name,
    required int quantity,
    required Category category,
  }) {
    return GroceryItem(
      id: DateTime.now().toString(),
      name: name,
      quantity: quantity,
      category: category,
    );
  }
}

final groceryFormProvider =
    StateNotifierProvider<GroceryFormNotifier, void>(
      (ref) => GroceryFormNotifier(),
    );
