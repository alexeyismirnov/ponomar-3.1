import 'package:json_annotation/json_annotation.dart';
import 'globals.dart';

part 'church_day.g.dart';

enum FeastType {
  @JsonValue("none")
  none,
  @JsonValue("noSign")
  noSign,
  @JsonValue("sixVerse")
  sixVerse,
  @JsonValue("doxology")
  doxology,
  @JsonValue("polyeleos")
  polyeleos,
  @JsonValue("vigil")
  vigil,
  @JsonValue("great")
  great
}

extension FeastTypeExt on FeastType {
  String get name =>
      ["none", "noSign", "sixVerse", "doxology", "polyeleos", "vigil", "great"][index];
}

@JsonSerializable()
class ChurchDay {
  @JsonKey(name: 'feastName', defaultValue: '')
  String name;

  @JsonKey(name: 'feastType')
  FeastType type;

  @JsonKey(fromJson: _fromJson)
  DateTime? date;

  @JsonKey(name: 'reading')
  String? reading;

  @JsonKey(name: 'saint')
  String? comment;

  factory ChurchDay.fromJson(Map<String, dynamic> json) {
    return _$ChurchDayFromJson(json);
  }

  ChurchDay(this.name, this.type, {this.date, this.reading, this.comment});

  @override
  String toString() {
    return "name: $name type ${type.name} date ${date ?? ""} reading $reading, comment ${comment ?? ""} \n";
  }
}

DateTime? _fromJson(String? date) => JSON.dateParser(date);

typedef Saint = ChurchDay;

/// A forefeast / afterfeast / apodosis day linked back to its major feast.
class FeastPeriod {
  /// One of `forefeast`, `afterfeast`, `apodosis`.
  final String kind;

  /// Calendar feast key, e.g. `transfiguration`.
  final String feast;

  /// Date of the feast itself (for navigation).
  final DateTime feastDate;

  const FeastPeriod({required this.kind, required this.feast, required this.feastDate});
}
