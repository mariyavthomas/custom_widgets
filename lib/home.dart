import 'package:flutter/material.dart';
import 'medicineTile.dart'; // your custom widget
import 'medicine_database.dart';
import 'medicine_entry.dart';

class MedicinePage extends StatefulWidget {
  @override
  _MedicinePageState createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  //  List<MedicineEntry> medicines = [];

  late final Map<String, List<MedicineEntry>> medicines;
  @override
  void initState() {
    super.initState();
    medicines = {}; // Now it's initialized in initState
  }

  void _addMedicine() {
    TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Medicine"),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: "Medicine Name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  // setState(() {
                  //   medicines.add(
                  //     MedicineEntry(
                  //       name: nameController.text,
                  //       addedOn: DateTime.now(),
                  //     ),
                  //   medicines.putIfAbsent(
                  //     nameController.text,
                  //     () => [
                  //       MedicineEntry(
                  //         name: nameController.text,
                  //         addedOn: DateTime.now(),
                  //       ),
                  //     ],
                  //    ) );
                  // });
                  Navigator.pop(context);
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _deleteMedicine(MedicineEntry medicine) {
    setState(() {
      medicines.remove(medicine);
    });
  }

  void _keepMedicine(MedicineEntry medicine) {
    print("Medicine kept: ${medicine.name}");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: MedicineListWidget(
      onAddPressed: _addMedicine,
      onDelete: _deleteMedicine,
      onKeep: _keepMedicine,
      cardWidth: MediaQuery.of(context).size.width * 0.99,
      cardHeight: 110,
      cardPadding: const EdgeInsets.all(5),
      buttonWidth: 180,
      buttonHeight: 45,
      buttonPadding: const EdgeInsets.only(bottom: 20),
      addButtonText: "Add Medicine",
      medicines: medicines,
    )));
  }
}
