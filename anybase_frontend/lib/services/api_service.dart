import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

    static const String baseUrl = "http://10.0.2.2:8080/api"; //
    //FOR PHYSICAL TESTING: change the 10.0.2.2  adress with the IPv4 address which results from running ipconfig in cmd(ex. 192.169.1.153
    //DEFAULT: 10.0.2.2 = default local host alias for emulator

    static Future<Map<String, dynamic>> adaptContent(String text, String profile) async{
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/adapt'),
          headers: {'Content-type': 'application/json'},
          body: jsonEncode({
            'text': text,
            'profile': profile}),
        );
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);

          return {
            'title': data['title'] ?? profile,
            'cards': List<String>.from(data['cards'] ?? []),
          };
        } else {
          throw Exception('Server errror: ${response.statusCode}');
        }
      }catch(e) {
            throw Exception('Network error; Cannot connect to the server');
      }

      }
    }
