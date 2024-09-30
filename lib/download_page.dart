import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadPage extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onDownloadComplete;

  const DownloadPage(
      {super.key, required this.imageUrl, required this.onDownloadComplete});

  Future<void> _downloadImage(BuildContext context) async {
    // Minta izin untuk menyimpan ke storage
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final directory = await getExternalStorageDirectory();
      final fileName = imageUrl.split('/').last;
      final file = File('${directory!.path}/$fileName');

      await file.writeAsBytes(response.bodyBytes);

      // Tandai gambar sebagai diunduh
      onDownloadComplete();
      log(file.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image downloaded to ${file.path}')),
      );
    } catch (e) {
      // print('Gagal mengunduh gambar: $e');
      if (await reqPermission(Permission.storage) ==
          false | await Permission.photos.request().isDenied) {
        showAlertDialog(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Image'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CachedNetworkImage(
              key: ValueKey(imageUrl), // Tambahkan key unik untuk setiap gambar

              imageUrl: imageUrl,
              width: 250,
              // height: 100,
              errorWidget: (context, url, error) => const Icon(
                Icons.image,
                size: 100,
              ),
              progressIndicatorBuilder: (context, url, progress) {
                return Center(
                  child: CircularProgressIndicator(value: progress.progress),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _downloadImage(context),
              child: const Text('Download'),
            ),
          ],
        ),
      ),
    );
  }
}

showAlertDialog(context) => showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Permission Denied'),
          // content: const Text('Allow Access to Camera and Gallery'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('Settings'),
            ),
          ],
        );
      },
    );

Future<bool> reqPermission(Permission permission) async {
  AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
  log(build.version.sdkInt.toString());
  if (build.version.sdkInt >= 30) {
    var storageManagr = await Permission.manageExternalStorage.request();
    if (storageManagr.isGranted) {
      debugPrint('storageManagr isGranted');
      return true;
    } else {
      debugPrint('storageManagr isDenied');
      return false;
    }
  } else {
    if (await permission.isGranted) {
      debugPrint('isGranted');
      return true;
    } else {
      var result = await permission.request();
      if (result.isGranted) {
        debugPrint('result isGeanted');
        return true;
      } else {
        debugPrint('result isDenied');
        return false;
      }
    }
  }
}
