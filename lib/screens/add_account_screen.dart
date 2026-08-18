import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../providers/data_provider.dart';
import '../providers/currency_provider.dart';
import '../utils/validators.dart';
import '../utils/formatters.dart';
import 'package:ei_app/providers/providers.dart';

class AddAccountScreen extends StatefulWidget {
  final Account? account;

  const AddAccountScreen({super.key, this.account});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _holderController = TextEditingController();
  final _balanceController = TextEditingController();
  String _selectedType = 'bank';

  String _nameError = '';
  String _numberError = '';

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _nameController.text = widget.account!.name;
      _numberController.text = widget.account!.number;
      _holderController.text = widget.account!.holder;
      _balanceController.text = widget.account!.balance.toString();
      _selectedType = widget.account!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _holderController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final number = _numberController.text.trim();
    final holder = _holderController.text.trim();
    final balanceStr = _balanceController.text.replaceAll(RegExp(r'[^\d]'), '');
    final balance = double.tryParse(balanceStr) ?? 0;

    // وریفای نام
    if (name.isEmpty) {
      setState(() => _nameError = '⚠️ نام حساب را وارد کنید');
      return;
    } else {
      setState(() => _nameError = '');
    }

    // وریفای شماره
    if (!Validators.isValidAccountNumber(number) && _selectedType != 'cash') {
      setState(() => _numberError = '⚠️ شماره باید حداقل ۱۰ رقم باشد');
      return;
    } else {
      setState(() => _numberError = '');
    }

    final account = Account(
      id: widget.account?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: _selectedType,
      number: _selectedType == 'cash' ? '' : number,
      holder: holder,
      balance: balance,
    );

    final data = context.read<DataProvider>();
    if (widget.account != null) {
      data.updateAccount(account);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حساب ویرایش شد')),
      );
    } else {
      data.addAccount(account);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حساب اضافه شد')),
      );
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account != null ? 'ویرایش حساب' : 'افزودن حساب'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== نوع حساب =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نوع حساب',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildTypeChip('بانک', 'bank'),
                        const SizedBox(width: 8),
                        _buildTypeChip('کارت', 'card'),
                        const SizedBox(width: 8),
                        _buildTypeChip('نقدی', 'cash'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ===== نام حساب =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'نام حساب *',
                        hintText: 'مثلاً بانک ملی، کارت اعتباری، ...',
                        border: InputBorder.none,
                        errorText: _nameError.isNotEmpty ? _nameError : null,
                      ),
                      onChanged: (_) => setState(() => _nameError = ''),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ===== شماره حساب (فقط برای بانک و کارت) =====
              if (_selectedType != 'cash')
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _numberController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'شماره حساب/کارت *',
                          hintText: 'حداقل ۱۰ رقم',
                          border: InputBorder.none,
                          errorText: _numberError.isNotEmpty ? _numberError : null,
                        ),
                        onChanged: (_) => setState(() => _numberError = ''),
                      ),
                    ],
                  ),
                ),
              if (_selectedType != 'cash') const SizedBox(height: 16),

              // ===== صاحب حساب =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _holderController,
                  decoration: const InputDecoration(
                    labelText: 'صاحب حساب',
                    hintText: 'مثلاً علی رضایی',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ===== موجودی اولیه =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _balanceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'موجودی اولیه (${currency.symbol})',
                    hintText: '۰',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      final formatted = Formatters.formatWithCommas(value);
                      if (formatted != value) {
                        _balanceController.text = formatted;
                        _balanceController.selection = TextSelection.fromPosition(
                          TextPosition(offset: formatted.length),
                        );
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),

              // ===== دکمه ذخیره =====
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  widget.account != null ? 'ویرایش' : 'افزودن',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, String value) {
    final isSelected = _selectedType == value;
    return Expanded(
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 13)),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedType = value;
              _numberError = '';
            });
          }
        },
        selectedColor: const Color(0xFF6C5CE7),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : null,
          fontSize: 13,
        ),
      ),
    );
  }
}