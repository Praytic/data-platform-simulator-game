import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';

import 'package:flutter/services.dart' show rootBundle;

class FactoryCensorsDataGenerator {
  static final List<Factory> _factoryCache = [];
  static final List<Site> _siteCache = [];
  static final List<Censor> _censorCache = [];
  static final List<Product> _productCache = [];

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
    if (_productCache.isEmpty) {
      _productCache.addAll(await Product.fromCsv('assets/csv/products.csv'));
    }
    return _productCache.removeAt(Random(seed).nextInt(_productCache.length));
  }

  static Future<Censor> generateCensors(int seed) async {
    if (_censorCache.isEmpty) {
      _censorCache.addAll(await Censor.fromCsv('assets/csv/censors.csv'));
    }
    return _censorCache.removeAt(Random(seed).nextInt(_censorCache.length));
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

  Product.productComponentNames(this.name, List<String> productComponentNames) :
        productComponents = productComponentNames.map((e) =>
            ProductComponent(e)).toList();

  static Future<List<Product>> fromCsv(String path) async {
    Map<String, List<String>> productComponentsByProduct = {};
    var rawRecords = CsvToListConverter()
        .convert(await rootBundle.loadString(path))
        .skip(1);
    for (var rawRecord in rawRecords) {
      productComponentsByProduct.putIfAbsent(rawRecord[0] as String, () => [])
          .add(rawRecord[1] as String);
    }
    return productComponentsByProduct
        .map((key, value) =>
        MapEntry(key, Product.productComponentNames(key, value)))
        .values
        .toList();
  }
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

  static Future<List<Censor>> fromCsv(String path) async {
    return CsvToListConverter()
        .convert(await rootBundle.loadString(path))
        .skip(1)
        .map((e) => Censor(e[0] as String, e[1] as String))
        .toList();
  }
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
