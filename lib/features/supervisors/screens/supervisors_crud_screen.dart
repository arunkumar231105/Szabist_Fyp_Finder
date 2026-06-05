import 'package:flutter/material.dart';
import '../../../shared/services/api_service.dart';

class SupervisorsCrudScreen extends StatefulWidget {
  const SupervisorsCrudScreen({super.key});
  @override
  State<SupervisorsCrudScreen> createState() => _SupervisorsCrudScreenState();
}

class _SupervisorsCrudScreenState extends State<SupervisorsCrudScreen> {
  List<Map<String, dynamic>> _supervisors = [];
  bool _loading = true;

  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _deptCtrl  = TextEditingController();
  final _desigCtrl = TextEditingController();
  final _specCtrl  = TextEditingController();
  final _slotsCtrl = TextEditingController(text: '2');
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await SupervisorsApi.getAll();
      if (!mounted) return;
      setState(() { _supervisors = data; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack('Error: $e', error: true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red : const Color(0xFF3B82F6),
    ));
  }

  void _clearForm() {
    _nameCtrl.clear(); _emailCtrl.clear(); _deptCtrl.clear();
    _desigCtrl.clear(); _specCtrl.clear();
    _slotsCtrl.text = '2';
    setState(() => _isAvailable = true);
  }

  // ── CREATE ──────────────────────────────────────
  Future<void> _create() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _deptCtrl.text.isEmpty) {
      _snack('Name, Email, Department zaroori hain', error: true);
      return;
    }
    try {
      await SupervisorsApi.create({
        'name':           _nameCtrl.text.trim(),
        'email':          _emailCtrl.text.trim(),
        'department':     _deptCtrl.text.trim(),
        'designation':    _desigCtrl.text.trim(),
        'specialization': _specCtrl.text.trim().split(',').map((s) => s.trim()).toList(),
        'availableSlots': int.tryParse(_slotsCtrl.text) ?? 0,
        'isAvailable':    _isAvailable,
      });
      if (!mounted) return;
      _snack('Supervisor added!');
      _clearForm();
      _load();
    } catch (e) {
      if (!mounted) return;
      _snack('$e', error: true);
    }
  }

  // ── UPDATE dialog ───────────────────────────────
  void _showEditDialog(Map<String, dynamic> sup) {
    final nCtrl  = TextEditingController(text: sup['name']        ?? '');
    final eCtrl  = TextEditingController(text: sup['email']       ?? '');
    final dCtrl  = TextEditingController(text: sup['department']  ?? '');
    final dgCtrl = TextEditingController(text: sup['designation'] ?? '');
    final spCtrl = TextEditingController(
        text: (sup['specialization'] as List?)?.join(', ') ?? '');
    final slCtrl = TextEditingController(
        text: (sup['availableSlots'] ?? 0).toString());
    bool avail = sup['isAvailable'] == true;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
        title: const Text('Update Supervisor', style: TextStyle(color: Color(0xFF3B82F6))),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          _tf(nCtrl,  'Full Name'),
          _tf(eCtrl,  'Email (@szabist.pk)'),
          _tf(dCtrl,  'Department (SE/CS/AI)'),
          _tf(dgCtrl, 'Designation'),
          _tf(spCtrl, 'Specialization (comma separated)'),
          _tf(slCtrl, 'Available Slots', num: true),
          const SizedBox(height: 4),
          Row(children: [
            const Text('Available:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Switch(
              value: avail,
              activeThumbColor: const Color(0xFF3B82F6),
              onChanged: (v) => setS(() => avail = v),
            ),
          ]),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
            onPressed: () async {
              try {
                await SupervisorsApi.update(sup['id'] as int, {
                  'name':           nCtrl.text.trim(),
                  'email':          eCtrl.text.trim(),
                  'department':     dCtrl.text.trim(),
                  'designation':    dgCtrl.text.trim(),
                  'specialization': spCtrl.text.trim().split(',').map((s) => s.trim()).toList(),
                  'availableSlots': int.tryParse(slCtrl.text) ?? 0,
                  'isAvailable':    avail,
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
        title: const Text('Delete Supervisor?'),
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
      await SupervisorsApi.delete(id);
      if (!mounted) return;
      _snack('Supervisor deleted!');
      _load();
    } catch (e) {
      if (!mounted) return;
      _snack('$e', error: true);
    }
  }

  Widget _tf(TextEditingController c, String label, {bool num = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: c,
      keyboardType: num ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      appBar: AppBar(
        title: const Text('FYP Supervisors', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3B82F6),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: Column(children: [

        // ── Add Form ─────────────────────────────────
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Add New Supervisor',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3B82F6))),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _tf(_nameCtrl,  'Full Name')),
              const SizedBox(width: 8),
              Expanded(child: _tf(_deptCtrl,  'Dept (SE/CS/AI)')),
            ]),
            _tf(_emailCtrl, 'Email (@szabist.pk)'),
            _tf(_desigCtrl, 'Designation (e.g. Lecturer)'),
            _tf(_specCtrl,  'Specialization (comma separated)'),
            Row(children: [
              Expanded(child: _tf(_slotsCtrl, 'Available Slots', num: true)),
              const SizedBox(width: 16),
              const Text('Available:', style: TextStyle(fontWeight: FontWeight.bold)),
              Switch(
                value: _isAvailable,
                activeThumbColor: const Color(0xFF3B82F6),
                onChanged: (v) => setState(() => _isAvailable = v),
              ),
            ]),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.person_add, color: Colors.white),
                label: const Text('Add Supervisor',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: _create,
              ),
            ),
          ]),
        ),

        // ── List ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(children: [
            Text('All Supervisors (${_supervisors.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF3B82F6))),
          ]),
        ),

        Expanded(
          child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
            : _supervisors.isEmpty
              ? const Center(child: Text('Koi supervisors nahi hain', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _supervisors.length,
                  itemBuilder: (_, i) {
                    final s = _supervisors[i];
                    final avail = s['isAvailable'] == true;
                    final specs = (s['specialization'] as List?)?.cast<String>() ?? [];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFF3B82F6),
                            child: Text(
                              (s['name'] as String? ?? '?').isNotEmpty
                                ? (s['name'] as String).substring(0, 1).toUpperCase()
                                : '?',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(s['name']?.toString() ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(s['designation']?.toString() ?? '',
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('Dept: ${s['department']}  •  Slots: ${s['availableSlots']}',
                              style: const TextStyle(fontSize: 12)),
                            if (specs.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Wrap(spacing: 4, runSpacing: 4,
                                children: specs.take(3).map((sp) => Chip(
                                  label: Text(sp, style: const TextStyle(fontSize: 10)),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  backgroundColor: const Color(0xFFDBEAFE),
                                )).toList(),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: avail ? Colors.green.withAlpha(25) : Colors.red.withAlpha(25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: avail ? Colors.green : Colors.red),
                              ),
                              child: Text(avail ? 'AVAILABLE' : 'NOT AVAILABLE',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                                  color: avail ? Colors.green : Colors.red)),
                            ),
                          ])),
                          Column(children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF3B82F6), size: 20),
                              onPressed: () => _showEditDialog(s),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () => _delete(s['id'] as int),
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
    _nameCtrl.dispose(); _emailCtrl.dispose(); _deptCtrl.dispose();
    _desigCtrl.dispose(); _specCtrl.dispose(); _slotsCtrl.dispose();
    super.dispose();
  }
}
