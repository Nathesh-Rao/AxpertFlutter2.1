import 'package:flutter/material.dart';

class WidgetDrawer extends StatelessWidget {
  const WidgetDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            DrawerHeader(
                decoration: BoxDecoration(
                    // gradient: LinearGradient(
                    //     colors: [MyColors.blue2, MyColors.blue1],
                    //     begin: Alignment.bottomCenter,
                    //     end: Alignment.topCenter,
                    //     stops: [0.3, 0.8]),
                    ),
                curve: Curves.easeInOut,
                child: Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 50, right: 50),
                        child: Image.asset(
                          'assets/images/axpert_name.png',
                          width: 100,
                        )),
                    SizedBox(height: 20),
                    Text("data")
                  ],
                )),
            Expanded(
              child: Container(
                height: double.maxFinite,
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => ListTile(title: Text("Hello")),
                  itemCount: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
