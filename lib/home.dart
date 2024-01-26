import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:devicelocale/devicelocale.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool textScanning = false;
  XFile? imageFile;
  String scannedText = "";
  String finalText = "";

  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (textScanning) const CircularProgressIndicator(),
              if (!textScanning && imageFile == null)
                Container(
                    width: 300,
                    height: 300,
                    // color: Colors.red,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/iconpng.png'),
                        fit: BoxFit.fill,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    )),
              if (imageFile != null) Image.file(File(imageFile!.path)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.only(top: 10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          backgroundColor: Colors.blueGrey[999],
                          shadowColor: Colors.grey[999],
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                        ),
                        onPressed: () {
                          getImage(ImageSource.gallery);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 5),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.image,
                                size: 30,
                              ),
                              Text(
                                "Galerie",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      )),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.only(top: 10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.red,
                          backgroundColor: Colors.blueGrey[999],
                          shadowColor: Colors.grey[999],
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                        ),
                        onPressed: () {
                          getImage(ImageSource.camera);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 5),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 30,
                              ),
                              Text(
                                "Caméra",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      )),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: textEditingController,
                maxLines: null,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Texte Scanné',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        setState(() {});
        getRecognizedText(pickedImage);
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
      scannedText = "Error occurred while scanning";
      setState(() {});
    }
  }

  void getRecognizedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    RecognizedText recognizedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    scannedText = "";
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = "$scannedText${line.text}\n";
      }
      scannedText = "$scannedText\n";
    }

    final languageIdentifier =
        GoogleMlKit.nlp.languageIdentifier(confidenceThreshold: 0.75);
    final String sourceLangBcpCode =
        await languageIdentifier.identifyLanguage(scannedText);
    final TranslateLanguage sourceLanguage = TranslateLanguage.values
        .firstWhere((element) => element.bcpCode == sourceLangBcpCode);
    await languageIdentifier.close();

    final languages = await Devicelocale.preferredLanguages;
    final String targetLangBcpCode =
        languages!.first.toString().substring(0, 2);
    final TranslateLanguage targetLanguage = TranslateLanguage.values
        .firstWhere((element) => element.bcpCode == targetLangBcpCode);

    if (sourceLangBcpCode.compareTo(targetLangBcpCode) == 0) {
      finalText = "\nSource:\n\n$scannedText";
    } else {
      final onDeviceTranslator = GoogleMlKit.nlp.onDeviceTranslator(
          sourceLanguage: sourceLanguage, targetLanguage: targetLanguage);
      String translatedText =
          await onDeviceTranslator.translateText(scannedText);
      await onDeviceTranslator.close();
      finalText = """\nTraduction [$sourceLangBcpCode => $targetLangBcpCode]:
        \n\n$translatedText\n\n\nSource:\n\n\n$scannedText""";
    }

    textScanning = false;

    textEditingController.text = finalText;

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }
}
