import 'package:flutter/material.dart';
import 'package:lightbulb_animation/utils/style.dart';
import 'package:lightbulb_animation/widgets/lightbulb.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Style.bgColor,
      body: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LightBulb(),
          ],
        ),
      ),
    );
  }
}