import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/calculator_engine.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  int _selectedCategory = 0;
  String _inputValue = '';
  String _outputValue = '0';
  String _fromUnit = '';
  String _toUnit = '';

  final List<ConverterCategory> _categories = [
    ConverterCategory(
      name: 'Length',
      icon: Icons.straighten,
      units: UnitConverter.lengthUnits.keys.toList(),
      convert: (val, from, to) =>
          UnitConverter.convert(val, from, to, UnitConverter.lengthUnits),
    ),
    ConverterCategory(
      name: 'Weight',
      icon: Icons.fitness_center,
      units: UnitConverter.weightUnits.keys.toList(),
      convert: (val, from, to) =>
          UnitConverter.convert(val, from, to, UnitConverter.weightUnits),
    ),
    ConverterCategory(
      name: 'Temperature',
      icon: Icons.thermostat,
      units: ['Celsius', 'Fahrenheit', 'Kelvin'],
      convert: UnitConverter.convertTemperature,
    ),
    ConverterCategory(
      name: 'Volume',
      icon: Icons.local_drink,
      units: UnitConverter.volumeUnits.keys.toList(),
      convert: (val, from, to) =>
          UnitConverter.convert(val, from, to, UnitConverter.volumeUnits),
    ),
    ConverterCategory(
      name: 'Area',
      icon: Icons.square_foot,
      units: UnitConverter.areaUnits.keys.toList(),
      convert: (val, from, to) =>
          UnitConverter.convert(val, from, to, UnitConverter.areaUnits),
    ),
    ConverterCategory(
      name: 'Speed',
      icon: Icons.speed,
      units: UnitConverter.speedUnits.keys.toList(),
      convert: (val, from, to) =>
          UnitConverter.convert(val, from, to, UnitConverter.speedUnits),
    ),
    ConverterCategory(
      name: 'Time',
      icon: Icons.access_time,
      units: UnitConverter.timeUnits.keys.toList(),
      convert: (val, from, to) =>
          UnitConverter.convert(val, from, to, UnitConverter.timeUnits),
    ),
    ConverterCategory(
      name: 'Data',
      icon: Icons.storage,
      units: UnitConverter.dataUnits.keys.toList(),
      convert: (val, from, to) =>
          UnitConverter.convert(val, from, to, UnitConverter.dataUnits),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeUnits();
  }

  void _initializeUnits() {
    final category = _categories[_selectedCategory];
    _fromUnit = category.units[0];
    _toUnit = category.units.length > 1 ? category.units[1] : category.units[0];
  }

  void _onCategoryChanged(int index) {
    setState(() {
      _selectedCategory = index;
      _inputValue = '';
      _outputValue = '0';
      _initializeUnits();
    });
  }

  void _convert() {
    if (_inputValue.isEmpty) {
      setState(() => _outputValue = '0');
      return;
    }

    try {
      double input = double.parse(_inputValue);
      double result =
          _categories[_selectedCategory].convert(input, _fromUnit, _toUnit);
      setState(() => _outputValue = UnitConverter.formatResult(result));
    } catch (e) {
      setState(() => _outputValue = 'Error');
    }
  }

  void _swapUnits() {
    HapticFeedback.mediumImpact();
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
      _convert();
    });
  }

  void _onKeyPressed(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      if (key == 'C') {
        _inputValue = '';
        _outputValue = '0';
      } else if (key == 'DEL') {
        if (_inputValue.isNotEmpty) {
          _inputValue = _inputValue.substring(0, _inputValue.length - 1);
        }
      } else if (key == '.') {
        if (!_inputValue.contains('.')) {
          _inputValue += _inputValue.isEmpty ? '0.' : '.';
        }
      } else {
        _inputValue += key;
      }
      _convert();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Category Selector
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = index == _selectedCategory;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _onCategoryChanged(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? Border.all(color: colorScheme.primary, width: 1.5)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        category.icon,
                        size: 18,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Conversion Display
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                // From Unit
                Expanded(
                  child: _buildUnitSection(
                    label: 'From',
                    value: _inputValue.isEmpty ? '0' : _inputValue,
                    unit: _fromUnit,
                    units: _categories[_selectedCategory].units,
                    onUnitChanged: (unit) {
                      setState(() {
                        _fromUnit = unit;
                        _convert();
                      });
                    },
                    colorScheme: colorScheme,
                    isInput: true,
                  ),
                ),

                // Swap Button
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  child: GestureDetector(
                    onTap: _swapUnits,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.swap_vert_rounded,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                // To Unit
                Expanded(
                  child: _buildUnitSection(
                    label: 'To',
                    value: _outputValue,
                    unit: _toUnit,
                    units: _categories[_selectedCategory].units,
                    onUnitChanged: (unit) {
                      setState(() {
                        _toUnit = unit;
                        _convert();
                      });
                    },
                    colorScheme: colorScheme,
                    isInput: false,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Keypad - responsive layout
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Row 1: C, DEL, empty, empty
                Expanded(
                  child: Row(
                    children: [
                      _buildKeypadButtonExpanded('C', colorScheme,
                          isAction: true),
                      _buildKeypadButtonExpanded('DEL', colorScheme,
                          isAction: true, icon: Icons.backspace_outlined),
                      _buildKeypadButtonExpanded('', colorScheme,
                          isEmpty: true),
                      _buildKeypadButtonExpanded('', colorScheme,
                          isEmpty: true),
                    ],
                  ),
                ),
                // Row 2: 7, 8, 9, empty
                Expanded(
                  child: Row(
                    children: [
                      _buildKeypadButtonExpanded('7', colorScheme),
                      _buildKeypadButtonExpanded('8', colorScheme),
                      _buildKeypadButtonExpanded('9', colorScheme),
                      _buildKeypadButtonExpanded('', colorScheme,
                          isEmpty: true),
                    ],
                  ),
                ),
                // Row 3: 4, 5, 6, empty
                Expanded(
                  child: Row(
                    children: [
                      _buildKeypadButtonExpanded('4', colorScheme),
                      _buildKeypadButtonExpanded('5', colorScheme),
                      _buildKeypadButtonExpanded('6', colorScheme),
                      _buildKeypadButtonExpanded('', colorScheme,
                          isEmpty: true),
                    ],
                  ),
                ),
                // Row 4: 1, 2, 3, empty
                Expanded(
                  child: Row(
                    children: [
                      _buildKeypadButtonExpanded('1', colorScheme),
                      _buildKeypadButtonExpanded('2', colorScheme),
                      _buildKeypadButtonExpanded('3', colorScheme),
                      _buildKeypadButtonExpanded('', colorScheme,
                          isEmpty: true),
                    ],
                  ),
                ),
                // Row 5: 0 (wide), ., empty
                Expanded(
                  child: Row(
                    children: [
                      _buildKeypadButtonExpanded('0', colorScheme),
                      _buildKeypadButtonExpanded('00', colorScheme),
                      _buildKeypadButtonExpanded('.', colorScheme),
                      _buildKeypadButtonExpanded('', colorScheme,
                          isEmpty: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitSection({
    required String label,
    required String value,
    required String unit,
    required List<String> units,
    required Function(String) onUnitChanged,
    required ColorScheme colorScheme,
    required bool isInput,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: isInput ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color:
                        isInput ? colorScheme.onSurface : colorScheme.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                initialValue: unit,
                onSelected: onUnitChanged,
                itemBuilder: (context) => units
                    .map((u) => PopupMenuItem(
                          value: u,
                          child: Text(u),
                        ))
                    .toList(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(
    String text,
    ColorScheme colorScheme, {
    bool isAction = false,
    bool isEmpty = false,
    bool isWide = false,
    IconData? icon,
  }) {
    if (isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _onKeyPressed(text),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isAction
              ? colorScheme.errorContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: icon != null
              ? Icon(
                  icon,
                  color: isAction
                      ? colorScheme.onErrorContainer
                      : colorScheme.onSurface,
                  size: 22,
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: isAction
                        ? colorScheme.onErrorContainer
                        : colorScheme.onSurface,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildKeypadButtonExpanded(
    String text,
    ColorScheme colorScheme, {
    bool isAction = false,
    bool isEmpty = false,
    IconData? icon,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: isEmpty
            ? const SizedBox.shrink()
            : GestureDetector(
                onTap: () => _onKeyPressed(text),
                child: Container(
                  decoration: BoxDecoration(
                    color: isAction
                        ? colorScheme.errorContainer
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: icon != null
                        ? Icon(
                            icon,
                            color: isAction
                                ? colorScheme.onErrorContainer
                                : colorScheme.onSurface,
                            size: 22,
                          )
                        : Text(
                            text,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: isAction
                                  ? colorScheme.onErrorContainer
                                  : colorScheme.onSurface,
                            ),
                          ),
                  ),
                ),
              ),
      ),
    );
  }
}

class ConverterCategory {
  final String name;
  final IconData icon;
  final List<String> units;
  final double Function(double, String, String) convert;

  ConverterCategory({
    required this.name,
    required this.icon,
    required this.units,
    required this.convert,
  });
}
