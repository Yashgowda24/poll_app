import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poll_chat/res/assets/icon_assets.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/view_models/controller/fill_your_profile_view_model.dart';

class FillYourProfileView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FillYourProfileState();
}

class _FillYourProfileState extends State<FillYourProfileView> {
  String genderGroupValue = "Male";
  final fillYourProfileViewModel = Get.put(FillYourProfileViewModel());
  final _formKey = GlobalKey<FormState>();
  XFile? pickedProfile;

  @override
  void initState() {
    super.initState();
    fillYourProfileViewModel.genderController.value.text =
        "Male"; // Default value
  }

  checkProfilePermissions(String source) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();

    if (statuses[Permission.camera] != PermissionStatus.granted &&
        statuses[Permission.storage] != PermissionStatus.granted) {
      print("Camera or storage permission not granted.");
    } else {
      print("Permissions checked and granted.");
    }
    _pickProfile(source);
  }

  _pickProfile(String source) async {
    final picker = ImagePicker();
    if (source == "camera") {
      pickedProfile = await picker.pickImage(source: ImageSource.camera);
    } else {
      pickedProfile = await picker.pickImage(source: ImageSource.gallery);
    }
    setState(() {
      fillYourProfileViewModel.addImage(pickedProfile!.path);
    });
  }

  askSourceProfile() {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0), // Set the top-left radius
          topRight: Radius.circular(20.0), // Set the top-right radius
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Container(
                padding: const EdgeInsets.all(25),
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt_outlined,
                              color: Color(0xFFB32073),
                              size: 40,
                            ),
                            onPressed: () {
                              checkProfilePermissions("camera");
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const Text(
                          "Take Picture",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: const Icon(
                              Icons.photo_camera_back_outlined,
                              color: Color(0xFFB32073),
                              size: 40,
                            ),
                            onPressed: () {
                              checkProfilePermissions("gallery");
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const Text(
                          "Upload Picture",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ],
                )),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Fill your Profile",
                    style: TextStyle(
                        color: AppColor.blackColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 4),
                    child: Text(
                      "Don’t worry, you can always edit it later",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColor.greyColor,
                          fontSize: 12,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Container(
                          clipBehavior: Clip.hardEdge,
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                              color: Colors.transparent,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(60))),
                          child: (pickedProfile?.path != null)
                              ? Image.file(
                                  File(pickedProfile!.path),
                                  fit: BoxFit.fill,
                                )
                              : (fillYourProfileViewModel.img != null &&
                                      fillYourProfileViewModel.img.isNotEmpty
                                  ? Image.network(
                                      fillYourProfileViewModel.img as String,
                                      fit: BoxFit.fill,
                                    )
                                  : SvgPicture.asset(
                                      IconAssets.fillYourProfileEditIcon,
                                      fit: BoxFit.fill,
                                    ))),
                      Positioned(
                        bottom: 10,
                        right: 0,
                        child: InkWell(
                            onTap: () {
                              askSourceProfile();
                            },
                            child: SvgPicture.asset(
                                IconAssets.fillYourProfileEditIcon)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextFormField(
                    controller:
                        fillYourProfileViewModel.yourNameController.value,
                    decoration: const InputDecoration(
                      labelText: "Your Name",
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextFormField(
                    controller:
                        fillYourProfileViewModel.usernameController.value,
                    decoration: const InputDecoration(
                      labelText: "Username",
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextFormField(
                    controller:
                        fillYourProfileViewModel.yourBioController.value,
                    decoration: const InputDecoration(
                      labelText: "Your Bio",
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Your Gender",
                      style:
                          TextStyle(color: AppColor.blackColor, fontSize: 14),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      Row(
                        children: [
                          Radio(
                              value: 'Male',
                              activeColor: AppColor.purpleColor,
                              groupValue: genderGroupValue,
                              onChanged: (value) {
                                setState(() {
                                  fillYourProfileViewModel
                                      .genderController.value.text = value!;
                                  genderGroupValue = value;
                                });
                              }),
                          const Text(
                            'Male',
                            style: TextStyle(
                                color: AppColor.blackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.normal),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                              value: 'Female',
                              activeColor: AppColor.purpleColor,
                              groupValue: genderGroupValue,
                              onChanged: (value) {
                                setState(() {
                                  fillYourProfileViewModel
                                      .genderController.value.text = value!;
                                  genderGroupValue = value;
                                });
                              }),
                          const Text(
                            'Female',
                            style: TextStyle(
                                color: AppColor.blackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.normal),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextFormField(
                    controller: fillYourProfileViewModel.cityController.value,
                    decoration: const InputDecoration(
                      labelText: "City",
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: InkWell(
                    onTap: () {
                      // Get.toNamed(RouteName.congratulationsScreen);
                      print("detail:: ${Get.arguments}");
                      fillYourProfileViewModel.createProfileApi(
                          Get.arguments['phone'].toString(),
                          Get.arguments['id'].toString());
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 90,
                      decoration: BoxDecoration(
                          color: AppColor.purpleColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        child: Text(
                          "Continue",
                          style: TextStyle(
                              color: AppColor.whiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )),
      )),
    );
  }
}
