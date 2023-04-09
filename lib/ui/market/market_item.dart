import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:qatar_speed/models/product.dart';
import 'package:qatar_speed/ui/common/shimmer_bocx.dart';

class MarketItem extends StatelessWidget {
  const MarketItem({Key? key, required this.product, required this.index, required this.onTap}) : super(key: key);

  final ProductModel product;
  final int index;
  final Function(ProductModel) onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap(product);
      },
      child: Container(
        alignment: Alignment.bottomLeft,
        width: 181.0,
        height: 147.0,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1.0,
            color: const Color(0xFF707070),
          ),
        ),
        child: Stack(
          children: [
              product.photos.isEmpty
          ? Container(
                color: Colors.grey.withOpacity(.5),
                height: double.infinity,
                width: double.infinity,
                child: const Center(
                  child: Icon(Icons.broken_image, size: 50.0,),
                ),
              )
          : CachedNetworkImage(
                imageUrl: product.photos.first,
                fit: BoxFit.cover,
                placeholder: (context, _) => const ShimmerBox(
                  height: double.infinity,
                  width: double.infinity,
                ),
                errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                height: double.infinity,
                width: double.infinity,
              ),
            Positioned(
              bottom: .0,
              left: .0,
              right: .0,
              child: Container(
                //width: double.infinity,
                //height: 39.0,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.67),
                  border: Border.all(
                    width: 1.0,
                    color: const Color(0xFF707070).withOpacity(0.67),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.title??'',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'arial',
                        fontSize: 13.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3.0,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'QR ${product.price??.0}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'arial',
                          fontSize: 11.0,
                          color: Colors.white,
                        ),
                      ),
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
}
