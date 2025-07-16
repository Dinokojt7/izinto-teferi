import 'package:flutter/material.dart';

class MainProgressIndicator extends StatelessWidget {
  const MainProgressIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Center(
                    child: CircularProgressIndicator(
                  color: Colors.white,
                )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
