import 'package:flutter/material.dart';
import 'package:map_app/Authenticator.dart';

class SettingsMenu extends StatefulWidget {
  const SettingsMenu({super.key});

  @override
  State<SettingsMenu> createState() => SettingsMenuState();
}

class SettingsMenuState extends State<SettingsMenu> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilledButton(onPressed: () {Authenticator().googleSignIn();}, child: const Icon(Icons.signal_wifi_0_bar))

      ],
    );
  }
}