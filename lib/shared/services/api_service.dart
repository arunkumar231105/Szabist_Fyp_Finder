import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String _base = 'http://10.0.2.2:3001/api';
const Map<String, String> _jsonHeaders = {'Content-Type': 'application/json'};

Future<Map<String, String>> _authHeaders() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token') ?? '';

  return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
}

Map<String, dynamic> _decode(http.Response res) {
  return jsonDecode(res.body) as Map<String, dynamic>;
}

void _check(http.Response res) {
  if (res.statusCode >= 400) {
    final body = _decode(res);
    throw Exception(body['message'] ?? 'API error ${res.statusCode}');
  }
}

class AuthApi {
  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> data,
  ) async {
    final res = await http.post(
      Uri.parse('$_base/auth/register'),
      headers: _jsonHeaders,
      body: jsonEncode(data),
    );

    _check(res);
    return _decode(res)['data'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$_base/auth/login'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    );

    _check(res);
    return _decode(res)['data'] as Map<String, dynamic>;
  }
}

class StudentsApi {
  static final _ep = Uri.parse('$_base/students');

  static Future<List<Map<String, dynamic>>> getAll({
    String? department,
    String? batch,
  }) async {
    final query = <String, String>{};
    if (department != null) query['department'] = department;
    if (batch != null) query['batch'] = batch;

    final uri = query.isEmpty ? _ep : _ep.replace(queryParameters: query);
    final res = await http.get(uri, headers: await _authHeaders());
    _check(res);
    return List<Map<String, dynamic>>.from(_decode(res)['data'] as List);
  }

  static Future<Map<String, dynamic>> getMe() async {
    final res = await http.get(
      Uri.parse('$_base/students/me'),
      headers: await _authHeaders(),
    );
    _check(res);
    return _decode(res)['data'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getById(int id) async {
    final res = await http.get(
      Uri.parse('$_base/students/$id'),
      headers: await _authHeaders(),
    );
    _check(res);
    return _decode(res)['data'] as Map<String, dynamic>;
  }

  static Future<int> create(Map<String, dynamic> data) async {
    final res = await http.post(
      _ep,
      headers: await _authHeaders(),
      body: jsonEncode(data),
    );
    _check(res);
    return (_decode(res)['data'] as Map<String, dynamic>)['id'] as int;
  }

  static Future<void> update(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$_base/students/$id'),
      headers: await _authHeaders(),
      body: jsonEncode(data),
    );
    _check(res);
  }

  static Future<void> delete(int id) async {
    final res = await http.delete(
      Uri.parse('$_base/students/$id'),
      headers: await _authHeaders(),
    );
    _check(res);
  }
}

class IdeasApi {
  static final _ep = Uri.parse('$_base/ideas');

  static Future<List<Map<String, dynamic>>> getAll({String? status}) async {
    final uri = status == null
        ? _ep
        : _ep.replace(queryParameters: {'status': status});
    final res = await http.get(uri, headers: await _authHeaders());
    _check(res);
    return List<Map<String, dynamic>>.from(_decode(res)['data'] as List);
  }

  static Future<List<Map<String, dynamic>>> getMy() async {
    final res = await http.get(
      Uri.parse('$_base/ideas/my'),
      headers: await _authHeaders(),
    );
    _check(res);
    return List<Map<String, dynamic>>.from(_decode(res)['data'] as List);
  }

  static Future<Map<String, dynamic>> getById(int id) async {
    final res = await http.get(
      Uri.parse('$_base/ideas/$id'),
      headers: await _authHeaders(),
    );
    _check(res);
    return _decode(res)['data'] as Map<String, dynamic>;
  }

  static Future<int> create(Map<String, dynamic> data) async {
    final res = await http.post(
      _ep,
      headers: await _authHeaders(),
      body: jsonEncode(data),
    );
    _check(res);
    return (_decode(res)['data'] as Map<String, dynamic>)['id'] as int;
  }

  static Future<void> update(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$_base/ideas/$id'),
      headers: await _authHeaders(),
      body: jsonEncode(data),
    );
    _check(res);
  }

  static Future<void> delete(int id) async {
    final res = await http.delete(
      Uri.parse('$_base/ideas/$id'),
      headers: await _authHeaders(),
    );
    _check(res);
  }
}

class RequestsApi {
  static final _ep = Uri.parse('$_base/requests');

  static Future<List<Map<String, dynamic>>> getAll({String? status}) async {
    final incoming = await getIncoming();
    final outgoing = await getOutgoing();
    final all = [...incoming, ...outgoing];

    if (status == null) {
      return all;
    }

    return all.where((request) => request['status'] == status).toList();
  }

  static Future<List<Map<String, dynamic>>> getIncoming() async {
    final res = await http.get(
      Uri.parse('$_base/requests/incoming'),
      headers: await _authHeaders(),
    );
    _check(res);
    return List<Map<String, dynamic>>.from(_decode(res)['data'] as List);
  }

  static Future<List<Map<String, dynamic>>> getOutgoing() async {
    final res = await http.get(
      Uri.parse('$_base/requests/outgoing'),
      headers: await _authHeaders(),
    );
    _check(res);
    return List<Map<String, dynamic>>.from(_decode(res)['data'] as List);
  }

  static Future<Map<String, dynamic>> getById(int id) async {
    final all = await getAll();
    return all.firstWhere((request) => request['id'] == id);
  }

  static Future<int> create(Map<String, dynamic> data) async {
    final res = await http.post(
      _ep,
      headers: await _authHeaders(),
      body: jsonEncode(data),
    );
    _check(res);
    return (_decode(res)['data'] as Map<String, dynamic>)['id'] as int;
  }

  static Future<void> update(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$_base/requests/$id'),
      headers: await _authHeaders(),
      body: jsonEncode(data),
    );
    _check(res);
  }

  static Future<void> accept(int id) async {
    await update(id, {'status': 'accepted'});
  }

  static Future<void> reject(int id) async {
    await update(id, {'status': 'rejected'});
  }

  static Future<void> delete(int id) async {
    final res = await http.delete(
      Uri.parse('$_base/requests/$id'),
      headers: await _authHeaders(),
    );
    _check(res);
  }
}

class SupervisorsApi {
  static final _ep = Uri.parse('$_base/supervisors');

  static Future<List<Map<String, dynamic>>> getAll({bool? available}) async {
    final uri = available == null
        ? _ep
        : _ep.replace(queryParameters: {'available': available.toString()});
    final res = await http.get(uri, headers: await _authHeaders());
    _check(res);
    return List<Map<String, dynamic>>.from(_decode(res)['data'] as List);
  }

  static Future<Map<String, dynamic>> getById(int id) async {
    final res = await http.get(
      Uri.parse('$_base/supervisors/$id'),
      headers: await _authHeaders(),
    );
    _check(res);
    return _decode(res)['data'] as Map<String, dynamic>;
  }

  static Future<int> create(Map<String, dynamic> data) async {
    final res = await http.post(
      _ep,
      headers: await _authHeaders(),
      body: jsonEncode(data),
    );
    _check(res);
    return (_decode(res)['data'] as Map<String, dynamic>)['id'] as int;
  }

  static Future<void> update(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$_base/supervisors/$id'),
      headers: await _authHeaders(),
      body: jsonEncode(data),
    );
    _check(res);
  }

  static Future<void> delete(int id) async {
    final res = await http.delete(
      Uri.parse('$_base/supervisors/$id'),
      headers: await _authHeaders(),
    );
    _check(res);
  }
}
