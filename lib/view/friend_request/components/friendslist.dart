import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/simmer/simmerlist.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({Key? key}) : super(key: key);

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  List<dynamic> _accounts = [];
  String? globalId;
  UserPreference userPreference = UserPreference();
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  Future<void> _fetchAccounts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var token = await userPreference.getAuthToken();
      var headers = {'Authorization': 'Bearer $token'};
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://pollchat.myappsdevelopment.co.in/api/v1/friend/received/'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> jsonData = jsonDecode(responseBody);

        if (jsonData['status'] == true) {
          dynamic friendRequest = jsonData['requests'];
          if (friendRequest is List) {
            setState(() {
              _accounts.clear();
              for (var request in friendRequest) {
                if (request != null) {
                  var account = request['friend2'];
                  if (account != null) {
                    account['frnd_id'] = request['_id'];
                    _accounts.add(account);
                  }
                }
              }
            });
          } else {
            print("Unexpected format for friend requests.");
          }
        } else {
          print("Failed to fetch friend requests: ${jsonData['message']}");
        }
      } else {
        print("Failed to fetch friend requests: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("An error occurred while fetching accounts: $e");
    } finally {
      setState(() {
        _isLoading = false; // Set loading state to false after data is fetched
      });
    }
  }

  String formatDateTime(String dateString) {
    DateTime dateTime = DateTime.parse(dateString).toLocal();
    String formattedDateTime = DateFormat('dd/MM/yy hh:mm a').format(dateTime);
    return formattedDateTime;
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: ShimmerListView(
            itemCount: 10), // Show skeleton loader while loading
      );
    } else if (_accounts.isEmpty) {
      return Center(
        child: Text('No friend requests found'), // Show message when no data
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          children: _accounts.map((account) {
            if (account != null) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircleAvatar(
                        radius: 30,
                        child: account['profilePhoto'] != null
                            ? Image.network(
                                account['profilePhoto'],
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/logo.png',
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/images/logo.png',
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 140,
                          child: Text(
                            account['name'] ?? 'No Name',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: Text(account['username'] ?? 'No Username'),
                        ),
                        Text(
                          formatDateTime(account['createdAt'] ?? ''),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        confirmrequest(account['frnd_id']);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: AppColor.purpleColor,
                        ),
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Confirm',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () async {
                        await cencalfriendreq(account['frnd_id']);
                      },
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
              );
            } else {
              return SizedBox.shrink(); // Skip if account is null
            }
          }).toList(),
        ),
      );
    }
  }

  Future<void> confirmrequest(String id) async {
    var token = await userPreference.getAuthToken();
    var headers = {'Authorization': 'Bearer $token'};
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://pollchat.myappsdevelopment.co.in/api/v1/friend/confirm/$id'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      Get.snackbar('Success', 'Request completed successfully');

      _fetchAccounts();
      print(await response.stream.bytesToString());
      print(response);
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> cencalfriendreq(String id) async {
    var token = await userPreference.getAuthToken();
    print('Token: $token'); // Check token
    var headers = {'Authorization': 'Bearer $token'};
    var url = Uri.parse(
        'https://pollchat.myappsdevelopment.co.in/api/v1/friend/delete/$id');
    var request = http.Request('DELETE', url);
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        print(responseBody);
        setState(() {
          _fetchAccounts();
        });
      } else {
        print('Failed to delete friend: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }
}
