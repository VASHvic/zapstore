import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:purplebase/purplebase.dart';
import 'package:zapstore/models/app.dart';
import 'package:zapstore/models/nostr_adapter.dart';

part 'app_curation_set.g.dart';

@JsonSerializable()
@DataAdapter([NostrAdapter, AppCurationSetAdapter])
class AppCurationSet extends BaseAppCurationSet
    with DataModelMixin<AppCurationSet> {
  final HasMany<App> apps;

  AppCurationSet(
      {super.id,
      super.pubkey,
      super.createdAt,
      super.content,
      super.tags,
      super.signature,
      required this.apps});
}

mixin AppCurationSetAdapter on Adapter<AppCurationSet> {
  @override
  DeserializedData<AppCurationSet> deserialize(Object? data, {String? key}) {
    final list = data is Iterable ? data : [data as Map];
    for (final e in list) {
      final map = e as Map<String, dynamic>;
      final aValues = (map['tags'] as Iterable).where((t) => t[0] == 'a');
      map['apps'] = aValues.map((e) => e[1].split(':')[2]);
    }
    return super.deserialize(data);
  }
}
