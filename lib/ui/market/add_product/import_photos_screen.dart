import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:qatar_speed/controllers/market_controller.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/ui/market/add_product/create_product_price_screen.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

import '../../common/shimmer_bocx.dart';

class ImportPhotosScreen extends StatefulWidget {
  const ImportPhotosScreen({Key? key}) : super(key: key);

  @override
  createState() => _ImportPhotosScreenState();
}

class _ImportPhotosScreenState extends State<ImportPhotosScreen>
    with RouteAware, RouteObserverMixin {

  final _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initAppbar();
  }

  _initAppbar() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.scrollController.value = _scrollController;
      Res.titleWidget.value = InkWell(
        onTap: Get.back,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(
            Platform.isIOS ? Icons.arrow_back_ios_new : Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      );
      Res.appBarActions.value = [];
      Res.showAppBar.value = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        controller: _scrollController,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: MaterialButton(
                    onPressed: () {
                      _next();
                    },
                    textColor: Colors.white,
                    minWidth: 80,
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999)),
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50,),
            GetBuilder<MarketController>(
              id: 'photos',
              builder: (controller) {
                return SizedBox(
                  width: Get.width,
                  child: Wrap(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    children: List.generate(
                        controller.product!.photos.length + 1, (index) {
                      if (index >= controller.product!.photos.length) {
                        return _addImage((path) => controller.addProductPhoto(path), controller);
                      }

                      return _imageItem(controller.product!.photos[index], (path) =>
                          controller.removeProductPhoto(path));
                    }),
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }


  Widget _addImage(Function(List<Media>) onTap, MarketController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 10.0),
      child: DottedBorder(
        borderType: BorderType.RRect,
        color: Colors.black54,
        padding: EdgeInsets.zero,
        radius: const Radius.circular(5.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(5.0),
          onTap: () async {
            final paths = await ImagePickers.pickerPaths(
                galleryMode: GalleryMode.image,
                showCamera: true,
                selectCount: 10 - controller.product!.photos.length,
                showGif: false);
            if (paths.isNotEmpty) {
              onTap(paths);
            }
          },
          child: SizedBox(
            width: 160.0,
            height: 190.0,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform.rotate(
                  angle: .3,
                  child: const Icon(
                    Icons.image,
                    color: Colors.black38,
                    size: 50.0,
                  ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Transform.rotate(
                  angle: .34,
                  child: const Text(
                    'Add image',
                    style:
                    TextStyle(fontFamily: 'arial', color: Colors.black54),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageItem(dynamic image, void Function(dynamic path) onTap) {
    final img = image is String ? image : Res.baseUrl + image['file'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0, right: 10.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: CachedNetworkImage(
                imageUrl: img,
                placeholder: (context, _) =>
                const ShimmerBox(
                  width: 160.0,
                  height: 190.0,
                ),
                errorWidget: (_, __, ___) =>
                    Image.file(
                      File(img),
                      fit: BoxFit.cover,
                    ),
                width: 160.0,
                height: 190.0,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: .0,
            top: .0,
            child: InkWell(
              onTap: () => onTap(image is String ? image : image['id']),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(5.0),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 13.0,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _next() {
    if (Get.find<MarketController>().product!.photos.isEmpty) {
      Get.dialog(AlertDialog(
        title: const Text('Error'),
        content: const Text('Select at least one image'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(Res.baseContext), child: const Text('Ok'))
        ],
      ));
      return;
    }

    Get.to(() => const CreateProductPriceScreen());
  }
}
