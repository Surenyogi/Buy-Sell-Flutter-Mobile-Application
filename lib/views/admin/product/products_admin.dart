import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:onlinedeck/constants.dart';
import 'package:onlinedeck/models/product.dart';
import 'package:onlinedeck/providers/product_provider.dart';
import 'package:onlinedeck/utils/app_utils.dart';
import 'package:onlinedeck/utils/date_utils.dart';
import 'package:onlinedeck/views/product/product_detail.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class ProductsAdmin extends StatefulWidget {
  const ProductsAdmin({Key? key}) : super(key: key);

  @override
  State<ProductsAdmin> createState() => _ProductsAdminState();
}

class _ProductsAdminState extends State<ProductsAdmin> {
  final _productProvider = ProductProvider();
  final _productsList = <Product>[];
  String? _productsError;
  bool _productsLoading = false;

  @override
  void initState() {
    _getProducts();
    super.initState();
  }

  Future<void> _getProducts() async {
    setState(() {
      _productsLoading = true;
    });
    _productProvider.getAllProducts().then((res) {
      setState(() {
        _productsLoading = false;
      });
      if (res.statusCode == 200) {
        final data = res.body as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>?;

        if (list == null) {
          setState(() {
            _productsError = "No products found";
          });
          return;
        }
        final products = list
            .map((e) => Product.fromMap(e as Map<String, dynamic>))
            .toList();

        if (products.isEmpty) {
          setState(() {
            _productsError = "No products found";
          });
          return;
        }

        setState(() {
          _productsList.clear();
          _productsList.addAll(products);
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
      debugPrint(error.toString());
      setState(() {
        _productsLoading = false;
        _productsError = error.toString();
      });
      Get.snackbar(
        'Error Getting  Products',
        error.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Products'),
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          leading: Image.asset(
            'assets/images/logo.png',
            height: 30,
            width: 30,
          ),
          leadingWidth: 80,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                  child: RefreshIndicator(
                      onRefresh: () => _getProducts(),
                      child: _productsLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : _productsError != null
                              ? Center(child: Text(_productsError ?? 'Error'))
                              : _productsList.isEmpty
                                  ? const Center(
                                      child: Text('No products found'),
                                    )
                                  : ListView.separated(
                                      separatorBuilder: (context, index) =>
                                          const Divider(
                                        color: Colors.grey,
                                      ),
                                      itemCount: _productsList.length,
                                      itemBuilder: (ctx, index) {
                                        return _getProductCard(
                                            _productsList[index]);
                                      },
                                    )))
            ],
          ),
        ));
  }

  Widget _getProductCard(Product product) {
    debugPrint("Featured Product: ${product.name}, ${product.featured}");
    return Slidable(
      endActionPane: ActionPane(motion: const ScrollMotion(), children: [
        SlidableAction(
          onPressed: ((context) {
            confirmMarkFeatured(product);
          }),
          backgroundColor: product.featured == true ? Colors.red : Colors.green,
          foregroundColor: Colors.white,
          icon: Icons.stars,
          label: 'Featured',
        ),
        SlidableAction(
          onPressed: ((context) {
            confirmDeleteProduct(product);
          }),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          icon: Icons.delete,
          label: 'Remove',
        ),
      ]),
      child: GestureDetector(
        onTap: () {
          Get.to(() => ProductDetail(
                product: product,
              ));
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: MediaQuery.of(context).size.height * 0.16,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kGrey, width: 0.1),
          ),
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.30,
                child: Hero(
                  tag: "product:${product.id}",
                  child: Stack(children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: (product.images != null &&
                              product.images?.isNotEmpty == true)
                          ? Image.network(product.images?.first.url ?? '',
                              fit: BoxFit.contain)
                          : Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                    ),
                    if (product.status == 'sold')
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 2, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                          ),
                          child: const Center(
                            child: Text(
                              'SOLD',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(product.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                )),
                          ),
                          if (product.featured != null &&
                              product.featured == true)
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 12,
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                              "Rs ${NumberFormat("#,##0.00", "en_US").format(product.price)}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              )),
                          const SizedBox(width: 8),
                          Text('|',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade300,
                              )),
                          const SizedBox(width: 8),
                          Text(
                              getTimeAgo(DateTime.tryParse(product.createdAt) ??
                                  DateTime.now()),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade500,
                              )),
                        ],
                      ),
                      const Divider(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.user['name'] ?? '',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  Text(
                                    (product.user["address"] ?? '') +
                                        ', ' +
                                        (product.user["city"] ?? ''),
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: kGrey,
                                    ),
                                  ),
                                ]),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Text(
                              'View More',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: kPrimary,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void confirmDeleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete product?'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteProduct(product);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void confirmMarkFeatured(Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Feature product?'),
          content: Text(
              'Are you sure you want to ${product.featured == true ? 'unmark' : 'mark'} this product featured?'),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                markFeatured(product);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void markFeatured(Product product) {
    showProgressDialog(context);
    _productProvider
        .markProductFeatured(
            product.id, product.featured != null ? !product.featured! : true)
        .then((res) {
      Get.back();
      if (res.statusCode == 200) {
        Get.snackbar('Success',
            'Product ${product.featured == true ? 'unmarked' : 'marked'} featured successfully',
            icon: const Icon(Icons.check),
            backgroundColor: Colors.green,
            colorText: Colors.white);
        _getProducts();
      } else {
        Get.snackbar('Error', res.bodyString.toString(),
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    }).catchError((error) {
      debugPrint(error.toString());
      Get.back();
      Get.snackbar('Error', error.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    });
  }

  void deleteProduct(Product product) {
    showProgressDialog(context);
    _productProvider.deleteProduct(product.id).then((res) {
      Get.back();
      if (res.statusCode == 200) {
        Get.snackbar('Success', 'Product deleted successfully',
            icon: const Icon(Icons.check),
            backgroundColor: Colors.green,
            colorText: Colors.white);
        _getProducts();
      } else {
        Get.snackbar('Error', res.bodyString.toString(),
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    }).catchError((error) {
      debugPrint(error.toString());
      Get.back();
      Get.snackbar('Error', error.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    });
  }
}
