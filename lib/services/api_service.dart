import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static Future<String?> uploadImageToCloudinary(File imageFile) async {
    final cloudName = 'dlklcpwse';
    final uploadPreset = 'flutter_uploads';

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final respData = await response.stream.bytesToString();
      final jsonData = json.decode(respData);
      return jsonData['secure_url'];
    } else {
      print('Upload failed with status ${response.statusCode}');
      return null;
    }
  }
}
