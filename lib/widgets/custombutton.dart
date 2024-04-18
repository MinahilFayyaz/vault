import 'package:flutter/material.dart';
import '../consts/consts.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.ontap,
    required this.buttontext,
  });
  final Function ontap;
  final String buttontext;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Consts.COLOR,
      borderRadius: BorderRadius.circular(Consts.BORDER_RADIUS),
      child: InkWell(
        onTap: () {
          ontap();
        },
        borderRadius: BorderRadius.circular(Consts.BORDER_RADIUS),
        child: Center(
          heightFactor: 2,
          child: Text(
              buttontext,
              style: const TextStyle(
                fontFamily: 'Gilroy',
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20
              )),
        ),
      ),
    );
  }
}
