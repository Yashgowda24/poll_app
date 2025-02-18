// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:poll_chat/res/assets/icon_assets.dart';
// import 'package:poll_chat/res/colors/app_color.dart';
// import 'package:poll_chat/view_models/controller/edit_profile_view_model.dart';
// import 'package:poll_chat/view_models/controller/home_model.dart';

// import '../../view_models/controller/user_preference_view_model.dart';

// class EditProfileView extends StatefulWidget {
//   const EditProfileView({super.key});

//   @override
//   State<StatefulWidget> createState() => _EditProfileViewState();
// }

// class _EditProfileViewState extends State<EditProfileView> {
//   final editProfileViewModel = Get.put(EditProfileViewModel());
//   final homeViewModel = Get.put(HomeViewModelController());

//   final _formKey = GlobalKey<FormState>();

//   XFile? pickedProfile;

//   getUserProfile() async {
//     UserPreference userPreference =UserPreference();
//     var id = await userPreference.getUserID();
//     homeViewModel.getSingleUser(id.toString());
//     print(homeViewModel.singleUser);
//     var user = homeViewModel.singleUser;
//     editProfileViewModel.usernameController.value.text=user["username"];
//     editProfileViewModel.nameController.value.text=user["name"];
//     editProfileViewModel.bioController.value.text=user["bio"];
//     editProfileViewModel.cityController.value.text=user["city"];
//     editProfileViewModel.mobileController.value.text=user["phone"];
//     // editProfileViewModel.dobController.value=user["phone"];
//     // editProfileViewModel.emailController.value=user["username"];
//   }

//   checkProfilePermissions(String source) async {
//     // Request camera and storage permissions
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.camera,
//       Permission.storage,
//     ].request();

//     // Check if both permissions are granted
//     if (statuses[Permission.camera] != PermissionStatus.granted &&
//         statuses[Permission.storage] != PermissionStatus.granted) {
//       // Handle the case where permissions are not granted
//       print("Camera or storage permission not granted.");
//     } else {
//       // Permissions are granted, you can proceed
//       print("Permissions checked and granted.");
//     }
//     _pickProfile(source);
//   }

//   //for profile
//   _pickProfile(String source) async {
//     final picker = ImagePicker();
//     if(source=="camera"){
//       pickedProfile = await picker.pickImage(source: ImageSource.camera);
//     }else{
//       pickedProfile = await picker.pickImage(source: ImageSource.gallery);
//     }
//     setState(() {
//       editProfileViewModel.addImage(pickedProfile!.path);
//     });

//   }

//   askSourceProfile(){
//     return showModalBottomSheet(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(20.0), // Set the top-left radius
//           topRight: Radius.circular(20.0), // Set the top-right radius
//         ),
//       ),
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//             builder: (BuildContext context, StateSetter setState) {
//               return SingleChildScrollView(
//                 child: Container(
//                     padding: EdgeInsets.all(25),
//                     height: 150,
//                     child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Column(
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: IconButton(
//                                 icon: Icon(Icons.camera_alt_outlined,color:  Color(0xFFB32073),size: 40,),
//                                 onPressed: () {
//                                   checkProfilePermissions("camera");
//                                   Navigator.pop(context);
//                                 },),
//                             ),
//                             Text("Take Picture",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),)
//                           ],
//                         ),
//                         SizedBox(width: 10,),
//                         Column(
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: IconButton(icon: Icon(Icons.photo_camera_back_outlined,color:  Color(0xFFB32073),size: 40,),
//                                 onPressed: () {
//                                   checkProfilePermissions("gallery");
//                                   Navigator.pop(context);
//                                 },),
//                             ),
//                             Text("Upload Picture",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),)
//                           ],
//                         ),
//                       ],
//                     )
//                 ),
//               );
//             }
//         );
//       },
//     );

//   }

//   @override
//   void initState() {
//     super.initState();
//     editProfileViewModel.getUserProfileApi();
//     getUserProfile();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Edit Profile"),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 20,
//             ),
//             child: UnconstrainedBox(
//               child: InkWell(
//                 onTap: () {

//                   editProfileViewModel.updateProfileApi();
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                       color: AppColor.purpleColor,
//                       borderRadius: BorderRadius.circular(25)),
//                   child: const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//                     child: Text(
//                       "Save",
//                       style:
//                           TextStyle(color: AppColor.whiteColor, fontSize: 12),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: SafeArea(
//           child: SingleChildScrollView(
//         child: Column(
//           children: [
//             Align(
//               alignment: Alignment.center,
//               child: Stack(
//                 children: [
//                   Container(clipBehavior: Clip.hardEdge,
//                     width: 120,
//                     height: 120,
//                     decoration: BoxDecoration(
//                       color: Colors.transparent,
//                       borderRadius: BorderRadius.all(Radius.circular(60))
//                     ),
//                     child: (pickedProfile?.path)!=null?Image.file(File(pickedProfile!.path),fit: BoxFit.fill,):Image.network(homeViewModel.singleUser["profilePhoto"]),
//                   ),
//                   Positioned(
//                     bottom: 5,
//                     right: 5,
//                     child: InkWell(
//                         onTap: () {
//                           askSourceProfile();
//                         },
//                         child: SvgPicture.asset(IconAssets.editProfileIcon)),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Form(
//                   key: _formKey,
//                   child: Column(
//                 children: [
//                   TextFormField(
//                     controller: editProfileViewModel.usernameController.value,
//                     decoration: const InputDecoration(labelText: "Username"),
//                   ),
//                   TextFormField(
//                     controller: editProfileViewModel.nameController.value,
//                     decoration: const InputDecoration(labelText: "Name"),
//                   ),
//                   TextFormField(
//                     controller: editProfileViewModel.bioController.value,
//                     decoration: const InputDecoration(labelText: "Bio"),
//                   ),
//                   TextFormField(
//                     controller: editProfileViewModel.cityController.value,
//                     decoration: const InputDecoration(labelText: "City"),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 20),
//                     child: InkWell(
//                       onTap: () {},
//                       child: Container(
//                         width: MediaQuery.of(context).size.width * 0.90,
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(25),
//                             border: Border.all(
//                                 width: 1, color: AppColor.purpleColor)),
//                         child: const Padding(
//                           padding:
//                               EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                           child: Align(
//                             alignment: Alignment.center,
//                             child: Text(
//                               "Switch to Business Account",
//                               style: TextStyle(
//                                   color: AppColor.purpleColor,
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 14),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       "Personal Information",
//                       style: TextStyle(
//                           color: AppColor.blackColor,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   TextFormField(
//                     controller: editProfileViewModel.emailController.value,
//                     decoration: const InputDecoration(labelText: "Email"),
//                   ),
//                   TextFormField(
//                     controller: editProfileViewModel.mobileController.value,
//                     decoration:
//                         const InputDecoration(labelText: "Mobile Number"),
//                   ),
//                   TextFormField(
//                     controller: editProfileViewModel.dobController.value,
//                     decoration:
//                         const InputDecoration(labelText: "Date of Birth"),
//                   ),
//                   TextFormField(
//                     controller: editProfileViewModel.cityController.value,
//                     decoration: const InputDecoration(labelText: "City"),
//                   ),
//                   TextFormField(
//                     controller: editProfileViewModel.interestController.value,
//                     decoration: const InputDecoration(labelText: "Interest"),
//                   ),
//                   TextFormField(
//                     controller: editProfileViewModel.hobbiesController.value,
//                     decoration: const InputDecoration(labelText: "Hobbies"),
//                   ),
//                   const SizedBox(
//                     height: 50,
//                   )
//                 ],
//               )),
//             )
//           ],
//         ),
//       )),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poll_chat/res/assets/icon_assets.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/view_models/controller/edit_profile_view_model.dart';
import 'package:poll_chat/view_models/controller/home_model.dart';

import '../../view_models/controller/user_preference_view_model.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<StatefulWidget> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final editProfileViewModel = Get.put(EditProfileViewModel());
  final homeViewModel = Get.put(HomeViewModelController());

  final _formKey = GlobalKey<FormState>();

  XFile? pickedProfile;

  getUserProfile() async {
    UserPreference userPreference = UserPreference();
    var id = await userPreference.getUserID();
    homeViewModel.getSingleUser(id!);
    var user = homeViewModel.singleUser;
    editProfileViewModel.usernameController.value.text = user["username"] ?? '';
    editProfileViewModel.nameController.value.text = user["name"] ?? '';
    editProfileViewModel.bioController.value.text = user["bio"] ?? '';
    editProfileViewModel.cityController.value.text = user["city"] ?? '';
    editProfileViewModel.mobileController.value.text = user["phone"] ?? '';
    editProfileViewModel.hobbiesController.value.text = user["hobbies"] ?? '';
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
      editProfileViewModel.addImage(pickedProfile!.path);
      editProfileViewModel.put_profileOnly(pickedProfile!.path);
    });
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
  void initState() {
    super.initState();
    getUserProfile();
  }

  Widget getImageWidget() {
    if (pickedProfile != null) {
      return CircleAvatar(
        backgroundImage: FileImage(File(pickedProfile!.path)),
        radius: 60,
      );
    } else if (homeViewModel.singleUser["profilePhoto"] != null) {
      String profilePhoto = homeViewModel.singleUser["profilePhoto"];
      if (profilePhoto.startsWith('http')) {
        return CircleAvatar(
          backgroundImage: NetworkImage(profilePhoto),
          radius: 60,
        );
      } else {
        return CircleAvatar(
          backgroundImage: FileImage(File(profilePhoto)),
          radius: 60,
        );
      }
    } else {
      return CircleAvatar(
        backgroundImage: AssetImage('assets/images/logo.png'),
        radius: 60,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: UnconstrainedBox(
              child: InkWell(
                onTap: () async {
                  editProfileViewModel.updateProfileApi();
                  Get.toNamed(RouteName.dashboardScreen);
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColor.purpleColor,
                      borderRadius: BorderRadius.circular(25)),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Text(
                      "Save",
                      style:
                          TextStyle(color: AppColor.whiteColor, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
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
                        borderRadius: BorderRadius.all(Radius.circular(60)),
                      ),
                      child: getImageWidget()),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: InkWell(
                        onTap: () {
                          askSourceProfile();
                        },
                        child: SvgPicture.asset(IconAssets.editProfileIcon)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller:
                            editProfileViewModel.usernameController.value,
                        decoration:
                            const InputDecoration(labelText: "Username"),
                      ),
                      TextFormField(
                        controller: editProfileViewModel.nameController.value,
                        decoration: const InputDecoration(labelText: "Name"),
                      ),
                      TextFormField(
                        controller: editProfileViewModel.bioController.value,
                        decoration: const InputDecoration(labelText: "Bio"),
                      ),
                      TextFormField(
                        controller: editProfileViewModel.cityController.value,
                        decoration: const InputDecoration(labelText: "City"),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: InkWell(
                          onTap: () async {
                            await editProfileViewModel.switchBusiness();
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.90,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                    width: 1, color: AppColor.purpleColor)),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Switch to Business Account",
                                  style: TextStyle(
                                      color: AppColor.purpleColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Personal Information",
                          style: TextStyle(
                              color: AppColor.blackColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextFormField(
                        controller: editProfileViewModel.emailController.value,
                        decoration: const InputDecoration(labelText: "Email"),
                      ),
                      TextFormField(
                        controller: editProfileViewModel.mobileController.value,
                        decoration:
                            const InputDecoration(labelText: "Mobile Number"),
                      ),
                      TextFormField(
                        controller: editProfileViewModel.dobController.value,
                        decoration:
                            const InputDecoration(labelText: "Date of Birth"),
                      ),
                      TextFormField(
                        controller: editProfileViewModel.cityController.value,
                        decoration: const InputDecoration(labelText: "City"),
                      ),
                      TextFormField(
                        controller:
                            editProfileViewModel.interestController.value,
                        decoration:
                            const InputDecoration(labelText: "Interest"),
                      ),
                      TextFormField(
                        controller:
                            editProfileViewModel.hobbiesController.value,
                        decoration: const InputDecoration(labelText: "Hobbies"),
                      ),
                      const SizedBox(
                        height: 50,
                      )
                    ],
                  )),
            )
          ],
        ),
      )),
    );
  }
}
