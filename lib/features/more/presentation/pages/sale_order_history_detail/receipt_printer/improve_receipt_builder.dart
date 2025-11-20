import 'package:flutter/material.dart';
import 'thermal_printer.dart';

class ReceiptPrinterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receipt Printer Test',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: ReceiptPrinterScreen(),
    );
  }
}

class ReceiptPrinterScreen extends StatefulWidget {
  @override
  _ReceiptPrinterScreenState createState() => _ReceiptPrinterScreenState();
}

class _ReceiptPrinterScreenState extends State<ReceiptPrinterScreen> {
  List<PrinterDevice> printers = [];
  PrinterDevice? selectedPrinter;
  bool isConnected = false;
  bool isSearching = false;
  bool isPrinting = false;
  ConnectionType selectedType = ConnectionType.bluetooth;

  final TextEditingController ipController = TextEditingController();
  final TextEditingController portController = TextEditingController(
    text: '9100',
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    ipController.dispose();
    portController.dispose();
    super.dispose();
  }

  Future<void> searchPrinters() async {
    setState(() {
      isSearching = true;
      printers.clear();
    });

    try {
      if (selectedType == ConnectionType.network) {
        showSnackBar('Enter IP address for network printer', Colors.orange);
        setState(() => isSearching = false);
        return;
      }

      final foundPrinters = await ThermalPrinter.discoverPrinters(
        type: selectedType,
      );

      setState(() {
        printers = foundPrinters;
        isSearching = false;
      });

      if (printers.isEmpty) {
        showSnackBar('No printers found', Colors.orange);
      } else {
        showSnackBar('Found ${printers.length} printer(s)', Colors.green);
      }
    } catch (e) {
      setState(() => isSearching = false);
      showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> connectToPrinter(PrinterDevice device) async {
    try {
      showSnackBar('Connecting to ${device.name}...', Colors.blue);

      final connected = await ThermalPrinter.connect(device);

      setState(() {
        isConnected = connected;
        if (connected) selectedPrinter = device;
      });

      if (connected) {
        showSnackBar('✓ Connected to ${device.name}', Colors.green);
      } else {
        showSnackBar('Failed to connect', Colors.red);
      }
    } catch (e) {
      showSnackBar('Connection error: $e', Colors.red);
    }
  }

  Future<void> connectNetworkPrinter() async {
    try {
      final ip = ipController.text.trim();
      final port = int.tryParse(portController.text) ?? 9100;

      if (ip.isEmpty) {
        showSnackBar('Please enter IP address', Colors.orange);
        return;
      }

      showSnackBar('Connecting to $ip:$port...', Colors.blue);

      final connected = await ThermalPrinter.connectNetwork(ip, port: port);

      setState(() {
        isConnected = connected;
        if (connected) {
          selectedPrinter = PrinterDevice(
            name: 'Network Printer',
            address: '$ip:$port',
            type: ConnectionType.network,
          );
        }
      });

      if (connected) {
        showSnackBar('✓ Connected to $ip:$port', Colors.green);
      } else {
        showSnackBar('Failed to connect', Colors.red);
      }
    } catch (e) {
      showSnackBar('Connection error: $e', Colors.red);
    }
  }

  Future<void> disconnectPrinter() async {
    try {
      await ThermalPrinter.disconnect();
      setState(() {
        isConnected = false;
        selectedPrinter = null;
      });
      showSnackBar('Disconnected', Colors.grey);
    } catch (e) {
      showSnackBar('Disconnect error: $e', Colors.red);
    }
  }

  // RECEIPT PRINTING FUNCTIONS

  Future<void> printSimpleReceipt() async {
    if (!isConnected) {
      showSnackBar('Please connect to a printer first', Colors.orange);
      return;
    }

    setState(() => isPrinting = true);

    try {
      await ThermalPrinter.printText(
        '================================',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        '        SIMPLE RECEIPT',
        fontSize: 24,
        bold: true,
      );
      await ThermalPrinter.printText(
        '================================',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        'Date: ${DateTime.now().toString().substring(0, 19)}',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        '--------------------------------',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        'Item 1: Coffee          \$3.50',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        'Item 2: Sandwich        \$7.00',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        'Item 3: Cookie          \$2.50',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        '--------------------------------',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        'TOTAL:                 \$13.00',
        fontSize: 28,
        bold: true,
      );
      await ThermalPrinter.printText(
        '================================',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        '       Thank you!',
        fontSize: 24,
        bold: true,
      );
      await ThermalPrinter.feedPaper(3);
      await ThermalPrinter.cutPaper();

      showSnackBar('✓ Simple receipt printed', Colors.green);
    } catch (e) {
      showSnackBar('Print error: $e', Colors.red);
    } finally {
      setState(() => isPrinting = false);
    }
  }

  Future<void> printDetailedReceipt() async {
    if (!isConnected) {
      showSnackBar('Please connect to a printer first', Colors.orange);
      return;
    }

    setState(() => isPrinting = true);

    try {
      // Header
      await ThermalPrinter.printText(
        '================================',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        '    MY COFFEE SHOP',
        fontSize: 32,
        bold: true,
      );
      await ThermalPrinter.printText('   123 Main Street', fontSize: 20);
      await ThermalPrinter.printText('   Tel: (555) 123-4567', fontSize: 20);
      await ThermalPrinter.printText(
        '================================',
        fontSize: 20,
      );
      await ThermalPrinter.printText('', fontSize: 20);

      // Date and Receipt Number
      final now = DateTime.now();
      await ThermalPrinter.printText(
        'Receipt #: 000${now.millisecond}',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        'Date: ${now.day}/${now.month}/${now.year}',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        'Time: ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
        fontSize: 20,
      );
      await ThermalPrinter.printText('Cashier: John Doe', fontSize: 20);
      await ThermalPrinter.printText('', fontSize: 20);
      await ThermalPrinter.printText(
        '--------------------------------',
        fontSize: 20,
      );

      // Items
      await ThermalPrinter.printText('ITEMS:', fontSize: 24, bold: true);
      await ThermalPrinter.printText('', fontSize: 20);

      await ThermalPrinter.printText('1x Espresso', fontSize: 22, bold: true);
      await ThermalPrinter.printText(
        '   Regular size           \$3.50',
        fontSize: 20,
      );
      await ThermalPrinter.printText('', fontSize: 20);

      await ThermalPrinter.printText('2x Cappuccino', fontSize: 22, bold: true);
      await ThermalPrinter.printText(
        '   Large size      @\$5.00 \$10.00',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        '   Extra shot              \$0.50',
        fontSize: 20,
      );
      await ThermalPrinter.printText('', fontSize: 20);

      await ThermalPrinter.printText('1x Croissant', fontSize: 22, bold: true);
      await ThermalPrinter.printText(
        '   Fresh baked             \$4.00',
        fontSize: 20,
      );
      await ThermalPrinter.printText('', fontSize: 20);

      await ThermalPrinter.printText(
        '1x Chocolate Muffin',
        fontSize: 22,
        bold: true,
      );
      await ThermalPrinter.printText(
        '   With chocolate chips    \$3.50',
        fontSize: 20,
      );
      await ThermalPrinter.printText('', fontSize: 20);

      // Totals
      await ThermalPrinter.printText(
        '--------------------------------',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        'Subtotal:              \$21.50',
        fontSize: 22,
      );
      await ThermalPrinter.printText(
        'Tax (10%):              \$2.15',
        fontSize: 22,
      );
      await ThermalPrinter.printText(
        '================================',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        'TOTAL:                 \$23.65',
        fontSize: 32,
        bold: true,
      );
      await ThermalPrinter.printText(
        '================================',
        fontSize: 20,
      );
      await ThermalPrinter.printText('', fontSize: 20);

      // Payment
      await ThermalPrinter.printText(
        'Payment Method: VISA **** 1234',
        fontSize: 20,
      );
      await ThermalPrinter.printText('Approval Code: 987654', fontSize: 20);
      await ThermalPrinter.printText('', fontSize: 20);

      // Footer
      await ThermalPrinter.printText(
        '--------------------------------',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        '   Thank you for your visit!',
        fontSize: 24,
        bold: true,
      );
      await ThermalPrinter.printText('  Please come again soon!', fontSize: 20);
      await ThermalPrinter.printText('', fontSize: 20);
      await ThermalPrinter.printText('   Save 10% on your next', fontSize: 20);
      await ThermalPrinter.printText('   purchase with code:', fontSize: 20);
      await ThermalPrinter.printText(
        '      COFFEE10',
        fontSize: 28,
        bold: true,
      );
      await ThermalPrinter.printText(
        '================================',
        fontSize: 20,
      );

      await ThermalPrinter.feedPaper(4);
      await ThermalPrinter.cutPaper();

      showSnackBar('✓ Detailed receipt printed', Colors.green);
    } catch (e) {
      showSnackBar('Print error: $e', Colors.red);
    } finally {
      setState(() => isPrinting = false);
    }
  }

  Future<void> printRestaurantReceipt() async {
    if (!isConnected) {
      showSnackBar('Please connect to a printer first', Colors.orange);
      return;
    }

    setState(() => isPrinting = true);

    try {
      // Header
      await ThermalPrinter.printText(
        '================================',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        '     RESTAURANT DELUXE',
        fontSize: 32,
        bold: true,
      );
      await ThermalPrinter.printText('   456 Restaurant Ave', fontSize: 20);
      await ThermalPrinter.printText('   Tel: (555) 987-6543', fontSize: 20);
      await ThermalPrinter.printText(
        '================================',
        fontSize: 20,
      );
      await ThermalPrinter.printText('', fontSize: 20);

      final now = DateTime.now();
      await ThermalPrinter.printText('Table: 12      Guests: 4', fontSize: 20);
      await ThermalPrinter.printText('Server: Sarah M.', fontSize: 20);
      await ThermalPrinter.printText(
        'Date: ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        'Order #: R-${now.millisecond}',
        fontSize: 20,
      );
      await ThermalPrinter.printText('', fontSize: 20);
      await ThermalPrinter.printText(
        '--------------------------------',
        fontSize: 20,
      );

      // Menu Items
      await ThermalPrinter.printText('APPETIZERS:', fontSize: 24, bold: true);
      await ThermalPrinter.printText(
        '2x Caesar Salad    @12.99 \$25.98',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        '1x Soup of the Day         \$8.50',
        fontSize: 20,
      );
      await ThermalPrinter.printText('', fontSize: 20);

      await ThermalPrinter.printText('MAIN COURSES:', fontSize: 24, bold: true);
      await ThermalPrinter.printText(
        '2x Grilled Salmon  @28.99 \$57.98',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        '1x Ribeye Steak (Medium)  \$42.99',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        '1x Vegetarian Pasta       \$22.99',
        fontSize: 20,
      );
      await ThermalPrinter.printText('', fontSize: 20);

      await ThermalPrinter.printText('BEVERAGES:', fontSize: 24, bold: true);
      await ThermalPrinter.printText(
        '2x Red Wine        @12.00 \$24.00',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        '2x Sparkling Water  @4.00  \$8.00',
        fontSize: 20,
      );
      await ThermalPrinter.printText('', fontSize: 20);

      await ThermalPrinter.printText('DESSERTS:', fontSize: 24, bold: true);
      await ThermalPrinter.printText(
        '2x Chocolate Cake   @9.99 \$19.98',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        '1x Ice Cream               \$6.99',
        fontSize: 20,
      );
      await ThermalPrinter.printText('', fontSize: 20);

      // Totals
      await ThermalPrinter.printText(
        '--------------------------------',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        'Subtotal:             \$217.41',
        fontSize: 22,
      );
      await ThermalPrinter.printText(
        'Tax (8.5%):            \$18.48',
        fontSize: 22,
      );
      await ThermalPrinter.printText(
        '--------------------------------',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        'TOTAL:                \$235.89',
        fontSize: 32,
        bold: true,
      );
      await ThermalPrinter.printText(
        '================================',
        fontSize: 20,
      );
      await ThermalPrinter.printText('', fontSize: 20);

      // Tip suggestion
      await ThermalPrinter.printText(
        'SUGGESTED GRATUITY:',
        fontSize: 22,
        bold: true,
      );
      await ThermalPrinter.printText('15%: \$35.38', fontSize: 20);
      await ThermalPrinter.printText('18%: \$42.46', fontSize: 20);
      await ThermalPrinter.printText('20%: \$47.18', fontSize: 20);
      await ThermalPrinter.printText('', fontSize: 20);

      // Footer
      await ThermalPrinter.printText(
        '--------------------------------',
        fontSize: 20,
      );
      await ThermalPrinter.printText(
        '  Thank you for dining with us!',
        fontSize: 22,
        bold: true,
      );
      await ThermalPrinter.printText('', fontSize: 20);
      await ThermalPrinter.printText(
        'Follow us @RestaurantDeluxe',
        fontSize: 18,
      );
      await ThermalPrinter.printText('www.restaurantdeluxe.com', fontSize: 18);
      await ThermalPrinter.printText(
        '================================',
        fontSize: 20,
      );

      await ThermalPrinter.feedPaper(4);
      await ThermalPrinter.cutPaper();

      showSnackBar('✓ Restaurant receipt printed', Colors.green);
    } catch (e) {
      showSnackBar('Print error: $e', Colors.red);
    } finally {
      setState(() => isPrinting = false);
    }
  }

  Future<void> testPrinter() async {
    if (!isConnected) {
      showSnackBar('Please connect to a printer first', Colors.orange);
      return;
    }

    setState(() => isPrinting = true);

    try {
      await ThermalPrinter.printText(
        '==== PRINTER TEST ====',
        fontSize: 24,
        bold: true,
      );
      // await ThermalPrinter.printText('', fontSize: 20);
      // await ThermalPrinter.printText('Testing font sizes:', fontSize: 20);
      // await ThermalPrinter.printText('Size 12', fontSize: 12);
      // await ThermalPrinter.printText('Size 16', fontSize: 16);
      // await ThermalPrinter.printText('Size 20', fontSize: 20);
      // await ThermalPrinter.printText('Size 24', fontSize: 24);
      await ThermalPrinter.printText(
        'ស្វាគមន៍​មកកាន់--Normal text',
        fontSize: 32,
        bold: true,
      );
      // await ThermalPrinter.printText('', fontSize: 20);
      // await ThermalPrinter.printText('Normal text', fontSize: 20, bold: false);
      // await ThermalPrinter.printText('Bold text', fontSize: 20, bold: true);
      // await ThermalPrinter.printText('', fontSize: 20);
      await ThermalPrinter.printText(
        'Test completed!',
        fontSize: 24,
        bold: true,
      );
      await ThermalPrinter.feedPaper(3);

      showSnackBar('✓ Test print completed', Colors.green);
    } catch (e) {
      showSnackBar('Test error: $e', Colors.red);
    } finally {
      setState(() => isPrinting = false);
    }
  }

  void showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receipt Printer Test'),
        actions: [
          if (isConnected)
            IconButton(
              icon: Icon(Icons.power_settings_new),
              onPressed: disconnectPrinter,
              tooltip: 'Disconnect',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection Type Selector
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Type:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text('Bluetooth'),
                          selected: selectedType == ConnectionType.bluetooth,
                          onSelected: (selected) {
                            if (selected && !isConnected) {
                              setState(() {
                                selectedType = ConnectionType.bluetooth;
                                printers.clear();
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: Text('BLE'),
                          selected: selectedType == ConnectionType.ble,
                          onSelected: (selected) {
                            if (selected && !isConnected) {
                              setState(() {
                                selectedType = ConnectionType.ble;
                                printers.clear();
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: Text('USB'),
                          selected: selectedType == ConnectionType.usb,
                          onSelected: (selected) {
                            if (selected && !isConnected) {
                              setState(() {
                                selectedType = ConnectionType.usb;
                                printers.clear();
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: Text('Network'),
                          selected: selectedType == ConnectionType.network,
                          onSelected: (selected) {
                            if (selected && !isConnected) {
                              setState(() {
                                selectedType = ConnectionType.network;
                                printers.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Network Printer Input
            if (selectedType == ConnectionType.network && !isConnected)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        controller: ipController,
                        decoration: InputDecoration(
                          labelText: 'IP Address',
                          hintText: '192.168.1.100',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.wifi),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: portController,
                        decoration: InputDecoration(
                          labelText: 'Port',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.settings_ethernet),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: connectNetworkPrinter,
                        icon: Icon(Icons.link),
                        label: Text('Connect'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Search Button
            if (selectedType != ConnectionType.network && !isConnected)
              ElevatedButton.icon(
                onPressed: isSearching ? null : searchPrinters,
                icon: isSearching
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.search),
                label: Text(isSearching ? 'Searching...' : 'Search Printers'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),

            SizedBox(height: 16),

            // Connection Status
            if (isConnected)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 48),
                      SizedBox(height: 8),
                      Text(
                        'Connected',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        selectedPrinter?.name ?? 'Unknown Printer',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        selectedPrinter?.type
                                .toString()
                                .split('.')
                                .last
                                .toUpperCase() ??
                            '',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

            // Printer List
            if (printers.isNotEmpty && !isConnected)
              Card(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Found ${printers.length} printer(s)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Divider(height: 1),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: printers.length,
                      itemBuilder: (context, index) {
                        final printer = printers[index];
                        return ListTile(
                          leading: Icon(
                            printer.type == ConnectionType.bluetooth
                                ? Icons.bluetooth
                                : printer.type == ConnectionType.ble
                                ? Icons.bluetooth_searching
                                : Icons.usb,
                            color: Colors.blue,
                          ),
                          title: Text(printer.name),
                          subtitle: Text(printer.address),
                          trailing: ElevatedButton(
                            onPressed: () => connectToPrinter(printer),
                            child: Text('Connect'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

            // Print Buttons
            if (isConnected) ...[
              SizedBox(height: 16),
              Text(
                'Test Receipts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: isPrinting ? null : testPrinter,
                icon: Icon(Icons.print),
                label: Text('Test Print'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),

              SizedBox(height: 8),

              ElevatedButton.icon(
                onPressed: isPrinting ? null : printSimpleReceipt,
                icon: Icon(Icons.receipt),
                label: Text('Print Simple Receipt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),

              SizedBox(height: 8),

              ElevatedButton.icon(
                onPressed: isPrinting ? null : printDetailedReceipt,
                icon: Icon(Icons.receipt_long),
                label: Text('Print Coffee Shop Receipt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),

              SizedBox(height: 8),

              ElevatedButton.icon(
                onPressed: isPrinting ? null : printRestaurantReceipt,
                icon: Icon(Icons.restaurant),
                label: Text('Print Restaurant Receipt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),

              if (isPrinting) ...[
                SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Printing...'),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
