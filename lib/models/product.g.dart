// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 1;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      id: fields[0] as String,
      name: fields[1] as String,
      quantity: fields[2] as int,
      liquidQuantity: fields[3] as double,
      type: fields[4] as ProductType,
      expiryDate: fields[5] as DateTime,
      description: fields[6] as String?,
      isExpired: fields[7] as bool,
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.liquidQuantity)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.expiryDate)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.isExpired)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProductTypeAdapter extends TypeAdapter<ProductType> {
  @override
  final int typeId = 2;

  @override
  ProductType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProductType.solid;
      case 1:
        return ProductType.liquid;
      default:
        return ProductType.solid;
    }
  }

  @override
  void write(BinaryWriter writer, ProductType obj) {
    switch (obj) {
      case ProductType.solid:
        writer.writeByte(0);
        break;
      case ProductType.liquid:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
