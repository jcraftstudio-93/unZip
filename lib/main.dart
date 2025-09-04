import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_manager.dart';
import 'unzip.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AdManager().initialize();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZIP Extractor',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: const ZipHomeScreen(),
    );
  }
}

enum Language { en, ko }

class ZipHomeScreen extends StatefulWidget {
  const ZipHomeScreen({super.key});

  @override
  State<ZipHomeScreen> createState() => _ZipHomeScreenState();
}

class _ZipHomeScreenState extends State<ZipHomeScreen> {
  List<String> extractedFiles = [];
  Language currentLanguage = Language.ko;

  void toggleLanguage() {
    setState(() {
      currentLanguage = currentLanguage == Language.en ? Language.ko : Language.en;
    });
  }

  String t(String en, String ko) {
    return currentLanguage == Language.en ? en : ko;
  }

  Future<void> _handleZipExtraction() async {
    final files = await Unzipper.pickAndExtractZipFile();
    if (files != null) {
      setState(() {
        extractedFiles = files;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('Extraction completed!', '압축 해제 완료!'))),
      );
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(t('Exit the app?', '앱을 종료하시겠습니까?')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(t('Cancel', '취소')),
              ),
              TextButton(
                onPressed: () {
                  AdManager().showInterstitialAd();
                  Future.delayed(const Duration(milliseconds: 500), () {
                    exit(0);
                  });
                },
                child: Text(t('Exit', '종료')),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t('ZIP Extractor', 'ZIP 압축 해제기')),
          actions: [
            IconButton(
              icon: const Icon(Icons.language),
              tooltip: t('Switch to Korean', '영어로 보기'),
              onPressed: toggleLanguage,
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleZipExtraction,
              child: Text(t('Select ZIP file and extract', 'ZIP 파일 선택 및 압축 해제')),
            ),
            const SizedBox(height: 16),
            Text(
              t('Extracted files:', '압축 해제된 파일 목록:'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: extractedFiles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(extractedFiles[index]),
                  );
                },
              ),
            ),
            SizedBox(
              height: 50,
              child: AdManager().getBannerWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
