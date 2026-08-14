import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:managementt/config.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {

  static const String _versionPath = "/app/version";

  /// Returns `true` when [latest] is greater than [current].
  ///
  /// Accepts `MAJOR.MINOR.PATCH` with optional build/metadata like `1.2.3+4`.
  /// Non-numeric suffixes are ignored (e.g. `1.2.3-beta` -> `1.2.3`).
  static bool _isNewerVersion(String latest, String current) {
    List<int> parseParts(String v) {
      final cleaned = v.split('+').first.split('-').first;
      final parts = cleaned.split('.');
      return List<int>.generate(3, (i) {
        if (i >= parts.length) return 0;
        return int.tryParse(parts[i]) ?? 0;
      });
    }

    final l = parseParts(latest);
    final c = parseParts(current);

    for (int i = 0; i < 3; i++) {
      if (l[i] != c[i]) return l[i] > c[i];
    }
    return false;
  }

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      String currentVersion = packageInfo.version;

      final response = await http
          .get(
            Uri.parse('${Config.baseUrl}$_versionPath'),
            headers: const {"Accept": "application/json"},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException(
            "Invalid update response: expected JSON object",
          );
        }

        final String latestVersion = (decoded["latestVersion"] ?? "")
            .toString();
        final bool forceUpdate = decoded["forceUpdate"] == true;
        final String apkUrl = (decoded["apkUrl"] ?? "").toString();

        if (latestVersion.isEmpty || apkUrl.isEmpty) {
          throw const FormatException(
            "Invalid update response: missing latestVersion/apkUrl",
          );
        }

        if (_isNewerVersion(latestVersion, currentVersion)) {
          if (!context.mounted) return;

          showDialog(
            context: context,
            barrierDismissible: !forceUpdate,
            builder: (_) => AlertDialog(
              title: const Text("Update Available"),
              content: const Text("Please update app to continue."),
              actions: [
                if (!forceUpdate)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Later"),
                  ),

                TextButton(
                  onPressed: () async {
                    await launchUrl(
                      Uri.parse(apkUrl),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  child: const Text("Update"),
                ),
              ],
            ),
          );
        }
      } else {
        debugPrint(
          "Update check failed: HTTP ${response.statusCode} ${response.reasonPhrase}",
        );
      }
    } catch (e) {
      debugPrint("Update check error: $e");
    }
  }
}
