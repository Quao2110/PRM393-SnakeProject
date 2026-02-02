import 'package:flutter/material.dart';

class Racer {
  final String id;
  final String name;
  final Color color;
 // final String imagePath; // Đường dẫn ảnh trong assets

  Racer({
    required this.id,
    required this.name,
    required this.color,
   // required this.imagePath,
  });

  // gọi Racer.dummyRacers là có danh sách 3 xe.
  static List<Racer> get dummyRacers => [
    Racer(
      id: '1',
      name: 'RẮN ĐỎ LÒM',
      color: Colors.redAccent,
     // imagePath:
       //   'assets/images/car_red.png', // Nhớ kiếm ảnh đặt tên đúng như này
    ),
    Racer(
      id: '2',
      name: 'RẮN XANH THÍCH ANH',
      color: Colors.blueAccent,
     // imagePath: 'assets/images/car_blue.png',
    ),
    Racer(
      id: '3',
      name: 'RẮN XANH LÁ NÉ RA',
      color: Colors.greenAccent,
     // imagePath: 'assets/images/car_green.png',
    ),
  ];
}
