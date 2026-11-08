import 'package:flutter/material.dart';

enum TemperatureUnit {
  celsius('Celsius', '°C'),
  fahrenheit('Fahrenheit', '°F');

  const TemperatureUnit(this.label, this.symbol);

  final String label;
  final String symbol;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _blue = Color(0xFF087BFA);
  static const _muted = Color(0xFF8A8F98);

  final _formKey = GlobalKey<FormState>();
  final _temperatureController = TextEditingController(text: '0');
  TemperatureUnit _inputUnit = TemperatureUnit.fahrenheit;
  double? _convertedValue = _convertTemperature(72, TemperatureUnit.fahrenheit);

  static double _convertTemperature(double value, TemperatureUnit inputUnit) {
    return switch (inputUnit) {
      TemperatureUnit.celsius => value * 9 / 5 + 32,
      TemperatureUnit.fahrenheit => (value - 32) * 5 / 9,
    };
  }

  String _formatTemperature(double value) {
    return value
        .toStringAsFixed(4)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  void _convert() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final value = double.parse(_temperatureController.text.trim());
    setState(() {
      _convertedValue = _convertTemperature(value, _inputUnit);
    });
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outputUnit = _inputUnit == TemperatureUnit.fahrenheit
        ? TemperatureUnit.celsius
        : TemperatureUnit.fahrenheit;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Temperature converter',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF2F5FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const .all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const Key('temperature-input'),
                          controller: _temperatureController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: _fieldDecoration('Degrees'),
                          validator: (value) {
                            final temperature = double.tryParse(
                              value?.trim() ?? '',
                            );
                            if (temperature == null || !temperature.isFinite) {
                              return 'Enter a valid temperature';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: DropdownButtonFormField<TemperatureUnit>(
                          key: const Key('temperature-type'),
                          initialValue: _inputUnit,
                          isExpanded: true,
                          decoration: _fieldDecoration('Type'),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Color.fromRGBO(98, 102, 109, 1),
                          ),
                          items: TemperatureUnit.values
                              .map(
                                (unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit.label),
                                ),
                              )
                              .toList(),
                          onChanged: (unit) {
                            if (unit == null) {
                              return;
                            }
                            setState(() {
                              _inputUnit = unit;
                              _convertedValue = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Result',
                    style: TextStyle(
                      fontSize: 12,
                      color: _muted,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE7E9ED)),
                      ),
                    ),
                    child: Text(
                      _convertedValue == null
                          ? '—'
                          : '${_formatTemperature(_convertedValue!)} ${outputUnit.symbol}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4A4D52),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: _convert,
                      style: FilledButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('Convert'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    const border = UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFE7E9ED)),
    );
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: _muted),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      isDense: true,
      contentPadding: const EdgeInsets.only(top: 12, bottom: 8),
      border: border,
      enabledBorder: border,
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: _blue, width: 1.5),
      ),
    );
  }
}
