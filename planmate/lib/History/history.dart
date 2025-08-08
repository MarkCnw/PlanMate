

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SvgPicture.asset(
              'assets/avatar/hisssss.svg',
              width: 300,
              height: 300,
            ),
            
          ),
          SizedBox(height: 40,),
          Text("History will be coming soon!!",style: TextStyle(
            fontSize: 20,
            
          ),)
        ],
      ),
    );
  }
}
