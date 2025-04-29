class MedicineEntry {
  int? id;
  String name;
  DateTime addedOn;
  bool isNew;
  bool isKept;
  bool isMarkedForRemoval;
  bool showKeepRemoveAlways;
  DateTime? markedRemovalTime;
  DateTime? lastKeptOrRemovedDate;
  String status;

  MedicineEntry({
    this.id,
    required this.name,
    required this.addedOn,
    this.isNew = true,
    this.isKept = false,
    this.isMarkedForRemoval = false,
    this.showKeepRemoveAlways = false,
    this.markedRemovalTime,
    this.lastKeptOrRemovedDate,
    this.status = "New",
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'addedOn': addedOn.toIso8601String(),
        'isNew': isNew ? 1 : 0,
        'isKept': isKept ? 1 : 0,
        'isMarkedForRemoval': isMarkedForRemoval ? 1 : 0,
        'showKeepRemoveAlways': showKeepRemoveAlways ? 1 : 0,
        'markedRemovalTime': markedRemovalTime?.toIso8601String(),
        'lastKeptOrRemovedDate': lastKeptOrRemovedDate?.toIso8601String(),
        'status': status,
      };

  factory MedicineEntry.fromJson(Map<String, dynamic> json) => MedicineEntry(
        id: json['id'],
        name: json['name'],
        addedOn: DateTime.parse(json['addedOn']),
        isNew: json['isNew'] == 1,
        isKept: json['isKept'] == 1,
        isMarkedForRemoval: json['isMarkedForRemoval'] == 1,
        showKeepRemoveAlways: json['showKeepRemoveAlways'] == 1,
        markedRemovalTime: json['markedRemovalTime'] != null
            ? DateTime.parse(json['markedRemovalTime'])
            : null,
        lastKeptOrRemovedDate: json['lastKeptOrRemovedDate'] != null
            ? DateTime.parse(json['lastKeptOrRemovedDate'])
            : null,
        status: json['status'],
      );
}
