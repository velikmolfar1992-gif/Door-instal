import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

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
      home: OrdersListScreen(),
    );
  }
}

// 1. Екран списку замовлень (проєктів)
class OrdersListScreen extends StatefulWidget {
  @override
  _OrdersListScreenState createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  final List<Map<String, dynamic>> orders = [
    {
      'orderNumber': '№ 2026-001',
      'clientName': 'Іван Петренко',
      'address': 'вул. Шевченка, 10',
      'doors': [
        {
          'name': 'Спальня',
          'openingWidthTop': 805.0,
          'openingWidthMid': 800.0,
          'openingWidthBottom': 802.0,
          'openingHeightLeft': 2010.0,
          'openingHeightRight': 2005.0,
          'wallThickTop': 160.0,
          'wallThickBottom': 165.0,
          'canvasWidth': 700.0,
          'canvasHeight': 1960.0,
          'boxWidth': 80.0,
          'boxDepth': 40.0,
          'doborWidth': 70.0,
          'architraveSize': '70 мм',
          'openSide': 'Праве',
          'openType': 'Зовнішнє',
          'hingeType': 'Приховані',
          'hingeCount': '3',
          'lockType': 'Магнітний',
          'hasHandle': true,
          'hasLatch': false,
          'hasKey': false,
          'basePrice': 1200.0,
          'extraPrice': 400.0,
        }
      ]
    }
  ];

  void _addNewOrder() {
    String newOrderNum = '№ 2026-00${orders.length + 1}';
    setState(() {
      orders.add({
        'orderNumber': newOrderNum,
        'clientName': 'Новий клієнт',
        'address': 'Адреса об\'єкта',
        'doors': []
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Список замовлень (проєктів)'),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          List doorsList = order['doors'];
          double orderTotal = doorsList.fold(0, (sum, d) => sum + (d['basePrice'] + d['extraPrice']));

          return Card(
            margin: EdgeInsets.all(8.0),
            elevation: 3,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo,
                child: Icon(Icons.folder, color: Colors.white),
              ),
              title: Text('${order['orderNumber']} — ${order['clientName']}', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Адреса: ${order['address']}\nКількість дверей: ${doorsList.length} | Сума: ${orderTotal.toStringAsFixed(0)} грн'),
              isThreeLine: true,
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectDoorsScreen(orderData: order),
                  ),
                );
                setState(() {});
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewOrder,
        child: Icon(Icons.add),
        tooltip: 'Створити нове замовлення',
      ),
    );
  }
}

// 2. Екран списку дверей у замовленні
class ProjectDoorsScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;
  ProjectDoorsScreen({required this.orderData});

  @override
  _ProjectDoorsScreenState createState() => _ProjectDoorsScreenState();
}

class _ProjectDoorsScreenState extends State<ProjectDoorsScreen> {
  late TextEditingController _clientController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _clientController = TextEditingController(text: widget.orderData['clientName']);
    _addressController = TextEditingController(text: widget.orderData['address']);
  }

  void _addNewDoor() {
    setState(() {
      widget.orderData['doors'].add({
        'name': 'Двері ${widget.orderData['doors'].length + 1}',
        'openingWidthTop': 800.0,
        'openingWidthMid': 800.0,
        'openingWidthBottom': 800.0,
        'openingHeightLeft': 2000.0,
        'openingHeightRight': 2000.0,
        'wallThickTop': 100.0,
        'wallThickBottom': 100.0,
        'canvasWidth': 700.0,
        'canvasHeight': 1960.0,
        'boxWidth': 80.0,
        'boxDepth': 40.0,
        'doborWidth': 0.0,
        'architraveSize': '70 мм',
        'openSide': 'Ліві',
        'openType': 'Зовнішнє',
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

  void _exportToWordDialog() {
    String htmlContent = "Замовлення: ${widget.orderData['orderNumber']}\nКлієнт: ${widget.orderData['clientName']}\nАдреса: ${widget.orderData['address']}\n\n";
    List doorsList = widget.orderData['doors'];
    for (var d in doorsList) {
      htmlContent += "--- Приміщення: ${d['name']} ---\n";
      htmlContent += "Полотно: ${d['canvasWidth']}x${d['canvasHeight']} мм\n";
      htmlContent += "Проріз верх/серед/низ: ${d['openingWidthTop']}/${d['openingWidthMid']}/${d['openingWidthBottom']} мм\n";
      htmlContent += "Висота ліво/право: ${d['openingHeightLeft']}/${d['openingHeightRight']} мм\n";
      htmlContent += "Стіна верх/низ: ${d['wallThickTop']}/${d['wallThickBottom']} мм\n";
      htmlContent += "Лиштва крило: ${d['architraveSize']}, Відкривання: ${d['openSide']}, ${d['openType']}\n";
      htmlContent += "Монтаж: ${d['basePrice'] + d['extraPrice']} грн\n\n";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Експорт замовлення'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              'Скопіюйте замовлення та вставте його в Microsoft Word (або надішліть клієнту):\n\n$htmlContent',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: htmlContent));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Скопійовано в буфер обміну!')));
            },
            child: Text('Копіювати текст'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрити'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List doorsList = widget.orderData['doors'];
    double totalProjectPrice = doorsList.fold(0, (sum, item) => sum + (item['basePrice'] + item['extraPrice']));

    return Scaffold(
      appBar: AppBar(
        title: Text('Замовлення: ${widget.orderData['orderNumber']}'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            tooltip: 'Скачати у Word',
            onPressed: _exportToWordDialog,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '${totalProjectPrice.toStringAsFixed(0)} грн',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _clientController,
                    decoration: InputDecoration(labelText: 'Ім\'я клієнта'),
                    onChanged: (val) => widget.orderData['clientName'] = val,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _addressController,
                    decoration: InputDecoration(labelText: 'Адреса об\'єкта'),
                    onChanged: (val) => widget.orderData['address'] = val,
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: doorsList.length,
              itemBuilder: (context, index) {
                final door = doorsList[index];
                double doorTotal = (door['basePrice'] as double) + (door['extraPrice'] as double);
                
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.door_sliding, color: Colors.white),
                    ),
                    title: Text(door['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Полотно: ${door['canvasWidth']}x${door['canvasHeight']} мм | Лиштва: ${door['architraveSize']}\nМонтаж: ${doorTotal.toStringAsFixed(0)} грн',
                    ),
                    isThreeLine: true,
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final updatedDoor = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditDoorScreen(doorData: door),
                        ),
                      );
                      if (updatedDoor != null) {
                        setState(() {
                          doorsList[index] = updatedDoor;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewDoor,
        child: Icon(Icons.add),
        tooltip: 'Додати двері в замовлення',
      ),
    );
  }
}

// 3. Екран редагування з обертовим 3D інтерактивним кресленням
class EditDoorScreen extends StatefulWidget {
  final Map<String, dynamic> doorData;
  EditDoorScreen({required this.doorData});

  @override
  _EditDoorScreenState createState() => _EditDoorScreenState();
}

class _EditDoorScreenState extends State<EditDoorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late TextEditingController _nameController;
  late TextEditingController _opTopController;
  late TextEditingController _opMidController;
  late TextEditingController _opBotController;
  late TextEditingController _opHLeftController;
  late TextEditingController _opHRightController;
  late TextEditingController _wallTopController;
  late TextEditingController _wallBotController;
  late TextEditingController _canvasWidthController;
  late TextEditingController _canvasHeightController;
  late TextEditingController _boxWidthController;
  late TextEditingController _boxDepthController;
  late TextEditingController _doborWidthController;
  
  String _architraveSize = '70 мм';
  String _openSide = 'Праве';
  String _openType = 'Зовнішнє';
  String _hingeType = 'Приховані';
  String _hingeCount = '3';
  String _lockType = 'Магнітний';
  
  bool _hasHandle = true;
  bool _hasLatch = false;
  bool _hasKey = false;
  
  double _basePrice = 1200.0;
  double _extraPrice = 400.0;

  // Кути обертання для 3D жестів
  double _rotateX = 0.0;
  double _rotateY = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _nameController = TextEditingController(text: widget.doorData['name']);
    _opTopController = TextEditingController(text: widget.doorData['openingWidthTop'].toString());
    _opMidController = TextEditingController(text: widget.doorData['openingWidthMid'].toString());
    _opBotController = TextEditingController(text: widget.doorData['openingWidthBottom'].toString());
    _opHLeftController = TextEditingController(text: widget.doorData['openingHeightLeft'].toString());
    _opHRightController = TextEditingController(text: widget.doorData['openingHeightRight'].toString());
    _wallTopController = TextEditingController(text: widget.doorData['wallThickTop'].toString());
    _wallBotController = TextEditingController(text: widget.doorData['wallThickBottom'].toString());
    
    _canvasWidthController = TextEditingController(text: widget.doorData['canvasWidth'].toString());
    _canvasHeightController = TextEditingController(text: widget.doorData['canvasHeight'].toString());
    _boxWidthController = TextEditingController(text: widget.doorData['boxWidth'].toString());
    _boxDepthController = TextEditingController(text: widget.doorData['boxDepth'].toString());
    _doborWidthController = TextEditingController(text: widget.doorData['doborWidth'].toString());
    
    _architraveSize = widget.doorData['architraveSize'] ?? '70 мм';
    _openSide = widget.doorData['openSide'];
    _openType = widget.doorData['openType'];
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
    double cWidth = double.tryParse(_canvasWidthController.text) ?? 700;
    double cHeight = double.tryParse(_canvasHeightController.text) ?? 1960;
    double opTop = double.tryParse(_opTopController.text) ?? 800;
    double opMid = double.tryParse(_opMidController.text) ?? 800;
    double opBot = double.tryParse(_opBotController.text) ?? 800;
    double opHLeft = double.tryParse(_opHLeftController.text) ?? 2000;
    double opHRight = double.tryParse(_opHRightController.text) ?? 2000;
    double wallTop = double.tryParse(_wallTopController.text) ?? 100;
    double wallBot = double.tryParse(_wallBotController.text) ?? 100;
    double boxW = double.tryParse(_boxWidthController.text) ?? 80;
    double boxD = double.tryParse(_boxDepthController.text) ?? 40;
    double doborW = double.tryParse(_doborWidthController.text) ?? 0;
    int hCount = int.tryParse(_hingeCount) ?? 3;

    return Scaffold(
      appBar: AppBar(
        title: Text('Двері та 3D Креслення'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '3D Полотно та Фурнітура', icon: Icon(Icons.door_sliding)),
            Tab(text: '3D Проріз (Обертовий)', icon: Icon(Icons.architecture)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              widget.doorData['name'] = _nameController.text;
              widget.doorData['openingWidthTop'] = opTop;
              widget.doorData['openingWidthMid'] = opMid;
              widget.doorData['openingWidthBottom'] = opBot;
              widget.doorData['openingHeightLeft'] = opHLeft;
              widget.doorData['openingHeightRight'] = opHRight;
              widget.doorData['wallThickTop'] = wallTop;
              widget.doorData['wallThickBottom'] = wallBot;
              widget.doorData['canvasWidth'] = cWidth;
              widget.doorData['canvasHeight'] = cHeight;
              widget.doorData['boxWidth'] = boxW;
              widget.doorData['boxDepth'] = boxD;
              widget.doorData['doborWidth'] = doborW;
              widget.doorData['architraveSize'] = _architraveSize;
              widget.doorData['openSide'] = _openSide;
              widget.doorData['openType'] = _openType;
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
      body: TabBarView(
        controller: _tabController,
        children: [
          // Вкладка 1: Пропорційне полотно з фурнітурою
          ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Назва приміщення (напр. Спальня)'),
              ),
              SizedBox(height: 16),
              Text('Пропорційне полотно та фурнітура', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Container(
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.blueGrey, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomPaint(
                  painter: ProportionalCanvasPainter(
                    canvasWidth: cWidth,
                    canvasHeight: cHeight,
                    openWidth: opMid,
                    openHeight: (opHLeft + opHRight) / 2,
                    wallThick: (wallTop + wallBot) / 2,
                    boxWidth: boxW,
                    architraveSize: _architraveSize,
                    openSide: _openSide,
                    openType: _openType,
                    hingeCount: hCount,
                    hasHandle: _hasHandle,
                    hasLatch: _hasLatch,
                    hasKey: _hasKey,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Розміри дверного полотна (мм)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                children: [
                  Expanded(child: TextField(controller: _canvasWidthController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Ширина полотна'), onChanged: (v) => setState(() {}))),
                  SizedBox(width: 10),
                  Expanded(child: TextField(controller: _canvasHeightController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Висота полотна'), onChanged: (v) => setState(() {}))),
                ],
              ),
              SizedBox(height: 20),
              Text('Фурнітура та отвори', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              DropdownButtonFormField<String>(
                value: _hingeType,
                decoration: InputDecoration(labelText: 'Вид петель'),
                items: ['Приховані', 'Бабочки', 'Врізні карткові', 'Штирові'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                onChanged: (val) => setState(() => _hingeType = val!),
              ),
              DropdownButtonFormField<String>(
                value: _hingeCount,
                decoration: InputDecoration(labelText: 'Кількість петель'),
                items: ['2', '3', '4'].map((val) => DropdownMenuItem(value: val, child: Text('$val шт.'))).toList(),
                onChanged: (val) => setState(() => _hingeCount = val!),
              ),
              DropdownButtonFormField<String>(
                value: _lockType,
                decoration: InputDecoration(labelText: 'Вид замка'),
                items: ['Магнітний', 'Механічний (язичок)', 'Під циліндр'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                onChanged: (val) => setState(() => _lockType = val!),
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
                decoration: InputDecoration(labelText: 'Додаткові роботи'),
                controller: TextEditingController(text: _extraPrice.toString()),
                onChanged: (val) => _extraPrice = double.tryParse(val) ?? 0,
              ),
            ],
          ),

          // Вкладка 2: Інтерактивний 3D проріз із жестами обертання та пропорціями
          ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              Text('Крутіть пальцем для огляду збоку/зверху (3D інтерактив)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              SizedBox(height: 8),
              GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _rotateY += details.delta.dx * 0.015;
                    _rotateX -= details.delta.dy * 0.015;
                  });
                },
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    border: Border.all(color: Colors.blueGrey, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(_rotateX)
                        ..rotateY(_rotateY),
                      alignment: Alignment.center,
                      child: CustomPaint(
                        size: Size(250, 250),
                        painter: Interactive3DOpeningPainter(
                          opTop: opTop,
                          opMid: opMid,
                          opBot: opBot,
                          opHLeft: opHLeft,
                          opHRight: opHRight,
                          wallTop: wallTop,
                          wallBot: wallBot,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: TextButton.icon(
                  onPressed: () => setState(() { _rotateX = 0.0; _rotateY = 0.0; }),
                  icon: Icon(Icons.refresh),
                  label: Text('Скинути положення обертання'),
                ),
              ),
              SizedBox(height: 10),

              Text('Ширина прорізу (мм)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Row(
                children: [
                  Expanded(child: TextField(controller: _opTopController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Зверху'), onChanged: (v) => setState(() {}))),
                  SizedBox(width: 8),
                  Expanded(child: TextField(controller: _opMidController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Посередині'), onChanged: (v) => setState(() {}))),
                  SizedBox(width: 8),
                  Expanded(child: TextField(controller: _opBotController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Знизу'), onChanged: (v) => setState(() {}))),
                ],
              ),
              SizedBox(height: 16),

              Text('Висота прорізу (мм)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Row(
                children: [
                  Expanded(child: TextField(controller: _opHLeftController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Зліва'), onChanged: (v) => setState(() {}))),
                  SizedBox(width: 10),
                  Expanded(child: TextField(controller: _opHRightController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Справа'), onChanged: (v) => setState(() {}))),
                ],
              ),
              SizedBox(height: 16),

              Text('Товщина стіни (мм)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Row(
                children: [
                  Expanded(child: TextField(controller: _wallTopController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Зверху'), onChanged: (v) => setState(() {}))),
                  SizedBox(width: 10),
                  Expanded(child: TextField(controller: _wallBotController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Знизу'), onChanged: (v) => setState(() {}))),
                ],
              ),
              SizedBox(height: 16),

              Text('Коробка та добір', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                children: [
                  Expanded(child: TextField(controller: _boxWidthController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Ширина коробки'), onChanged: (v) => setState(() {}))),
                  SizedBox(width: 10),
                  Expanded(child: TextField(controller: _doborWidthController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Ширина добору'), onChanged: (v) => setState(() {}))),
                ],
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _architraveSize,
                decoration: InputDecoration(labelText: 'Розмір лиштви (крило)'),
                items: ['30 мм', '50 мм', '70 мм'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                onChanged: (val) => setState(() => _architraveSize = val!),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Пропорційний рендер полотна з урахуванням введених мір
class ProportionalCanvasPainter extends CustomPainter {
  final double canvasWidth;
  final double canvasHeight;
  final double openWidth;
  final double openHeight;
  final double wallThick;
  final double boxWidth;
  final String architraveSize;
  final String openSide;
  final String openType;
  final int hingeCount;
  final bool hasHandle;
  final bool hasLatch;
  final bool hasKey;

  ProportionalCanvasPainter({
    required this.canvasWidth,
    required this.canvasHeight,
    required this.openWidth,
    required this.openHeight,
    required this.wallThick,
    required this.boxWidth,
    required this.architraveSize,
    required this.openSide,
    required this.openType,
    required this.hingeCount,
    required this.hasHandle,
    required this.hasLatch,
    required this.hasKey,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintCanvas = Paint()..color = Colors.blue.shade600..style = PaintingStyle.stroke..strokeWidth = 2.0;
    final paintHardware = Paint()..color = Colors.amber.shade800..style = PaintingStyle.fill;
    final paintHole = Paint()..color = Colors.black87..style = PaintingStyle.fill;
    final paintText = TextPainter(textDirection: TextDirection.ltr);

    double cx = size.width / 2;
    double cy = size.height / 2 + 10;

    // Розрахунок пропорцій на основі реальних цифр полотна
    double maxDim = math.max(canvasWidth, canvasHeight);
    double scale = 160.0 / (maxDim > 0 ? maxDim : 1000.0);

    double cW = canvasWidth * scale;
    double cH = canvasHeight * scale;

    Rect doorRect = Rect.fromCenter(center: Offset(cx, cy), width: cW, height: cH);
    canvas.drawRect(doorRect, paintCanvas);

    bool isRight = (openSide == 'Праве');
    double hingeX = isRight ? (cx + cW / 2) : (cx - cW / 2);
    
    for (int i = 0; i < hingeCount; i++) {
      double hY = cy + (i - (hingeCount - 1) / 2) * (cH / 3);
      canvas.drawCircle(Offset(hingeX, hY), 3.5, paintHardware);
    }

    double handleX = isRight ? (cx - cW / 3) : (cx + cW / 3);
    double handleY = cy;

    if (hasHandle) {
      canvas.drawCircle(Offset(handleX, handleY), 5.0, paintHardware);
    }
    if (hasLatch) {
      canvas.drawCircle(Offset(handleX, handleY + 22), 3.5, paintHole);
    }
    if (hasKey) {
      canvas.drawRect(Rect.fromCenter(center: Offset(handleX, handleY + 38), width: 4, height: 8), paintHole);
    }

    void drawDim(String text, double x, double y) {
      paintText.text = TextSpan(text: text, style: TextStyle(color: Colors.indigo.shade900, fontSize: 10, fontWeight: FontWeight.bold));
      paintText.layout();
      paintText.paint(canvas, Offset(x - paintText.width / 2, y - paintText.height / 2));
    }

    drawDim('Полотно: ${canvasWidth.toStringAsFixed(0)} x ${canvasHeight.toStringAsFixed(0)} мм', cx, cy + cH / 2 + 15);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Інтерактивний 3D проріз з пропорційним масштабуванням зверху/знизу/посередині
class Interactive3DOpeningPainter extends CustomPainter {
  final double opTop;
  final double opMid;
  final double opBot;
  final double opHLeft;
  final double opHRight;
  final double wallTop;
  final double wallBot;

  Interactive3DOpeningPainter({
    required this.opTop,
    required this.opMid,
    required this.opBot,
    required this.opHLeft,
    required this.opHRight,
    required this.wallTop,
    required this.wallBot,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintOpening = Paint()..color = Colors.indigo.shade700..style = PaintingStyle.stroke..strokeWidth = 2.5;
    final paintText = TextPainter(textDirection: TextDirection.ltr);

    double cx = size.width / 2;
    double cy = size.height / 2;

    // Пропорційне масштабування за шириною та висотою отвору
    double maxW = math.max(math.max(opTop, opMid), opBot);
    double maxH = math.max(opHLeft, opHRight);
    double scaleW = 140.0 / (maxW > 0 ? maxW : 900.0);
    double scaleH = 160.0 / (maxH > 0 ? maxH : 2100.0);

    double wTop = opTop * scaleW;
    double wMid = opMid * scaleW;
    double wBot = opBot * scaleW;
    double hLeft = opHLeft * scaleH;
    double hRight = opHRight * scaleH;

    // Формуємо нерівний контур отвору за введеними точними мірами
    Path openingPath = Path()
      ..moveTo(cx - wTop / 2, cy - hLeft / 2)
      ..lineTo(cx + wTop / 2, cy - hRight / 2)
      ..lineTo(cx + wBot / 2, cy + hRight / 2)
      ..lineTo(cx - wBot / 2, cy + hLeft / 2)
      ..close();

    canvas.drawPath(openingPath, paintOpening);

    // Додаємо лінійки та цифри показників
    void drawDim(String text, double x, double y) {
      paintText.text = TextSpan(text: text, style: TextStyle(color: Colors.blueGrey.shade900, fontSize: 9, fontWeight: FontWeight.bold));
      paintText.layout();
      paintText.paint(canvas, Offset(x - paintText.width / 2, y - paintText.height / 2));
    }

    drawDim('Зверху: ${opTop.toStringAsFixed(0)} мм', cx, cy - hLeft / 2 - 14);
    drawDim('Посер: ${opMid.toStringAsFixed(0)} мм', cx, cy);
    drawDim('Знизу: ${opBot.toStringAsFixed(0)} мм', cx, cy + hLeft / 2 + 14);
    
    drawDim('Ліва: ${opHLeft.toStringAsFixed(0)}', cx - maxW * scaleW / 2 - 35, cy);
    drawDim('Права: ${opHRight.toStringAsFixed(0)}', cx + maxW * scaleW / 2 + 35, cy);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
