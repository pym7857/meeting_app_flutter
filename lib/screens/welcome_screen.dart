import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_chat/components/rounded_button.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  // Mixin 자료형: with를 이용해, 다중상속이 가능하도록 해주는 역할

  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      // (필수)controller
      duration: Duration(seconds: 3),
      vsync: this, // (필수)ticker
      //upperBound: 100.0 // curvedAnimation 쓸때는 upperBound 있으면 X
    );
    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller);
    // animation = CurvedAnimation(parent: controller, curve: Curves.decelerate);
    controller.forward();
    // controller.reverse(from: 1.0);
    controller.addListener(() {
      setState(() {}); // setState 있어야 (실시간으로 바뀌는)value 가져다 쓰기 가능
      //print(animation.value);
    });

    // // forward, backward 왔다갔다 하기
    // animation.addStatusListener((status) {
    //   // print(status)
    //   if (status == AnimationStatus.completed) { // controller.forward 라면..
    //     controller.reverse(from: 1.0);
    //   } else if (status == AnimationStatus.dismissed) { // controller.reverse 라면..
    //     controller.forward();
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.red.withOpacity(animation.value),
      backgroundColor: animation.value, // value가 바뀌려면 setState 필요
      // value null 에러 해결: Hot reload 말고, Restart를 해야 value가 제대로 적용됨 !!!
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  // Hero animation
                  tag: 'logo', // (Hero) 필수
                  child: Container(
                    child: Image.asset('images/logo2.png'),
                    height: 60.0,
                  ),
                ),
                TypewriterAnimatedTextKit(
                  text: ['YoungMin PK'],
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                  ),
                  isRepeatingAnimation: true,
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            Rounded_button(
              title: '로그인',
              colour: Colors.lightBlueAccent,
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
            Rounded_button(
              title: '회원가입',
              colour: Colors.blueAccent,
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
            ),
          ],
        ),
      ),
    );
  }
}

