import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:poll_chat/res/app_url/app_url.dart';
import 'package:poll_chat/simmer/simmerlist.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';

class SupportersScreen extends StatefulWidget {
  @override
  _SupportersScreenState createState() => _SupportersScreenState();
}

class _SupportersScreenState extends State<SupportersScreen> {
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
        'GET', Uri.parse('${AppUrl.baseUrl}/api/v1/support/supporters'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var decodedData = json.decode(responseData);

      setState(() {
        supporters = decodedData['supporter'];
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
        title: Text("Supporters"),
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
                            backgroundImage: supporter['supporterId']
                                        ['profilePhoto'] !=
                                    null
                                ? NetworkImage(
                                    supporter['supporterId']['profilePhoto'])
                                : null,
                            child: supporter['supporterId']['profilePhoto'] ==
                                    null
                                ? Icon(Icons
                                    .person) // Fallback icon when there is no profile photo
                                : null,
                          ),
                          title: Text(
                              "Supporter ID: ${supporter['supporterId']['name']}"),
                          subtitle:
                              Text("${supporter['supporterId']['username']}"),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
