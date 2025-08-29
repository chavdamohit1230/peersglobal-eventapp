import 'package:dio/dio.dart';
import 'package:peersglobleeventapp/modelClass/model/auth_User_model.dart';

class AuthRepository {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "https://firestore.googleapis.com/v1/projects/event-9da2e/databases/(default)/documents/",
    ),
  );

  Future<List<AuthUserModel>> fetchUsers() async {
    final response = await dio.get("userregister");

    final data = response.data;
    final documents = data['documents'] as List<dynamic>? ?? [];

    return documents.map((doc) {
      final fields = doc['fields'] as Map<String, dynamic>? ?? {};

      return AuthUserModel(
        id: doc['name'] ?? '',
        name: fields['name']?['stringValue'] ?? '',
        mobile: fields['mobile']?['stringValue'] ?? '',
        role: fields['role']?['stringValue'] ?? '',
      );
    }).toList();
  }
}
