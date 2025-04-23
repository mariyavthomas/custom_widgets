import 'package:flutter/material.dart';
import 'package:flutterintern/medicineTile.dart';

class MedicinePage extends StatefulWidget {
  @override
  _MedicinePageState createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  List<MedicineEntry> medicines = [];

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
                  setState(() {
                    medicines.add(
                      MedicineEntry(
                        name: nameController.text,
                        addedOn: DateTime.now(),
                      ),
                    );
                  });
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Medicine List',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: MedicineListWidget(
        
        onAddPressed: _addMedicine,
        onDelete: _deleteMedicine,
        onKeep: _keepMedicine,
        cardWidth: MediaQuery.of(context).size.width * 0.99,
        cardHeight: 110,
        cardPadding: EdgeInsets.all(5),
        buttonWidth: 180,
        buttonHeight: 45,
        buttonPadding: EdgeInsets.only(bottom: 20),
        addButtonText: "Add Medicine",
      ),
    );
  }
}
