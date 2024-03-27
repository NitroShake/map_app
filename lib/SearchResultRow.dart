import 'package:flutter/material.dart';
import 'package:map_app/AddressSearchResult.dart';

class SearchResultRow extends StatelessWidget {
  const SearchResultRow({
    required this.details,
    required this.optionStyle
  });
  final AddressSearchResult details;
  final ButtonStyle optionStyle;

  String assembleDetails(List<String?> components) {
    String string = "";
    for (String? component in components) {
      if (component != null) {
        if (string != "") {
          string += ", ";
        }
        string += component;
      }
    }
    return string;
  }

  @override
  Widget build(BuildContext context) {
      return OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Test()),
          );
        }, 
        style: optionStyle,
        child: Align(alignment: Alignment.centerLeft, child: Column( 
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(assembleDetails([details.houseNumber != null ? details.houseNumber! + " " + details.street! : details.name, details.city ?? details.county]), textScaler: const TextScaler.linear(1.15)),
            Text(assembleDetails([details.postcode, details.state, details.country, details.type, details.osmValue]), textScaler: const TextScaler.linear(0.85)),
          ],
        ),
      )
    );
  }
}

class Test extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [OutlinedButton(onPressed: Navigator.of(context).pop, child: const Text("Back"))],
    );
  }
}