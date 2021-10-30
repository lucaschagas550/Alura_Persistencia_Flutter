import 'package:bytebank/components/centered_message.dart';
import 'package:bytebank/components/container.dart';
import 'package:bytebank/components/progress.dart';
import 'package:bytebank/database/dao/contact_dao.dart';
import 'package:bytebank/models/contact.dart';
import 'package:bytebank/screens/contact_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'transaction_form.dart';

@immutable
abstract class ContactsListState {
  const ContactsListState();
}

@immutable
class LoadingContactsListState extends ContactsListState {
  const LoadingContactsListState();
}

@immutable
class InitContactsListState extends ContactsListState {
  const InitContactsListState();
}

@immutable
class LoadedContactsListState extends ContactsListState {
  final List<Contact> _contacts;
  const LoadedContactsListState(this._contacts);
}

@immutable
class FatalErrorContactsListState extends ContactsListState {
  const FatalErrorContactsListState();
}

class ContactsListCubit extends Cubit<ContactsListState> {
  ContactsListCubit() : super(InitContactsListState());

  void reload(ContactDao dao) async {
    emit(LoadingContactsListState());
    dao.findAll().then(
          (contacts) => emit(
            LoadedContactsListState(contacts),
          ),
        );
  }
}

class ContactsListContainer extends BlocContainer {
  @override
  Widget build(BuildContext context) {
    final ContactDao dao = ContactDao();
    return BlocProvider<ContactsListCubit>(
      create: (BuildContext context) {
        final cubit = ContactsListCubit();
        cubit.reload(dao);
        return cubit;
      },
      child: ContactsList(dao),
    );
  }
}

class ContactsList extends StatelessWidget {
  final ContactDao _dao;
  ContactsList(this._dao);
  // final ContactDao _dao = ContactDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transfer"),
      ),
      body: BlocBuilder<ContactsListCubit, ContactsListState>(
        builder: (context, state) {
          if (state is InitContactsListState ||
              state is LoadingContactsListState) {
            return Progress();
          }
          if (state is LoadedContactsListState) {
            // if (state._contacts.isEmpty) {
            final List<Contact> contacts = state._contacts;
            if (contacts.isNotEmpty) {
              return ListView.builder(
                itemBuilder: (context, index) {
                  final Contact contact = contacts[index];
                  return _ContactItem(
                    contact,
                    onClick: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TransactionForm(contact),
                        ),
                      );
                    },
                  );
                },
                itemCount: contacts.length,
              );
            }
          }
          // return CenteredMessage('No contacts found', icon: Icons.warning);
          // }
          return Text('Unknown error');
        },
        // body: FutureBuilder<List<Contact>>(
        //   initialData: [],
        //   future: widget._dao.findAll(),
        //  builder: (context, snapshot) {
        // switch (snapshot.connectionState) {
        //   // if (snapshot.data != null) {
        //   case ConnectionState.none:
        //     break;
        //   case ConnectionState.waiting:
        //     return Progress();
        //   case ConnectionState.active:
        //     //Recomendodavel para download 10% completo, 20% completo retorna valor
        //     break;
        //     case ConnectionState.done:
        //       if (snapshot.hasData) {
        //         final List<Contact> contacts = snapshot.data as List<Contact>;
        //         if (contacts.isNotEmpty) {
        //           return ListView.builder(
        //             itemBuilder: (context, index) {
        //               final Contact contact = contacts[index];
        //               return _ContactItem(
        //                 contact,
        //                 onClick: () {
        //                   Navigator.of(context).push(
        //                     MaterialPageRoute(
        //                       builder: (context) => TransactionForm(contact),
        //                     ),
        //                   );
        //                 },
        //               );
        //             },
        //             itemCount: contacts.length,
        //           );
        //         }
        //       }
        //       return CenteredMessage('No contacts found', icon: Icons.warning);
        //   }
        //   return Text('Unknown error');
        // },
      ),
      floatingActionButton: buildAddContactButton(context),
    );
  }

  FloatingActionButton buildAddContactButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ContactForm(),
          ),
        );
        update(context);
      },
      child: Icon(
        Icons.add,
      ),
    );
  }

  void update(BuildContext context) {
    context.read<ContactsListCubit>().reload(_dao);
  }
}

class _ContactItem extends StatelessWidget {
  final Contact contact;
  final Function onClick;

  _ContactItem(this.contact, {required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => onClick(),
        title: Text(
          contact.name,
          style: TextStyle(fontSize: 24.0),
        ),
        subtitle: Text(
          contact.accountNumber.toString(),
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}
