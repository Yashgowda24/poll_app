import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:poll_chat/res/app_url/app_url.dart';
import 'package:poll_chat/simmer/simmerlist.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';

class SupportingScreen extends StatefulWidget {
  @override
  _SupportingScreenState createState() => _SupportingScreenState();
}

class _SupportingScreenState extends State<SupportingScreen> {
  List supporters = [];
  bool loading = false;
  String progress = "";
  UserPreference userPreference = UserPreference();
  @override
  void initState() {
    super.initState();
    _fetchSupporters();
  }

  Future<void> _fetchSupporters() async {
    var token = await userPreference.getAuthToken();
    setState(() {
      loading = true;
      progress = "Fetching supporters...";
    });

    var headers = {'Authorization': 'Bearer $token'};
    var request = http.Request(
        'GET', Uri.parse('${AppUrl.baseUrl}/api/v1/support/supporting'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var decodedData = json.decode(responseData);

      setState(() {
        supporters = decodedData['supporting'];
        progress = "";
      });
    } else {
      setState(() {
        progress = "Failed to fetch supporters: ${response.reasonPhrase}";
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Supporting"),
      ),
      body: loading
          ? ShimmerListView(itemCount: 10)
          : progress.isNotEmpty
              ? Center(child: Text(progress))
              : Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: ListView.builder(
                    itemCount: supporters.length,
                    itemBuilder: (context, index) {
                      var supporter = supporters[index];
                      return Card(
                        elevation: 4,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: supporter['supportingId']
                                        ['profilePhoto'] !=
                                    null
                                ? NetworkImage(
                                    supporter['supportingId']['profilePhoto'])
                                : null,
                            child: supporter['supportingId']['profilePhoto'] ==
                                    null
                                ? Icon(Icons
                                    .person) // Fallback icon when there is no profile photo
                                : null,
                          ),
                          title: Text("${supporter['supportingId']['name']}"),
                          subtitle:
                              Text("${supporter['supportingId']['username']}"),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
