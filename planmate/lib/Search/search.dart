import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SvgPicture.asset(
              'assets/avatar/se.svg',
              width: 300,
              height: 300,
            ),
            
          ),
          SizedBox(height: 40,),
          Text("Search will be coming soon!!",style: TextStyle(
            fontSize: 20,
            
          ),)
        ],
      ),
    );
  }
}