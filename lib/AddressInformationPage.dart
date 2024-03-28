import 'package:flutter/material.dart';
import 'package:map_app/AddressSearchResult.dart';

class AddressInformationPage extends StatefulWidget {
  final AddressSearchResult details;

  const AddressInformationPage({super.key, required this.title, required this.details});

  final String title;

  @override
  State<AddressInformationPage> createState() => _AddressInformationPage(details: details);
}

class _AddressInformationPage extends State<AddressInformationPage> {
  AddressSearchResult details;
  _AddressInformationPage({required this.details});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutlinedButton(onPressed: Navigator.of(context).pop, child: const Text("Back")),
        OutlinedButton(onPressed: () => {}, child: const Text("Calculate Route")),
      ],
    );
  }
}