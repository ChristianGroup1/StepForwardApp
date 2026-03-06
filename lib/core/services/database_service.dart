abstract class DatabaseService {
  Future<void> addData({
    required String path,
    String? uId,
    required Map<String, dynamic> data,
  });
  Future<dynamic> getData({
    required String path,
    String? documentId,
    Map<String, dynamic>? query,
    String? filterValueEqualTo,
    String? filterValue,
    List<Map<String, dynamic>>? whereConditions,
  });

  Future<bool> checkIfDataExist({required String path, required String uId});

  Future<void> updateData({
    required String path,
    required String documentId,
    required Map<String, dynamic> data,
  });

  Future<List<Map<String, dynamic>>> searchData(
    String searchText,
    String searchIn,
  );

  Future<void> deleteData({required String path, required String uId});
}
