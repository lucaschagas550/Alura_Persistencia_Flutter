import 'dart:async';
import 'package:bytebank/components/progress.dart';
import 'package:bytebank/components/response_dialog.dart';
import 'package:bytebank/components/transaction_auth_dialog.dart';
import 'package:bytebank/http/webclients/transaction_webclient.dart';
import 'package:bytebank/models/contact.dart';
import 'package:bytebank/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class TransactionForm extends StatefulWidget {
  final Contact contact;

  TransactionForm(this.contact);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final TextEditingController _valueController = TextEditingController();
  final TransactionWebClient _webClient = TransactionWebClient();
  final String transactionId = Uuid().v4();

  bool _sending = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  //chave para o estado do scaffold, é possivel ver por toda a aplicação

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('New transaction'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Visibility(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Progress(
                    message: 'Sending...',
                  ),
                ),
                visible: _sending,
              ),
              Text(
                widget.contact.name,
                style: TextStyle(
                  fontSize: 24.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  widget.contact.accountNumber.toString(),
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextField(
                  controller: _valueController,
                  style: TextStyle(fontSize: 24.0),
                  decoration: InputDecoration(labelText: 'Value'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton(
                    child: Text('Transfer'),
                    onPressed: () {
                      if (_valueController.text.isNotEmpty) {
                        final double? value =
                            double.tryParse(_valueController.text);
                        final transactionCreated =
                            Transaction(transactionId, value!, widget.contact);
                        showDialog(
                            context: context,
                            builder: (contextDialog) {
                              return TransactionAuthDialog(
                                onConfirm: (String password) {
                                  _save(transactionCreated, password, context);
                                },
                              );
                            });
                      } else {
                        showDialog(
                            context: context,
                            builder: (contextDialog) {
                              return FailureDialog('Field value this empty');
                            });
                      }
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _save(Transaction transactionCreated, String password,
      BuildContext context) async {
    setState(() {
      _sending = true;
    });
    Transaction transaction =
        await _send(transactionCreated, password, context);
    //erros especificos e mensagens espeficicas

    _showSucessFullMessage(transaction, context);
  }

  Future<void> _showSucessFullMessage(
      Transaction transaction, BuildContext context) async {
      await showDialog(
          context: context,
          builder: (contextDialog) {
            return SuccessDialog('sucessful transaction');
          });
      Navigator.pop(context);
  }

  Future<Transaction> _send(Transaction transactionCreated, String password,
      BuildContext context) async {
    final Transaction transaction =
        await _webClient.save(transactionCreated, password).catchError((e) {
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.setCustomKey('exception', e.toString());
        FirebaseCrashlytics.instance
            .setCustomKey('http_body', transactionCreated.toString());
        FirebaseCrashlytics.instance.recordError(e.message, null);
        _showFailureMessage(context,
            message: 'timeout submitting the transaction');
      }
    }, test: (e) => e is TimeoutException).catchError((e) {
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.setCustomKey('exception', e.toString());
        FirebaseCrashlytics.instance
            .setCustomKey('http_body', transactionCreated.toString());
        FirebaseCrashlytics.instance.recordError(e.message, null);
      }

      _showFailureMessage(context, message: e.message);
    }, test: (e) => e is HttpException).catchError((e) {
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.setCustomKey('exception', e.toString());
        FirebaseCrashlytics.instance.setCustomKey('http_code', e.statusCode);
        FirebaseCrashlytics.instance
            .setCustomKey('http_body', transactionCreated.toString());
        FirebaseCrashlytics.instance.recordError(e.message, null);
      }
      _showFailureMessage(context);
    }).whenComplete(() {
      // whenCOmplete eh igual o finaly no final eh executado
      setState(() {
        _sending = false;
      });
    });
    //erros especificos e mensagens espeficicas
    return transaction;
  }

  void _showFailureMessage(BuildContext context,
      {String message = 'Unkown error'}) {
    //parametro opcional
    // showDialog(
    //     context: context,
    //     builder: (contextDialog) {
    //       return FailureDialog('Unknown error');
    //     });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));

    // showToast(message, gravity: Toast.BOTTOM);

    // showDialog(
    //     context: context,
    //     builder: (_) => NetworkGiffyDialog(
    //           image: Image.asset(''),
    //           title: Text('OPS',
    //               textAlign: TextAlign.center,
    //               style:
    //                   TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
    //           description: Text(
    //             'message',
    //             textAlign: TextAlign.center,
    //           ),
    //           entryAnimation: EntryAnimation.TOP,
    //           onOkButtonPressed: () {},
    //         ));
  }

  // void showToast(String msg, {int duration = 5, required int gravity}) {
  //   Toast.show(msg, context, duration: duration, gravity: gravity);
  // }
}
