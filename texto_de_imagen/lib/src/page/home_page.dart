import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? imagen;
  String texto = '';
  List<TextBlock>? blocks;

  Future obtenerImagen(int numero) async {
    final image;
    try {
      if (numero == 1) {
        image = await ImagePicker().pickImage(source: ImageSource.gallery);
      } else {
        image = await ImagePicker().pickImage(source: ImageSource.camera);
      }

      if (image == null) return;
      final imagenTemporal = File(image.path);
      setState(() => imagen = imagenTemporal);
      obtenerTexto(imagen);
    } on PlatformException catch (e) {
      print('Error al traer la imagen $e');
    }
  }

  Future obtenerTexto(File? imagen2) async {
    InputImage imagen = InputImage.fromFile(imagen2!);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(imagen);
    texto = recognizedText.text;
    blocks = recognizedText.blocks;
    for (var e in blocks!) {
      log('bloque');
      for (var i in e.lines) {
        log('linea');
        print(i.text);
      }
    }
    log(texto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tomar textos de una imagen'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  child: (imagen != null)
                      ? Image.file(
                          imagen!,
                          height: 300,
                          width: 300,
                        )
                      : const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 40,
                        )),
              TextButton(
                onPressed: () {
                  obtenerImagen(1);
                },
                child: const Text('Seleccionar imagen'),
              ),
              TextButton(
                onPressed: () {
                  obtenerImagen(2);
                },
                child: const Text('Tomar imagen'),
              ),
              IconButton(
                onPressed: () async {
                  setState(() {});
                },
                icon: const Icon(
                  Icons.refresh,
                  size: 35,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ...blocks!.map((e) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all()
                  ),
                  child: Text(e.text));
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
