import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

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
  final Map<String, List<MedicineEntry>> medicines;
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
    this.cardColor = Colors.white,
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
      medicine.markedRemovalTime =
          DateTime.now().add(const Duration(hours: 24));
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
          child: Text(label,
              style: const TextStyle(color: Colors.black, fontSize: 12)),
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
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      final key =
                          DateFormat('yyyy-MM-dd').format(_selectedDate);
                      setState(() {
                        widget.medicines.putIfAbsent(key, () => []);
                        widget.medicines[key]!.add(newMedicine);
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final selectedKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final todayMedicines = widget.medicines[selectedKey] ?? [];

    final filteredMedicines = todayMedicines.where((medicine) {
      if (medicine.isMarkedForRemoval &&
          medicine.markedRemovalTime != null &&
          now.isAfter(medicine.markedRemovalTime!)) {
        widget.onDelete(medicine);
        return false;
      }
      return true;
    }).toList();
    // Methods to increase and decrease the date
    void _increaseDate() {
      setState(() {
        _selectedDate = _selectedDate.add(Duration(days: 1));
      });
    }

    void _decreaseDate() {
      setState(() {
        _selectedDate = _selectedDate.subtract(Duration(days: 1));
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            "Medicine as on ${DateFormat('dd-MM-yyyy').format(_selectedDate)}",
            style: const TextStyle(fontSize: 18, color: Colors.black),
          ),
          const SizedBox(height: 10),
          if (filteredMedicines.isEmpty)
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: _decreaseDate, icon: Icon(Icons.arrow_back)),
                    ElevatedButton(
                      onPressed: _showAddMedicineBottomSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.buttonColor,
                        fixedSize:
                            Size(widget.buttonWidth, widget.buttonHeight),
                      ),
                      child: Text(widget.addButtonText,
                          style: widget.buttonTextStyle),
                    ),
                    IconButton(
                        onPressed: _increaseDate,
                        icon: Icon(Icons.arrow_forward)),
                  ],
                ),
              ),
            )
          else
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

                      final showKeepLabel = medicine.isKept && wasKeptToday;
                      final showRemoveLabel =
                          medicine.isMarkedForRemoval && wasKeptToday;

                      Color cardColor = widget.cardColor;

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
                                    _buildLabelStrip("KEEP", Colors.green)
                                  else if (medicine.isNew && isAddedToday)
                                    _buildLabelStrip("NEW", Colors.blue)
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
                                      child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(12),
                                      title: Center(
                                        child: Text(
                                          medicine.name,
                                          style: widget.titleTextStyle,
                                        ),
                                      ),
                                    ),
                                  )),
                                  if (showRemoveLabel)
                                    _buildLabelStrip("REMOVE",
                                        const Color.fromARGB(255, 231, 78, 67))
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
                  Positioned(
                    bottom: widget.buttonPadding.bottom - 19.6,
                    left: widget.buttonPadding.left + 60,
                    right: widget.buttonPadding.right,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(children: [
                        IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: _decreaseDate),
                        ElevatedButton(
                          onPressed: _showAddMedicineBottomSheet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.buttonColor,
                            fixedSize:
                                Size(widget.buttonWidth, widget.buttonHeight),
                          ),
                          child: Text(widget.addButtonText,
                              style: widget.buttonTextStyle),
                        ),
                        IconButton(
                            icon: Icon(Icons.arrow_forward),
                            onPressed: _increaseDate),
                      ]),
                    ),
                  ),
                  // Positioned(
                  //   bottom: widget.buttonPadding.bottom + 60,
                  //   left: widget.buttonPadding.left,
                  //   right: widget.buttonPadding.right,
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       IconButton(
                  //           icon: Icon(Icons.arrow_back),
                  //           onPressed: _decreaseDate
                  //           // () {
                  //           //   setState(() {
                  //           //     _selectedDate = _selectedDate
                  //           //         .subtract(const Duration(days: 1));
                  //           //   });
                  //           // }
                  //           ),
                  //       // Text(
                  //       //   DateFormat('dd-MM-yyyy').format(_selectedDate),
                  //       //   style: TextStyle(fontSize: 16),
                  //       // ),
                  //       IconButton(
                  //           icon: Icon(Icons.arrow_forward),
                  //           onPressed: _increaseDate
                  //           // () {
                  //           //   setState(() {
                  //           //     _selectedDate =
                  //           //         _selectedDate.add(const Duration(days: 1));
                  //           //   });
                  //           // }
                  //           ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
