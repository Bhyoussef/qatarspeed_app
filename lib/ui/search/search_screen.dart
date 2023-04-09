import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/ui/search/search_result_screen.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with RouteAware, RouteObserverMixin {
  final _scrollController = ScrollController();
  final _searchTextController = TextEditingController();
  final _focus = FocusNode();
  final RxList<String> _history = <String>[].obs;
  Box<String>? _box;

  @override
  void initState() {
    super.initState();
    _initHive();
    _initAppbar();
  }

  @override
  void dispose() {
    super.dispose();
    //_box.close();
    _initAppbar(shown: true);
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _initAppbar();
    _initHive();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ScrollAppBar(
        controller: _scrollController,
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: _searchWidget(),
      ),
      body: Obx(() => ListView.builder(
        itemCount: _history.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.history),
            title: Text(_history[index]),
            trailing: InkWell(
              onTap: () => _delete(index),
              child: const Icon(Icons.close),
            ),
            onTap: () {
              _searchTextController.text = _history[index];
              _searchTextController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _searchTextController.text.length));
            },
          );
        },
      )),
    );
  }

  _initAppbar({bool shown = false}) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.showAppBar.value = shown;
      Timer(const Duration(milliseconds: 300), () {
        _focus.requestFocus();
      });
    });
  }

  Widget _searchWidget() {
    return Hero(
      tag: 'search_bar',
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
              color: Colors.grey.withOpacity(.3),
              borderRadius: BorderRadius.circular(5.0)),
          child: TextField(
            focusNode: _focus,
            controller: _searchTextController,
            onChanged: (txt) {
              setState(() {
                _history
                  ..clear()
                  ..addAll(_box!.values
                      .where((element) => element.contains(txt))
                      .take(20));
              });
            },
            maxLines: 1,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(fontSize: Res.isPhone ? 13.0 : 17.0),
            textInputAction: TextInputAction.search,
            onSubmitted: (txt) {
              if (txt.removeAllWhitespace.isNotEmpty) {
                _submit();
              }
            },
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search here',
              hintStyle: TextStyle(fontSize: Res.isPhone ? 13.0 : 17.0),
              suffixIcon:
                  InkWell(onTap: _submit, child: const Icon(Icons.search)),
              border: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _initHive() async {
    _box ??= await Hive.openBox<String>('search_history');
    setState(() {
      _history
        ..clear()
        ..addAll(_box!.values.take(20));
    });
  }

  void _submit() {
    if (_searchTextController.text.isNotEmpty) {
      FocusScope.of(context).unfocus();
      Get.to(() => SearchResultScreen(keyword: _searchTextController.text));
      if (!(_box?.values.contains(_searchTextController.text) ?? false)) {
        _box?.add(_searchTextController.text);
      }
    }
  }

  _delete(int index) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text('delete'),
      content: Text('Do you want to delete "${_history[index]}" from history?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
              _history.removeAt(index);
              unawaited(_box?.deleteAt(index));
            },
            child: const Text('Yes')),
      ],
    ));
  }
}
