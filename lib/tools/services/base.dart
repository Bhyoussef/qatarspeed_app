import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:qatar_speed/tools/res.dart';

class BaseWebService {
  late Dio dio;
  static AlertDialog? dialog;

  BaseWebService() {
    dio = Dio(BaseOptions(baseUrl: Res.apiUrl, headers: {
      'Authorization': 'Bearer ${Res.token}',
      'Accept': 'Application/json'
    }));
    dio.interceptors.add(InterceptorsWrapper(onError: (err, handler) {
      if (err.response?.statusCode == 401 &&
          err.requestOptions.path != 'logout' &&
          dialog == null) {
        dio.close(force: true);
        _showErrorDialog(
            text: 'Your session has been expired.\nPlease authenticate.',
            whenComplete: () {
              Res.logout();
            });
        return;
      } else if (dialog == null && err.response?.statusCode == 422) {
        dio.close(force: true);
        String message = '';
        Map.of(err.response!.data)['errors'].forEach((key, value) {
          message += '$key: ';
          for (var element in List.of(value)) {
            message += '$element, ';
          }
          message += '\n';
        });
        _showErrorDialog(text: message);
        throw err;
      } else if (dialog == null) {
        dio.close(force: true);
        _showErrorDialog();
        throw err;
      }
    }));
  }

  _showErrorDialog({String? text, VoidCallback? whenComplete}) {
    dialog = AlertDialog(
      title: const Text('Error'),
      content: Text(text ?? 'Something went wrong.\nPlease try again later.'),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(Res.baseContext);
            },
            child: const Text('Ok'))
      ],
    );
    showDialog(
      context: Res.baseContext,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () async => false,
        child: dialog!,
      ),
    ).whenComplete(() {
      if (whenComplete != null) {
        whenComplete();
      }
      dialog = null;
    });
  }
}
