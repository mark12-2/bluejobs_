class TypesOfJobs {
  static const List<String> allJobTypes = [
  "Construction and Trades",
  "Manufacturing and Production",
  "Logistics and Transportation",
  "Maintenance and Repair",
  "Agriculture and Landscaping",
  "Hospitality and Services",
  "Retail and Customer Service",
  "Oil and Gas",
  "Utility and Infrastructure",
  "Environmental and Waste Management"
  ];
}

// type of job dropdown discard (use if you want)
// const Padding(
//               padding: EdgeInsets.only(
//                 right: 280.0,
//               ),
//               child: Text(
//                 ('Type of Job'),
//               ),
//             ),
//             DropdownButton<String>(
//               value: _typeSelection,
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _typeSelection = newValue;
//                 });
//               },
//               items: TypesOfJobs.allJobTypes
//                   .map<DropdownMenuItem<String>>((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//             ),