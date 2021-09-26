import 'contact.dart';

class Transaction {
  final double value;
  final Contact contact;

  Transaction(
    this.value,
    this.contact,
  );

  Transaction.fromJson(Map<String, dynamic> json)
      : value = json['value'] as double,
        contact = Contact.fromJson(json['contact'] as Map<String, dynamic>);

  @override
  String toString() {
    return 'Transaction{value: $value, contact: $contact}';
  }
}
