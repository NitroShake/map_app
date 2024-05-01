import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:map_app/ServerManager.dart';
import 'package:map_app/SystemManager.dart';

class SettingsMenu extends StatefulWidget {
  const SettingsMenu({super.key});

  @override
  State<SettingsMenu> createState() => SettingsMenuState();
}

class SettingsMenuState extends State<SettingsMenu> {
  SettingsMenuState() {
    SystemManager().settingsMenu = this;
  }

  void refresh() {
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      enabled: false,
      child: 
        Column(
          children: [
            Divider(),


            Semantics(
              container: true,
              child: Row(
                children: [
                  const Expanded(
                    child: Text("Low Power Mode", softWrap: true)
                  ),  
                  Switch(value: SystemManager().isLowPowerMode, onChanged: (enabled) => {setState(() {SystemManager().setLowPowerMode(!SystemManager().isLowPowerMode);})},)
                ],
              ),
            )
,

            Divider(),

            Semantics(
              container: true,
              child: Row(
                children: [
                  const Expanded(
                    child: Text("Enable extra buttons", softWrap: true)
                  ),  
                  Switch(value: SystemManager().isExtraButtonsEnabled, onChanged: (enabled) => {setState(() {SystemManager().setExtraButtons(!SystemManager().isExtraButtonsEnabled);})},)
              ],),
            ),




            Divider(),

            Semantics(
              container: true,
              child: Row(
                children: [
                  Expanded(
                    child: 
                    ServerManager().user == null
                      ? Text("Not signed in", softWrap: true)
                      : Text("Signed in as ${ServerManager().user!.displayName}", softWrap: true,),
                  ),

                  ServerManager().user == null
                    ? FilledButton(onPressed: () {ServerManager().googleSignIn();}, child: const Text("Sign in"))
                    : FilledButton(onPressed: () {ServerManager().googleSignOut();}, child: const Text("Sign out")),  
                ],
              ),
            ),

            Text("We only store your bookmarks, and for your use only.", textScaler: TextScaler.linear(MediaQuery.of(context).textScaleFactor * 0.65),),
            Divider(),
          ],
        )
    );
  }
}