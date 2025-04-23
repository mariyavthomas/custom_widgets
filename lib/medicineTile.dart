import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

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
    this.cardColor = const Color.fromARGB(255, 222, 221, 223),
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
  DateTime _selectedDate = DateTime.now();
  List<List<MedicineEntry>> medicineHistory = [];

  void _handleKeep(MedicineEntry medicine) {
    setState(() {
      medicine.isKept = true;
      medicine.isMarkedForRemoval = false;
      medicine.isNew = false;
      medicine.markedRemovalTime = null;
      medicine.showKeepRemoveAlways = true;
      medicine.lastKeptOrRemovedDate = _selectedDate;
    });
    widget.onKeep(medicine);
    _updateMedicineHistory();
  }

  void _updateMedicineHistory() {
    List<MedicineEntry> newDayList = [];
    for (var medicine in widget.medicines) {
      if (!medicine.isMarkedForRemoval) {
        newDayList.add(MedicineEntry(
          name: medicine.name,
          addedOn: medicine.addedOn,
          isKept: medicine.isKept,
          isMarkedForRemoval: medicine.isMarkedForRemoval,
          isNew: medicine.isNew,
          markedRemovalTime: medicine.markedRemovalTime,
          showKeepRemoveAlways: medicine.showKeepRemoveAlways,
          lastKeptOrRemovedDate: medicine.lastKeptOrRemovedDate,
        ));
      }
    }
    medicineHistory.add(newDayList);
  }

  // Methods to increase and decrease the date
  void _increaseDate() {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: 1));
    });
    _updateMedicineHistory();
  }

  void _decreaseDate() {
    setState(() {
      _selectedDate = _selectedDate.subtract(Duration(days: 1));
    });
    _updateMedicineHistory();
  }

  void handleRemove(MedicineEntry medicine) {
    setState(() {
      medicine.isMarkedForRemoval = true;
      medicine.isKept = false;
      medicine.isNew = false;
      medicine.markedRemovalTime = _selectedDate.add(const Duration(hours: 24));
      medicine.showKeepRemoveAlways = true;
      medicine.lastKeptOrRemovedDate = _selectedDate;
    });
    // widget.onDelete(medicine);
    _updateMedicineHistory();
  }

  bool _canShowKeep(MedicineEntry medicine) {
    final isOldEnough = _selectedDate.difference(medicine.addedOn).inDays >= 1;
    return isOldEnough || medicine.showKeepRemoveAlways;
  }

  bool _wasActionToday(DateTime? date) {
    if (date == null) return false;
    return _selectedDate.year == date.year &&
        _selectedDate.month == date.month &&
        _selectedDate.day == date.day;
  }

  Widget _buildHorizontalLabelStrip(String label, Color color) {
    return Container(
      width: widget.cardWidth,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center, // Center align the text
      ),
    );
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
          child: Text(label,
              style: const TextStyle(color: Colors.black, fontSize: 12)),
        ),
      ),
    );
  }

  void _showAddMedicineAlertBox() {
    String medicineName = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Add New Medicine",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: TextField(
            decoration: const InputDecoration(
              labelText: 'Medicine Name',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              medicineName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (medicineName.trim().isNotEmpty) {
                  final newMedicine = MedicineEntry(
                    name: medicineName.trim(),
                    addedOn: DateTime.now(),
                  );
                  //_medicineBox.add(newMedicine);
                  Navigator.pop(context);
                  setState(() {
                    widget.medicines.add(newMedicine);
                    _updateMedicineHistory();
                  });
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredMedicines = widget.medicines.where((medicine) {
      if (medicine.isMarkedForRemoval &&
          medicine.markedRemovalTime != null &&
          _selectedDate.isAfter(medicine.markedRemovalTime!)) {
        widget.onDelete(medicine);
        return false;
      }
      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 500,
            child: TableCalendar(
              focusedDay: _selectedDate,
              firstDay: DateTime.utc(2020, 01, 01),
              lastDay: DateTime.utc(2030, 12, 31),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
                _updateMedicineHistory();
              },
              selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            ),
          ),
          // SizedBox(
          //   width: 200,
          // ),
          Container(
            width: 500,
            decoration: BoxDecoration(border: Border.all()),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    "Medicine as on ${DateFormat('dd-MM-yyyy').format(_selectedDate)}",
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 35),
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: widget.buttonHeight + 19),
                    itemCount: filteredMedicines.length,
                    itemBuilder: (context, index) {
                      final medicine = filteredMedicines[index];

                      final isAddedToday =
                          _selectedDate.difference(medicine.addedOn).inDays ==
                              0;
                      final wasKeptToday =
                          _wasActionToday(medicine.lastKeptOrRemovedDate);

                      final showKeepLabel = medicine.isKept && wasKeptToday;
                      final showRemoveLabel =
                          medicine.isMarkedForRemoval && wasKeptToday;

                      Color cardColor;
                      if ((medicine.isKept || medicine.isMarkedForRemoval) &&
                          wasKeptToday) {
                        cardColor = widget.cardColor;
                      } else if (!isAddedToday) {
                        cardColor = const Color.fromARGB(
                            255, 205, 210, 210); // Light grey
                      } else {
                        cardColor = widget.cardColor;
                      }

                      return Slidable(
                        key: ValueKey(
                            medicine.name + medicine.addedOn.toString()),
                        startActionPane: _canShowKeep(medicine)
                            ? ActionPane(
                                motion: const DrawerMotion(),
                                extentRatio: 0.5,
                                children: [
                                  SlidableAction(
                                    onPressed: (context) =>
                                        _handleKeep(medicine),
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
                                    _buildLabelStrip("KEEP",
                                        const Color.fromARGB(255, 103, 190, 56))
                                  else if (medicine.isNew && isAddedToday)
                                    _buildLabelStrip("NEW",
                                        const Color.fromARGB(255, 98, 170, 218))
                                  else if (!isAddedToday &&
                                      !showKeepLabel &&
                                      !showRemoveLabel &&
                                      !medicine.isKept &&
                                      !medicine.isMarkedForRemoval &&
                                      !medicine.isNew)
                                    _buildHorizontalLabelStrip(
                                        "NOT REVIEWED", Colors.yellow)
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
                                    _buildLabelStrip("REMOVE",
                                        const Color.fromARGB(255, 231, 78, 67))
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
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
                        onPressed: _showAddMedicineAlertBox,
                        child: Text(widget.addButtonText,
                            style: widget.buttonTextStyle),
                      ),
                    ),
                  ),
                ),
                Positioned(
                    bottom: widget.buttonPadding.bottom,
                    left: widget.buttonPadding.left,
                    right: widget.buttonPadding.right,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: _decreaseDate,
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: _increaseDate,
                          ),
                        ]))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
