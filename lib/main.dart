import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' as vmath;

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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFC8A278),
          primary: Color(0xFF8D6E63),
          secondary: Color(0xFFD7CCC8),
          surface: Color(0xFFFAF7F2),
        ),
        scaffoldBackgroundColor: Color(0xFFF7F4EF),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF8D6E63),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: Color(0xFFFFFFFF),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFFFFDF9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFD7CCC8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFD7CCC8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF8D6E63), width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF8D6E63),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
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
        title: Text('Каталог Замовлень', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          List doorsList = order['doors'];
          double orderTotal = doorsList.fold(0, (sum, d) => sum + (d['basePrice'] + d['extraPrice']));

          return Container(
            margin: EdgeInsets.symmetric(vertical: 6),
            child: Card(
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Color(0xFFD7CCC8),
                  child: Icon(Icons.folder_open, color: Color(0xFF5D4037)),
                ),
                title: Text('${order['orderNumber']} — ${order['clientName']}', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                subtitle: Text('Адреса: ${order['address']}\nДверей: ${doorsList.length} | Сума: ${orderTotal.toStringAsFixed(0)} грн', style: TextStyle(color: Color(0xFF6D4C41))),
                isThreeLine: true,
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF8D6E63)),
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
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF8D6E63),
        foregroundColor: Colors.white,
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
        'doborWidth': 70.0,
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
            child: Text('Копіювати текст', style: TextStyle(color: Color(0xFF8D6E63))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрити', style: TextStyle(color: Colors.grey)),
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
        title: Text('Проєкт: ${widget.orderData['orderNumber']}'),
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded),
            tooltip: 'Експорт у Word',
            onPressed: _exportToWordDialog,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                '${totalProjectPrice.toStringAsFixed(0)} грн',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD7CCC8)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Color(0xFFEFEBE9),
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
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: doorsList.length,
              itemBuilder: (context, index) {
                final door = doorsList[index];
                double doorTotal = (door['basePrice'] as double) + (door['extraPrice'] as double);
                
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Color(0xFFD7CCC8),
                      child: Icon(Icons.door_sliding_rounded, color: Color(0xFF5D4037)),
                    ),
                    title: Text(door['name'], style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                    subtitle: Text(
                      'Полотно: ${door['canvasWidth']}x${door['canvasHeight']} мм | Лиштва: ${door['architraveSize']}\nМонтаж: ${doorTotal.toStringAsFixed(0)} грн',
                      style: TextStyle(color: Color(0xFF6D4C41)),
                    ),
                    isThreeLine: true,
                    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF8D6E63)),
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
        backgroundColor: Color(0xFF8D6E63),
        foregroundColor: Colors.white,
        onPressed: _addNewDoor,
        child: Icon(Icons.add),
        tooltip: 'Додати двері в замовлення',
      ),
    );
  }
}

// 3. Екран редагування з 3 вкладками
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

  double _rotateX = 0.0;
  double _rotateY = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

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
    double doborW = double.tryParse(_doborWidthController.text) ?? 70;
    int hCount = int.tryParse(_hingeCount) ?? 3;

    double avgHeight = (opHLeft + opHRight) / 2;
    double avgWidth = (opTop + opMid + opBot) / 3;
    double avgWall = (wallTop + wallBot) / 2;

    double boxMeters = (avgHeight * 2 + avgWidth) / 1000 * 1.1;
    double architravePieces = 6.0;
    bool needsDobor = avgWall > 90.0;
    double doborMeters = needsDobor ? (avgHeight * 2 + avgWidth) / 1000 * 1.1 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Конфігурація Дверей'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Color(0xFFD7CCC8),
          labelColor: Colors.white,
          unselectedLabelColor: Color(0xFFD7CCC8),
          tabs: [
            Tab(text: '3D Полотно', icon: Icon(Icons.door_sliding_rounded)),
            Tab(text: '3D Проріз', icon: Icon(Icons.architecture_rounded)),
            Tab(text: 'Калькулятор', icon: Icon(Icons.calculate_rounded)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save_rounded),
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
  
