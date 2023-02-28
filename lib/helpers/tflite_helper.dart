import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:asl_live_detection_owned/models/result.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';


import 'app_helper.dart';

class TFLiteHelper {

  static StreamController<List<Result>> tfLiteResultsController = new StreamController.broadcast();
  static List<Result> _outputs = [];
  static var modelLoaded = false;

  static Future<Future<String?>> loadModel() async{
    AppHelper.log("loadModel", "Loading model..");

    return Tflite.loadModel(
      model: "assets/ASL_classifier.tflite",
      labels: "assets/labels.txt",
    );
  }

  static classifyImage(CameraImage image) async {

    await Tflite.runModelOnFrame(
        threshold: 0.1,     // defaults to 0.1
        asynch: true ,
        imageHeight: 200,
        imageWidth: 200,
        bytesList: image.planes.map((plane) {
              return plane.bytes  ;
            }).toList() ,
            numResults: 1) //5
        .then((value) {

      if (value!.isNotEmpty) {
        AppHelper.log("classifyImage", "Results loaded. ${value.length}");

        //Clear previous results
        _outputs.clear();

        value.forEach((element) {
          _outputs.add(Result(
              element['confidence'], element['index'], element['label']));

          AppHelper.log("classifyImage",
              "${element['confidence']} , ${element['index']}, ${element['label']}");
        });
      }

      //Sort results according to most confidence
      _outputs.sort((a, b) => a.confidence.compareTo(b.confidence));

      //Send results
      tfLiteResultsController.add(_outputs);
    });
  }

  static void disposeModel(){
    Tflite.close();
    tfLiteResultsController.close();
  }
}
