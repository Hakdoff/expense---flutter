import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/views/LoginPage.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          top: 100,
          left: 20,
          right: 20,
          bottom: 100,
        ),
        child: Column(
          children: [
            Container(
              height: 500,
              width: 500,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'lib/assets/images/logo.png',
                  height: 200,
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
                onPressed: () => {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => LoginPage()))
                    },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffffd2ff),
                    foregroundColor: const Color(0xffff1ba7),
                    fixedSize: const Size(250, 60)),
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 20),
                ))
          ],
        ),
      ),
    );
  }
}
