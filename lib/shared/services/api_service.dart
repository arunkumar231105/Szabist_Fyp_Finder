import 'dart:convert';
import 'package:http/http.dart' as http;

// Android emulator  → 10.0.2.2 = your PC localhost
// Real device (WiFi) → change to your PC's IP e.g. 192.168.1.5
const String _base = 'http://10.0.2.2:3000/api';

// ─── shared helper ────────────────────────────────────────────────────────
void _check(http.Response res) {
  if (res.statusCode >= 400) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception(body['message'] ?? 'API error ${res.statusCode}');
  }
}

const _headers = {'Content-Type': 'application/json'};

// ══════════════════════════════════════════════════════════════════════════
//  MODULE 1 — STUDENTS
// ══════════════════════════════════════════════════════════════════════════
class StudentsApi {
  static final _ep = Uri.parse('$_base/students');

  // GET /api/students
  static Future<List<Map<String, dynamic>>> getAll() async {
    final res = await http.get(_ep);
    _check(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(body['data'] as List);
  }

  // GET /api/students/:id
  static Future<Map<String, dynamic>> getById(int id) async {
    final res = await http.get(Uri.parse('$_base/students/$id'));
    _check(res);
    return (jsonDecode(res.body) as Map<String, dynamic>)['data']
        as Map<String, dynamic>;
  }

  // POST /api/students
  static Future<int> create(Map<String, dynamic> data) async {
    final res = await http.post(_ep, headers: _headers, body: jsonEncode(data));
    _check(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return (body['data'] as Map<String, dynamic>)['id'] as int;
  }

  // PUT /api/students/:id
  static Future<void> update(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$_base/students/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
    _check(res);
  }

  // DELETE /api/students/:id
  static Future<void> delete(int id) async {
    final res = await http.delete(Uri.parse('$_base/students/$id'));
    _check(res);
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  MODULE 2 — IDEAS
// ══════════════════════════════════════════════════════════════════════════
class IdeasApi {
  static final _ep = Uri.parse('$_base/ideas');

  // GET /api/ideas  (optional status filter)
  static Future<List<Map<String, dynamic>>> getAll({String? status}) async {
    final uri = status != null
        ? Uri.parse('$_base/ideas?status=$status')
        : _ep;
    final res = await http.get(uri);
    _check(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(body['data'] as List);
  }

  // GET /api/ideas/:id
  static Future<Map<String, dynamic>> getById(int id) async {
    final res = await http.get(Uri.parse('$_base/ideas/$id'));
    _check(res);
    return (jsonDecode(res.body) as Map<String, dynamic>)['data']
        as Map<String, dynamic>;
  }

  // POST /api/ideas
  static Future<int> create(Map<String, dynamic> data) async {
    final res = await http.post(_ep, headers: _headers, body: jsonEncode(data));
    _check(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return (body['data'] as Map<String, dynamic>)['id'] as int;
  }

  // PUT /api/ideas/:id
  static Future<void> update(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$_base/ideas/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
    _check(res);
  }

  // DELETE /api/ideas/:id
  static Future<void> delete(int id) async {
    final res = await http.delete(Uri.parse('$_base/ideas/$id'));
    _check(res);
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  MODULE 3 — REQUESTS
// ══════════════════════════════════════════════════════════════════════════
class RequestsApi {
  static final _ep = Uri.parse('$_base/requests');

  static Future<List<Map<String, dynamic>>> getAll({String? status}) async {
    final uri = status != null ? Uri.parse('$_base/requests?status=$status') : _ep;
    final res = await http.get(uri);
    _check(res);
    return List<Map<String, dynamic>>.from(
        (jsonDecode(res.body) as Map<String, dynamic>)['data'] as List);
  }

  static Future<Map<String, dynamic>> getById(int id) async {
    final res = await http.get(Uri.parse('$_base/requests/$id'));
    _check(res);
    return (jsonDecode(res.body) as Map<String, dynamic>)['data']
        as Map<String, dynamic>;
  }

  static Future<int> create(Map<String, dynamic> data) async {
    final res = await http.post(_ep, headers: _headers, body: jsonEncode(data));
    _check(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return (body['data'] as Map<String, dynamic>)['id'] as int;
  }

  static Future<void> update(int id, Map<String, dynamic> data) async {
    final res = await http.put(Uri.parse('$_base/requests/$id'),
        headers: _headers, body: jsonEncode(data));
    _check(res);
  }

  static Future<void> delete(int id) async {
    final res = await http.delete(Uri.parse('$_base/requests/$id'));
    _check(res);
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  MODULE 4 — SUPERVISORS
// ══════════════════════════════════════════════════════════════════════════
class SupervisorsApi {
  static final _ep = Uri.parse('$_base/supervisors');

  static Future<List<Map<String, dynamic>>> getAll() async {
    final res = await http.get(_ep);
    _check(res);
    return List<Map<String, dynamic>>.from(
        (jsonDecode(res.body) as Map<String, dynamic>)['data'] as List);
  }

  static Future<Map<String, dynamic>> getById(int id) async {
    final res = await http.get(Uri.parse('$_base/supervisors/$id'));
    _check(res);
    return (jsonDecode(res.body) as Map<String, dynamic>)['data']
        as Map<String, dynamic>;
  }

  static Future<int> create(Map<String, dynamic> data) async {
    final res = await http.post(_ep, headers: _headers, body: jsonEncode(data));
    _check(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return (body['data'] as Map<String, dynamic>)['id'] as int;
  }

  static Future<void> update(int id, Map<String, dynamic> data) async {
    final res = await http.put(Uri.parse('$_base/supervisors/$id'),
        headers: _headers, body: jsonEncode(data));
    _check(res);
  }

  static Future<void> delete(int id) async {
    final res = await http.delete(Uri.parse('$_base/supervisors/$id'));
    _check(res);
  }
}
