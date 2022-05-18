import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:onlinedeck/constants.dart';
import 'package:onlinedeck/models/category.dart';
import 'package:onlinedeck/models/product.dart';
import 'package:onlinedeck/providers/category_provider.dart';
import 'package:onlinedeck/providers/product_provider.dart';
import 'package:onlinedeck/providers/user_provider.dart';
import 'package:onlinedeck/utils/app_utils.dart';
import 'package:onlinedeck/utils/date_utils.dart';
import 'package:onlinedeck/views/category/categories.dart';
import 'package:onlinedeck/views/product/product_detail.dart';
import 'package:onlinedeck/views/product/products_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _categoryProvider = CategoryProvider();
  final _productProvider = ProductProvider();
  final _userProvider = UserProvider();

  final _categoryList = <Category>[];
  final _featuredProductList = <Product>[];
  final _recentProductList = <Product>[];
  String? _featuredError;
  String? _categoryError;
  String? _recentError;

  bool _featuredLoading = false;
  bool _categoryLoading = false;
  bool _recentLoading = false;
  String? _userName;

  @override
  void initState() {
    final profile = _userProvider.getMyProfile();
    if (profile != null) {
      _userName = (profile as Map<String, dynamic>)['name'].toString();
    }
    super.initState();
    _getCategoriesApi();
    _getFeaturedProducts();
    _getRecentProducts();
  }

  void _getFeaturedProducts() async {
    setState(() {
      _featuredLoading = true;
    });
    _productProvider.getFeaturedProducts().then((res) {
      setState(() {
        _featuredLoading = false;
      });
      if (res.statusCode == 200) {
        final data = res.body as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>?;

        if (list == null) {
          setState(() {
            _featuredError = "No products found";
          });
          return;
        }
        final products = list
            .map((e) => Product.fromMap(e as Map<String, dynamic>))
            .toList();

        if (products.isEmpty) {
          setState(() {
            _featuredError = "No products found";
          });
          return;
        }
        _featuredError = null;

        setState(() {
          _featuredProductList.clear();
          _featuredProductList.addAll(products);
        });
      } else {
        setState(() {
          _featuredError = res.bodyString;
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
        _featuredLoading = false;
        _featuredError = error.toString();
      });
      Get.snackbar(
        'Error getting featured products',
        error.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    });
  }

  void _getRecentProducts() async {
    setState(() {
      _recentLoading = true;
    });
    _productProvider.getRecentProducts().then((res) {
      debugPrint(res.body.toString());
      setState(() {
        _recentLoading = false;
      });
      if (res.statusCode == 200) {
        final data = res.body as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>?;

        if (list == null) {
          setState(() {
            _recentError = "No products found";
          });
          return;
        }
        _recentError = null;
        final products = list
            .map((e) => Product.fromMap(e as Map<String, dynamic>))
            .toList();

        if (products.isEmpty) {
          setState(() {
            _recentError = "No products found";
          });
          return;
        }

        setState(() {
          _recentProductList.clear();
          _recentProductList.addAll(products);
        });
      } else {
        setState(() {
          _recentError = res.bodyString;
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
        _recentLoading = false;
        _recentError = error.toString();
      });
      Get.snackbar(
        'Error Getting Recent Products',
        error.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    });
  }

  void _getCategoriesApi() async {
    setState(() {
      _categoryLoading = true;
    });
    _categoryProvider.getAllCategories().then((data) {
      setState(() {
        _categoryLoading = false;
      });
      var list = data.body['data'] as List<dynamic>?;

      if (list == null) {
        setState(() {
          _categoryError = "No categories found";
        });
        return;
      }
      _categoryError = null;
      var finalList = List<Category>.from(list
          .map((e) => Category.fromMap(e as Map<String, dynamic>))
          .toList());

      if (finalList.isNotEmpty) {
        GetStorage().write('categories', finalList);

        setState(() {
          _categoryList.clear();
          _categoryList.addAll(finalList.take(6));
        });
      } else {
        GetStorage().write('categories', null);
        setState(() {
          _categoryError = "No categories found";
        });
      }
    }).catchError((error) {
      setState(() {
        _categoryLoading = false;
        _categoryError = error.toString();
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
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: RefreshIndicator(
          onRefresh: () {
            if (!_featuredLoading) {
              _getFeaturedProducts();
            }
            if (!_categoryLoading) {
              _getCategoriesApi();
            }
            if (!_recentLoading) {
              _getRecentProducts();
            }
            return Future.value(null);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ListView(
              children: [
                Row(children: [
                  Hero(
                    tag: 'logo',
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 60,
                      alignment: Alignment.centerLeft,
                      width: 60,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Online Deck',
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      Text(
                        'Buy in Sell out',
                        style: TextStyle(fontSize: 10, color: Colors.black),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (_userName != null)
                    CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey.shade200,
                        child: Center(
                          child: Text(_userName?[0].toUpperCase() ?? 'A'),
                        ))
                ]),
                const SizedBox(height: 16),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/banner.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => const CategoriesPage());
                      },
                      child: const Text(
                        'SEE ALL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.12,
                  child: _categoryLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : _categoryError != null
                          ? Center(child: Text('$_categoryError'))
                          : _getCategories(),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Featured',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                ..._featuredLoading
                    ? [
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      ]
                    : _featuredError != null
                        ? [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.10,
                              child: Center(
                                child: Text('$_featuredError'),
                              ),
                            ),
                          ]
                        : _getProducts(false),
                const SizedBox(height: 20),
                const Text(
                  'Recently Added',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                ..._recentLoading
                    ? [
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      ]
                    : _recentError != null
                        ? [
                            Center(
                              child: Text('$_recentError'),
                            ),
                          ]
                        : _getProducts(true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getProductCard(Product product) {
    debugPrint("Featured Product: ${product.name}, ${product.featured}");
    return GestureDetector(
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
                            getTimeAgo(DateTime.tryParse(product.updatedAt) ??
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
    );
  }

  List<Widget> _getProducts(bool recent) {
    if (recent) {
      if (_recentProductList.isEmpty) {
        return [
          const Center(
            child: Text('No recent products'),
          )
        ];
      }
      return _recentProductList.map((product) {
        return _getProductCard(product);
      }).toList();
    }

    if (_featuredProductList.isEmpty) {
      return [
        const Center(
          child: Text('No featured products'),
        )
      ];
    }

    return _featuredProductList.map((product) {
      return _getProductCard(product);
    }).toList();
  }

  Widget _getCategories() {
    return _categoryList.isNotEmpty
        ? ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categoryList.length,
            itemBuilder: ((context, index) {
              return Column(children: [
                GestureDetector(
                  onTap: () {
                    Get.to(() => ProductsPage(
                          categoryId: _categoryList[index].id,
                          categoryName: _categoryList[index].name,
                        ));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 18),
                    decoration: BoxDecoration(
                      color: kPrimary.shade50,
                      border: Border.all(color: kPrimary.shade700, width: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      getIcon(_categoryList[index].icon),
                      color: kPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _categoryList[index].name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: kGrey,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]);
            }),
            separatorBuilder: (context, index) => const SizedBox(
              width: 20,
            ),
          )
        : const Center(
            child: Text('No Categories'),
          );
  }
}
