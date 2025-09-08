import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

  part 'api_userRegister.g.dart';

  @RestApi(baseUrl:"https://firestore.googleapis.com/v1/projects/event-9da2e/databases/(default)/documents/")
  abstract class ApiClient {
    factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

    @POST("userregister")
    Future<HttpResponse<dynamic>> registerUser(@Body() Map<String, dynamic> body);

    @GET("userregister")
    Future<HttpResponse<dynamic>> VerifyUser();


  }
