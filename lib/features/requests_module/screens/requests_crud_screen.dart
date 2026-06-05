import 'package:flutter/material.dart';
import '../../../shared/services/api_service.dart';

class RequestsCrudScreen extends StatefulWidget {
  const RequestsCrudScreen({super.key});
  @override
  State<RequestsCrudScreen> createState() => _RequestsCrudScreenState();
}

class _RequestsCrudScreenState extends State<RequestsCrudScreen> {
  List<Map<String, dynamic>> _requests = [];
  bool _loading = true;

  final _senderCtrl   = TextEditingController();
  final _deptCtrl     = TextEditingController();
  final _receiverCtrl = TextEditingController();
  final _msgCtrl      = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await RequestsApi.getAll();
      if (!mounted) return;
      setState(() { _requests = data; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack('Error: $e', error: true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red : const Color(0xFF7C3AED),
    ));
  }

  void _clearForm() {
    _senderCtrl.clear(); _deptCtrl.clear();
    _receiverCtrl.clear(); _msgCtrl.clear();
  }

  // ── CREATE ──────────────────────────────────────
  Future<void> _create() async {
    if (_senderCtrl.text.isEmpty || _deptCtrl.text.isEmpty || _receiverCtrl.text.isEmpty) {
      _snack('Sender, Dept, Receiver zaroori hain', error: true);
      return;
    }
    try {
      await RequestsApi.create({
        'senderName':   _senderCtrl.text.trim(),
        'senderDept':   _deptCtrl.text.trim(),
        'receiverName': _receiverCtrl.text.trim(),
        'message':      _msgCtrl.text.trim(),
      });
      if (!mounted) return;
      _snack('Request sent!');
      _clearForm();
      _load();
    } catch (e) {
      if (!mounted) return;
      _snack('$e', error: true);
    }
  }

  // ── UPDATE dialog ───────────────────────────────
  void _showEditDialog(Map<String, dynamic> req) {
    final sCtrl = TextEditingController(text: req['sender_name']   ?? '');
    final dCtrl = TextEditingController(text: req['sender_dept']   ?? '');
    final rCtrl = TextEditingController(text: req['receiver_name'] ?? '');
    final mCtrl = TextEditingController(text: req['message']       ?? '');
    String status = req['status'] ?? 'pending';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
        title: const Text('Update Request', style: TextStyle(color: Color(0xFF7C3AED))),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          _tf(sCtrl, 'Sender Name'),
          _tf(dCtrl, 'Sender Dept'),
          _tf(rCtrl, 'Receiver Name'),
          _tf(mCtrl, 'Message'),
          const SizedBox(height: 8),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
            child: DropdownButton<String>(
              value: status,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: ['pending', 'accepted', 'rejected']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                  .toList(),
              onChanged: (v) => setS(() => status = v!),
            ),
          ),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
            onPressed: () async {
              try {
                await RequestsApi.update(req['id'] as int, {
                  'senderName':   sCtrl.text.trim(),
                  'senderDept':   dCtrl.text.trim(),
                  'receiverName': rCtrl.text.trim(),
                  'message':      mCtrl.text.trim(),
                  'status':       status,
                });
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _snack('Updated!');
                _load();
              } catch (e) {
                if (!ctx.mounted) return;
                _snack('$e', error: true);
              }
            },
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      )),
    );
  }

  // ── DELETE ──────────────────────────────────────
  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Request?'),
        content: const Text('Kya aap sure hain? Yeh action undo nahi ho sakti.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await RequestsApi.delete(id);
      if (!mounted) return;
      _snack('Request deleted!');
      _load();
    } catch (e) {
      if (!mounted) return;
      _snack('$e', error: true);
    }
  }

  Widget _tf(TextEditingController c, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(controller: c, decoration: InputDecoration(
      labelText: label, border: const OutlineInputBorder(),
    )),
  );

  Color _statusColor(String s) {
    if (s == 'accepted') return Colors.green;
    if (s == 'rejected') return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        title: const Text('Partner Requests', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF7C3AED),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: Column(children: [

        // ── Add New Request Form ─────────────────────
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Send New Request',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C3AED))),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _tf(_senderCtrl, 'Sender Name')),
              const SizedBox(width: 8),
              Expanded(child: _tf(_deptCtrl, 'Dept (SE/CS/AI)')),
            ]),
            _tf(_receiverCtrl, 'Receiver Name'),
            _tf(_msgCtrl, 'Message (optional)'),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text('Send Request',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: _create,
              ),
            ),
          ]),
        ),

        // ── Requests List ────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(children: [
            Text('All Requests (${_requests.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF7C3AED))),
          ]),
        ),

        Expanded(
          child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
            : _requests.isEmpty
              ? const Center(child: Text('Koi requests nahi hain', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _requests.length,
                  itemBuilder: (_, i) {
                    final r = _requests[i];
                    final sc = _statusColor(r['status'] ?? '');
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF7C3AED),
                            child: Text('${r['id']}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('${r['sender_name']}  →  ${r['receiver_name']}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('Dept: ${r['sender_dept']}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            if ((r['message'] ?? '').toString().isNotEmpty)
                              Text(r['message'].toString(),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: sc.withAlpha(25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: sc),
                              ),
                              child: Text((r['status'] ?? '').toString().toUpperCase(),
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: sc)),
                            ),
                          ])),
                          Column(children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF7C3AED), size: 20),
                              onPressed: () => _showEditDialog(r),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () => _delete(r['id'] as int),
                            ),
                          ]),
                        ]),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _senderCtrl.dispose(); _deptCtrl.dispose();
    _receiverCtrl.dispose(); _msgCtrl.dispose();
    super.dispose();
  }
}
