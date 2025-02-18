import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Loader Example'),
      ),
      body: Center(
        child: FutureBuilder<Uint8List>(
          future: loadFromAsset(
              'assets/sample_image.jpg'), // Replace with your asset path
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // Display loaded image
              return Image.memory(snapshot.data!);
            } else if (snapshot.hasError) {
              return const Text('Error loading asset');
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}

Future<Uint8List> loadFromAsset(String key) async {
  final ByteData byteData = await rootBundle.load(key);
  return byteData.buffer.asUint8List();
}
