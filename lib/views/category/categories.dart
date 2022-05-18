import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onlinedeck/constants.dart';
import 'package:onlinedeck/models/category.dart';
import 'package:onlinedeck/providers/category_provider.dart';
import 'package:onlinedeck/utils/app_utils.dart';
import 'package:onlinedeck/views/product/products_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  String? _categoryError;
  final _categoryList = <Category>[];
  bool _categoryLoading = false;
  final _categoryProvider = CategoryProvider();
  final _admin = GetStorage().read('admin') as bool? ?? false;

  @override
  void initState() {
    _getCategoriesApi();
    super.initState();
  }

  Future<void> _getCategoriesApi() async {
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
      var finalList = List<Category>.from(list
          .map((e) => Category.fromMap(e as Map<String, dynamic>))
          .toList());

      if (finalList.isEmpty) {
        setState(() {
          _categoryError = "No categories found";
        });
        return;
      }
      debugPrint("FinalList: ${finalList.length}");

      GetStorage().write('categories', finalList);

      setState(() {
        _categoryList.clear();
        _categoryList.addAll(finalList);
      });
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
    return Scaffold(
        floatingActionButton: _admin
            ? FloatingActionButton(
                onPressed: () {
                  showAddCategory();
                },
                child: const Icon(Icons.add),
              )
            : null,
        body: SafeArea(
            child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 12),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              const SizedBox(width: 16),
              if (!_admin)
                IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(Icons.arrow_back_ios, size: 18)),
              const Text('All Categories', style: TextStyle(fontSize: 16)),
            ]),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                  onRefresh: () => _getCategoriesApi(),
                  child: _categoryError != null
                      ? Center(
                          child: Text(
                            _categoryError ?? '',
                          ),
                        )
                      : _categoryLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : (!_categoryLoading && _categoryList.isEmpty)
                              ? const Center(
                                  child: Text(
                                    'No categories found',
                                  ),
                                )
                              : ListView.separated(
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      onTap: (() {
                                        if (!_admin) {
                                          Get.to(
                                            () => ProductsPage(
                                                categoryId:
                                                    _categoryList[index].id,
                                                categoryName:
                                                    _categoryList[index].name),
                                          );
                                        }
                                      }),
                                      onLongPress: () {
                                        if (!_admin) {
                                          return;
                                        }
                                        showUpdateCategory(
                                            _categoryList[index]);
                                      },
                                      style: ListTileStyle.drawer,
                                      leading: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 12),
                                              decoration: BoxDecoration(
                                                color: kPrimary.shade50,
                                                border: Border.all(
                                                    color: kPrimary.shade700,
                                                    width: 0.5),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                getIcon(
                                                    _categoryList[index].icon),
                                                color: kPrimary,
                                                size: 20,
                                              ),
                                            ),
                                          ]),
                                      title: Text(_categoryList[index].name),
                                      subtitle: Text(
                                          _categoryList[index].description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey)),
                                      trailing: !_admin
                                          ? const Icon(Icons.chevron_right)
                                          : null,
                                    );
                                  },
                                  separatorBuilder: (context, index) =>
                                      const Divider(),
                                  itemCount: _categoryList.length)),
            )
          ],
        )));
  }

  void showCategorySheet(Category? category) {
    final _categoryNameController =
        TextEditingController(text: category?.name ?? '');
    final _categoryDescriptionController =
        TextEditingController(text: category?.description ?? '');
    final _categoryIconController =
        TextEditingController(text: category?.icon ?? '');
    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (ctx) {
        return Form(
          key: _formKey,
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(children: [
                const SizedBox(height: 12),
                Text(
                  category != null ? 'Edit Category' : 'Add Category',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Category name is required';
                    }
                    return null;
                  },
                  controller: _categoryNameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: Theme.of(context).textTheme.bodyText1,
                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kGrey, width: 0.6)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: kPrimary, width: 1)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 1)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 1)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _categoryDescriptionController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Category description is required';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    isDense: true,
                    labelStyle: Theme.of(context).textTheme.bodyText1,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kGrey, width: 0.6)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: kPrimary, width: 1)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 1)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 1)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _categoryIconController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Category icon is required';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Icon',
                    isDense: true,
                    labelStyle: Theme.of(context).textTheme.bodyText1,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kGrey, width: 0.6)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: kPrimary, width: 1)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 1)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 1)),
                  ),
                ),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                      child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        primary: kPrimary,
                        textStyle: Theme.of(context).textTheme.button),
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      if (category != null) {
                        updateCategory(
                            category.id,
                            _categoryNameController.text,
                            _categoryDescriptionController.text,
                            _categoryIconController.text);
                      } else {
                        addCategory(
                            _categoryNameController.text,
                            _categoryDescriptionController.text,
                            _categoryIconController.text);
                      }
                    },
                    child: Text(category != null ? 'Update' : 'Add',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16)),
                  ))
                ]),
              ])),
        );
      },
    );
  }

  void showAddCategory() {
    showCategorySheet(null);
  }

  void showUpdateCategory(Category category) {
    showCategorySheet(category);
  }

  void updateCategory(int id, String name, String desc, String icon) {
    showProgressDialog(context);
    _categoryProvider.updateCategory(id, name, desc, icon).then((res) {
      Get.back();
      if (res.statusCode == 200) {
        _getCategoriesApi();
        Get.back();
        Get.snackbar('Success', 'Category updated successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: kPrimary,
            colorText: Colors.white,
            borderRadius: 8,
            margin: const EdgeInsets.all(8),
            snackStyle: SnackStyle.FLOATING,
            duration: const Duration(seconds: 2));
      } else {
        Get.snackbar('Error', 'Error updating category: ${res.bodyString}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            borderRadius: 8,
            margin: const EdgeInsets.all(8),
            snackStyle: SnackStyle.FLOATING,
            duration: const Duration(seconds: 2));
      }
    }).catchError((err) {
      Get.back();
      Get.snackbar('Error', 'Error updating category: $err',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          borderRadius: 8,
          margin: const EdgeInsets.all(8),
          snackStyle: SnackStyle.FLOATING,
          duration: const Duration(seconds: 2));
    });
  }

  void addCategory(String name, String desc, String icon) {
    showProgressDialog(context);
    _categoryProvider.addCategory(name, desc, icon).then((res) {
      Get.back();
      if (res.statusCode == 200) {
        _getCategoriesApi();
        Get.back();
        Get.snackbar('Success', 'Category added successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: kPrimary,
            colorText: Colors.white,
            borderRadius: 8,
            margin: const EdgeInsets.all(8),
            snackStyle: SnackStyle.FLOATING,
            duration: const Duration(seconds: 2));
      } else {
        Get.snackbar('Error', 'Error adding category: ${res.bodyString}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            borderRadius: 8,
            margin: const EdgeInsets.all(8),
            snackStyle: SnackStyle.FLOATING,
            duration: const Duration(seconds: 2));
      }
    }).catchError((err) {
      Get.back();
      Get.snackbar('Error', 'Error adding category: $err',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          borderRadius: 8,
          margin: const EdgeInsets.all(8),
          snackStyle: SnackStyle.FLOATING,
          duration: const Duration(seconds: 2));
    });
  }
}
