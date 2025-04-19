import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MedicineEntry {
  String name;
  DateTime addedOn;
  bool isKept;
  bool isMarkedForRemoval;
  bool isNew;
  DateTime? markedRemovalTime;
  bool showKeepRemoveAlways;
  DateTime? lastKeptOrRemovedDate;

  MedicineEntry({
    required this.name,
    required this.addedOn,
    this.isKept = false,
    this.isMarkedForRemoval = false,
    this.isNew = true,
    this.markedRemovalTime,
    this.showKeepRemoveAlways = false,
    this.lastKeptOrRemovedDate,
  });
}

class MedicineListWidget extends StatefulWidget {
  final List<MedicineEntry> medicines;
  final VoidCallback onAddPressed;
  final Function(MedicineEntry) onDelete;
  final Function(MedicineEntry) onKeep;
  final double cardWidth;
  final double cardHeight;
  final EdgeInsets cardPadding;
  final double buttonWidth;
  final double buttonHeight;
  final EdgeInsets buttonPadding;
  final Color cardColor;
  final TextStyle titleTextStyle;
  final TextStyle subtitleTextStyle;
  final Color keepButtonColor;
  final Color deleteButtonColor;
  final double slidableBorderRadius;
  final String keepLabel;
  final String deleteLabel;
  final TextStyle buttonTextStyle;
  final Color buttonColor;
  final String addButtonText;

  const MedicineListWidget({
    super.key,
    required this.medicines,
    required this.onAddPressed,
    required this.onDelete,
    required this.onKeep,
    this.cardWidth = double.infinity,
    this.cardHeight = 80.0,
    this.cardPadding = EdgeInsets.zero,
    this.buttonWidth = 200,
    this.buttonHeight = 50,
    this.buttonPadding = const EdgeInsets.only(bottom: 16),
    this.cardColor = const Color(0xFFEBCCFF),
    this.titleTextStyle = const TextStyle(
        color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
    this.subtitleTextStyle =
        const TextStyle(color: Colors.black54, fontSize: 14),
    this.keepButtonColor = Colors.green,
    this.deleteButtonColor = Colors.red,
    this.slidableBorderRadius = 0.0,
    this.keepLabel = 'Keep',
    this.deleteLabel = 'Remove',
    this.buttonTextStyle =
        const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    this.buttonColor = Colors.blueAccent,
    this.addButtonText = "Add Medicine",
  });

  @override
  State<MedicineListWidget> createState() => _MedicineListWidgetState();
}

class _MedicineListWidgetState extends State<MedicineListWidget> {
  void _handleKeep(MedicineEntry medicine) {
    setState(() {
      medicine.isKept = true;
      medicine.isMarkedForRemoval = false;
      medicine.isNew = false;
      medicine.markedRemovalTime = null;
      medicine.showKeepRemoveAlways = true;
      medicine.lastKeptOrRemovedDate = DateTime.now();
    });
    widget.onKeep(medicine);
  }

  void handleRemove(MedicineEntry medicine) {
    setState(() {
      medicine.isMarkedForRemoval = true;
      medicine.isKept = false;
      medicine.isNew = false;
      medicine.markedRemovalTime = DateTime.now().add(const Duration(hours: 24));
      medicine.showKeepRemoveAlways = true;
      medicine.lastKeptOrRemovedDate = DateTime.now();
    });
  }

  bool _canShowKeep(MedicineEntry medicine) {
    final now = DateTime.now();
    final isOldEnough = now.difference(medicine.addedOn).inDays >= 1;
    return (isOldEnough || medicine.showKeepRemoveAlways);
  }

  bool _wasActionToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  Widget _buildLabelStrip(String label, Color color) {
    return Container(
      width: 25,
      height: widget.cardHeight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
      ),
      child: Center(
        child: RotatedBox(
          quarterTurns: 3,
          child: Text(label, style: const TextStyle(color: Colors.black, fontSize: 12)),
        ),
      ),
    );
  }

  void _showAddMedicineBottomSheet() {
    String medicineName = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Add New Medicine",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(
                      labelText: 'Medicine Name', border: OutlineInputBorder()),
                  onChanged: (value) {
                    medicineName = value;
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    if (medicineName.trim().isNotEmpty) {
                      final newMedicine = MedicineEntry(
                        name: medicineName.trim(),
                        addedOn: DateTime.now(),
                      );
                      Navigator.pop(context);
                      setState(() {
                        widget.medicines.add(newMedicine);
                      });
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final filteredMedicines = widget.medicines.where((medicine) {
      if (medicine.isMarkedForRemoval &&
          medicine.markedRemovalTime != null &&
          now.isAfter(medicine.markedRemovalTime!)) {
        widget.onDelete(medicine);
        return false;
      }
      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  padding: EdgeInsets.only(bottom: widget.buttonHeight + 19),
                  itemCount: filteredMedicines.length,
                  itemBuilder: (context, index) {
                    final medicine = filteredMedicines[index];

                    final bool isAddedToday =
                        now.difference(medicine.addedOn).inDays == 0;

                    final bool wasKeptToday =
                        _wasActionToday(medicine.lastKeptOrRemovedDate);

                    final showKeepLabel =
                        medicine.isKept && wasKeptToday;

                    final showRemoveLabel =
                        medicine.isMarkedForRemoval && wasKeptToday;

                    Color cardColor;

                    if ((medicine.isKept || medicine.isMarkedForRemoval) &&
                        wasKeptToday) {
                      cardColor = widget.cardColor;
                    } else if (!isAddedToday) {
                      cardColor = const Color(0xFFA4D8D8);
                    } else {
                      cardColor = widget.cardColor;
                    }

                    return Slidable(
                      key: ValueKey(medicine.name + medicine.addedOn.toString()),
                      startActionPane: _canShowKeep(medicine)
                          ? ActionPane(
                              motion: const DrawerMotion(),
                              extentRatio: 0.5,
                              children: [
                                SlidableAction(
                                  onPressed: (context) => _handleKeep(medicine),
                                  backgroundColor: widget.keepButtonColor,
                                  foregroundColor: Colors.white,
                                  icon: Icons.check,
                                  label: widget.keepLabel,
                                  autoClose: true,
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                  padding: const EdgeInsets.all(5),
                                ),
                              ],
                            )
                          : null,
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.5,
                        children: [
                          SlidableAction(
                            onPressed: (context) => handleRemove(medicine),
                            backgroundColor: widget.deleteButtonColor,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: widget.deleteLabel,
                            autoClose: true,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10)),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: Card(
                          elevation: 7,
                          shadowColor: Colors.blueGrey,
                          color: cardColor,
                          child: SizedBox(
                            height: widget.cardHeight,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showKeepLabel)
                                  _buildLabelStrip(
                                      "KEEP", const Color.fromARGB(255, 103, 190, 56))
                                else if (medicine.isNew && isAddedToday)
                                  _buildLabelStrip(
                                      "NEW", const Color.fromARGB(255, 98, 170, 218))
                                else
                                  const SizedBox(width: 25),
                                Expanded(
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    title: Center(
                                      child: Text(
                                        medicine.name,
                                        style: widget.titleTextStyle,
                                      ),
                                    ),
                                  ),
                                ),
                                if (showRemoveLabel)
                                  _buildLabelStrip(
                                      "REMOVE", const Color.fromARGB(255, 231, 78, 67))
                                else
                                  const SizedBox(width: 40),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Add Button Positioned
                Positioned(
                  bottom: widget.buttonPadding.bottom,
                  left: widget.buttonPadding.left,
                  right: widget.buttonPadding.right,
                  child: Center(
                    child: SizedBox(
                      width: widget.buttonWidth,
                      height: widget.buttonHeight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _showAddMedicineBottomSheet,
                        child: Text(widget.addButtonText,
                            style: widget.buttonTextStyle),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
