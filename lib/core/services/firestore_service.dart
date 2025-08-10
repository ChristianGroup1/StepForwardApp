import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stepforward/core/errors/custom_exceptions.dart';
import 'package:stepforward/core/services/database_service.dart';

class FireStoreService implements DatabaseService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Future<void> addData({
    required String path,
    String? uId,
    required Map<String, dynamic> data,
  }) async {
    if (uId != null) {
      await firestore.collection(path).doc(uId).set(data);
    } else {
      await firestore.collection(path).add(data);
    }
  }

  @override
  Future<dynamic> getData({
    required String path,
    String? documentId,
    Map<String, dynamic>? query,
    String? filterValueEqualTo,
    String? filterValue,
    List<Map<String, dynamic>>?
    whereConditions, // Add this optional parameter for user-specific queries
  }) async {
    try {
      // If documentId is provided, fetch the document by its ID
      if (documentId != null) {
        var data = await firestore.collection(path).doc(documentId).get();
        return data.data();
      } else {
        // Query the collection
        Query<Map<String, dynamic>> data = firestore.collection(path);

        if (whereConditions != null) {
          for (var condition in whereConditions) {
            data = data.where(
              condition['field'],
              isEqualTo: condition['isEqualTo'],
              isLessThan: condition['isLessThan'],
              isGreaterThan: condition['isGreaterThan'],
              isLessThanOrEqualTo: condition['isLessThanOrEqualTo'],
              isGreaterThanOrEqualTo: condition['isGreaterThanOrEqualTo'],
            );
          }
        }

        // If userId is provided, filter the query by userId (only for orders)
        if (filterValueEqualTo != null && filterValue != null) {
          data = data.where(filterValue, isEqualTo: filterValueEqualTo);
        }

        // Apply additional query filters if provided
        if (query != null) {
          if (query['orderBy'] != null) {
            var orderByField = query['orderBy'];
            var descending = query['descending'] ?? false;
            data = data.orderBy(orderByField, descending: descending);
          }
          if (query['limit'] != null) {
            var limit = query['limit'];
            data = data.limit(limit);
          }
          if (query['where'] != null && query['isEqualTo'] != null) {
            data = data.where(query['where'], isEqualTo: query['isEqualTo']);
          }
        }

        // Fetch the data from Firestore
        var result = await data.get();

        // Return the fetched data
        return result.docs.map((e) => e.data()).toList();
      }
    } catch (e) {
      throw CustomException(message: 'Failed to fetch data: ${e.toString()}');
    }
  }


  @override
  Future<bool> checkIfDataExist({
    required String path,
    required String uId,
  }) async {
    var data = await firestore.collection(path).doc(uId).get();
    return data.exists;
  }

  @override
  Future<void> updateData({
    required String path,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await firestore.collection(path).doc(documentId).update(data);
  }

  

@override
Future<List<Map<String, dynamic>>> searchData(
  String searchText,
  String searchIn,
) async {
  try {
    final List<String> prefixes = [
      "الراعي ",
      "القسيس ",
      "الأخ",
      "الاخ",
      "القس ",
      "الشيخ ",
      "فريق ",
      "فريق تمثيل ",
      "فريق رياضي ",
      "لعبة ",
      "لعبه",
    ];

    final snapshot = await firestore
        .collection(searchIn)
        .orderBy('name')
        .get();

    final List<Map<String, dynamic>> filteredResults = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      String name = data['name'];

     
      for (String prefix in prefixes) {
        if (name.startsWith(prefix)) {
          name = name.substring(prefix.length);
          break; 
        }
      }

      name = name.trim().toLowerCase();
      final normalizedSearch = searchText.trim().toLowerCase();

      if (name.startsWith(normalizedSearch)) {
        filteredResults.add(data);
      }
    }

    return filteredResults;
  } catch (e) {
    throw Exception('Failed to search: ${e.toString()}');
  }
}


  
 

  @override
  Future<void> deleteData({required String path, required String uId}) async {
    try {
      // Construct the document reference
      final documentReference = firestore.collection(path).doc(uId);

      // Delete the document
      await documentReference.delete();
    } catch (e) {
      throw CustomException(
        message: 'Failed to delete data. Please try again.',
      );
    }
  }


}
