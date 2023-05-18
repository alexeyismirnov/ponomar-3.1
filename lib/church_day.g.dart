// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'church_day.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChurchDay _$ChurchDayFromJson(Map<String, dynamic> json) => ChurchDay(
      json['feastName'] as String? ?? '',
      $enumDecode(_$FeastTypeEnumMap, json['feastType']),
      date: _fromJson(json['date'] as String?),
      reading: json['reading'] as String?,
      comment: json['saint'] as String?,
    );

Map<String, dynamic> _$ChurchDayToJson(ChurchDay instance) => <String, dynamic>{
      'feastName': instance.name,
      'feastType': _$FeastTypeEnumMap[instance.type]!,
      'date': instance.date?.toIso8601String(),
      'reading': instance.reading,
      'saint': instance.comment,
    };

const _$FeastTypeEnumMap = {
  FeastType.none: 'none',
  FeastType.noSign: 'noSign',
  FeastType.sixVerse: 'sixVerse',
  FeastType.doxology: 'doxology',
  FeastType.polyeleos: 'polyeleos',
  FeastType.vigil: 'vigil',
  FeastType.great: 'great',
};
