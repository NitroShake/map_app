import 'package:flutter/material.dart';
import 'package:map_app/ServerManager.dart';

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
        FilledButton(onPressed: () {ServerManager().googleSignIn();}, child: const Icon(Icons.signal_wifi_0_bar))

      ],
    );
  }
}