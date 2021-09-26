import 'dart:convert';

import 'package:bytebank/models/contact.dart';
import 'package:bytebank/models/transaction.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';

class LoggingInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    print('Request');
    print('url ${data.url}');
    print('headers ${data.headers}');
    print('body ${data.body}');
    print(data.toString());
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    print('Response');
    print('status code: ${data.statusCode}');
    print('headers ${data.headers}');
    print('body ${data.body}');
    print(data.toString());
    return data;
  }
}

Future<List<Transaction>> findAll() async {
  final Client client = InterceptedClient.build(
    interceptors: [LoggingInterceptor()],
  );
  String url = 'http://192.168.0.6:8080/transactions';
  final Response response =
      await client.get(Uri.parse(url)).timeout(Duration(seconds: 5));
  final List<dynamic> decodeJson = jsonDecode(response.body);
  final List<Transaction> transactions = [];
  for (Map<String, dynamic> transactionJson in decodeJson) {
    final Map<String, dynamic> contactJson = transactionJson['contact'];
    final Transaction transaction = Transaction(
      transactionJson['value'],
      Contact(
        0,
        contactJson['name'],
        contactJson['accountNumber'],
      ),
    );
    transactions.add(transaction);
  }
  return transactions;
}
