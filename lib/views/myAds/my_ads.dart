import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:onlinedeck/models/product.dart';
import 'package:onlinedeck/providers/product_provider.dart';
import 'package:onlinedeck/providers/user_provider.dart';
import 'package:onlinedeck/utils/app_utils.dart';

class MyAds extends StatefulWidget {
  const MyAds({Key? key}) : super(key: key);

  @override
  State<MyAds> createState() => _MyAdsState();
}

class _MyAdsState extends State<MyAds> {
  final List<Product> _productList = [];
  final _provider = UserProvider();
  final _productProvider = ProductProvider();
  final _loggedIn = GetStorage().read('token') != null;
  bool _loading = false;

  @override
  void initState() {
    if (_loggedIn) {
      _getMyAds();
    }
    super.initState();
  }

  void _getMyAds() async {
    setState(() {
      _loading = true;
    });
    _provider.getMyAds().then((res) {
      setState(() {
        _loading = false;
      });
      if (res.statusCode == 200) {
        final data = res.body as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>;
        final products = list
            .map((e) => Product.fromMap(e as Map<String, dynamic>))
            .toList();

        setState(() {
          _productList.clear();
          _productList.addAll(products);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(res.bodyString.toString(),
              style: const TextStyle(color: Colors.white)),
        ));
      }
    }).catchError((error) {
      setState(() {
        _loading = false;
      });
      debugPrint(error.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content:
            Text(error.toString(), style: const TextStyle(color: Colors.white)),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Ads',
            style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _loggedIn
            ? _loading
                ? const Center(child: CircularProgressIndicator())
                : _productList.isEmpty
                    ? const Center(
                        child: Text('No Ads Found',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black)))
                    : ListView(
                        children: [
                          ..._productList.map((e) => myProductCard(e)),
                        ],
                      )
            : const Center(
                child: Text('You are not logged in'),
              ),
      ),
    );
  }

  myProductCard(Product product) {
    return Slidable(
      endActionPane: ActionPane(motion: const ScrollMotion(), children: [
        if (product.status == 'active')
          SlidableAction(
            onPressed: ((context) {
              confirmMarkSold(product);
            }),
            backgroundColor: const Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: Icons.check,
            label: 'Mark as sold',
          ),
        SlidableAction(
          onPressed: ((context) {
            confirmDeleteProduct(product);
          }),
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          icon: Icons.delete,
          label: 'Remove',
        ),
      ]),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.shade50,
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            Row(children: [
              Expanded(
                child: ListTile(
                  title: const Text('Added on'),
                  subtitle: Text(
                    DateFormat.yMMMd()
                        .format(DateTime.parse(product.updatedAt)),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: const Text('Price'),
                  subtitle: Text(
                    'Rs ${formatCurrency(product.price.toString())}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ),
            ]),
            Row(children: [
              Expanded(
                child: ListTile(
                  title: const Text('Type'),
                  subtitle: Text(
                    product.type,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: const Text('Status'),
                  subtitle: Text(
                    product.status == 'sold' ? 'Sold' : 'Available',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ),
            ]),
            ExpansionTile(
              childrenPadding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              title: const Text('Description'),
              children: [
                Text(
                  product.description,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void hideProgressDialog(BuildContext context) {
    Navigator.of(context).pop();
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
        _getMyAds();
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

  void _markSold(Product product) async {
    showProgressDialog(context);
    _productProvider.markProductSold(product.id).then((res) {
      Get.back();
      if (res.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Product marked as sold',
          icon: const Icon(Icons.check),
          backgroundColor: Colors.green,
        );
        _getMyAds();
      } else {
        Get.snackbar(
          'Error',
          res.bodyString.toString(),
          backgroundColor: Colors.red,
        );
      }
    }).catchError((error) {
      debugPrint(error.toString());
      Get.back();
      Get.snackbar(
        'Error',
        error.toString(),
        backgroundColor: Colors.red,
      );
    });
  }

  void confirmMarkSold(Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Mark as sold?'),
          content:
              const Text('Are you sure you want to mark this product as sold?'),
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
                _markSold(product);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
