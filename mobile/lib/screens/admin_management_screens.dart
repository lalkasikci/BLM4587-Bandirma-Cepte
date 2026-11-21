import 'package:flutter/material.dart';
import '../models/bus_line.dart';
import '../models/local_info.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/section_app_bar.dart';

typedef _Editor<T> = Future<bool?> Function(BuildContext context, T? item);
typedef _DeleteAction = Future<void> Function(int id, {required String token});
typedef _TileBuilder<T> =
    Widget Function(
      BuildContext context,
      T item,
      VoidCallback edit,
      VoidCallback delete,
      VoidCallback refresh,
    );

class _AdminEntityList<T> extends StatefulWidget {
  final String title;
  final AuthService authService;
  final Future<List<T>> Function() loadItems;
  final int Function(T) idOf;
  final String Function(T) labelOf;
  final _Editor<T> editItem;
  final _DeleteAction deleteItem;
  final _TileBuilder<T> tileBuilder;

  const _AdminEntityList({
    required this.title,
    required this.authService,
    required this.loadItems,
    required this.idOf,
    required this.labelOf,
    required this.editItem,
    required this.deleteItem,
    required this.tileBuilder,
  });

  @override
  State<_AdminEntityList<T>> createState() => _AdminEntityListState<T>();
}

class _AdminEntityListState<T> extends State<_AdminEntityList<T>> {
  late Future<List<T>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loadItems();
  }

  void _refresh() {
    setState(() {
      _future = widget.loadItems();
    });
  }

  Future<void> _edit([T? item]) async {
    final saved = await widget.editItem(context, item);
    if (saved == true && mounted) _refresh();
  }

  Future<void> _delete(T item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Kaydı sil'),
            content: Text('“${widget.labelOf(item)}” kaydı silinsin mi?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Vazgeç'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sil'),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) return;
    final token = widget.authService.current?.token;
    if (token == null || !widget.authService.isAdmin) {
      _message('Yönetici oturumu gerekli.');
      return;
    }
    try {
      await widget.deleteItem(widget.idOf(item), token: token);
      if (mounted) {
        _refresh();
        _message('Kayıt silindi.');
      }
    } catch (error) {
      if (mounted) _message(_errorText(error));
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: sectionAppBar(
      context,
      widget.title,
      actions: [
        IconButton(
          tooltip: 'Yenile',
          onPressed: _refresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _edit(),
      icon: const Icon(Icons.add),
      label: const Text('Yeni kayıt'),
    ),
    body: FutureBuilder<List<T>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _AdminError(
            message: _errorText(snapshot.error!),
            onRetry: _refresh,
          );
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('Henüz kayıt bulunmuyor.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 90),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder:
              (context, index) => widget.tileBuilder(
                context,
                items[index],
                () => _edit(items[index]),
                () => _delete(items[index]),
                _refresh,
              ),
        );
      },
    ),
  );
}

class AdminBusLinesScreen extends StatelessWidget {
  final AuthService authService;
  const AdminBusLinesScreen({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    return _AdminEntityList<BusLine>(
      title: 'Otobüs Hattı Yönetimi',
      authService: authService,
      loadItems: api.getBusLines,
      idOf: (line) => line.id,
      labelOf: (line) => 'Hat ${line.lineNumber}',
      editItem:
          (context, line) => showDialog<bool>(
            context: context,
            builder: (_) => _BusLineForm(authService: authService, line: line),
          ),
      deleteItem: api.deleteBusLine,
      tileBuilder:
          (context, line, edit, delete, refresh) => Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Hat ${line.lineNumber} · ${line.route}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Düzenle',
                        onPressed: edit,
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Sil',
                        onPressed: delete,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  if (line.description.isNotEmpty) Text(line.description),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Sefer saatleri',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final saved = await showDialog<bool>(
                            context: context,
                            builder:
                                (_) => _ScheduleForm(
                                  authService: authService,
                                  line: line,
                                ),
                          );
                          if (saved == true) refresh();
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Saat ekle'),
                      ),
                    ],
                  ),
                  if (line.schedules.isEmpty)
                    Text(
                      line.scheduleCsv.isEmpty
                          ? 'Sefer saati yok.'
                          : line.scheduleCsv,
                      style: const TextStyle(color: Colors.blueGrey),
                    )
                  else
                    ...line.schedules.map(
                      (schedule) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${schedule.departureTime} · ${schedule.dayType}',
                        ),
                        subtitle: Text(
                          '${schedule.departurePoint} → ${schedule.arrivalPoint}',
                        ),
                        trailing: Wrap(
                          spacing: 0,
                          children: [
                            IconButton(
                              tooltip: 'Sefer saatini düzenle',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () async {
                                final saved = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (_) => _ScheduleForm(
                                        authService: authService,
                                        line: line,
                                        schedule: schedule,
                                      ),
                                );
                                if (saved == true) refresh();
                              },
                            ),
                            IconButton(
                              tooltip: 'Sefer saatini sil',
                              icon: const Icon(
                                Icons.close,
                                color: Colors.redAccent,
                              ),
                              onPressed:
                                  () => _deleteSchedule(
                                    context,
                                    authService,
                                    api,
                                    schedule.id,
                                    refresh,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _deleteSchedule(
    BuildContext context,
    AuthService auth,
    ApiService api,
    int id,
    VoidCallback refresh,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sefer saatini sil'),
            content: const Text('Bu sefer saati silinsin mi?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Vazgeç'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sil'),
              ),
            ],
          ),
    );
    final token = auth.current?.token;
    if (confirmed != true || token == null) return;
    try {
      await api.deleteBusSchedule(id, token: token);
      refresh();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_errorText(error))));
      }
    }
  }
}

class AdminPharmaciesScreen extends StatelessWidget {
  final AuthService authService;
  const AdminPharmaciesScreen({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    return _AdminEntityList<Pharmacy>(
      title: 'Nöbetçi Eczane Yönetimi',
      authService: authService,
      loadItems: api.getPharmacies,
      idOf: (item) => item.id,
      labelOf: (item) => item.name,
      editItem:
          (context, item) => showDialog<bool>(
            context: context,
            builder: (_) => _PharmacyForm(authService: authService, item: item),
          ),
      deleteItem: api.deletePharmacy,
      tileBuilder:
          (context, item, edit, delete, _) => Card(
            child: ListTile(
              leading: Icon(
                item.isOnCall
                    ? Icons.local_pharmacy
                    : Icons.medication_outlined,
                color: const Color(0xFF147D9A),
              ),
              title: Text(item.name),
              subtitle: Text(
                '${item.address}\n${item.phone ?? ''} · ${item.isOnCall ? 'Nöbetçi' : 'Normal'}',
              ),
              isThreeLine: true,
              trailing: _TileActions(edit: edit, delete: delete),
            ),
          ),
    );
  }
}

class AdminEmergencyContactsScreen extends StatelessWidget {
  final AuthService authService;
  const AdminEmergencyContactsScreen({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    return _AdminEntityList<EmergencyContact>(
      title: 'Acil Numara Yönetimi',
      authService: authService,
      loadItems: api.getEmergencyContacts,
      idOf: (item) => item.id,
      labelOf: (item) => item.name,
      editItem:
          (context, item) => showDialog<bool>(
            context: context,
            builder:
                (_) =>
                    _EmergencyContactForm(authService: authService, item: item),
          ),
      deleteItem: api.deleteEmergencyContact,
      tileBuilder:
          (context, item, edit, delete, _) => Card(
            child: ListTile(
              leading: const Icon(Icons.emergency, color: Colors.redAccent),
              title: Text(item.name),
              subtitle: Text(
                '${item.phoneNumber} · ${item.category ?? ''}\n${item.description ?? ''}',
              ),
              isThreeLine: true,
              trailing: _TileActions(edit: edit, delete: delete),
            ),
          ),
    );
  }
}

class _TileActions extends StatelessWidget {
  final VoidCallback edit;
  final VoidCallback delete;
  const _TileActions({required this.edit, required this.delete});
  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    onSelected: (value) => value == 'edit' ? edit() : delete(),
    itemBuilder:
        (_) => const [
          PopupMenuItem(value: 'edit', child: Text('Düzenle')),
          PopupMenuItem(value: 'delete', child: Text('Sil')),
        ],
  );
}

class _BusLineForm extends StatefulWidget {
  final AuthService authService;
  final BusLine? line;
  const _BusLineForm({required this.authService, this.line});
  @override
  State<_BusLineForm> createState() => _BusLineFormState();
}

class _BusLineFormState extends State<_BusLineForm> {
  final _formKey = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _route = TextEditingController();
  final _description = TextEditingController();
  final _times = TextEditingController();
  final _api = ApiService();
  bool _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    final item = widget.line;
    _number.text = item?.lineNumber ?? '';
    _route.text = item?.route ?? '';
    _description.text = item?.description ?? '';
    _times.text = item?.scheduleCsv ?? '';
  }

  @override
  void dispose() {
    _number.dispose();
    _route.dispose();
    _description.dispose();
    _times.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final token = widget.authService.current?.token;
    if (token == null) {
      setState(() => _error = 'Yönetici oturumu gerekli.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final line = BusLine(
      id: widget.line?.id ?? 0,
      lineNumber: _number.text.trim(),
      route: _route.text.trim(),
      description: _description.text.trim(),
      scheduleCsv: _times.text.trim(),
      schedules: widget.line?.schedules ?? const [],
    );
    try {
      if (widget.line == null) {
        await _api.createBusLine(line, token: token);
      } else {
        await _api.updateBusLine(line, token: token);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = _errorText(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => _FormDialog(
    title: widget.line == null ? 'Otobüs hattı ekle' : 'Otobüs hattını düzenle',
    formKey: _formKey,
    saving: _saving,
    error: _error,
    onSave: _save,
    children: [
      _field(_number, 'Hat numarası', max: 20, required: true),
      _field(_route, 'Güzergâh', max: 200, required: true),
      _field(_description, 'Açıklama', max: 250),
      _field(
        _times,
        'Saat listesi (virgülle ayır)',
        hint: '07:30, 08:00, 08:30',
      ),
    ],
  );
}

class _ScheduleForm extends StatefulWidget {
  final AuthService authService;
  final BusLine line;
  final BusSchedule? schedule;
  const _ScheduleForm({
    required this.authService,
    required this.line,
    this.schedule,
  });
  @override
  State<_ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<_ScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  final _time = TextEditingController();
  final _from = TextEditingController();
  final _to = TextEditingController();
  final _api = ApiService();
  String _dayType = 'Hafta İçi';
  String? _error;
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    final schedule = widget.schedule;
    _time.text = schedule?.departureTime ?? '';
    _from.text = schedule?.departurePoint ?? '';
    _to.text = schedule?.arrivalPoint ?? '';
    _dayType = schedule?.dayType ?? 'Hafta İçi';
  }

  @override
  void dispose() {
    _time.dispose();
    _from.dispose();
    _to.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final token = widget.authService.current?.token;
    if (token == null) {
      setState(() => _error = 'Yönetici oturumu gerekli.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final schedule = BusSchedule(
        id: widget.schedule?.id ?? 0,
        departureTime: _time.text.trim(),
        departurePoint: _from.text.trim(),
        arrivalPoint: _to.text.trim(),
        dayType: _dayType,
      );
      if (widget.schedule == null) {
        await _api.createBusSchedule(widget.line, schedule, token: token);
      } else {
        await _api.updateBusSchedule(widget.line, schedule, token: token);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = _errorText(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => _FormDialog(
    title:
        widget.schedule == null
            ? 'Hat ${widget.line.lineNumber} sefer saati ekle'
            : 'Hat ${widget.line.lineNumber} sefer saatini düzenle',
    formKey: _formKey,
    saving: _saving,
    error: _error,
    onSave: _save,
    children: [
      _field(_time, 'Kalkış saati', hint: '08:30', required: true),
      _field(_from, 'Kalkış noktası'),
      _field(_to, 'Varış noktası'),
      DropdownButtonFormField<String>(
        value: _dayType,
        decoration: const InputDecoration(
          labelText: 'Geçerli günler',
          border: OutlineInputBorder(),
        ),
        items:
            const ['Hafta İçi', 'Hafta Sonu', 'Her gün']
                .map((day) => DropdownMenuItem(value: day, child: Text(day)))
                .toList(),
        onChanged: (value) => setState(() => _dayType = value ?? 'Hafta İçi'),
      ),
    ],
  );
}

class _PharmacyForm extends StatefulWidget {
  final AuthService authService;
  final Pharmacy? item;
  const _PharmacyForm({required this.authService, this.item});
  @override
  State<_PharmacyForm> createState() => _PharmacyFormState();
}

class _PharmacyFormState extends State<_PharmacyForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _api = ApiService();
  bool _onCall = true, _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _name.text = widget.item?.name ?? '';
    _address.text = widget.item?.address ?? '';
    _phone.text = widget.item?.phone ?? '';
    _onCall = widget.item?.isOnCall ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final token = widget.authService.current?.token;
    if (token == null) {
      setState(() => _error = 'Yönetici oturumu gerekli.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final item = Pharmacy(
      id: widget.item?.id ?? 0,
      name: _name.text.trim(),
      address: _address.text.trim(),
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      isOnCall: _onCall,
    );
    try {
      if (widget.item == null) {
        await _api.createPharmacy(item, token: token);
      } else {
        await _api.updatePharmacy(item, token: token);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = _errorText(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => _FormDialog(
    title: widget.item == null ? 'Eczane ekle' : 'Eczaneyi düzenle',
    formKey: _formKey,
    saving: _saving,
    error: _error,
    onSave: _save,
    children: [
      _field(_name, 'Eczane adı', max: 150, required: true),
      _field(_address, 'Adres', max: 250, required: true),
      _field(_phone, 'Telefon'),
      SwitchListTile(
        title: const Text('Nöbetçi'),
        value: _onCall,
        onChanged: (value) => setState(() => _onCall = value),
      ),
    ],
  );
}

class _EmergencyContactForm extends StatefulWidget {
  final AuthService authService;
  final EmergencyContact? item;
  const _EmergencyContactForm({required this.authService, this.item});
  @override
  State<_EmergencyContactForm> createState() => _EmergencyContactFormState();
}

class _EmergencyContactFormState extends State<_EmergencyContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _phone = TextEditingController(),
      _category = TextEditingController(),
      _description = TextEditingController();
  final _api = ApiService();
  bool _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _name.text = item?.name ?? '';
    _phone.text = item?.phoneNumber ?? '';
    _category.text = item?.category ?? '';
    _description.text = item?.description ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _category.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final token = widget.authService.current?.token;
    if (token == null) {
      setState(() => _error = 'Yönetici oturumu gerekli.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final item = EmergencyContact(
      id: widget.item?.id ?? 0,
      name: _name.text.trim(),
      phoneNumber: _phone.text.trim(),
      category: _category.text.trim().isEmpty ? null : _category.text.trim(),
      description:
          _description.text.trim().isEmpty ? null : _description.text.trim(),
    );
    try {
      if (widget.item == null) {
        await _api.createEmergencyContact(item, token: token);
      } else {
        await _api.updateEmergencyContact(item, token: token);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = _errorText(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => _FormDialog(
    title: widget.item == null ? 'Acil numara ekle' : 'Acil numarayı düzenle',
    formKey: _formKey,
    saving: _saving,
    error: _error,
    onSave: _save,
    children: [
      _field(_name, 'Kurum / hizmet adı', max: 150, required: true),
      _field(_phone, 'Telefon numarası', max: 50, required: true),
      _field(_category, 'Kategori', max: 50),
      _field(_description, 'Açıklama', max: 250),
    ],
  );
}

class _FormDialog extends StatelessWidget {
  final String title;
  final GlobalKey<FormState> formKey;
  final bool saving;
  final String? error;
  final VoidCallback onSave;
  final List<Widget> children;
  const _FormDialog({
    required this.title,
    required this.formKey,
    required this.saving,
    required this.error,
    required this.onSave,
    required this.children,
  });
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(title),
    content: SizedBox(
      width: 460,
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...children.expand(
                (child) => [child, const SizedBox(height: 12)],
              ),
              if (error != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: saving ? null : () => Navigator.pop(context, false),
        child: const Text('Vazgeç'),
      ),
      FilledButton.icon(
        onPressed: saving ? null : onSave,
        icon:
            saving
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(Icons.save),
        label: Text(saving ? 'Kaydediliyor' : 'Kaydet'),
      ),
    ],
  );
}

Widget _field(
  TextEditingController controller,
  String label, {
  int? max,
  bool required = false,
  String? hint,
}) => TextFormField(
  controller: controller,
  maxLength: max,
  decoration: InputDecoration(
    labelText: label,
    hintText: hint,
    border: const OutlineInputBorder(),
  ),
  validator: (value) {
    final text = value?.trim() ?? '';
    if (required && text.isEmpty) return '$label zorunludur.';
    if (max != null && text.length > max) {
      return '$label en fazla $max karakter olabilir.';
    }
    return null;
  },
);

class _AdminError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _AdminError({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Yeniden dene'),
          ),
        ],
      ),
    ),
  );
}

String _errorText(Object error) =>
    error.toString().replaceFirst('Exception: ', '');
