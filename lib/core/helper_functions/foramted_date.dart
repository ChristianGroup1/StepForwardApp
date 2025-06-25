import 'package:cloud_firestore/cloud_firestore.dart';

String formatOrderDateFromTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  String day = dateTime.day.toString().padLeft(2, '0');
  String month = dateTime.month.toString().padLeft(2, '0');
  String year = dateTime.year.toString();

  return '$day/$month/$year';
}