import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:onlinedeck/providers/user_provider.dart';
import 'package:onlinedeck/utils/app_utils.dart';

class UsersAdmin extends StatefulWidget {
  const UsersAdmin({Key? key}) : super(key: key);

  @override
  State<UsersAdmin> createState() => _UsersAdminState();
}

class _UsersAdminState extends State<UsersAdmin> {
  final List<Map<String, dynamic>> _usersList = [];
  bool _usersLoading = false;
  String? _userError;

  final _userProvider = UserProvider();

  @override
  void initState() {
    _getUsers();
    super.initState();
  }

  Future<void> _getUsers() async {
    setState(() {
      _usersLoading = true;
    });
    _userProvider.getAllUsers().then((res) {
      setState(() {
        _usersLoading = false;
      });
      if (res.statusCode == 200) {
        _userError = null;
        final data = res.body as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>?;

        if (list == null) {
          return;
        }

        setState(() {
          _usersList.clear();
          _usersList.addAll(list.map((e) => e as Map<String, dynamic>));
        });

        if (_usersList.isEmpty) {
          setState(() {
            _userError = 'No users found';
          });
        }
      } else {
        setState(() {
          _userError = res.bodyString;
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
        _usersLoading = false;
        _userError = error.toString();
      });
      Get.snackbar(
        'Error getting  users',
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
        elevation: 0,
        title: const Text(
          'Users',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => _getUsers(),
        child: _usersLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _userError != null
                ? Center(
                    child: Text(
                      _userError ?? 'Unknown Error',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.separated(
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 12,
                      ),
                      itemCount: _usersList.length,
                      itemBuilder: (ctx, index) {
                        final user = _usersList[index];
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 0.4,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ExpansionTile(
                            backgroundColor: Colors.transparent,
                            collapsedBackgroundColor: Colors.transparent,
                            textColor: Colors.black,
                            collapsedTextColor: Colors.black,
                            title: Text(
                              user['name'],
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.black),
                            ),
                            subtitle: Text(
                              user['email'],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      title: const Text(
                                        'Phone',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Text(
                                        user['phone'] ?? 'unavailable',
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      title: const Text(
                                        'Date of Birth',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Text(
                                        user['dob'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              ListTile(
                                title: const Text(
                                  'Full Address',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  "${user['address'] ?? 'unavailable'}\n${user['city'] ?? 'unavailable'}, ${user['state'] ?? 'unavailable'}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      title: const Text(
                                        'Created At',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Text(
                                        DateFormat.yMMMMd().format(
                                            DateTime.parse(user['createdAt'])),
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: ListTile(
                                      title: const Text(
                                        'Product Count',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Text(
                                        user['productsCount'] != null
                                            ? user['productsCount'].toString()
                                            : '0',
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: OutlinedButton(
                                          onPressed: () {
                                            tryRemoveUser(user['id']);
                                          },
                                          child: const Text('Remove User',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.red,
                                              )))),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  void tryRemoveUser(int id) {
    showProgressDialog(context);
    _userProvider.removeUser(id).then((res) {
      Get.back();
      if (res.statusCode == 200) {
        Get.snackbar(
          'Success',
          'User Removed',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        _getUsers();
      } else {
        Get.snackbar(
          'Error',
          res.bodyString.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }).catchError((error) {
      Get.back();
      Get.snackbar(
        'Error',
        error.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    });
  }
}
