import 'dart:convert';

import 'package:bytebank/http/webclient.dart';
import 'package:bytebank/models/transaction.dart';
import 'package:http/http.dart';

class TransactionWebClient {
  Future<List<Transaction>> findAll() async {
    final Response response = await client.get(Uri.parse(baseUrl));
    final List<dynamic> decodedJson = jsonDecode(response.body);
    return decodedJson
        .map((dynamic json) => Transaction.fromJson(json))
        .toList();
  }

  Future<Transaction> save(Transaction transaction, String password) async {
    Map<String, dynamic> transactionMap = _toMap(transaction);
    final String transactionJson = jsonEncode(transactionMap);

    await Future.delayed(Duration(seconds: 2));

    final Response response = await client.post(Uri.parse(baseUrl),
        headers: {
          'Content-type': 'application/json',
          'password': password, //1000 PARA SUCESSO
        },
        body: transactionJson);

    if (response.statusCode != 200) {
      _getMessage(response.statusCode);
    }

    return Transaction.fromJson(jsonDecode(response.body));
  }

  String _getMessage(int statusCode) {
    if (_statusCodeResponse.containsKey(statusCode)) {
      return _throwHttpError(statusCode);
    } else {
      return 'Unknown error';
    }
  }

  String _throwHttpError(int statusCode) =>
      throw Exception(_statusCodeResponse[statusCode]);

  static final Map<int, String> _statusCodeResponse = {
    400: 'there was an error submitting transaction',
    401: 'authentication failed',
    409: 'transaction always exists'
  };

  Map<String, dynamic> _toMap(Transaction transaction) {
    final Map<String, dynamic> transactionMap = {
      'value': transaction.value,
      'contact': {
        'name': transaction.contact.name,
        'accountNumber': transaction.contact.accountNumber
      }
    };
    return transactionMap;
  }
}

class HttpException implements Exception {
  final String message;

  HttpException(this.message);
}
