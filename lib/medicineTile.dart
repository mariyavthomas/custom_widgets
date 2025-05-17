// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterintern/medicine_Database.dart';
import 'package:flutterintern/medicine_entry.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

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
    this.buttonColor = Colors.white,
    this.addButtonText = "Add Medicine",
  });

  @override
  State<MedicineListWidget> createState() => _MedicineListWidgetState();
}

class _MedicineListWidgetState extends State<MedicineListWidget> {
  DateTime _selectedDate = DateTime.now();
  late MedicineDBHelper _databaseHelper;
  late Future<List<Map<String, dynamic>>> _medicinesFuture;
  @override
  void initState() {
    super.initState();
    _databaseHelper = MedicineDBHelper();
    //_medicinesFuture = _databaseHelper.getAllMedicinesGroupedByDate() as Future<List<Map<String, dynamic>>>;
  }

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

    // Update the medicine in the database
    MedicineDBHelper().updateMedicine(medicine);
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

    // Update the medicine in the database
    MedicineDBHelper().updateMedicine(medicine);
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
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddMedicineBottomSheet() {
    String medicineName = '';
    final _formKey =
        GlobalKey<FormState>(); // Add a GlobalKey for FormState validation

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
                Text(
                  "Add New Medicine",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Form(
                  key: _formKey, // Attach the Form to the key
                  child: Column(
                    children: [
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                            labelText: 'Medicine Name',
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                            border: OutlineInputBorder()),
                        onChanged: (value) {
                          medicineName = value;
                        },
                        validator: (value) {
                          // Validate if the input is empty
                          if (value == null || value.isEmpty) {
                            return 'Please enter a medicine name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            // // Only proceed if validation passes
                            // final newMedicine = MedicineEntry(
                            //   name: medicineName.trim(),
                            //   addedOn: _selectedDate,
                            //   status: "New",
                            //   //isNew: true,
                            // );

                            // // Insert the new medicine into the database
                            // await MedicineDBHelper()
                            //     .insertMedicine(newMedicine);

                            Navigator.pop(context);
                            await Future.delayed(const Duration(
                                milliseconds: 300)); // Optional delay

                            // Open dosage bottom sheet and pass medicine name
                            _showAddDosageBottomSheet(
                              medicineName: medicineName,
                              selectedDate: _selectedDate,
                              isEdit: false,
                            );

                            // Update the state and UI
                            // final key =
                            //     DateFormat('yyyy-MM-dd').format(_selectedDate);
                            // setState(() {
                            //   widget.medicines.putIfAbsent(key, () => []);
                            //   widget.medicines[key]!.add(newMedicine);
                            // });
                          }
                        },
                        child: Text(
                          "Add",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // void _showAddDosageBottomSheet(String medicineName, DateTime selectedDate) {
  //   List<int> dosageValues = []; // holds 0 or 1 for each slot
  //   List<TimeOfDay?> dosageTimes = []; // time for 1, null for 0
  //   List<int> undoValues = [];
  //   List<TimeOfDay?> undoTimes = [];

  //   TimeOfDay _add30Min(TimeOfDay time) {
  //     final now = DateTime.now();
  //     final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute)
  //         .add(const Duration(minutes: 30));
  //     return TimeOfDay(hour: dt.hour, minute: dt.minute);
  //   }

  //   TimeOfDay _subtract30Min(TimeOfDay time) {
  //     final now = DateTime.now();
  //     final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute)
  //         .subtract(const Duration(minutes: 30));
  //     return TimeOfDay(hour: dt.hour, minute: dt.minute);
  //   }

  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     builder: (context) {
  //       return StatefulBuilder(builder: (context, setModalState) {
  //         return Padding(
  //           padding: MediaQuery.of(context).viewInsets,
  //           child: Padding(
  //             padding: const EdgeInsets.all(16),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 const Text("Dosage Time Setup",
  //                     style:
  //                         TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //                 const SizedBox(height: 16),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                   children: dosageValues.asMap().entries.map((entry) {
  //                     final index = entry.key;
  //                     final value = entry.value;
  //                     final time = dosageTimes[index];

  //                     return Column(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         // Time text if value == 1, else blank space
  //                         SizedBox(
  //                           height: 20,
  //                           child: value == 1 && time != null
  //                               ? Text(time.format(context),
  //                                   style: const TextStyle(fontSize: 14))
  //                               : const SizedBox(), // to align empty space for 0
  //                         ),
  //                         Text("$value ",
  //                             style: const TextStyle(fontSize: 16)),

  //                         const SizedBox(height: 4),
  //                         if (value == 1 && time != null)
  //                           Container(
  //                             width: 35,
  //                             decoration: BoxDecoration(
  //                               border: Border.all(color: Colors.grey),
  //                               borderRadius: BorderRadius.circular(8),
  //                             ),
  //                             child: Column(
  //                               mainAxisSize: MainAxisSize.min,
  //                               children: [
  //                                 IconButton(
  //                                   icon: const Icon(Icons.arrow_drop_up),
  //                                   padding: EdgeInsets.zero,
  //                                   visualDensity: VisualDensity.compact,
  //                                   onPressed: () {
  //                                     setModalState(() {
  //                                       dosageTimes[index] = _add30Min(time);
  //                                     });
  //                                   },
  //                                 ),
  //                                 SizedBox(
  //                                   width: 35,
  //                                   child: Divider(
  //                                     thickness: 1,
  //                                     height: 1,
  //                                     color: Colors
  //                                         .grey, // make it dark so it's visible
  //                                   ),
  //                                 ),
  //                                 IconButton(
  //                                   icon: const Icon(Icons.arrow_drop_down),
  //                                   padding: EdgeInsets.zero,
  //                                   visualDensity: VisualDensity.compact,
  //                                   onPressed: () {
  //                                     setModalState(() {
  //                                       dosageTimes[index] =
  //                                           _subtract30Min(time);
  //                                     });
  //                                   },
  //                                 ),
  //                               ],
  //                             ),
  //                           )
  //                         else
  //                           const SizedBox(height: 80),
  //                       ],
  //                     );
  //                   }).toList(),
  //                 ),
  //                 const SizedBox(height: 16),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                   children: [
  //                     ElevatedButton(
  //                       onPressed: () {
  //                         if (dosageValues.isNotEmpty) {
  //                           setModalState(() {
  //                             undoValues.add(dosageValues.removeLast());
  //                             undoTimes.add(dosageTimes.removeLast());
  //                           });
  //                         }
  //                       },
  //                       child: const Icon(Icons.arrow_back),
  //                     ),
  //                     ElevatedButton(
  //                       onPressed: () {
  //                         if (undoValues.isNotEmpty) {
  //                           setModalState(() {
  //                             dosageValues.add(undoValues.removeLast());
  //                             dosageTimes.add(undoTimes.removeLast());
  //                           });
  //                         }
  //                       },
  //                       child: const Text("DEL"),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 16),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                   children: [
  //                     ElevatedButton(
  //                       onPressed: () {
  //                         if (dosageValues.length >= 6) return;
  //                         setModalState(() {
  //                           dosageValues.add(1);
  //                           if (dosageTimes.isEmpty) {
  //                             dosageTimes
  //                                 .add(const TimeOfDay(hour: 6, minute: 0));
  //                           } else {
  //                             final lastTime = dosageTimes.last ??
  //                                 const TimeOfDay(hour: 6, minute: 0);
  //                             dosageTimes.add(_add30Min(lastTime));
  //                           }
  //                         });
  //                       },
  //                       child: const Text("1"),
  //                     ),
  //                     ElevatedButton(
  //                       onPressed: () {
  //                         if (dosageValues.length >= 6) return;
  //                         setModalState(() {
  //                           dosageValues.add(0);
  //                           if (dosageTimes.isEmpty) {
  //                             dosageTimes.add(null);
  //                           } else {
  //                             final lastTime = dosageTimes.last ??
  //                                 const TimeOfDay(hour: 6, minute: 0);
  //                             dosageTimes.add(_add30Min(lastTime));
  //                           }
  //                         });
  //                       },
  //                       child: const Text("0"),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 16),
  //                 ElevatedButton(
  //                   onPressed: () async {
  //                     String dosage = dosageValues.join("-");

  //                     final newMedicine = MedicineEntry(
  //                       name: medicineName,
  //                       addedOn: selectedDate,
  //                       status: "New",
  //                       dosage: dosage,
  //                     );

  //                     await MedicineDBHelper().insertMedicine(newMedicine);

  //                     final key = DateFormat('yyyy-MM-dd').format(selectedDate);
  //                     setState(() {
  //                       widget.medicines.putIfAbsent(key, () => []);
  //                       widget.medicines[key]!.add(newMedicine);
  //                     });

  //                     Navigator.pop(context);
  //                   },
  //                   child: const Text("OK"),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  //     },
  //   );
  // }

  void _showAddDosageBottomSheet({
    String? medicineName,
    DateTime? selectedDate,
    bool? isEdit,
    String? dosage,
    List<String>? dosageTimes,
    int? editIndex,
    String? status,
  }) {
    List<int> dosageValues = [];
    List<TimeOfDay?> localDosageTimes = [];

    if (isEdit == true && dosage != null && dosageTimes != null) {
      dosageValues = dosage.split('-').map(int.parse).toList();
      localDosageTimes = dosageTimes.map((str) {
        if (str == "null") return null;
        final timeParts = str.split(" ");
        final hourMinute = timeParts[0].split(":");
        int hour = int.parse(hourMinute[0]);
        int minute = int.parse(hourMinute[1]);
        if (timeParts[1].toLowerCase() == "pm" && hour != 12) hour += 12;
        if (timeParts[1].toLowerCase() == "am" && hour == 12) hour = 0;
        return TimeOfDay(hour: hour, minute: minute);
      }).toList();

      // Ensure time list length matches dosage values
      while (localDosageTimes.length < dosageValues.length) {
        localDosageTimes.add(null);
      }
    }

    final fixedTimes = [
      const TimeOfDay(hour: 6, minute: 0),
      const TimeOfDay(hour: 11, minute: 0),
      const TimeOfDay(hour: 12, minute: 0),
      const TimeOfDay(hour: 19, minute: 0),
      const TimeOfDay(hour: 14, minute: 0),
      const TimeOfDay(hour: 16, minute: 0),
    ];

    int timeIndex = localDosageTimes.where((t) => t != null).length;
    List<int> undoValues = [];
    List<TimeOfDay?> undoTimes = [];
    List<FixedExtentScrollController> hourControllers = [];
    List<FixedExtentScrollController> minuteControllers = [];
    List<FixedExtentScrollController> ampmControllers = [];
// Initialize controllers only once

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEdit == true ? "Edit Dosage" : "Add Dosage",
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: dosageValues.asMap().entries.map((entry) {
                        final index = entry.key;
                        final value = entry.value;
                        TimeOfDay? time = localDosageTimes[index];

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 30,
                              child: value == 1
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Hour Picker (12-hour format)
                                        SizedBox(
                                          width: 10,
                                          height: 30,
                                          child: CupertinoPicker(
                                            scrollController:
                                                FixedExtentScrollController(
                                              initialItem:
                                                  (time!.hourOfPeriod == 0
                                                          ? 12
                                                          : time.hourOfPeriod) -
                                                      1,
                                            ),
                                            itemExtent: 30,
                                            onSelectedItemChanged: (int index) {
                                              final hour = index + 1 == 12
                                                  ? 0
                                                  : index + 1;
                                              final adjustedHour =
                                                  time!.period == DayPeriod.pm
                                                      ? hour + 12
                                                      : hour;
                                              setModalState(() {
                                                localDosageTimes[index] =
                                                    TimeOfDay(
                                                        hour: adjustedHour,
                                                        minute: time!.minute);
                                              });
                                            },
                                            children: List.generate(
                                              12,
                                              (index) => Center(
                                                child: Text(
                                                  (index + 1)
                                                      .toString()
                                                      .padLeft(2, '0'),
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 8),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(": ",
                                            style: GoogleFonts.poppins(
                                                fontSize: 8)),
                                        // Minute Picker
                                        SizedBox(
                                          width: 10,
                                          height: 30,
                                          child: CupertinoPicker(
                                            scrollController:
                                                FixedExtentScrollController(
                                              initialItem: time.minute,
                                            ),
                                            itemExtent: 30,
                                            onSelectedItemChanged:
                                                (int minute) {
                                              setModalState(() {
                                                localDosageTimes[index] =
                                                    TimeOfDay(
                                                        hour: time!.hour,
                                                        minute: minute);
                                              });
                                            },
                                            children: List.generate(
                                              60,
                                              (index) => Center(
                                                child: Text(
                                                  index
                                                      .toString()
                                                      .padLeft(2, '0'),
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 8),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        //   const SizedBox(width: 4),
                                        // AM/PM Picker
                                        Container(
                                          //   color: Colors.white,
                                          width: 15,
                                          height: 30,
                                          child: CupertinoPicker(
                                            scrollController:
                                                FixedExtentScrollController(
                                              initialItem:
                                                  time.period == DayPeriod.am
                                                      ? 0
                                                      : 1,
                                            ),
                                            itemExtent: 30,
                                            onSelectedItemChanged:
                                                (int selectedIndex) {
                                              final isPM = selectedIndex == 1;
                                              int hour = time!.hourOfPeriod;
                                              if (hour == 12) hour = 0;
                                              final newHour =
                                                  isPM ? hour + 12 : hour;
                                              setModalState(() {
                                                localDosageTimes[index] =
                                                    TimeOfDay(
                                                        hour: newHour,
                                                        minute: time!.minute);
                                              });
                                            },
                                            children: [
                                              Center(
                                                  child: Text("AM",
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 8))),
                                              Center(
                                                  child: Text("PM",
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 8))),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),
                            ),
                            Text(
                              "$value",
                              style: GoogleFonts.poppins(
                                  fontSize: 16, color: Colors.black),
                            ),
                            const SizedBox(height: 4),
                            if (value == 1 && time != null)
                              Container(
                                width: 35,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_drop_up),
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        if (time != null) {
                                          final totalMinutes = time!.hour * 60 +
                                              time!.minute +
                                              30;
                                          final newHour =
                                              (totalMinutes ~/ 60) % 24;
                                          final newMinute = totalMinutes % 60;
                                          final newTime = TimeOfDay(
                                              hour: newHour, minute: newMinute);

                                          setModalState(() {
                                            time = newTime;
                                            localDosageTimes[index] = newTime;
                                          });
                                        }
                                      },
                                    ),
                                    const Divider(
                                        thickness: 1,
                                        height: 1,
                                        color: Colors.grey),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_drop_down),
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        if (time != null) {
                                          int totalMinutes = time!.hour * 60 +
                                              time!.minute -
                                              30;
                                          if (totalMinutes < 0)
                                            totalMinutes = 0;

                                          final newHour =
                                              (totalMinutes ~/ 60) % 24;
                                          final newMinute = totalMinutes % 60;
                                          final newTime = TimeOfDay(
                                              hour: newHour, minute: newMinute);

                                          setModalState(() {
                                            time = newTime;
                                            localDosageTimes[index] = newTime;
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              )
                            else
                              const SizedBox(height: 80),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (undoValues.isNotEmpty) {
                              setModalState(() {
                                dosageValues.add(undoValues.removeLast());
                                localDosageTimes.add(undoTimes.removeLast());
                                timeIndex++;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Color.fromARGB(255, 210, 208, 208),
                            fixedSize: Size(
                                widget.buttonWidth - 30, widget.buttonHeight),
                          ),
                          child: const Icon(
                            Icons.undo,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              if (dosageValues.isNotEmpty) {
                                setModalState(() {
                                  undoValues.add(dosageValues.removeLast());
                                  undoTimes.add(localDosageTimes.removeLast());
                                  timeIndex--;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor:
                                  Color.fromARGB(255, 210, 208, 208),
                              fixedSize: Size(
                                  widget.buttonWidth - 30, widget.buttonHeight),
                            ),
                            child: Text("Delete",
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.black) // Text color
                                ) // ,),),
                            ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: dosageValues.length >= 6
                              ? null
                              : () {
                                  setModalState(() {
                                    dosageValues.add(1);
                                    if (timeIndex < fixedTimes.length) {
                                      localDosageTimes
                                          .add(fixedTimes[timeIndex]);
                                      timeIndex++;
                                    } else {
                                      localDosageTimes.add(null);
                                    }
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: dosageValues.length >= 6
                                ? Colors.grey // Color when limit is reached
                                : Color(0xFF1E3A8A),
                            fixedSize: Size(
                                widget.buttonWidth - 25, widget.buttonHeight),
                          ),
                          child: Text(
                            "1",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: dosageValues.length >= 6
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        ElevatedButton(
                          onPressed: dosageValues.length >= 6
                              ? null
                              : () {
                                  setModalState(() {
                                    dosageValues.add(0);
                                    localDosageTimes.add(null);
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fixedSize: Size(
                                widget.buttonWidth - 25, widget.buttonHeight),
                            backgroundColor: dosageValues.length >= 6
                                ? Colors.grey // Color when limit is reached
                                : Color(0xFF1E3A8A), // Normal color
                          ),
                          child: Text(
                            "0",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: dosageValues.length >= 6
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        String finalDosage = dosageValues.join("-");
                        List<String> timeStrings = localDosageTimes
                            .map((t) => t?.format(context) ?? "null")
                            .toList();
                        final key =
                            DateFormat('yyyy-MM-dd').format(selectedDate!);
                        final newEntry = MedicineEntry(
                          name: medicineName!, // make sure it's not null
                          addedOn: selectedDate!,
                          dosage: finalDosage,
                          dosageTimes: timeStrings,
                          status: isEdit == false
                              ? "New"
                              : widget.medicines[key]?[editIndex!].status ??
                                  status ??
                                  "Not Reviewed",
                        );

                        //print(newEntry.status);
                        if (isEdit == true && editIndex != null) {
                          print("Updating entry:");
                          print("Name: ${newEntry.name}");
                          print("Date: ${newEntry.addedOn}");
                          print("Dosage: ${newEntry.dosage}");
                          print("Times: ${newEntry.dosageTimes}");
                          print("Status: ${newEntry.status}");
                          setState(() {
                            widget.medicines[key]![editIndex] = newEntry;
                          });
                          await MedicineDBHelper().updateMedicine(newEntry);
                          setState(() {});
                        } else if (isEdit == false && editIndex == null) {
                          await MedicineDBHelper().insertMedicine(newEntry);
                          // await MedicineDBHelper().updateMedicine(newEntry);
                          setState(() {
                            widget.medicines.putIfAbsent(key, () => []);
                            widget.medicines[key]!.add(newEntry);
                          });
                        }

                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1E3A8A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fixedSize:
                            Size(widget.buttonWidth + 145, widget.buttonHeight),
                      ),
                      child: Text(
                        "OK",
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
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

  void _increaseDate() async {
    final today = _selectedDate;
    final todayKey = DateFormat('yyyy-MM-dd').format(today);
    final medicinesToday = widget.medicines[todayKey] ?? [];

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

    final nextDate = today.add(const Duration(days: 1));
    final nextKey = DateFormat('yyyy-MM-dd').format(nextDate);

    // Ensure that you are not overwriting existing data
    if (!widget.medicines.containsKey(nextKey)) {
      widget.medicines[nextKey] = [];
    }

    // Retrieve today's kept medicines
    final todayKeptList =
        medicinesToday.where((med) => med.status != "Remove").toList();

    // Generate the next day's list based on today's kept medicines
    final generatedNextDayList = todayKeptList
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
              dosage: med.dosage,
              dosageTimes: med.dosageTimes,
            ))
        .toList();

    // Add new medicines to the next day's list without removing existing ones
    for (var med in generatedNextDayList) {
      if (!widget.medicines[nextKey]!
          .any((existingMed) => existingMed.name == med.name)) {
        widget.medicines[nextKey]!.add(med);
      }
    }

    setState(() {
      _selectedDate = nextDate;
    });

    // Save the updated date information in the database
    await MedicineDBHelper().updateDate(nextDate);
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
                  style:
                      //const TextStyle(fontSize: 18, color: Colors.black),
                      GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            todayMedicines.isEmpty
                ? Expanded(
                    child: Center(),
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
                            // ignore: unused_local_variable
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
                                              if (medicine.status == "New")
                                                _buildLabelStrip(
                                                    "NEW", Colors.blue)
                                              else if (medicine.status ==
                                                  "Keep")
                                                _buildLabelStrip(
                                                    "KEEP", Colors.green)
                                              else
                                                const SizedBox(width: 25),

                                              // MAIN CONTENT
                                              Expanded(
                                                  child:
                                                      //  ListTile(
                                                      //   contentPadding:
                                                      //       const EdgeInsets.all(
                                                      //           12),
                                                      //   title: Center(
                                                      //     child: Text(
                                                      //       medicine.name,
                                                      //       style:
                                                      //           GoogleFonts.poppins(
                                                      //         fontSize: 17,
                                                      //         fontWeight:
                                                      //             FontWeight.bold,
                                                      //         color: Colors.black,
                                                      //       ),
                                                      //     ),
                                                      //   ),
                                                      // trailing: TextButton(
                                                      //   onPressed: () {
                                                      //     print(medicine.status);
                                                      //     _showAddDosageBottomSheet(
                                                      //         medicineName:
                                                      //             medicine.name,
                                                      //         selectedDate:
                                                      //             medicine
                                                      //                 .addedOn,
                                                      //         isEdit: true,
                                                      //         editIndex: index,
                                                      //         dosage:
                                                      //             medicine.dosage,
                                                      //         dosageTimes: medicine
                                                      //             .dosageTimes,
                                                      //         status: medicine
                                                      //             .status);
                                                      //   },
                                                      //   child: Padding(
                                                      //     padding: const EdgeInsets.only(left: 15),
                                                      //     child: Container(
                                                      //       height: 70,
                                                      //       width: 150,
                                                      //       child: Column(
                                                      //         children: [
                                                      //           Expanded(
                                                      //             child: Text(medicine.dosageTimes?.join(", ") ?? "",
                                                      //             style:
                                                      //                   GoogleFonts.poppins(
                                                      //                 fontSize: 6,

                                                      //                 color: Colors.black54,
                                                      //               ),
                                                      //             ),
                                                      //           ),
                                                      //           Text(
                                                      //             medicine.dosage ??
                                                      //                 "No dosage specified",
                                                      //             style:
                                                      //                 GoogleFonts.poppins(
                                                      //               fontSize: 14,
                                                      //               fontWeight: FontWeight.bold,
                                                      //               color: Colors.black54,
                                                      //             ),
                                                      //           ),
                                                      //         ],
                                                      //       ),
                                                      //     ),
                                                      //   ),
                                                      //   ),
                                                      // ),
                                                      Row(
                                                children: [
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 15),
                                                      child: Expanded(
                                                        child: Text(
                                                          medicine.name,
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 120, top: 40),
                                                    child: Expanded(
                                                      child: Container(
                                                        width: 120,
                                                        child: Column(
                                                          //mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              medicine.dosageTimes
                                                                      ?.join(
                                                                          ", ") ??
                                                                  "",
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontSize: 6,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                print(medicine
                                                                    .status);
                                                                _showAddDosageBottomSheet(
                                                                    medicineName:
                                                                        medicine
                                                                            .name,
                                                                    selectedDate:
                                                                        medicine
                                                                            .addedOn,
                                                                    isEdit:
                                                                        true,
                                                                    editIndex:
                                                                        index,
                                                                    dosage: medicine
                                                                        .dosage,
                                                                    dosageTimes:
                                                                        medicine
                                                                            .dosageTimes,
                                                                    status: medicine
                                                                        .status);
                                                              },
                                                              child: Text(
                                                                medicine.dosage ??
                                                                    "No dosage specified",
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              )),

                                              // RIGHT SIDE — KEEP or REMOVE only

                                              if (medicine.status == "Remove")
                                                _buildLabelStrip(
                                                    "REMOVE",
                                                    const Color.fromARGB(
                                                        255, 231, 78, 67))
                                              // else if (medicine.status ==
                                              //     "Not Reviewed")
                                              //   _buildLabelStrip("NOT REVIEWED",
                                              //       Colors.yellow)
                                              else
                                                const SizedBox(width: 25),
                                            ],
                                          ),
                                        ),

                                        // BOTTOM STRIP — Only for "Not Reviewed"
                                        if (medicine.status == "Not Reviewed")
                                          _buildHorizontalLabelStrip(
                                              "NOT REVIEWED", Colors.yellow)
                                        else
                                          const SizedBox.shrink(),
                                      ],
                                    ),
                                  ),
                                ));
                          },
                        ),
                      ],
                    ),
                  ),
            Positioned(
              bottom: widget.buttonPadding.bottom,
              left: widget.buttonPadding.left,
              right: widget.buttonPadding.right,
              top: widget.buttonPadding.top + 10,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _showAddMedicineBottomSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1E3A8A),
                        shape: RoundedRectangleBorder(
                          //border color and width
                          borderRadius: BorderRadius.circular(
                              10), // Set border radius for rounded corners
                        ),
                        fixedSize:
                            Size(widget.buttonWidth + 145, widget.buttonHeight),
                      ),
                      child: Text(
                        widget.addButtonText,
                        style: GoogleFonts.poppins(
                            fontSize: 18, color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  // and width
                                  borderRadius: BorderRadius.circular(
                                      10), // Set border radius for rounded corners
                                ),
                                fixedSize: Size(
                                  widget.buttonWidth - 40,
                                  widget.buttonHeight,
                                ),
                                backgroundColor:
                                    Color.fromARGB(255, 210, 208, 208)),
                            onPressed: _decreaseDate,
                            child: Text("Prev Day",
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.black) // Text color
                                ) // ,),
                            ),
                        SizedBox(
                          width: 45,
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              fixedSize: Size(
                                  widget.buttonWidth - 40, widget.buttonHeight),
                              backgroundColor:
                                  Color.fromARGB(255, 210, 208, 208),
                            ),
                            onPressed: _increaseDate,
                            child: Text("Next Day",
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.black) // Text color
                                ) // Text color
                            ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
