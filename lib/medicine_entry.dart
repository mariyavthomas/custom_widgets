class MedicineEntry {
  int? id;
  String name;
  DateTime addedOn;
  bool isKept;
  bool isMarkedForRemoval;
  bool isNew;
  DateTime? markedRemovalTime;
  bool showKeepRemoveAlways;
  DateTime? lastKeptOrRemovedDate;
  String? status;
  String? dosage; // Added dateKey property

  MedicineEntry({
    this.id,
    required this.name,
    required this.addedOn,
    this.isKept = false,
    this.isMarkedForRemoval = false,
    this.isNew = true,
    this.markedRemovalTime,
    this.showKeepRemoveAlways = false,
    this.lastKeptOrRemovedDate,
    this.status = 'Not Reviewed',
    this.dosage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': addedOn.toIso8601String(),
      'status': status,
      'isKept': isKept ? 1 : 0,
      'isMarkedForRemoval': isMarkedForRemoval ? 1 : 0,
      'isNew': isNew ? 1 : 0,
      'showKeepRemoveAlways': showKeepRemoveAlways ? 1 : 0,
      'markedRemovalTime': markedRemovalTime?.toIso8601String(),
      'lastKeptOrRemovedDate': lastKeptOrRemovedDate?.toIso8601String(),
    
      'dosage': dosage,};
  }

  static MedicineEntry fromMap(Map<String, dynamic> map) {
    return MedicineEntry(
      id: map['id'],
      name: map['name'],
      addedOn: DateTime.parse(map['date']),
      status: map['status'],
      isKept: map['isKept'] == 1,
      isMarkedForRemoval: map['isMarkedForRemoval'] == 1,
      isNew: map['isNew'] == 1,
      showKeepRemoveAlways: map['showKeepRemoveAlways'] == 1,
      markedRemovalTime: map['markedRemovalTime'] != null
          ? DateTime.parse(map['markedRemovalTime'])
          : null,
      lastKeptOrRemovedDate: map['lastKeptOrRemovedDate'] != null
          ? DateTime.parse(map['lastKeptOrRemovedDate'])
          : null,
      dosage: map['dosage'],
    );
  }
}