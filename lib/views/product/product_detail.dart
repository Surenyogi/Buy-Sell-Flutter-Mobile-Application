import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:onlinedeck/constants.dart';
import 'package:onlinedeck/models/comment.dart';
import 'package:onlinedeck/models/product.dart';
import 'package:onlinedeck/providers/product_provider.dart';
import 'package:onlinedeck/utils/app_utils.dart';
import 'package:onlinedeck/utils/date_utils.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetail extends StatefulWidget {
  final Product product;
  const ProductDetail({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final _admin = GetStorage().read('admin') as bool? ?? false;

  final PageController _pageController = PageController(initialPage: 0);
  final _commentController = TextEditingController();
  bool _commentButtonEnabled = false;
  bool _addCommentLoading = false;
  bool _reportsLoading = false;
  String? _reportError;

  late final Product _product;
  final _provider = ProductProvider();
  final List<Comment> _comments = [];
  final List<Map<String, dynamic>> _reports = [];

  bool _commentsLoading = false;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    _product = widget.product;
    debugPrint("ProductUserID: ${_product.user['id']}");
    _user = GetStorage().read('user');
    super.initState();
    _getComments();
    if (_admin) {
      _getReports();
    }
    if (_user != null) {
      _commentController.addListener(() {
        setState(() {
          _commentButtonEnabled = _commentController.text.isNotEmpty;
        });
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _getComments() async {
    setState(() {
      _commentsLoading = true;
    });
    _provider.getCommentsByProductId(_product.id).then((response) {
      setState(() {
        _commentsLoading = false;
      });
      if (response.statusCode == 200) {
        final data = response.body as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>;
        debugPrint(list.toString());
        final comments = list
            .map((e) => Comment.fromMap(e as Map<String, dynamic>))
            .toList();

        setState(() {
          _comments.clear();
          _comments.addAll(comments);
        });
      }
    }).catchError((error) {
      setState(() {
        _commentsLoading = false;
      });

      Get.snackbar('Error', 'Error getting comments',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10));
    });
  }

  void _getReports() async {
    setState(() {
      _reportsLoading = true;
    });
    _provider.getProductReports(_product.id).then((response) {
      setState(() {
        _reportsLoading = false;
      });
      if (response.statusCode == 200) {
        final data = response.body as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>;
        debugPrint(list.toString());
        final reports = list.map((e) => e as Map<String, dynamic>).toList();

        setState(() {
          _reportError = null;
          _reports.clear();
          _reports.addAll(reports);
        });
      } else {
        setState(() {
          _reportError = response.bodyString;
        });
        Get.snackbar('Error', 'Error getting reports',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            margin: const EdgeInsets.all(10));
      }
    }).catchError((error) {
      setState(() {
        _reportError = error.toString();
        _reportsLoading = false;
      });

      Get.snackbar('Error', 'Error getting comments',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: (() {
          FocusScope.of(context).requestFocus(FocusNode());
        }),
        child: SafeArea(
          child: Stack(children: [
            ListView(
              children: [
                _buildImageCarousel(),
                const SizedBox(height: 20),
                _buildProductInfo(),
                _buildComments(),
                const SizedBox(height: 32),
                if (!_admin) ...[
                  _buildAddComment(),
                  const SizedBox(height: 32),
                ],
                if (_admin) ...[
                  _buildReports(),
                  const SizedBox(height: 40),
                ]
              ],
            ),
            Positioned(
              top: 0,
              left: 10,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white,
                onPressed: () {},
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, color: kPrimary),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildAddComment() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _commentController,
              style: const TextStyle(fontSize: 16),
              maxLines: 1,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                hintText: 'Add a comment',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey, width: 0.4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: kPrimary, width: 1),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _addCommentLoading
              ? const CircularProgressIndicator()
              : IconButton(
                  icon: Icon(Icons.send,
                      color: _commentButtonEnabled ? kPrimary : Colors.grey),
                  onPressed: () {
                    if (_commentButtonEnabled) {
                      _addComment();
                    }
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildComments() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _commentsLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Comments (${_comments.length})',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 20),
                _commentsLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _comments.isEmpty
                        ? const Center(child: Text('No comments yet'))
                        : ListView.separated(
                            separatorBuilder: (context, index) =>
                                const Divider(height: 30),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              final _randomColor = Color.fromARGB(
                                  255,
                                  Random.secure().nextInt(255),
                                  Random.secure().nextInt(255),
                                  Random.secure().nextInt(255));
                              debugPrint(
                                  "CommentUserId: ${comment.user?['id']}");
                              return Slidable(
                                enabled: _admin,
                                endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) {
                                        _deleteComment(comment);
                                      },
                                      backgroundColor: Colors.red,
                                      icon: Icons.delete,
                                      foregroundColor: Colors.white,
                                    )
                                  ],
                                ),
                                child: Column(children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: _randomColor,
                                        backgroundImage: const AssetImage(
                                          'assets/images/logo_white.png',
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              comment.comment,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: RichText(
                                                    text: TextSpan(
                                                      text:
                                                          '${comment.user?['name']} ',
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: kGrey,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      children: [
                                                        TextSpan(
                                                          text: getTimeAgo(
                                                              DateTime.parse(
                                                                  comment
                                                                      .createdAt)),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .grey),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ]),
                              );
                            },
                          ),
              ],
            ),
    );
  }

  Widget _buildReportButton() {
    return GestureDetector(
      onTap: () {
        if (_user == null) {
          Get.snackbar('Error', 'You must be logged in to report a product');
          return;
        }
        _showReportSheet();
      },
      child: Row(children: const [
        Icon(
          Icons.warning,
          size: 12,
          color: Colors.red,
        ),
        SizedBox(width: 5),
        Text('Report', style: TextStyle(color: Colors.red, fontSize: 12)),
      ]),
    );
  }

  Widget _buildImageCarousel() {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(children: [
        Hero(
          tag: 'product:${_product.id}',
          child: PageView(
            controller: _pageController,
            children: _product.images?.isNotEmpty == true
                ? _product.images!
                    .map((image) => Image.network(
                          image.url,
                          fit: BoxFit.cover,
                        ))
                    .toList()
                : [
                    Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    )
                  ],
          ),
        ),
        Positioned(
            bottom: 10,
            left: MediaQuery.of(context).size.width * 0.5 - 40,
            child: SmoothPageIndicator(
              count: (_product.images?.length ?? 0) != 0
                  ? _product.images?.length ?? 1
                  : 1,
              controller: _pageController,
              effect: const WormEffect(
                dotHeight: 6,
                dotWidth: 12,
                type: WormType.thin,
                activeDotColor: kPrimary,
              ),
            )),
        if (_product.status == 'sold')
          Positioned(
            bottom: 20,
            right: 20,
            child: Image.asset(
              'assets/images/sold.png',
              height: 40,
              width: 40,
            ),
          )
      ]),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_product.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              )),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                  "Rs ${NumberFormat("#,##0.00", "en_US").format(_product.price)}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: kPrimary,
                  )),
              const Spacer(),
              Text(_product.type,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ))
            ],
          ),
          const Divider(),
          const SizedBox(
            height: 10,
          ),
          const Text('Description',
              style: TextStyle(
                fontSize: 12,
              )),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(_product.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: kGrey,
                  letterSpacing: 1,
                )),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text('Seller Details',
                    style: TextStyle(
                      fontSize: 12,
                    )),
              ),
              if (_user != null &&
                  !_admin &&
                  _user?['id'] != _product.user['id'])
                _buildReportButton()
            ],
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Column(children: [
              Row(
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircleAvatar(
                      child: Center(
                        child: Text(
                            _product.user['name']?[0].toUpperCase() ?? '-'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(_product.user['name'] ?? '-',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  )),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.pin_drop,
                                color: kPrimary,
                              ),
                              onPressed: () {
                                customLaunch(
                                    "https://www.google.com/maps/search/${_user?['address']}");
                              },
                            )
                          ],
                        ),
                        Text(_product.user['phone'] ?? '-',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: kGrey,
                            )),
                        const SizedBox(height: 6),
                        Text(
                            "${_product.user['address']}, ${_product.user['city'] ?? '-'}\n${_product.user['state'] ?? '-'}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                      getTimeAgo(DateTime.tryParse(_product.createdAt) ??
                          DateTime.now()),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kGrey,
                      )),
                ],
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  customLaunch("tel:+977${_product.user['phone']}");
                },
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Icon(
                    Icons.phone,
                    color: kPrimary.shade700,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Call Now',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kPrimary.shade700,
                    ),
                  ),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 20),
        ]));
  }

  Future<void> customLaunch(command) async {
    if (await canLaunch(command)) {
      await launch(command);
    } else {
      debugPrint(' could not launch $command');
    }
  }

  void _addComment() {
    setState(() {
      _addCommentLoading = true;
    });

    _provider.addComment(_product.id, _commentController.text).then((res) {
      setState(() {
        _addCommentLoading = false;
      });
      if (res.statusCode == 200) {
        _commentController.clear();
        _getComments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(res.statusText.toString(),
              style: const TextStyle(color: Colors.white)),
        ));
      }
    }).catchError((error) {
      setState(() {
        _addCommentLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content:
            Text(error.toString(), style: const TextStyle(color: Colors.white)),
      ));
      debugPrint(error.toString());
    });
  }

  void _showReportSheet() {
    String? _reportReason;
    final _additionalInfoController = TextEditingController();
    bool _reportLoading = false;
    showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: StatefulBuilder(builder: ((ctx, myState) {
              return Container(
                height: MediaQuery.of(ctx).size.height * 0.5,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                child: ListView(
                  children: [
                    const SizedBox(height: 8),
                    const Text('Report this product',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 20),
                    const Text('Reason',
                        style: TextStyle(
                          fontSize: 14,
                          color: kGrey,
                        )),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline: Container(),
                        onChanged: (value) {
                          myState((() {
                            _reportReason = value;
                          }));
                        },
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        value: _reportReason,
                        items: const [
                          DropdownMenuItem(
                            child: Text('Not available'),
                            value: 'Not available',
                          ),
                          DropdownMenuItem(
                            child: Text('Fake'),
                            value: 'Fake',
                          ),
                          DropdownMenuItem(
                            child: Text('Unauthorized'),
                            value: 'Unauthorized',
                          ),
                          DropdownMenuItem(
                            child: Text('Inappropriate'),
                            value: 'Inappropriate',
                          ),
                          DropdownMenuItem(
                            child: Text('Other'),
                            value: 'Other',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Additional Info',
                        style: TextStyle(
                          fontSize: 14,
                          color: kGrey,
                        )),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _additionalInfoController,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      maxLines: 5,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        hintStyle:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                        hintText: 'Additional info',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 0.4),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: kPrimary, width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: kPrimary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          if (_reportReason == null) {
                            return;
                          }
                          myState(() {
                            _reportLoading = true;
                          });

                          _provider
                              .reportProduct(
                            _product.id,
                            _reportReason ?? '',
                            _additionalInfoController.text,
                          )
                              .then((res) {
                            myState(() {
                              _reportLoading = false;
                            });
                            debugPrint(res.bodyString);
                            if (res.statusCode == 200) {
                              Navigator.pop(context);
                              Get.snackbar(
                                'Success',
                                'Your report has been sent',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 2),
                              );
                            } else {}
                          }).catchError((error) {
                            myState(() {
                              _reportLoading = false;
                            });
                            Get.snackbar(
                              'Error',
                              error.toString(),
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 2),
                            );
                            debugPrint(error.toString());
                          });
                        },
                        child: _reportLoading
                            ? const Center(child: CircularProgressIndicator())
                            : const Text(
                                'Report',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ))
                  ],
                ),
              );
            })),
          );
        });
  }

  Widget _buildReports() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _reportsLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Reports (${_reports.length})',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 20),
                _reportsLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _reports.isEmpty
                        ? const Center(child: Text('No reports yet'))
                        : ListView.separated(
                            separatorBuilder: (context, index) =>
                                const Divider(height: 30),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _reports.length,
                            itemBuilder: (context, index) {
                              final report = _reports[index];
                              final _randomColor = Color.fromARGB(
                                  255,
                                  Random.secure().nextInt(255),
                                  Random.secure().nextInt(255),
                                  Random.secure().nextInt(255));

                              return Column(children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: _randomColor,
                                      child: Text(
                                        report['user']['name'].substring(0, 1),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            report['reason'] ?? '',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            report['additionalInfo'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  getTimeAgo(DateTime.parse(
                                                      report['createdAt'])),
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                ),
                                              ),
                                              Text(
                                                "by ${report['user']['name']}",
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ]);
                            },
                          ),
              ],
            ),
    );
  }

  void _deleteComment(Comment comment) {
    showProgressDialog(context);
    _provider.deleteComment(widget.product.id, comment.id).then((res) {
      Get.back();
      if (res.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Comment deleted',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        );
        setState(() {
          _comments.remove(comment);
        });
      } else {
        Get.snackbar(
          'Error',
          res.bodyString.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        );
      }
    }).catchError((error) {
      Get.back();
      Get.snackbar(
        'Error',
        error.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      );
      debugPrint(error.toString());
    });
  }
}
