import 'package:flutter/material.dart';

void main() {
  runApp(DoorInstallerApp());
}

class DoorInstallerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Монтаж Дверей',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFFF5F7FA),
      ),
      home: DoorProjectScreen(),
    );
  }
}

class DoorProjectScreen extends StatefulWidget {
  @override
  _DoorProjectScreenState createState() => _DoorProjectScreenState();
}

class _DoorProjectScreenState extends State<DoorProjectScreen> {
  // Дані про двері у проєкті
  final List<Map<String, dynamic>> doors = [
    {
      'name': 'Спальня',
      'width': '800',
      'height': '2000',
      'wallThick': '150',
      'hingeType': 'Приховані',
      'hingeCount': '3',
      'lockType': 'Магнітний',
      'hasHandle': true,
      'hasLatch': false,
      'hasKey': false,
      'basePrice': 1200.0,
      'extraPrice': 400.0,
    }
  ];

  void _addNewDoor() {
    setState(() {
      doors.add({
        'name': 'Нові двері ${doors.length + 1}',
        'width': '700',
        'height': '2000',
        'wallThick': '100',
        'hingeType': 'Бабочки',
        'hingeCount': '2',
        'lockType': 'Механічний',
        'hasHandle': true,
        'hasLatch': true,
        'hasKey': false,
        'basePrice': 1000.0,
        'extraPrice': 300.0,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalProjectPrice = doors.fold(0, (sum, item) => sum + (item['basePrice'] + item['extraPrice']));

    return Scaffold(
      appBar: AppBar(
        title: Text('Об\'єкт: Квартира на Шевченка'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Разом: ${totalProjectPrice.toStringAsFixed(0)} грн',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: doors.length,
        itemBuilder: (context, index) {
          final door = doors[index];
          double doorTotal = door['basePrice'] + door['extraPrice'];
          
          return Card(
            margin: EdgeInsets.all(8.0),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.door_sliding, color: Colors.white),
              ),
              title: Text(door['name'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Розмір: ${door['width']}x${door['height']} мм | Петлі: ${door['hingeType']} (${door['hingeCount']} шт.)\nМонтаж: ${doorTotal.toStringAsFixed(0)} грн',
              ),
              isThreeLine: true,
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                // Перехід до редагування конкретних дверей
                final updatedDoor = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditDoorScreen(doorData: door),
                  ),
                );
                if (updatedDoor != null) {
                  setState(() {
                    doors[index] = updatedDoor;
                  });
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewDoor,
        child: Icon(Icons.add),
        tooltip: 'Додати двері',
      ),
    );
  }
}

class EditDoorScreen extends StatefulWidget {
  final Map<String, dynamic> doorData;
  EditDoorScreen({required this.doorData});

  @override
  _EditDoorScreenState createState() => _EditDoorScreenState();
}

class _EditDoorScreenState extends State<EditDoorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late TextEditingController _wallController;
  
  String _hingeType = 'Приховані';
  String _hingeCount = '3';
  String _lockType = 'Магнітний';
  
  bool _hasHandle = true;
  bool _hasLatch = false;
  bool _hasKey = false;
  
  double _basePrice = 1200.0;
  double _extraPrice = 400.0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.doorData['name']);
    _widthController = TextEditingController(text: widget.doorData['width']);
    _heightController = TextEditingController(text: widget.doorData['height']);
    _wallController = TextEditingController(text: widget.doorData['wallThick']);
    
    _hingeType = widget.doorData['hingeType'];
    _hingeCount = widget.doorData['hingeCount'];
    _lockType = widget.doorData['lockType'];
    _hasHandle = widget.doorData['hasHandle'];
    _hasLatch = widget.doorData['hasLatch'];
    _hasKey = widget.doorData['hasKey'];
    _basePrice = widget.doorData['basePrice'];
    _extraPrice = widget.doorData['extraPrice'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Редагування прорізу'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              widget.doorData['name'] = _nameController.text;
              widget.doorData['width'] = _widthController.text;
              widget.doorData['height'] = _heightController.text;
              widget.doorData['wallThick'] = _wallController.text;
              widget.doorData['hingeType'] = _hingeType;
              widget.doorData['hingeCount'] = _hingeCount;
              widget.doorData['lockType'] = _lockType;
              widget.doorData['hasHandle'] = _hasHandle;
              widget.doorData['hasLatch'] = _hasLatch;
              widget.doorData['hasKey'] = _hasKey;
              widget.doorData['basePrice'] = _basePrice;
              widget.doorData['extraPrice'] = _extraPrice;
              
              Navigator.pop(context, widget.doorData);
            },
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Назва приміщення (напр. Спальня)'),
          ),
          SizedBox(height: 16),
          Text('Розміри прорізу (мм)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Row(
            children: [
              Expanded(child: TextField(controller: _widthController, decoration: InputDecoration(labelText: 'Ширина'))),
              SizedBox(width: 10),
              Expanded(child: TextField(controller: _heightController, decoration: InputDecoration(labelText: 'Висота'))),
              SizedBox(width: 10),
              Expanded(child: TextField(controller: _wallController, decoration: InputDecoration(labelText: 'Товщина стіни'))),
            ],
          ),
          SizedBox(height: 20),
          
          // Блок 3D візуалізації (спрощений макет каркаса)
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              border: Border.all(color: Colors.blueGrey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.crop_din, size: 40, color: Colors.blueGrey),
                  SizedBox(height: 8),
                  Text('3D Креслення прорізу\n(${_widthController.text} x ${_heightController.text} мм)', textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey[800])),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          
          Text('Фурнітура та отвори', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          DropdownButtonFormField<String>(
            value: _hingeType,
            decoration: InputDecoration(labelText: 'Вид петель'),
            items: ['Приховані', 'Бабочки', 'Врізні карткові', 'Штирові'].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList,
            onChanged: (newValue) => setState(() => _hingeType = newValue!),
          ),
          DropdownButtonFormField<String>(
            value: _hingeCount,
            decoration: InputDecoration(labelText: 'Кількість петель'),
            items: ['2', '3', '4'].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text('$value шт.'));
            }).toList,
            onChanged: (newValue) => setState(() => _hingeCount = newValue!),
          ),
          DropdownButtonFormField<String>(
            value: _lockType,
            decoration: InputDecoration(labelText: 'Вид замка'),
            items: ['Магнітний', 'Механічний (язичок)', 'Під циліндр'].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList,
            onChanged: (newValue) => setState(() => _lockType = newValue!),
          ),
          
          CheckboxListTile(
            title: Text('Отвори під ручку'),
            value: _hasHandle,
            onChanged: (val) => setState(() => _hasHandle = val!),
          ),
          CheckboxListTile(
            title: Text('Отвори під фіксатор (санвузол)'),
            value: _hasLatch,
            onChanged: (val) => setState(() => _hasLatch = val!),
          ),
          CheckboxListTile(
            title: Text('Отвори під ключ (циліндр)'),
            value: _hasKey,
            onChanged: (val) => setState(() => _hasKey = val!),
          ),
          
          SizedBox(height: 20),
          Text('Ціна за монтаж (грн)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Базова вартість монтажу'),
            controller: TextEditingController(text: _basePrice.toString()),
            onChanged: (val) => _basePrice = double.tryParse(val) ?? 0,
          ),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Додаткові роботи (добори, лиштва тощо)'),
            controller: TextEditingController(text: _extraPrice.toString()),
            onChanged: (val) => _extraPrice = double.tryParse(val) ?? 0,
          ),
        ],
      ),
    );
  }
}
