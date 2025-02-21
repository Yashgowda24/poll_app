import 'package:poll_chat/data/network/network_api_services.dart';
import 'package:poll_chat/res/app_url/app_url.dart';

class LoginRepository {
  final _apiService = NetworkApiServices();

  Future<dynamic> loginApi(var data) async {
    dynamic response = _apiService.getLoginApi(
        AppUrl.loginUrl, data['phone'], data["password"]);
    return response;
  }

  Future<dynamic> postloginApi(var data) async {
    dynamic response = _apiService.postLoginApi(
        AppUrl.loginUrl, data['phone'], data["password"]);
    return response;
  }

  Future<dynamic> loginGetApi(String phone, String password) async {
    dynamic response =
        _apiService.getLoginApi(AppUrl.loginUrl, phone, password);
    return response;
  }

  Future<dynamic> signupApi(var data) async {
    dynamic response = _apiService.postApi(data, AppUrl.signupUrl);
    return response;
  }

  Future<dynamic> signupApi1(var data) async {
    dynamic response = _apiService.postApi1(data, AppUrl.signupUrl);
    return response;
  }

  Future<dynamic> activateUserApi(var data, String id) async {
    dynamic response = _apiService.postApi(data, AppUrl.verifyotpId());
    return response;
  }

  Future<dynamic> createProfileApi(var data, String id) async {
    dynamic response =
        _apiService.postApi(data, AppUrl.createProfileId(id: id));
    return response;
  }
}
