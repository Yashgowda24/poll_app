import 'package:flutter/material.dart';
import 'package:poll_chat/res/assets/icon_assets.dart';
import 'package:poll_chat/res/colors/app_color.dart';

class AccountsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AccountsViewState();
}

class _AccountsViewState extends State<AccountsView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "People",
              style: TextStyle(color: AppColor.blackColor, fontSize: 14),
            ),
          ),
        ),
        Expanded(child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Image.asset(IconAssets.imagePlaceholderIcon),
                  ),
                  const SizedBox(width: 10,),
                  const Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                    Text("Tom Cruise", style: TextStyle(color: AppColor.blackColor, fontSize: 14, fontWeight: FontWeight.w500),),
                    Text("American Actor", style: TextStyle(color: AppColor.greyColor, fontSize: 12, fontWeight: FontWeight.normal)),
                  ],)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Image.asset(IconAssets.imagePlaceholderIcon),
                  ),
                  const SizedBox(width: 10,),
                  const Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                    Text("Tina Haque", style: TextStyle(color: AppColor.blackColor, fontSize: 14, fontWeight: FontWeight.w500),),
                    Text("Keep working ✍", style: TextStyle(color: AppColor.greyColor, fontSize: 12, fontWeight: FontWeight.normal)),
                  ],)
                ],
              ),
            )
          ],
        ))
      ],
    );
  }
}
