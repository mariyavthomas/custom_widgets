// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicineTile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicineEntryAdapter extends TypeAdapter<MedicineEntry> {
  @override
  final int typeId = 0;

  @override
  MedicineEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicineEntry(
      name: fields[0] as String,
      addedOn: fields[1] as DateTime,
      isKept: fields[2] as bool,
      isMarkedForRemoval: fields[3] as bool,
      isNew: fields[4] as bool,
      markedRemovalTime: fields[5] as DateTime?,
      showKeepRemoveAlways: fields[6] as bool,
      lastKeptOrRemovedDate: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MedicineEntry obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.addedOn)
      ..writeByte(2)
      ..write(obj.isKept)
      ..writeByte(3)
      ..write(obj.isMarkedForRemoval)
      ..writeByte(4)
      ..write(obj.isNew)
      ..writeByte(5)
      ..write(obj.markedRemovalTime)
      ..writeByte(6)
      ..write(obj.showKeepRemoveAlways)
      ..writeByte(7)
      ..write(obj.lastKeptOrRemovedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
