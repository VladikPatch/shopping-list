import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/providers/grocery_list_provider.dart';

class AddNewItemView extends ConsumerStatefulWidget {
  const AddNewItemView({super.key});

  @override
  ConsumerState<AddNewItemView> createState() =>
      _AddNewItemViewState();
}

class _AddNewItemViewState extends ConsumerState<AddNewItemView> {
  final formKey = GlobalKey<FormState>();

  late String _name;
  late int _quantity;
  late Category _category;

  @override
  void initState() {
    super.initState();

    _name = '';
    _quantity = 1;
    _category = categories[CategoryType.fruits]!;
  }

  void _handleAddItem() async {
    if (!formKey.currentState!.validate()) return;

    formKey.currentState!.save();

    final String tempId = DateTime.now().toString();

    final notifier = ref.read(groceryListProvider.notifier);
    notifier.addItem(
      GroceryItem(
        id: tempId,
        name: _name,
        quantity: _quantity,
        category: _category,
      ),
    );

    if (mounted) {
      Navigator.of(context).pop();
    }

    try {
      final serverId = await notifier.pushItem(
        name: _name,
        quantity: _quantity,
        category: _category,
      );
      notifier.updateItemId(tempId, serverId);
    } catch (e) {
      notifier.deleteItem(id: tempId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Item')),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              _buildNameField(),
              SizedBox(height: 20),
              _buildQuantityAndCategoryRow(),
              SizedBox(height: 35),
              _buildActionButtons(ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration: InputDecoration(
        label: Text('Title'),
        counter: Offstage(),
      ),
      maxLength: 50,
      onSaved: (newValue) {
        _name = newValue!;
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Empty title';
        }
        if (value.trim().length <= 4) {
          return 'Minimum 4 symbols';
        }
        return null;
      },
    );
  }

  Widget _buildQuantityAndCategoryRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextFormField(
            initialValue: _quantity.toString(),
            decoration: InputDecoration(
              label: Text('Quantity'),
              counter: Offstage(),
            ),
            keyboardType: TextInputType.number,
            maxLength: 3,
            onSaved: (newValue) {
              _quantity = int.parse(newValue!);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Empty quantity';
              }
              if (int.tryParse(value) == null ||
                  int.tryParse(value)! <= 0) {
                return 'Minimum 1';
              }
              return null;
            },
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: DropdownButtonFormField(
            items: categories.entries
                .map(
                  (category) => DropdownMenuItem(
                    value: category.value,
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: category.value.color,
                            shape: BoxShape.circle,
                          ),
                          width: 8,
                          height: 8,
                        ),
                        SizedBox(width: 15),
                        Text(category.value.title),
                      ],
                    ),
                  ),
                )
                .toList(),
            hint: Text('Category'),
            value: _category,
            onChanged: (value) {
              _category = value!;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: _handleAddItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primaryContainer,
          ),
          child: Text('Add Item'),
        ),
        SizedBox(width: 15),
        TextButton(
          onPressed: () {
            formKey.currentState!.reset();
          },
          child: Text('Reset'),
        ),
      ],
    );
  }
}
