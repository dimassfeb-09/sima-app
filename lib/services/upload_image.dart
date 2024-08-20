import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class UploadPhotosResponse {
  final String imageUrl;
  final bool status;

  UploadPhotosResponse({required this.imageUrl, required this.status});

  factory UploadPhotosResponse.fromJson(Map<String, dynamic> json) {
    return UploadPhotosResponse(
      imageUrl: json['data']['image_url'],
      status: json['status'],
    );
  }
}

class PredictFireResponse {
  final String prediction;
  final double probability;
  final bool status;

  PredictFireResponse({
    required this.prediction,
    required this.probability,
    required this.status,
  });

  factory PredictFireResponse.fromJson(Map<String, dynamic> json) {
    return PredictFireResponse(
      prediction: json['data']['prediction'],
      probability: json['data']['probability'],
      status: json['status'],
    );
  }
}

class UploadImage {
  Future<PredictFireResponse?> postPredictFire(String imagePath) async {
    const String url = 'https://fire-detection.fly.dev/check_fire_detection';

    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(File(imagePath).path, contentType: DioMediaType('image', 'png')),
      });

      Dio dio = Dio();
      Response response = await dio.post(url, data: formData);

      if (response.statusCode == 200) {
        final predictFireResponse = PredictFireResponse.fromJson(response.data);
        print('Prediction: ${predictFireResponse.prediction}');
        return predictFireResponse;
      } else {
        print('Failed to upload file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while uploading file: $e');
    }
    return null;
  }

  Future<UploadPhotosResponse?> postUploadPhotos(String imagePath) async {
    const String url = 'https://fire-detection.fly.dev/upload_images';

    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(File(imagePath).path, contentType: DioMediaType('image', 'png')),
      });

      Dio dio = Dio();
      Response response = await dio.post(url, data: formData);

      if (response.statusCode == 200) {
        final uploadPhotosResponse = UploadPhotosResponse.fromJson(response.data);
        return uploadPhotosResponse;
      }

      return null;
    } catch (e) {
      throw ErrorDescription("Failted to Upload Image $e");
    }
  }
}
