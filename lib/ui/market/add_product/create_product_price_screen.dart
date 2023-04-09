import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/market_controller.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

import '../../../tools/res.dart';

class CreateProductPriceScreen extends StatefulWidget {
  const CreateProductPriceScreen({Key? key}) : super(key: key);

  @override
  createState() =>
      _CreateProductPriceScreenState();
}

class _CreateProductPriceScreenState extends State<CreateProductPriceScreen> with RouteAware, RouteObserverMixin{

  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Column(
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
                Form(
                  key: _formKey,
                  child: _textBox('Price', numeric: true, validator: (txt) => (txt?.isEmpty ?? true) ? 'Required' : null, onSaved: (txt) {
                    Get.find<MarketController>().product!.price = double.parse(txt!);
                  }, ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  Widget _textBox(String hint,
      {bool numeric = false,
        FormFieldValidator<String>? validator,
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
            onSaved: onSaved,
            keyboardType: numeric ? TextInputType.number : TextInputType.text,
            validator: validator,
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

  void _next() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Get.find<MarketController>().saveProduct();
    }
  }
}
