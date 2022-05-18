import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onlinedeck/constants.dart';
import 'package:onlinedeck/models/category.dart';
import 'package:onlinedeck/models/product.dart';
import 'package:onlinedeck/providers/category_provider.dart';
import 'package:onlinedeck/providers/product_provider.dart';
import 'package:onlinedeck/utils/app_utils.dart';

class AddProduct extends StatefulWidget {
  final Product? product;
  const AddProduct({Key? key, this.product}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final List<Category> _categories = [];
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];
  final _categoryProvider = CategoryProvider();
  final _productProvider = ProductProvider();

  Product? _product;

  Category? _selectedCategory;
  String? _selectedType;

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _product = widget.product;
    _nameController = TextEditingController(text: _product?.name ?? '');
    _descriptionController = TextEditingController(text: _product?.name ?? '');
    _priceController = TextEditingController(text: _product?.name ?? '0');
    _selectedType = _product?.type ?? 'Used';
    super.initState();

    checkCategories();
  }

  void checkCategories() {
    var categories = GetStorage().read('categories') as List<Category>?;

    if (categories != null && categories.isNotEmpty) {
      setState(() {
        _categories.addAll(categories);
      });
    } else {
      _getCategoriesApi();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();

    super.dispose();
  }

  void _getCategoriesApi() {
    _categoryProvider.getAllCategories().then((data) {
      var list = data.body['data'] as List<dynamic>;
      var finalList = List<Category>.from(list
          .map((e) => Category.fromMap(e as Map<String, dynamic>))
          .toList());

      setState(() {
        _categories.clear();
        _categories.addAll(finalList);
        GetStorage().write('categories', _categories);
        if (_product != null) {
          _selectedCategory =
              _categories.firstWhere((e) => e.id == _product?.categoryId);
        }
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(error.toString(), style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: ListView(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ADD PRODUCT',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          ..._getCategory(),
          const SizedBox(
            height: 24,
          ),
          const Text(
            '* NAME',
            style: TextStyle(
              color: kGrey,
              fontSize: 12,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          TextFormField(
            controller: _nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }

              if (value.length > 40) {
                return 'Name should be less than 20 characters';
              }
              if (value.length < 3) {
                return 'Name should be more than 3 characters';
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              isDense: true,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kGrey, width: 0.4)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kPrimary, width: 1)),
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 1)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 1)),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          const Text(
            '* DESCRIPTION',
            style: TextStyle(
              color: kGrey,
              fontSize: 12,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          TextFormField(
            maxLines: null,
            controller: _descriptionController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              if (value.length > 200) {
                return 'Description should be less than 200 characters';
              }

              if (value.length < 10) {
                return 'Description should be more than 10 characters';
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              isDense: true,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kGrey, width: 0.4)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kPrimary, width: 1)),
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 1)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 1)),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          const Text(
            '* PRICE',
            style: TextStyle(
              color: kGrey,
              fontSize: 12,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          TextFormField(
            controller: _priceController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a price';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid price';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              prefixText: "Rs ",
              isDense: true,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kGrey, width: 0.4)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kPrimary, width: 1)),
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 1)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 1)),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          ..._getType(),
          const SizedBox(
            height: 24,
          ),
          const Text(
            'IMAGES',
            style: TextStyle(
              color: kGrey,
              fontSize: 12,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          _getImagePicker(),
          const SizedBox(
            height: 24,
          ),
          InkWell(
            onTap: () {
              if (_formKey.currentState?.validate() == true) {
                debugPrint("Valid");
                _addProduct();
              }
            },
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kPrimary, Colors.green.shade300],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                      child: Text(
                    'CONTINUE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )),
                ),
              ),
            ]),
          ),
          const SizedBox(
            height: 24,
          ),
        ]),
      ),
    );
  }

  _getImagePicker() {
    return GestureDetector(
        onTap: () async {
          final List<XFile>? images = await _picker.pickMultiImage();
          if (images != null && images.isNotEmpty) {
            setState(() {
              _selectedImages.clear();
              _selectedImages.addAll(images);
            });
          }
        },
        child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
              border: Border.all(color: kGrey, width: 0.4),
            ),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: _selectedImages.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                  Icon(
                                    Icons.add_a_photo,
                                    color: kGrey,
                                  ),
                                  Text(
                                    'ADD IMAGES',
                                    style:
                                        TextStyle(fontSize: 12, color: kGrey),
                                  ),
                                ])
                          : SizedBox(
                              height: 100,
                              child: ListView.separated(
                                separatorBuilder: (context, index) =>
                                    const SizedBox(
                                  width: 10,
                                ),
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedImages.length,
                                itemBuilder: (context, index) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Stack(
                                      children: [
                                        Image.file(
                                          File(_selectedImages[index].path),
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                            top: 0,
                                            right: 4,
                                            child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedImages
                                                        .removeAt(index);
                                                  });
                                                },
                                                child: const Text('x',
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 20)))),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ))
                ])));
  }

  _getCategory() {
    return [
      const Text(
        '* CATEGORY',
        style: TextStyle(
          color: kGrey,
          fontSize: 12,
        ),
      ),
      const SizedBox(
        height: 5,
      ),
      DropdownButtonFormField(
        validator: (value) {
          if (value == null) {
            return 'Please select a category';
          }
          return null;
        },
        value: _selectedCategory,
        autovalidateMode: AutovalidateMode.always,
        decoration: InputDecoration(
          isDense: true,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kGrey, width: 0.4)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kPrimary, width: 1)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1)),
        ),
        items: _getCategoriesList(),
        onChanged: (item) {
          _selectedCategory = item as Category?;
        },
      )
    ];
  }

  _getType() {
    return [
      const Text(
        '* PRODUCT TYPE',
        style: TextStyle(
          color: kGrey,
          fontSize: 12,
        ),
      ),
      const SizedBox(
        height: 5,
      ),
      DropdownButtonFormField<String>(
        validator: (value) {
          if (value == null) {
            return 'Please select a product type';
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.always,
        decoration: InputDecoration(
          isDense: true,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kGrey, width: 0.4)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kPrimary, width: 1)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1)),
        ),
        items: _getTypeList(),
        onChanged: (item) {
          _selectedType = item;
        },
      )
    ];
  }

  List<DropdownMenuItem<Category>> _getCategoriesList() {
    return _categories.map((category) {
      return DropdownMenuItem<Category>(
        value: category,
        child: Text(category.name),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> _getTypeList() {
    return const [
      DropdownMenuItem(value: 'used', child: Text('Used')),
      DropdownMenuItem(value: 'brand_new', child: Text('Brand New'))
    ];
  }

  void _addProduct() {
    showProgressDialog(context);

    final _data = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'price': _priceController.text,
      'categoryId': _selectedCategory?.id,
      'type': _selectedType
    };

    final formData = FormData(_data);
    formData.files.addAll(_selectedImages.map((image) {
      return MapEntry('img',
          MultipartFile(image.path, filename: image.path.split('/').last));
    }));
    _productProvider.addProduct(formData).then((res) {
      Get.back();

      if (res.statusCode == 200) {
        Get.back();
        Get.snackbar('Success', 'Product added successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: kPrimary,
            colorText: Colors.white,
            icon: const Icon(
              Icons.check,
              color: Colors.white,
            ));
      } else {
        Get.snackbar('Error', 'Something went wrong: ${res.bodyString}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            icon: const Icon(
              Icons.error,
              color: Colors.white,
            ));
      }
    }).catchError((err) {
      Get.back();
      Get.snackbar('Error', 'Something went wrong: ${err.toString()}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(
            Icons.error,
            color: Colors.white,
          ));
      debugPrint(err.toString());
    });
  }
}
