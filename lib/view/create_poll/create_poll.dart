import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:poll_chat/components/octagon_shape.dart';
import 'package:poll_chat/res/assets/icon_assets.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/utils/utils.dart';
import 'package:poll_chat/view/create_poll/customcemra.dart';
import 'package:poll_chat/view_models/controller/create_poll_view_model.dart';
import 'package:poll_chat/view_models/controller/home_model.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';

class CreatePollView extends StatefulWidget {
  const CreatePollView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreatePollView();
}

class _CreatePollView extends State<CreatePollView> {
  final createPollViewModel = Get.put(CreatePollViewModel());
  final homeViewModel = Get.put(HomeViewModelController());
  final _formKey = GlobalKey<FormState>();

  late String pickedProfile;

  var _selectedItem = "Everyone";
  var _commentingPermission = "Everyone can comment";
  @override
  void initState() {
    getProfile();
    super.initState();
  }

  getProfile() async {
    UserPreference userPreference = UserPreference();
    var id = await userPreference.getUserID();
    print("ID here: $id");
    homeViewModel.getSingleUser(id!);
    // homeViewModel.getAllPollsEveryOne();
  }

  // checkProfilePermissions(String source) async {
  //   Map<Permission, PermissionStatus> statuses = await [
  //     Permission.camera,
  //     Permission.storage,
  //   ].request();

  //   if (statuses[Permission.camera] != PermissionStatus.granted &&
  //       statuses[Permission.storage] != PermissionStatus.granted) {
  //     print("Camera or storage permission not granted.");
  //   } else {
  //     print("Permissions checked and granted.");
  //   }
  //   _pickProfile(source);
  // }

  // _pickProfile(String source) async {
  //   final picker = ImagePicker();
  //   if (source == "camera") {
  //     pickedProfile = await picker.pickImage(source: ImageSource.camera);
  //   } else {
  //     pickedProfile = await picker.pickImage(source: ImageSource.gallery);
  //   }
  //   setState(() {
  //     createPollViewModel.addImage(pickedProfile!.path);
  //   });
  // }

  final picker = ImagePicker();

  _pickProfile(String source) async {
    if (source == "camera") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomCameraScreen(
            onImageCaptured: (path) {
              setState(() {
                pickedProfile = path;
                createPollViewModel.addImage(pickedProfile);
              });
              Get.back();
            },
          ),
        ),
      );
    } else {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        pickedProfile = pickedFile!.path;
        createPollViewModel.addImage(pickedProfile);
      });
    }
  }

  askSourceProfile() {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
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
                              color: AppColor.purpleColor,
                              size: 40,
                            ),
                            onPressed: () async {
                              await _pickProfile("camera");
                            },
                          ),
                        ),
                        const Text(
                          "Take Picture",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: const Icon(
                              Icons.photo_camera_back_outlined,
                              color: AppColor.purpleColor,
                              size: 40,
                            ),
                            onPressed: () async {
                              _pickProfile("gallery");
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const Text(
                          "Upload Picture",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  
  @override
  Widget build(BuildContext context) {
    final homeModelController = Get.put(HomeViewModelController());
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
          "Poll",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        )),
        actions: [
          Obx(() {
            return InkWell(
              onTap: () async {
                if (homeModelController.loading.value)
                  return; // Prevent multiple taps while loading

                String? userId = homeViewModel.userModel?.id;
                setState(() {
                  userId = homeViewModel.userModel?.id;
                });
                print("USER ID-- $userId");
                if (userId != null) {
                  createPollViewModel.createPollApi();
                  homeModelController.getAllPolls();
                  homeModelController.getAllPollsEveryOne();
                } else {
                  Utils.snackBar("Error", "UserId Not Found");
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // The Post button with conditional visibility of text
                    Visibility(
                      visible: !homeModelController.loading.value,
                      child: Container(
                        decoration: const BoxDecoration(
                            color: AppColor.purpleColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(25))),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                          child: Text('Post',
                              style: TextStyle(
                                  color: AppColor.whiteColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ),
                    // The loader
                    if (homeModelController.loading.value)
                      const CircularProgressIndicator(
                        color: AppColor.purpleColor,
                      ),
                  ],
                ),
              ),
            );
          }),

          // InkWell(
          //   onTap: () {
          //     String? userId = homeViewModel.userModel?.id;
          //     setState(() {
          //       userId = homeViewModel.userModel?.id;
          //     });
          //     print("USER ID-- $userId");
          //     if (userId != null) {
          //       createPollViewModel.createPollApi();
          //       homeModelController.getAllPolls();
          //       homeModelController.getAllPollsEveryOne();
          //     } else {
          //       Utils.snackBar("Error", "UserId Not Found");
          //     }
          //   },
          //   child: Padding(
          //     padding: const EdgeInsets.only(right: 12),
          //     child: Container(
          //       decoration: const BoxDecoration(
          //         color: AppColor.purpleColor,
          //         borderRadius: BorderRadius.all(Radius.circular(25)),
          //       ),
          //       child: const Padding(
          //         padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
          //         child: Text(
          //           'Post',
          //           style: TextStyle(
          //             color: AppColor.whiteColor,
          //             fontSize: 14,
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Divider(
                thickness: 1.5,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipPath(
                      clipper: OctagonClipper(),
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: Image.network(
                          homeViewModel.singleUser["profilePhoto"]
                                  ?.toString()
                                  .trim() ??
                              '',
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return const CircularProgressIndicator();
                            }
                          },
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return const Icon(Icons.error);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Container(
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: AppColor.purpleColor,
                          width: 1.18,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: DropdownButton<String>(
                          alignment: Alignment.center,
                          icon: Padding(
                            padding: const EdgeInsets.all(4),
                            child: SizedBox(
                              width: 6,
                              height: 10,
                              child:
                                  SvgPicture.asset(IconAssets.chevronRightIcon),
                            ),
                          ),
                          underline: Container(),
                          value: _selectedItem,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedItem = newValue!;
                              createPollViewModel.addPollType(newValue);
                            });
                          },
                          items: <String>['Everyone', 'Friends', 'None']
                              .map<DropdownMenuItem<String>>(
                                (String value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                      color: AppColor.purpleColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Container(
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: AppColor.purpleColor,
                          width: 1.18,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: DropdownButton<String>(
                          alignment: Alignment.center,
                          icon: Padding(
                            padding: const EdgeInsets.all(6),
                            child: SizedBox(
                              width: 6,
                              height: 10,
                              child:
                                  SvgPicture.asset(IconAssets.chevronRightIcon),
                            ),
                          ),
                          underline: Container(),
                          value: _commentingPermission,
                          onChanged: (String? newValue) {
                            setState(() {
                              _commentingPermission = newValue!;
                              // Handle the selected permission here
                            });
                          },
                          items: <String>[
                            'Everyone can comment',
                            'Only Friends',
                            'NoOne'
                          ]
                              .map<DropdownMenuItem<String>>(
                                (String value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/newglobe.png',
                                        height: 14,
                                        width: 14,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        value,
                                        style: const TextStyle(
                                          color: AppColor.purpleColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: TextFormField(
                    controller: createPollViewModel.askQuestionController.value,
                    decoration: const InputDecoration(
                      labelText: "Ask your question",
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: TextFormField(
                    controller: createPollViewModel.tagController.value,
                    decoration: const InputDecoration(
                      labelText: "#match",
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 5,
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Obx(
                                () => ListView.builder(
                                  itemCount: createPollViewModel
                                      .textEditingControllers.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    var choiceNo = index + 1;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            flex: 9,
                                            child: Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: AppColor.purpleColor,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 2,
                                                  horizontal: 10,
                                                ),
                                                child: TextFormField(
                                                  controller: createPollViewModel
                                                          .textEditingControllers[
                                                      index],
                                                  focusNode: createPollViewModel
                                                      .focusNodes[index],
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText:
                                                        "Choice $choiceNo",
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            flex: 1,
                                            child: InkWell(
                                              onTap: () {
                                                createPollViewModel
                                                    .removeController(
                                                  index: index,
                                                );
                                              },
                                              child: SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: SvgPicture.asset(
                                                  IconAssets.removeIcon,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                createPollViewModel.addNewController();
                                Future.delayed(Duration(milliseconds: 100), () {
                                  FocusScope.of(context).requestFocus(
                                      createPollViewModel.focusNodes.last);
                                });
                              },
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: SvgPicture.asset(IconAssets.plusIcon),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: GestureDetector(
                  onTap: () {
                    askSourceProfile();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: AppColor.greyLight3Color,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: SvgPicture.asset(
                              IconAssets.pollImagePlaceholderIcon,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('Upload Poll Background'),
                          ),
                          const Spacer(),
                          createPollViewModel.img.value != ''
                              ? InkWell(
                                  onTap: () {
                                    setState(() {
                                      createPollViewModel.clearImage();
                                    });
                                  },
                                  child: const Icon(Icons.delete),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'You can upload up to 4 backgrounds',
                        style: TextStyle(
                          color: AppColor.greyLight4Color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => Container(
                  height: 200,
                  margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                  decoration: BoxDecoration(
                    image: (createPollViewModel.img.value.isNotEmpty)
                        ? DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(
                              File(createPollViewModel.img.value),
                            ),
                          )
                        : null,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
