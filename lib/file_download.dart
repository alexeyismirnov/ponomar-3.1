import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path/path.dart' as path;

import 'dart:io';

class BookButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color color;
  final Icon icon;

  const BookButton(
      {required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
          elevation: 8.0, primary: Colors.grey.shade300, padding: const EdgeInsets.all(10.0)),
      icon: icon,
      label: SizedBox(
          height: 40,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(title, style: Theme.of(context).textTheme.headline6!.copyWith(color: color))
              ])),
      onPressed: onTap);
}

class FileDownload extends StatefulWidget {
  final String url;
  const FileDownload(this.url);

  @override
  _FileDownloadState createState() => _FileDownloadState();
}

class _FileDownloadState extends State<FileDownload> {
  final client = http.Client();
  int _total = 0, _received = 0;
  final List<int> _bytes = [];

  http.StreamedResponse? _response;

  late File file;
  late String title;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    title = 'downloading'.tr().toUpperCase();
    downloadFile();
  }

  Future<void> downloadFile() async {
    _response = await client.send(http.Request('GET', Uri.parse(widget.url)));

    if (_response == null) return;

    _total = _response!.contentLength ?? 0;

    _response!.stream.listen((value) {
      // print("recv $_received");

      setState(() {
        _bytes.addAll(value);
        _received += value.length;
      });
    })
      ..onError((error) {
        isError = true;
        Navigator.pop(context, false);
      })
      ..onDone(() async {
        if (isError) return;

        setState(() {
          title = "extracting".tr().toUpperCase();
        });

        final filename = path.basename(widget.url);
        final file = File("${GlobalPath.documents}/$filename");
        await file.writeAsBytes(_bytes);

        try {
          await ZipFile.extractToDirectory(
              zipFile: file, destinationDir: Directory(GlobalPath.documents));
        } catch (e) {
          print(e);
        }

        Navigator.pop(context, true);
      });
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
      contentPadding: const EdgeInsets.all(5.0),
      content: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          height: 200,
          padding: const EdgeInsets.all(10.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
                    child: Text(title, style: Theme.of(context).textTheme.button)),
                if (_total == 0)
                  const Center(child: CircularProgressIndicator())
                else
                  LinearProgressIndicator(
                    value: _received / _total,
                  ),
                const Spacer(),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  BookButton(
                      title: "CANCEL".tr(),
                      icon: const Icon(Icons.close, size: 40.0, color: Colors.red),
                      color: Colors.red,
                      onTap: () {
                        client.close();
                        if (_response == null) Navigator.pop(context, false);
                      })
                ])
              ])));
}
