import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:manshi/screens/product/model/product_model.dart';

final dio = Dio();

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  bool _isLoading = true;
  List<Products> _productList = [];

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  Future<void> _fetchProduct() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final Dio dio = Dio();
      final response = await dio.get('https://dummyjson.com/products');

      if (response.statusCode == 200) {
        final List<dynamic> dynamicList = response.data['products'];
        _productList = dynamicList
            .map((e) => Products.fromJson(e))
            .toList();
      }
    } catch (e) {
      // Handle or log the error
      print('Error while fetching product: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product List')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _productList.length,
        itemBuilder: (ctx, i) {
          final productModel = _productList[i];
          return ListTile(
            title: Text(productModel.title ?? ''),
            subtitle: Text(productModel.description ?? ''),
          );
        },
      ),
    );
  }
}