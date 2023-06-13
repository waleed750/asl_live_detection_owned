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

  static Future<String?> loadModel() async{
    AppHelper.log("loadModel", "Loading model..");

    return await Tflite.loadModel(
      model: "assets/converted_tflite_(2).tflite",
      labels: "assets/labels_converted_tflite_(2).txt",
    );
  }

  static classifyImage(CameraImage image) async {

    await Tflite.runModelOnFrame(
        threshold: 0.2,     // defaults to 0.1
        asynch: true ,
        imageHeight: image.height,
        imageWidth: image.width,
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

/*
PlatformException (PlatformException(Failed to load model, flutter_assets/assets/teachable signlanguage.tflite, java.io.FileNotFoundException: flutter_assets/assets/teachable signlanguage.tflite
	at android.content.res.AssetManager.nativeOpenAssetFd(Native Method)
	at android.content.res.AssetManager.openFd(AssetManager.java:880)
	at sq.flutter.flutter_tflite.TflitePlugin.loadModel(TflitePlugin.java:245)
	at sq.flutter.flutter_tflite.TflitePlugin.onMethodCall(TflitePlugin.java:132)
	at io.flutter.plugin.common.MethodChannel$IncomingMethodCallHandler.onMessage(MethodChannel.java:258)
	at io.flutter.embedding.engine.dart.DartMessenger.invokeHandler(DartMessenger.java:295)
	at io.flutter.embedding.engine.dart.DartMessenger.lambda$dispatchMessageToQueue$0$io-flutter-embedding-engine-dart-DartMessenger(DartMessenger.java:322)
	at io.flutter.embedding.engine.dart.DartMessenger$$ExternalSyntheticLambda0.run(Unknown Source:12)
	at android.os.Handler.handleCallback(Handler.java:899)
	at android.os.Handler.dispatchMessage(Handler.java:100)
	at android.os.Looper.loop(Looper.java:238)
	at android.app.ActivityThread.main(ActivityThread.java:7853)
	at java.lang.reflect.Method.invoke(Native Method)
	at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:492)
	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:984)
, null))
loading

*/