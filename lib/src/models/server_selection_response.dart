///
class ServerSelectionResponse {
  ///
  ServerSelectionResponse({this.client, this.targets});

  ///
  ServerSelectionResponse.fromJson(Map<String, dynamic> json) {
    client = json['client'] != null
        ? Client.fromJson(json['client'] as Map<String, dynamic>)
        : null;
    targets = <Targets>[];
    if (json['targets'] != null) {
      for (final v in json['targets'] as List<Map<String, dynamic>>) {
        targets!.add(Targets.fromJson(v));
      }
    }
  }

  ///
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (client != null) {
      data['client'] = client!.toJson();
    }
    if (targets != null) {
      data['targets'] = targets!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  ///
  late final Client? client;

  ///
  late final List<Targets>? targets;
}

///
class Client {
  ///
  Client({
    this.ip,
    this.asn,
    this.isp,
    this.location,
  });

  ///
  Client.fromJson(Map<String, dynamic> json) {
    ip = json['ip'] as String?;
    asn = json['asn'] as String?;
    isp = json['isp'] as String?;
    location = json['location'] != null
        ? Location.fromJson(json['location'] as Map<String, dynamic>)
        : null;
  }

  ///
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ip'] = ip;
    data['asn'] = asn;
    data['isp'] = isp;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    return data;
  }

  ///

  late final String? ip;

  ///
  late final String? asn;

  ///
  late final String? isp;

  ///
  late final Location? location;
}

////
class Location {
  ///
  Location({
    this.city,
    this.country,
  });

  ///
  Location.fromJson(Map<String, dynamic> json) {
    city = json['city'] as String?;
    country = json['country'] as String?;
  }

  ///
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['city'] = city;
    data['country'] = country;
    return data;
  }

  ///
  late final String? city;

  ///
  late final String? country;
}

///
class Targets {
  ///
  Targets.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String?;
    url = json['url'] as String?;
    location = json['location'] != null
        ? Location.fromJson(json['location'] as Map<String, dynamic>)
        : null;
  }

  ///
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['url'] = url;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    return data;
  }

  ///
  late final String? name;

  ///
  late final String? url;

  ///
  late final Location? location;
}
