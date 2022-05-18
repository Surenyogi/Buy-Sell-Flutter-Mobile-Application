import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onlinedeck/models/product.dart';
import 'package:onlinedeck/utils/app_utils.dart';
import 'package:onlinedeck/views/product/product_detail.dart';

Widget productCard(Product product) {
  return GestureDetector(
    onTap: () {
      Get.to(() => ProductDetail(product: product));
    },
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(children: [
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child:
                    product.images != null && product.images?.isNotEmpty == true
                        ? Image.network(
                            product.images?[0].url ?? '',
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) {
                              return progress == null
                                  ? child
                                  : const Center(
                                      child: CircularProgressIndicator(),
                                    );
                            },
                          )
                        : Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
              ),
              if (product.featured == true)
                const Positioned(
                  child: Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 16,
                  ),
                  top: 2,
                  right: 2,
                ),
            ]),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs ${formatCurrency(product.price.toString())}',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
