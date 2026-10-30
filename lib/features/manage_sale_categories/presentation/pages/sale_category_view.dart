// Backward compatibility wrapper
import 'package:flutter/material.dart';
import 'sale_category_list_view.dart';

class SaleCategoryView extends StatelessWidget {
  const SaleCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SaleCategoryListView();
  }
}
