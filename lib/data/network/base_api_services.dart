abstract class BaseApiServices {

  Future<dynamic> getApi(String url);

  Future<dynamic> getLoginApi(String url, String phone, String password);

  Future<dynamic> postApi(dynamic data, String url);

  Future<dynamic> postApi1(dynamic data, String url);

  Future<dynamic> putApi(dynamic data, String url);

  Future<dynamic> deleteApi(String url);

}