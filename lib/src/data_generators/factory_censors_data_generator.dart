import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';

import 'package:flutter/services.dart' show rootBundle;

class FactoryCensorsDataGenerator {
  static final List<Factory> _factoryCache = [];
  static final List<Site> _siteCache = [];

  static Future<Factory> generateFactory(int seed) async {
    if (_factoryCache.isEmpty) {
      _factoryCache.addAll(await Factory.fromCsv('assets/csv/factories.csv'));
    }
    return _factoryCache.removeAt(Random(seed).nextInt(_factoryCache.length));
  }

  static Future<Site> generateSite(int seed) async {
    if (_siteCache.isEmpty) {
      _siteCache.addAll(await Site.fromCsv('assets/csv/sites.csv'));
    }
    return _siteCache.removeAt(Random(seed).nextInt(_siteCache.length));
  }

  static Future<Product> generateProducts(int seed) async {
    if (_siteCache.isEmpty) {
      _siteCache.addAll(await Site.fromCsv('assets/csv/sites.csv'));
    }
    return _siteCache.removeAt(Random(seed).nextInt(_siteCache.length));
  }

  static Future<Censor> generateCensors(int seed) async {
    if (_siteCache.isEmpty) {
      _siteCache.addAll(await Site.fromCsv('assets/csv/sites.csv'));
    }
    return _siteCache.removeAt(Random(seed).nextInt(_siteCache.length));
  }
}

class Factory {

  final String name;
  List<Site> onboardedSites;
  Map<Site, List<Product>> productsBySite;
  List<ProductionLine> productionLines;

  Factory._(this.name)
      : onboardedSites = [],
        productsBySite = {},
        productionLines = [];

  Factory(this.name, this.onboardedSites, this.productsBySite,
      this.productionLines);

  set _onboardedSites(value) {
    onboardedSites = value;
  }

  set _productsBySite(value) {
    productsBySite = value;
  }

  set _productionLines(value) {
    productionLines = value;
  }

  static Future<List<Factory>> fromCsv(String path) async {
    return CsvToListConverter()
        .convert(await rootBundle.loadString(path))
        .skip(1)
        .map((e) => Factory._(e[0] as String))
        .toList();
  }
}

@immutable
class Site {
  final String name;
  final String field;

  Site(this.name, this.field);

  static Future<List<Site>> fromCsv(String path) async {
    return CsvToListConverter()
        .convert(await rootBundle.loadString(path))
        .skip(1)
        .map((e) => Site(e[0] as String, e[1] as String))
        .toList();
  }
}

class Product {
  final String name;
  final List<ProductComponent> productComponents;

  Product(this.name, this.productComponents);
}

class ProductionLine {
  final ProductComponent producedProductComponent;
  final List<Censor> censors;

  ProductionLine(this.producedProductComponent, this.censors);
}

@immutable
class ProductComponent {
  final String name;

  ProductComponent(this.name);
}

@immutable
class Censor {
  final String name;
  final String recordTemplate;

  Censor(this.name, this.recordTemplate);
}

class RawFile {
  final String nameTemplate;
  final String format;
  List<String> records;

  RawFile._(this.nameTemplate, this.format) : this.records = [];

  RawFile(this.nameTemplate, this.format, this.records);

  set _records(value) {
    records = value;
  }
}
