// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiaryAdapter extends TypeAdapter<Diary> {
  @override
  final int typeId = 0;

  @override
  Diary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Diary(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      type: fields[2] as String,
      rawContent: fields[3] as String,
      aiContent: fields[4] as String?,
      mood: fields[5] as String?,
      style: fields[6] as String,
      photos: (fields[7] as List).cast<String>(),
      location: fields[8] as String?,
      tags: (fields[9] as List).cast<String>(),
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime?,
      isEdited: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Diary obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.rawContent)
      ..writeByte(4)
      ..write(obj.aiContent)
      ..writeByte(5)
      ..write(obj.mood)
      ..writeByte(6)
      ..write(obj.style)
      ..writeByte(7)
      ..write(obj.photos)
      ..writeByte(8)
      ..write(obj.location)
      ..writeByte(9)
      ..write(obj.tags)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.isEdited);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
