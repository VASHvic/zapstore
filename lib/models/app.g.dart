// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app.dart';

// **************************************************************************
// AdapterGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin _$AppAdapter on Adapter<App> {
  static final Map<String, RelationshipMeta> _kAppRelationshipMetas = {
    'releases': RelationshipMeta<Release>(
      name: 'releases',
      inverseName: 'app',
      type: 'releases',
      kind: 'HasMany',
      instance: (_) => (_ as App).releases,
    )
  };

  @override
  Map<String, RelationshipMeta> get relationshipMetas => _kAppRelationshipMetas;

  @override
  App deserializeLocal(map, {String? key}) {
    map = transformDeserialize(map);
    return internalWrapStopInit(() => App.fromJson(map), key: key);
  }

  @override
  Map<String, dynamic> serializeLocal(model, {bool withRelationships = true}) {
    final map = _$AppToJson(model);
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _appsFinders = <String, dynamic>{};

class $AppAdapter = Adapter<App>
    with _$AppAdapter, NostrAdapter<App>, CoolAdapter;

final appsAdapterProvider = Provider<Adapter<App>>(
    (ref) => $AppAdapter(ref, InternalHolder(_appsFinders)));

extension AppAdapterX on Adapter<App> {
  NostrAdapter<App> get nostrAdapter => this as NostrAdapter<App>;
  CoolAdapter get coolAdapter => this as CoolAdapter;
}

extension AppRelationshipGraphNodeX on RelationshipGraphNode<App> {
  RelationshipGraphNode<Release> get releases {
    final meta = _$AppAdapter._kAppRelationshipMetas['releases']
        as RelationshipMeta<Release>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

App _$AppFromJson(Map<String, dynamic> json) => App()
  ..id = json['id']
  ..pubkey = json['pubkey'] as String
  ..createdAt = DateTime.parse(json['createdAt'] as String)
  ..content = json['content'] as String
  ..kind = json['kind'] as int
  ..tags = (json['tags'] as List<dynamic>)
      .map((e) => (e as List<dynamic>).map((e) => e as String).toList())
      .toList()
  ..signature = json['signature'] as String?
  ..releases =
      HasMany<Release>.fromJson(json['releases'] as Map<String, dynamic>);

Map<String, dynamic> _$AppToJson(App instance) => <String, dynamic>{
      'id': instance.id,
      'pubkey': instance.pubkey,
      'createdAt': instance.createdAt.toIso8601String(),
      'content': instance.content,
      'kind': instance.kind,
      'tags': instance.tags,
      'signature': instance.signature,
      'releases': instance.releases,
    };
