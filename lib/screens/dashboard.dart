import 'package:bytebank/screens/contacts_list.dart';
import 'package:bytebank/screens/name.dart';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'transactions_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardContainer extends StatelessWidget {
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NameCubit("Guilherme"),
      child: DashBoardView(),
    );
  }
}

class DashBoardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //misturando um blocbuilder (que é um observe de eventos) com UI
        title: BlocBuilder<NameCubit, String>(
          builder: (context, state) => Text("Welcome $state"),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset("images/bytebank_logo.png"),
          ),
          // SingleChildScrollView(
          //   scrollDirection: Axis.horizontal,
          SingleChildScrollView(
            // resolve problema da tela estourar proporção
            child: Container(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                //permite colocar componentes um ao lado do outro
                children: <Widget>[
                  _FeatureItem(
                    'Transfer',
                    Icons.monetization_on,
                    onClick: () {
                      _showContactsList(context);
                    },
                  ),
                  _FeatureItem(
                    'Transaction Feed',
                    Icons.description,
                    onClick: () {
                      _showTransactionsList(context);
                    },
                  ),
                  _FeatureItem(
                    'Change Name',
                    Icons.person_outline,
                    onClick: () {
                      _showChangeName(context);
                      print("Scroll horizontal em linha");
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final Function onClick; //Callback

//required exige que onClick seja implementado no click
  _FeatureItem(this.name, this.icon, {required this.onClick}); //{} Opcional

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Theme.of(context).primaryColor,
        child: InkWell(
          //sensação de clique no botão
          //tem evento para chamar outra tela, container nao tem
          onTap: () => onClick(),
          child: Container(
            padding: EdgeInsets.all(8.0), // padding tudo no container
            width: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24.0,
                ),
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//Funcao que chama a tela de contatos
void _showContactsList(BuildContext context) {
  // FirebaseCrashlytics.instance
  //     .crash(); //crash o app para relatorio no crashlytics

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ContactsList(),
    ),
  );
}

void _showTransactionsList(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => TransactionsList(),
    ),
  );
}

void _showChangeName(BuildContext blocContext) {
  Navigator.of(blocContext).push(
    MaterialPageRoute(
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<NameCubit>(blocContext),
        child: NameContainer(),
      ),
    ),
  );
}
