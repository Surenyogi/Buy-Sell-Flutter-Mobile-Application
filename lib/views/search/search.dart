import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onlinedeck/constants.dart';
import 'package:onlinedeck/models/category.dart';
import 'package:onlinedeck/models/product.dart';
import 'package:onlinedeck/providers/product_provider.dart';
import 'package:onlinedeck/widgets/product_card.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final _provider = ProductProvider();
  final List<Product> _searchResults = [];
  String? _sort = 'latest';
  String? _query = '';
  bool _searchLoading = false;
  String? _searchError;
  final List<Category> _categories = [];
  bool? featuredOnly = false;
  String? minPrice;
  String? maxPrice;
  int? category;

  @override
  void initState() {
    checkAndAddCategories();
    super.initState();
  }

  void checkAndAddCategories() async {
    var categoryString = await GetStorage().read('categories');

    if (categoryString != null) {
      _categories.addAll(categoryString);
    }
    debugPrint('Categories: ${_categories.length}');
  }

  void searchProducts() {
    setState(() {
      _searchLoading = true;
    });
    debugPrint('Searching for: $_query');
    debugPrint('Sort: $_sort');
    debugPrint('Featured: $featuredOnly');
    debugPrint('Min Price: $minPrice');
    debugPrint('Max Price: $maxPrice');
    debugPrint('Category: $category');

    _provider
        .getAllProducts(
            query: _query,
            sort: _sort,
            isFeatured: featuredOnly == true,
            minPrice: minPrice,
            category: category,
            maxPrice: maxPrice)
        .then((res) {
      debugPrint(res.body.toString());
      setState(() {
        _searchLoading = false;
      });

      if (res.statusCode == 200) {
        final data = res.body as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>?;
        if (list == null) {
          setState(() {
            _searchError = "No results found";
          });
          return;
        }
        final products = list
            .map((e) => Product.fromMap(e as Map<String, dynamic>))
            .toList();

        setState(() {
          _searchResults.clear();
          _searchResults.addAll(products);
        });
      } else {
        setState(() {
          _searchError = res.bodyString;
        });
        Get.snackbar(
          'Error',
          res.bodyString.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }).catchError((error) {
      setState(() {
        _searchLoading = false;
        _searchError = error.toString();
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

  void showFilterSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
          maxWidth: MediaQuery.of(context).size.width,
          minHeight: MediaQuery.of(context).size.height * 0.4,
          minWidth: MediaQuery.of(context).size.width,
        ),
        builder: (ctx) {
          final _minPriceController =
              TextEditingController(text: (minPrice ?? '').toString());
          final _maxPriceController = TextEditingController(
            text: (maxPrice ?? '').toString(),
          );
          Category? _selectedCategory = category != null
              ? _categories.firstWhere((element) => element.id == category)
              : null;
          bool _featuredOnly = featuredOnly ?? false;

          return StatefulBuilder(builder: (context, myState) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: ListView(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter',
                      style: TextStyle(fontSize: 20),
                    ),
                    TextButton(
                        onPressed: () {
                          Get.back();
                          minPrice = null;
                          maxPrice = null;
                          category = null;
                          featuredOnly = null;
                          searchProducts();
                        },
                        child: const Text('Reset')),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'CATEGORY',
                  style: TextStyle(
                    color: kGrey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                DropdownButtonFormField<Category>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kGrey, width: 0.4)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: kPrimary, width: 1)),
                  ),
                  items: _getCategoriesList(),
                  onChanged: (item) {
                    _selectedCategory = item;
                  },
                ),
                const SizedBox(height: 20),
                //min and max price text form field
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minPriceController,
                      decoration: InputDecoration(
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: kGrey, width: 0.4)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: kPrimary, width: 1)),
                        labelText: 'Min Price',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          signed: false, decimal: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _maxPriceController,
                      decoration: InputDecoration(
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: kGrey, width: 0.4)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: kPrimary, width: 1)),
                        labelText: 'Max Price',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          signed: false, decimal: true),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      'Featured Only',
                      style: TextStyle(
                        color: kGrey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Checkbox(
                      value: _featuredOnly,
                      onChanged: (value) {
                        myState(() {
                          _featuredOnly = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text(
                    'Apply',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    minPrice = _minPriceController.text;
                    maxPrice = _maxPriceController.text;
                    category = _selectedCategory?.id;
                    featuredOnly = _featuredOnly;
                    searchProducts();
                  },
                ),
              ]),
            );
          });
        });
  }

  List<DropdownMenuItem<Category>> _getCategoriesList() {
    return _categories.map((category) {
      return DropdownMenuItem<Category>(
        value: category,
        child: Text(category.name),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Expanded(
                      flex: 6,
                      child: Text('Search Results',
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                    ),
                    Flexible(
                      flex: 7,
                      child: DropdownButton<String>(
                        items: _getSortOptions(),
                        onChanged: (value) {
                          if (value != _sort) {
                            setState(() {
                              _sort = value;
                            });
                            searchProducts();
                          }
                        },
                        value: _sort,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                        alignment: AlignmentDirectional.centerEnd,
                        underline: Container(),
                        iconSize: 24,
                        isDense: true,
                        isExpanded: false,
                        icon: const Icon(Icons.arrow_drop_down),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _searchLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : _searchError != null
                          ? Center(
                              child: Text(_searchError.toString()),
                            )
                          : _searchResults.isEmpty
                              ? const Center(
                                  child: Text('No Products Found'),
                                )
                              : _buildSearchResults(),
                )
              ],
            ),
          ),
        ));
  }

  Widget _buildSearchResults() {
    return AnimationLimiter(
      child: GridView.builder(
        itemCount: _searchResults.length,
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
                _searchResults[index],
              ))));
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 24,
              color: kPrimary,
            )),
        Expanded(
          child: TextFormField(
            autofocus: true,
            textInputAction: TextInputAction.search,
            autocorrect: false,
            keyboardType: TextInputType.text,
            onFieldSubmitted: (text) {
              _query = text;
              searchProducts();
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(CupertinoIcons.search),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintText: 'Search',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kPrimary, width: 1),
              ),
            ),
          ),
        ),
        IconButton(
            onPressed: () {
              showFilterSheet();
            },
            icon: Icon(Icons.filter_alt_outlined,
                size: 24,
                color: category != null ||
                        minPrice != null ||
                        maxPrice != null ||
                        featuredOnly == true
                    ? kPrimary
                    : Colors.grey)),
      ],
    );
  }

  Widget buildSearchResults() {
    return AnimationLimiter(
      child: GridView.builder(
        itemCount: _searchResults.length,
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
                _searchResults[index],
              ))));
        },
      ),
    );
  }

  List<DropdownMenuItem<String>> _getSortOptions() {
    return const [
      DropdownMenuItem(
        child: Text('Latest'),
        value: 'latest',
      ),
      DropdownMenuItem(
        child: Text('Price: Low to High'),
        value: 'lowToHigh',
      ),
      DropdownMenuItem(
        child: Text('Price: High to Low'),
        value: 'highToLow',
      ),
      DropdownMenuItem(
        child: Text('Relevance'),
        value: 'relevance',
      ),
      DropdownMenuItem(
        child: Text('A-Z'),
        value: 'a-z',
      ),
      DropdownMenuItem(
        child: Text('Z-A'),
        value: 'z-a',
      ),
    ];
  }
}
