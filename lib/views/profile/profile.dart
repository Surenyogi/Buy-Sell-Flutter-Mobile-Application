import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:onlinedeck/constants.dart';
import 'package:onlinedeck/providers/user_provider.dart';
import 'package:onlinedeck/views/auth/login.dart';
import 'package:onlinedeck/views/home.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String? _user = GetStorage().read('token');
  final Map<String, dynamic>? _userProfile = GetStorage().read('user');

  final _provider = UserProvider();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isInEditMode = false;

  @override
  void initState() {
    if (_userProfile != null) {
      _nameController.text = _userProfile?['name'] ?? '';
      _emailController.text = _userProfile?['email'] ?? '';
      _phoneController.text = _userProfile?['phone'] ?? '';
      _addressController.text = _userProfile?['address'] ?? '';
      _dobController.text = _userProfile?['dob'];
      _cityController.text = _userProfile?['city'] ?? '';
      _stateController.text = _userProfile?['state'] ?? '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(_userProfile.toString());
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _user == null ? notLoggedIn() : loggedIn()),
    );
  }

  Widget loggedIn() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text(
              'Profile',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            IconButton(
                onPressed: () {
                  GetStorage().write('token', null);
                  GetStorage().write('user', null);
                  GetStorage().write('admin', null);
                  Get.offAll(() => const Home());
                },
                icon: const Icon(Icons.exit_to_app)),
          ]),
          const SizedBox(
            height: 20,
          ),
          Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              radius: 36,
              child: Text(
                (_userProfile?['name'][0] ?? 'N').toString().toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Text('Name',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      )),
                  const SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    controller: _nameController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 245, 245, 245),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2),
                    readOnly: !_isInEditMode,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('Email',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      )),
                  const SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      // validate email
                      if (!value.isEmail) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 245, 245, 245),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2),
                    readOnly: !_isInEditMode,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('Phone',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      )),
                  const SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    controller: _phoneController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (!value.isPhoneNumber) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 245, 245, 245),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2),
                    readOnly: !_isInEditMode,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('Address',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      )),
                  const SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    controller: _addressController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 245, 245, 245),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2),
                    readOnly: !_isInEditMode,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('Date of Birth',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      )),
                  const SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    controller: _dobController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your date of birth';
                      }
                      return null;
                    },
                    onTap: () async {
                      if (!_isInEditMode) return;
                      await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2025),
                      ).then((selectedDate) {
                        if (selectedDate != null) {
                          _dobController.text =
                              DateFormat.yMMMMd().format(selectedDate);
                        }
                      });
                    },
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 245, 245, 245),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2),
                    readOnly: !_isInEditMode,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('City',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      )),
                  const SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    controller: _cityController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your city';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 245, 245, 245),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2),
                    readOnly: !_isInEditMode,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('State',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      )),
                  const SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    controller: _stateController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your state';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 245, 245, 245),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2),
                    readOnly: !_isInEditMode,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              onPressed: () {
                if (_isInEditMode) {
                  if (_formKey.currentState!.validate()) {
                    _tryUpdateProfile();
                  }
                } else {
                  setState(() {
                    _isInEditMode = true;
                  });
                }
              },
              child: Text(_isInEditMode ? 'UPDATE PROFILE' : 'EDIT PROFILE')),
          const SizedBox(
            height: 20,
          ),
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              onPressed: () {
                showChangePasswordDialog(context);
              },
              child: const Text('CHANGE PASSWORD')),
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }

  Widget notLoggedIn() {
    return Center(
      child: ElevatedButton(
        child: const Text('Login'),
        onPressed: () {
          Get.to(() => const Login());
        },
      ),
    );
  }

  void showChangePasswordDialog(BuildContext context) {
    final _oldPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    showModalBottomSheet(
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (ctx, myState) {
          bool _isLoading = false;
          return Scaffold(
            body: Container(
              padding: const EdgeInsets.all(20),
              child: ListView(children: <Widget>[
                const Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _oldPasswordController,
                  autovalidateMode: AutovalidateMode.always,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your old password';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    fillColor: const Color.fromARGB(255, 245, 245, 245),
                    labelText: 'Old Password',
                    hintText: 'Enter old password',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kPrimary, width: 1),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 0.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                  ),
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _newPasswordController,
                  autovalidateMode: AutovalidateMode.always,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter new password';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    fillColor: const Color.fromARGB(255, 245, 245, 245),
                    labelText: 'New Password',
                    hintText: 'Enter new password',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kPrimary, width: 1),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 0.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                  ),
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  autovalidateMode: AutovalidateMode.always,
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    fillColor: const Color.fromARGB(255, 245, 245, 245),
                    labelText: 'Confirm Password',
                    hintText: 'Confirm new password',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kPrimary, width: 1),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 0.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                  ),
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2),
                ),
                const SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                    ),
                    onPressed: () {
                      if (_newPasswordController.text ==
                          _confirmPasswordController.text) {
                        myState(() {
                          _isLoading = true;
                        });
                        _provider
                            .changePassword(
                          _oldPasswordController.text,
                          _newPasswordController.text,
                        )
                            .then((res) {
                          myState(() {
                            _isLoading = false;
                          });
                          if (res.statusCode == 200) {
                            Navigator.pop(context);

                            Get.snackbar(
                              'Success',
                              'Password changed successfully',
                              backgroundColor: kPrimary,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                              borderRadius: 12,
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(8),
                              borderColor: Colors.grey,
                              borderWidth: 1,
                              duration: const Duration(seconds: 2),
                            );
                          } else {
                            Get.snackbar(
                              'Error',
                              res.bodyString.toString(),
                              icon: const Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                              backgroundColor: Colors.white,
                              colorText: Colors.red,
                              borderRadius: 12,
                              snackPosition: SnackPosition.TOP,
                              margin: const EdgeInsets.all(8),
                              duration: const Duration(seconds: 3),
                            );
                          }
                        }).catchError((err) {
                          myState(() {
                            _isLoading = false;
                          });
                          Get.snackbar(
                            'Error',
                            err.toString(),
                            icon: const Icon(
                              Icons.error,
                              color: Colors.red,
                            ),
                            backgroundColor: Colors.white,
                            colorText: Colors.red,
                            borderRadius: 12,
                            snackPosition: SnackPosition.TOP,
                            margin: const EdgeInsets.all(8),
                            duration: const Duration(seconds: 3),
                          );
                        });
                      } else {
                        Get.snackbar(
                          'Error',
                          'New password and confirm password do not match',
                          icon: const Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                          backgroundColor: Colors.white,
                          colorText: Colors.black,
                          borderRadius: 12,
                          snackPosition: SnackPosition.TOP,
                          margin: const EdgeInsets.all(20),
                          duration: const Duration(seconds: 3),
                        );
                      }
                    },
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : const Text('CHANGE PASSWORD')),
                const SizedBox(
                  height: 40,
                ),
              ]),
            ),
          );
        });
      },
    );
  }

  void _tryUpdateProfile() {
    showDialog(
        context: context,
        builder: (ctx) {
          return const Center(child: CircularProgressIndicator());
        });
    _provider
        .updateProfile(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      state: _stateController.text,
      city: _cityController.text,
      address: _addressController.text,
      dob: _dobController.text,
    )
        .then((res) {
      Get.back();
      if (res.statusCode == 200) {
        setState(() {
          _isInEditMode = false;
        });
        Get.back();
        GetStorage().write('user', res.body?['data']);
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          backgroundColor: kPrimary,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          borderRadius: 12,
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          borderColor: Colors.grey,
          borderWidth: 1,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          res.bodyString.toString(),
          icon: const Icon(
            Icons.error,
            color: Colors.red,
          ),
          backgroundColor: Colors.white,
          colorText: Colors.red,
          borderRadius: 12,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(8),
          duration: const Duration(seconds: 3),
        );
      }
    }).catchError((err) {
      Get.back();
      Get.snackbar(
        'Error',
        err.toString(),
        icon: const Icon(
          Icons.error,
          color: Colors.red,
        ),
        backgroundColor: Colors.white,
        colorText: Colors.red,
        borderRadius: 12,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(8),
        duration: const Duration(seconds: 3),
      );
    });
  }
}
