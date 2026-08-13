import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class UploadService {
  static const String _cloudName = 'dtneftgss';
  static const String _uploadPreset = 'upload_app_profile_image';

  Future<String> uploadImage(File imageFile) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    var request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = _uploadPreset;
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var data = jsonDecode(responseData);

    if (response.statusCode == 200) {
      return data['secure_url'] as String;
    } else {
      throw Exception('Cloudinary upload failed: ${data['error']['message']}');
    }
  }
}
