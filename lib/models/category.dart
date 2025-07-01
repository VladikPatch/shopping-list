import 'package:flutter/material.dart';

enum CategoryType {
  vegetables,
  fruits,
  meat,
  dairy,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other,
}

class Category {
  const Category(this.title, this.color);

  final String title;
  final Color color;
}
