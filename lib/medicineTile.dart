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
  String? status; // Added status field

  MedicineEntry({
    required this.name,
    required this.addedOn,
    this.isKept = false,
    this.isMarkedForRemoval = false,
    this.isNew = true,
    this.markedRemovalTime,
    this.showKeepRemoveAlways = false,
    this.lastKeptOrRemovedDate,
    this.status,
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
    this.buttonTextStyle = const TextStyle(
      fontSize: 16,
    ),
    this.buttonColor = Colors.black,
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
      medicine.status = "Keep";
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
      medicine.status = "Remove";
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
                        status: "New",
                        isNew: true,
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
      width: double.infinity, // Fill the card
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _getStatusLabel(MedicineEntry med) {
    if (med.status == null || med.status!.isEmpty) return 'Not Reviewed';
    return med.status!;
  }

  void _increaseDate() {
    final today = _selectedDate;
    final todayKey = DateFormat('yyyy-MM-dd').format(today);
    final medicinesToday = widget.medicines[todayKey] ?? [];

    // 1. Check if any medicine is "Not Reviewed"
    final hasNotReviewed =
        medicinesToday.any((med) => _getStatusLabel(med) == 'Not Reviewed');

    if (hasNotReviewed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black87,
          elevation: 6,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
              'Please review all medicines for $todayKey before proceeding.'),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    // 2. Move to the next day
    final nextDate = today.add(const Duration(days: 1));
    final nextKey = DateFormat('yyyy-MM-dd').format(nextDate);

    // 3. Prepare new list for next day excluding "Remove" items
    final nextDayMedicines = medicinesToday
        .where((med) => med.status != "Remove")
        .map((med) => MedicineEntry(
              name: med.name,
              addedOn: nextDate,
              isNew: false,
              isKept: false,
              isMarkedForRemoval: false,
              showKeepRemoveAlways: false,
              markedRemovalTime: null,
              lastKeptOrRemovedDate: null,
              status: "Not Reviewed",
            ))
        .toList();

    // 4. Store the new list for the next day (only if not already set)
    if (!widget.medicines.containsKey(nextKey)) {
      widget.medicines[nextKey] = nextDayMedicines;
    }

    // 5. Call delete for items marked as "Remove"
    final toDelete =
        medicinesToday.where((med) => med.status == "Remove").toList();
    for (var med in toDelete) {
      widget.onDelete(med);
    }

    // 6. Move the selected date forward
    setState(() {
      _selectedDate = nextDate;
    });
  }

  void _decreaseDate() {
    setState(() {
      _selectedDate = _selectedDate.subtract(Duration(days: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final selectedKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final todayMedicines = widget.medicines[selectedKey] ?? [];
    print(todayMedicines);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Container(
        color: const Color.fromARGB(26, 209, 214, 221),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Medicine as on ${DateFormat('dd-MM-yyyy').format(_selectedDate)}",
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
                IconButton(
                    icon: Icon(Icons.arrow_back), onPressed: _decreaseDate),
                IconButton(
                    icon: Icon(Icons.arrow_forward), onPressed: _increaseDate),
              ],
            ),
            const SizedBox(height: 10),
            todayMedicines.isEmpty
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 50),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _showAddMedicineBottomSheet,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.buttonColor,
                                fixedSize: Size(
                                    widget.buttonWidth, widget.buttonHeight),
                              ),
                              child: Text(widget.addButtonText,
                                  style: widget.buttonTextStyle),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: Stack(
                      children: [
                        ListView.builder(
                          padding:
                              EdgeInsets.only(bottom: widget.buttonHeight + 19),
                          itemCount: todayMedicines.length,
                          itemBuilder: (context, index) {
                            final medicine = todayMedicines[index];

                            final bool isAddedToday =
                                now.difference(medicine.addedOn).inDays == 0;

                            final bool wasKeptToday =
                                _wasActionToday(medicine.lastKeptOrRemovedDate);

                            final showKeepLabel =
                                medicine.isKept && wasKeptToday;
                            final showRemoveLabel =
                                medicine.isMarkedForRemoval && wasKeptToday;

                            Color cardColor = widget.cardColor;
                            final bool isFirstRow = index == 0;
                            return Slidable(
                                key: ValueKey(medicine.name +
                                    medicine.addedOn.toString()),
                                startActionPane:
                                    medicine.status == 'Not Reviewed' ||
                                            medicine.status == "Keep" ||
                                            medicine.status == "Remove" ||
                                            _canShowKeep(medicine)
                                        ? ActionPane(
                                            motion: const DrawerMotion(),
                                            extentRatio: 0.5,
                                            children: [
                                              SlidableAction(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                onPressed: (context) =>
                                                    _handleKeep(medicine),
                                                backgroundColor:
                                                    widget.keepButtonColor,
                                                foregroundColor: Colors.white,
                                                icon: Icons.check,
                                                label: widget.keepLabel,
                                                autoClose: true,
                                              ),
                                            ],
                                          )
                                        : null,
                                endActionPane:
                                    medicine.status == "Not Reviewed" ||
                                            medicine.status == "New" ||
                                            medicine.status == "Keep"
                                        ? ActionPane(
                                            motion: const DrawerMotion(),
                                            extentRatio: 0.5,
                                            children: [
                                              SlidableAction(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                onPressed: (context) =>
                                                    handleRemove(medicine),
                                                backgroundColor:
                                                    widget.deleteButtonColor,
                                                foregroundColor: Colors.white,
                                                icon: Icons.delete,
                                                label: widget.deleteLabel,
                                                autoClose: true,
                                              ),
                                            ],
                                          )
                                        : null,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 1),
                                  child: Card(
                                    elevation: 7,
                                    shadowColor: Colors.blueGrey,
                                    color: cardColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: widget.cardHeight,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // LEFT SIDE — Only for NEW
                                              if (medicine.isNew &&
                                                  isAddedToday)
                                                _buildLabelStrip(
                                                    "NEW", Colors.blue)
                                              else if (showKeepLabel)
                                                _buildLabelStrip(
                                                    "KEEP", Colors.green)
                                              else
                                                const SizedBox(width: 25),

                                              // MAIN CONTENT
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: ListTile(
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            12),
                                                    title: Center(
                                                      child: Text(
                                                        medicine.name,
                                                        style: widget
                                                            .titleTextStyle,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // RIGHT SIDE — KEEP or REMOVE only

                                              if (showRemoveLabel)
                                                _buildLabelStrip(
                                                    "REMOVE",
                                                    const Color.fromARGB(
                                                        255, 231, 78, 67))
                                              else if (medicine.status ==
                                                  "Not Reviewed")
                                                _buildLabelStrip("NOT REVIEWED",
                                                    Colors.yellow)
                                              else
                                                const SizedBox(width: 25),
                                            ],
                                          ),
                                        ),

                                        // // BOTTOM STRIP — Only for "Not Reviewed"
                                        // if (medicine.status == "Not Reviewed")
                                        //   _buildHorizontalLabelStrip(
                                        //       "NOT REVIEWED", Colors.yellow)
                                        // else
                                        //   const SizedBox.shrink(),
                                      ],
                                    ),
                                  ),
                                ));
                          },
                        ),
                        Positioned(
                          bottom: widget.buttonPadding.bottom + 30,
                          left: widget.buttonPadding.left + 80,
                          right: widget.buttonPadding.right,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(children: [
                              ElevatedButton(
                                onPressed: _showAddMedicineBottomSheet,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: const Color.fromARGB(
                                            255, 212, 185, 226),
                                        width:
                                            1), // Set your border color and width
                                    borderRadius: BorderRadius.circular(
                                        10), // Set border radius for rounded corners
                                  ),
                                  fixedSize: Size(
                                      widget.buttonWidth, widget.buttonHeight),
                                ),
                                child: Text(
                                  widget.addButtonText,
                                  style: widget.buttonTextStyle,
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
