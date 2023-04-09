import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/market_controller.dart';
import 'package:qatar_speed/models/market.dart';
import 'package:qatar_speed/models/product.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/ui/market/add_product/import_photos_screen.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

class CreateProductDetailsScreen extends StatefulWidget {
  const CreateProductDetailsScreen({Key? key, required this.markets})
      : super(key: key);
  final List<MarketModel> markets;

  @override
  createState() =>
      _CreateProductDetailsScreenState();
}

class _CreateProductDetailsScreenState extends State<CreateProductDetailsScreen>
    with RouteAware, RouteObserverMixin {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initAppbar();
    Get.find<MarketController>().product = ProductModel(photos: []);
  }

  @override
  void didPopNext() {
    super.didPopNext();
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
      body: GetBuilder<MarketController>(builder: (controller) {
        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
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
                _dropDown<MarketModel>('Type', (value) {
                  controller.product!.categoryId = value?.id;
                },
                    validator: (txt) => txt == null ? 'Required' : null,
                    widget.markets),

                _textBox(
                  'Maker',
                  validator: (txt) =>
                  (txt?.isEmpty ?? false) ? 'Required' : null,
                  onSaved: (txt) => controller.product!.manifacturer = txt,
                ),

                _textBox(
                  'Model',
                  validator: (txt) =>
                  (txt?.isEmpty ?? false) ? 'Required' : null,
                  onSaved: (txt) => controller.product!.model = txt,
                ),

                _textBox(
                  'Ad title',
                  validator: (txt) =>
                  (txt?.isEmpty ?? false) ? 'Required' : null,
                  onSaved: (txt) => controller.product!.title = txt,
                ),
                _textBox('Additional informations',
                    textArea: true,
                    inputAction: TextInputAction.done,
                    validator: (txt) =>
                    (txt?.isEmpty ?? false) ? 'Required' : null,
                    onSaved: (txt) => controller.product!.description = txt),
                // _textBox(
                //   'Brand',
                //   validator: (txt) =>
                //       (txt?.isEmpty ?? false) ? 'Required' : null,
                //   onSaved: (txt) => controller.product!.manifacturer = txt,
                // ),
                // _textBox(
                //   'Model',
                //   validator: (txt) =>
                //       (txt?.isEmpty ?? false) ? 'Required' : null,
                //   onSaved: (txt) => controller.product!.model = txt,
                // ),
                // _dropDown('Year', (value) {},
                //     List.generate(70, (index) => DateTime.now().year - index)),
                /*_list('Fuel', ['Petrol', 'Diesel', 'Electric', 'CNG & Hybrid'],
                    (value) {}),*/
                //_list('Transmission', ['Automatic', 'Manual'], (value) {}),
                // _textBox('Km Driven',
                //     inputType: TextInputType.number,
                //     validator: (txt) =>
                //         (txt?.isEmpty ?? false) ? 'Required' : null,
                //     onSaved: (txt) {
                //       controller.product!.mileage = txt;
                //     }),

                _textBox('Phone',
                    inputType: TextInputType.phone,
                    validator: (txt) =>
                        (txt?.isEmpty ?? false) ? 'Required' : null,
                    onSaved: (txt) => controller.product!.phone = txt),

                _textBox('Email',
                    inputType: TextInputType.emailAddress,
                    validator: (txt) =>
                        (txt?.isEmpty ?? false) || !GetUtils.isEmail(txt!)
                            ? 'Required'
                            : null,
                    onSaved: (txt) => controller.product!.email = txt),
                /*_list(
                    'No Of Owner',
                    List.generate(10, (index) {
                      final msg = index == 0
                          ? 'st'
                          : index == 1
                              ? 'nd'
                              : index == 2
                                  ? 'rd'
                                  : 'th';
                      return '${index + 1}$msg';
                    }).toList(),
                    (value) {}),*/



              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _textBox(String hint,
      {TextInputType inputType = TextInputType.text,
      FormFieldValidator<String>? validator,
        ValueChanged<String>? onSubmit,
        TextInputAction inputAction = TextInputAction.next,
      FormFieldSetter<String>? onSaved,
      bool textArea = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            '$hint*',
            style: const TextStyle(fontFamily: 'arial', fontWeight: FontWeight.w900),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: const Color(0xffDCDCDC),
              borderRadius: BorderRadius.circular(5.0)),
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          margin: const EdgeInsets.only(bottom: 40.0, top: 10.0),
          child: TextFormField(
            minLines: textArea ? 3 : null,
            maxLines: textArea ? 3 : null,
            keyboardType: inputType,
            validator: validator,
            textInputAction: inputAction,
            onSaved: onSaved,
            onFieldSubmitted: onSubmit,
            decoration: InputDecoration(
              hintText: hint,
              disabledBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }

  Widget _dropDown<T>(
      String hint, ValueChanged<T?> onChanged, List<dynamic> values,
      {FormFieldValidator? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            '$hint*',
            style: const TextStyle(fontFamily: 'arial', fontWeight: FontWeight.w900),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: const Color(0xffDCDCDC),
              borderRadius: BorderRadius.circular(5.0)),
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          margin: const EdgeInsets.only(bottom: 40.0, top: 10.0),
          child: DropdownButtonFormField<T>(
            onChanged: onChanged,
            items: values
                .map((e) => DropdownMenuItem(
                      value: e as T,
                      child: Text(
                          '${e is String ? e : e is MarketModel ? e.name : e.toString()}'),
                    ))
                .toList(),
            hint: Text(hint),
            validator: validator,
            isExpanded: true,
            decoration: const InputDecoration(
              disabledBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }

 /* Widget _list(String hint, List<String> values, Function(String) onTap,
      {bool selected = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            '$hint*',
            style: const TextStyle(fontFamily: 'arial', fontWeight: FontWeight.w900),
          ),
        ),
        SizedBox(
          height: 90.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 40.0, top: 10.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: values.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: InkWell(
                    onTap: () => onTap(values[index]),
                    child: Container(
                      decoration: BoxDecoration(
                          color: selected ? Colors.black : const Color(0xffDCDCDC),
                          borderRadius: BorderRadius.circular(5.0)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Center(
                          child: Text(
                        values[index],
                        style: TextStyle(
                            color: selected ? Colors.white : Colors.black),
                      )),
                    ),
                  ),
                );
              },
            ),
          ),
        )
      ],
    );
  }*/

  void _next() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Get.to(() => const ImportPhotosScreen());
    }
  }
}
