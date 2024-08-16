import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/core.errors.dart';

class HereMapUtils {
  void initialize(
      {required String accessKeyId, required String accessKeySecret}) async {
    // Needs to be called before accessing SDKOptions to load necessary libraries.
    SdkContext.init(IsolateOrigin.main);
    SDKOptions sdkOptions =
        SDKOptions.withAccessKeySecret(accessKeyId, accessKeySecret);

    try {
      await SDKNativeEngine.makeSharedInstance(sdkOptions);
    } on InstantiationException {
      throw Exception("Failed to initialize the HERE SDK.");
    }
  }
}
