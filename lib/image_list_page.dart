import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/download_page.dart';
import 'package:path_provider/path_provider.dart';

class ImageListPage extends StatefulWidget {
  const ImageListPage({super.key});

  @override
  State<ImageListPage> createState() => _ImageListPageState();
}

class _ImageListPageState extends State<ImageListPage> {
  final List<String> imageUrls = [
    // 'https://example.com/image1.jpg',
    // 'https://example.com/image2.jpg',
    // 'https://example.com/image3.jpg',
    'https://github.com/sya-hid/charging_station_flutter_map/raw/master/assets/previews/Screenshot_1699518794.png',
    'https://github.com/sya-hid/charging_station_flutter_map/raw/master/assets/previews/Screenshot_1699518799.png',
    'https://github.com/sya-hid/charging_station_flutter_map/raw/master/assets/previews/Screenshot_1699518809.png',
    'https://github.com/sya-hid/sushi_app_ui/raw/master/assets/previews/Screenshot_1698814160.png',
    'https://github.com/sya-hid/sushi_app_ui/raw/master/assets/previews/Screenshot_1698814168.png',
    'https://github.com/sya-hid/dinosaur-app-ui/raw/master/assets/previews/Screenshot_1685263008.png',
    'https://github.com/sya-hid/dinosaur-app-ui/raw/master/assets/previews/Screenshot_1685263029.png',
    'https://github.com/sya-hid/dinosaur-app-ui/raw/master/assets/previews/Screenshot_1685263012.png',
    'https://github.com/sya-hid/dinosaur-app-ui/raw/master/assets/previews/Screenshot_1685263018.png'
  ];

// Status download untuk setiap gambar
  late List<bool> downloadStatus;

  @override
  void initState() {
    super.initState();
    // Inisialisasi status download
    downloadStatus = List<bool>.filled(imageUrls.length, false);
    _checkDownloadedFiles();
  }

  // Fungsi untuk mengecek keberadaan file
  Future<void> _checkDownloadedFiles() async {
    for (int i = 0; i < imageUrls.length; i++) {
      final fileName = imageUrls[i].split('/').last;
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/$fileName';
      final fileExists = await File(filePath).exists();

      setState(() {
        downloadStatus[i] = fileExists;
      });
    }
  }

  void markAsDownloaded(int index) {
    setState(() {
      downloadStatus[index] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image List'),
      ),
      body: GridView.builder(
        // gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        //   maxCrossAxisExtent: 200.0,
        //   mainAxisSpacing: 10.0,
        //   crossAxisSpacing: 5.0,
        //   // childAspectRatio: 0.7, // Mengatur rasio aspek item
        // ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          childAspectRatio: .6,
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DownloadPage(
                    imageUrl: imageUrls[index],
                    onDownloadComplete: () => markAsDownloaded(index),
                  ),
                ),
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                GridTile(
                  child: CachedNetworkImage(
                    key: ValueKey(imageUrls[index]),
                    imageUrl: imageUrls[index],
                    width: 100,
                    // height: 100,
                    errorWidget: (context, url, error) => const Icon(
                      Icons.image,
                      size: 100,
                    ),
                    progressIndicatorBuilder: (context, url, progress) {
                      return Center(
                        child:
                            CircularProgressIndicator(value: progress.progress),
                      );
                    },
                  ),
                ),
                downloadStatus[index]
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.download_for_offline_sharp,
                        color: Colors.grey),
              ],
            ),
          );
        },
      ),
      // body: ListView.builder(
      //   itemCount: imageUrls.length,
      //   itemBuilder: (context, index) {
      //     return ListTile(
      //       leading: CachedNetworkImage(
      //         key: ValueKey(
      //             imageUrls[index]),
      //         imageUrl: imageUrls[index],
      //         width: 100,
      //         height: 100,
      //         errorWidget: (context, url, error) => const Icon(
      //           Icons.image,
      //           size: 100,
      //         ),
      //         progressIndicatorBuilder: (context, url, progress) {
      //           return Center(
      //             child: CircularProgressIndicator(value: progress.progress),
      //           );
      //         },
      //       ),
      //       title: Text('Image ${index + 1}'),
      //       trailing: downloadStatus[index]
      //           ? const Icon(Icons.check_circle, color: Colors.green)
      //           : const Icon(Icons.download, color: Colors.grey),
      //       onTap: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => DownloadPage(
      //               imageUrl: imageUrls[index],
      //               onDownloadComplete: () => markAsDownloaded(index),
      //             ),
      //           ),
      //         );
      //       },
      //     );
      //   },
      // ),
    );
  }
}
