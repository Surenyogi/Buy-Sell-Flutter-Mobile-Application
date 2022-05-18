import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:onlinedeck/models/product.dart';
import 'package:onlinedeck/providers/product_provider.dart';
import 'package:onlinedeck/widgets/product_card.dart';

class ProductsPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  const ProductsPage(
      {Key? key, required this.categoryId, required this.categoryName})
      : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  bool _productsLoading = false;
  final _provider = ProductProvider();
  final List<Product> _products = [];
  String? _productsError;

  @override
  void initState() {
    getProductsByCategoryId(widget.categoryId);
    super.initState();
  }

  getProductsByCategoryId(int categoryId) {
    debugPrint("categoryId: $categoryId");
    setState(() {
      _productsLoading = true;
    });
    _provider
        .getAllProducts(
            category: widget.categoryId, minPrice: null, maxPrice: null)
        .then((res) {
      debugPrint("success");
      setState(() {
        _productsLoading = false;
      });

      if (res.statusCode == 200) {
        final data = res.body as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>?;
        if (list == null) {
          setState(() {
            _productsError = "No results found";
          });
          return;
        }
        final products = list
            .map((e) => Product.fromMap(e as Map<String, dynamic>))
            .toList();

        setState(() {
          _products.clear();
          _products.addAll(products);
        });
      } else {
        setState(() {
          _productsError = res.bodyString;
        });
        Get.snackbar(
          'Error',
          res.bodyString.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }).catchError((error) {
      debugPrint("failed");
      setState(() {
        _productsLoading = false;
        _productsError = error.toString();
      });
      debugPrint(error.toString());
      Get.snackbar(
        'Error',
        error.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(children: [
      const SizedBox(height: 12),
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const SizedBox(width: 12),
        IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back_ios, size: 18)),
        Text(widget.categoryName),
      ]),
      const SizedBox(height: 12),
      Expanded(
          child: RefreshIndicator(
        onRefresh: () => getProductsByCategoryId(widget.categoryId),
        child: _productsLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _productsError != null
                ? Center(
                    child: Text(_productsError.toString()),
                  )
                : _products.isEmpty
                    ? const Center(
                        child: Text('No Products Found'),
                      )
                    : _buildSearchResults(),
      ))
    ])));
  }

  Widget _buildSearchResults() {
    return AnimationLimiter(
      child: GridView.builder(
        itemCount: _products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 375),
              columnCount: 2,
              child: ScaleAnimation(
                  child: FadeInAnimation(
                      child: productCard(
                _products[index],
              ))));
        },
      ),
    );
  }
}
