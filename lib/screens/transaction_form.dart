import 'dart:async';
import 'package:bytebank/components/container.dart';
import 'package:bytebank/components/error.dart';
import 'package:bytebank/components/progress.dart';
import 'package:bytebank/components/response_dialog.dart';
import 'package:bytebank/components/transaction_auth_dialog.dart';
import 'package:bytebank/http/webclients/transaction_webclient.dart';
import 'package:bytebank/models/contact.dart';
import 'package:bytebank/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@immutable
abstract class TransactionFormState {
  const TransactionFormState();
}

@immutable
class SendingState extends TransactionFormState {
  const SendingState();
}

@immutable
class ShowFormState extends TransactionFormState {
  const ShowFormState();
}

@immutable
class SentState extends TransactionFormState {
  const SentState();
}

@immutable
class FatalErrorFormState extends TransactionFormState {
  final String _message;
  const FatalErrorFormState(this._message);
}

class TransactionFormCubit extends Cubit<TransactionFormState> {
  TransactionFormCubit() : super(ShowFormState());

  void save(Transaction transactionCreated, String password,
      BuildContext context) async {
    emit(SendingState());
    await _send(transactionCreated, password, context);
  }

  _send(Transaction transactionCreated, String password,
      BuildContext context) async {
    await TransactionWebClient()
        .save(transactionCreated, password)
        .then((transaction) => emit(SentState()))
        .catchError((e) {
      emit(FatalErrorFormState(e.message));
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.setCustomKey('exception', e.toString());
        FirebaseCrashlytics.instance
            .setCustomKey('http_body', transactionCreated.toString());
        FirebaseCrashlytics.instance.recordError(e.message, null);
        emit(FatalErrorFormState(e.message));
      }
    }, test: (e) => e is TimeoutException).catchError((e) {
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.setCustomKey('exception', e.toString());
        FirebaseCrashlytics.instance
            .setCustomKey('http_body', transactionCreated.toString());
        FirebaseCrashlytics.instance.recordError(e.message, null);
      }

      emit(FatalErrorFormState(e.message));
    }, test: (e) => e is HttpException).catchError((e) {
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.setCustomKey('exception', e.toString());
        FirebaseCrashlytics.instance.setCustomKey('http_code', e.statusCode);
        FirebaseCrashlytics.instance
            .setCustomKey('http_body', transactionCreated.toString());
        FirebaseCrashlytics.instance.recordError(e.message, null);
      }
      emit(FatalErrorFormState(e.message));
    });
    //.whenComplete(() {
    //   // whenCOmplete eh igual o finaly no final eh executado
    //   // setState(() {
    //   //   _sending = false;
    //   // });
    // });
    //erros especificos e mensagens espeficicas
    // return transaction;
  }
}

class TransactionFormContainer extends BlocContainer {
  //recebendo variavel pelo construtor
  final Contact _contact;
  TransactionFormContainer(this._contact);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionFormCubit>(
      create: (BuildContext context) {
        return TransactionFormCubit();
      },
      child: BlocListener<TransactionFormCubit, TransactionFormState>(
        listener: (context, state) {
          if (state is SentState) {
            Navigator.pop(context);
          }
        },
        child: TransactionFormStateless(_contact),
      ),
    );
  }
}

class TransactionFormStateless extends StatelessWidget {
  final Contact _contact;
  TransactionFormStateless(this._contact);
  //chave para o estado do scaffold, é possivel ver por toda a aplicação

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionFormCubit, TransactionFormState>(
        builder: (context, state) {
      if (state is ShowFormState) {
        return _BasicForm(_contact);
      } else if (state is SendingState || state is SentState) {
        return ProgressView();
      } else if (state is FatalErrorFormState) {
        return ErrorView(state._message);
      }
      return ErrorView("Unknown error");
    });
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

class _BasicForm extends StatelessWidget {
  final Contact _contact;
  final TextEditingController _valueController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final String transactionId = Uuid().v4();
  _BasicForm(this._contact);

  @override
  Widget build(BuildContext context) => Scaffold(
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
                Text(
                  _contact.name,
                  style: TextStyle(
                    fontSize: 24.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _contact.accountNumber.toString(),
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
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
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
                              Transaction(transactionId, value!, _contact);
                          showDialog(
                              context: context,
                              builder: (contextDialog) {
                                return TransactionAuthDialog(
                                  onConfirm: (String password) {
                                    BlocProvider.of<TransactionFormCubit>(
                                            context)
                                        .save(transactionCreated, password,
                                            context);
                                    // _save(transactionCreated, password, context);
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

class ProgressView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Processing'),
      ),
      body: Progress(
        message: 'Sending...',
      ),
    );
  }
}
