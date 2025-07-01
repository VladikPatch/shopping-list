import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';

final groceryListProvider =
    StateNotifierProvider<GroceryListNotifier, List<GroceryItem>>(
      (ref) => GroceryListNotifier(),
    );

class GroceryListNotifier extends StateNotifier<List<GroceryItem>> {
  GroceryListNotifier() : super([]);

  final Uri url = Uri.https(
    'shopping-list-app-ee5ba-default-rtdb.firebaseio.com',
    'shopping-list-app.json',
  );

  void addItem(GroceryItem item) {
    state = [...state, item];
  }

  void updateItemId(String oldId, String newId) {
    state = state.map((item) {
      return item.id == oldId ? item.copyWith(id: newId) : item;
    }).toList();
  }

  Future<void> getAllItems() async {
    try {
      final response = await http.get(url);

      if (response.body == 'null') {
        return;
      }

      final Map<String, dynamic> listData = json.decode(
        response.body,
      );

      List<GroceryItem> loadedItems = [];

      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
              (catItem) =>
                  catItem.value.title == item.value['category'],
            )
            .value;
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }

      state = loadedItems;
    } catch (e) {
      log(e.toString());
    }
  }

  Future<String> pushItem({
    required String name,
    required int quantity,
    required Category category,
  }) async {
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'quantity': quantity,
          'category': category.title,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Push failed');
      }

      final Map<String, dynamic> responseData = json.decode(
        response.body,
      );
      return responseData['name'] as String;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  void _deleteItemLocally(GroceryItem item) {
    state = state.where((element) => element.id != item.id).toList();
  }

  Future<void> _deleteServerItem(GroceryItem item) async {
    final Uri url = Uri.https(
      'shopping-list-app-ee5ba-default-rtdb.firebaseio.com',
      'shopping-list-app/${item.id}.json',
    );

    final response = await http.delete(url);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete item on server');
    }
  }

  void _restoreItem(GroceryItem item) {
    state = [...state, item];
  }

  Future<void> deleteItem({required String id}) async {
    final item = state.firstWhere((item) => item.id == id);

    _deleteItemLocally(item);

    try {
      await _deleteServerItem(item);
    } catch (_) {
      _restoreItem(item);
      rethrow;
    }
  }
}
