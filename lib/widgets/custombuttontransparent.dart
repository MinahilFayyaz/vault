import 'package:flutter/material.dart';
import '../consts/consts.dart';

class CustomButton1 extends StatelessWidget {
  const CustomButton1({
    Key? key,
    required this.ontap,
    required this.buttontext,
    required this.buttontext1,
  }) : super(key: key);

  final Function ontap;
  final String buttontext;
  final String buttontext1;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Consts.BORDER_RADIUS),
        border: Border.all(color: Consts.COLOR), // Purple border color
      ),
      child: Material(
        color: Consts.FG_COLOR,
        borderRadius: BorderRadius.circular(Consts.BORDER_RADIUS),
        child: InkWell(
          onTap: () {
            ontap();
          },
          borderRadius: BorderRadius.circular(Consts.BORDER_RADIUS),
          child: Center(
            heightFactor: 2.6,
            child: Container(
              // Adjust the padding as needed
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    buttontext,
                    style: const TextStyle(
                      fontFamily: 'Gilroy',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 8.0), // Add spacing between text options
                  Text(
                    buttontext1,
                    style: const TextStyle(
                      fontFamily: 'Gilroy',
                      color: Color(0xFF585956),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
