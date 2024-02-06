import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Produtos App',
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final String username = _usernameController.text;
      final String password = _passwordController.text;

      try {
        final response = await http.post(
    Uri.parse('http://localhost/login'),
  headers: {
      'Authorization': 'Bearer tokenacess',
    'Content-Type': 'application/json'
    },  
  body: json.encode({
    'usuario': username,
    'senha': password,
  }),
);


        if (response.statusCode == 200) {
          final dynamic responseData = json.decode(response.body);

          if (responseData['status'] == 'success') {
            Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => HomeScreen(token: 'Bearer tokenacess'),
  ),
);

          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Login Failed'),
                  content: Text('Invalid username or password.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else {
          print('Server error: ${response.statusCode}');
        }
      } catch (e) {
        print('Error during login: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username is required';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Username',
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  _handleLogin();
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
    final String token;
  HomeScreen({required this.token});
  
   void _handleLogout(BuildContext context) {
   
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF33333),
        leading: Image.asset('assets/logo.png', height: 40, width: 40),
        title: Text(
          'Emp',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Consultar Produtos') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductSearch(token: token)),
                );
              } else if (value == 'Consultar Clientes') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClienteSearch(token: token)),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'Consultar Produtos',
                child: Text('Consultar Produtos'),
              ),
              PopupMenuItem<String>(
                value: 'Consultar Clientes',
                child: Text('Consultar Clientes'),
              ),
              PopupMenuItem<String>(
                value: 'Logout',
                child: Text('Logout'),
                 onTap: () {
                _handleLogout(context);
              },
              ),
            ],
          ),
        ],
      ),
      body: Container(
        color: Color(0xFF333333),
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              
            ],
          ),
        ),
      ),
    );
  }
}

class ProductSearch extends StatefulWidget {
    final String token;
      ProductSearch({required this.token});
  @override
  _ProductSearchState createState() => _ProductSearchState();
}

class _ProductSearchState extends State<ProductSearch> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> products = [];
  bool isLoading = false;

  Future<void> fetchData(String productName) async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        Uri.parse('http://localhost/produtos?nompro=$productName'),
         headers: {
          'Authorization': 'Bearer tokenacess',
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData is List<dynamic>) {
          setState(() {
            products = responseData;
            isLoading = false;
          });
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
        products = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF33333),
        title: Text(
          'Consultar Produto',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        color: Color(0xFF333333),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9 ]')),
                UpperCaseTextFormatter(),
              ],
              style: TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                labelText: 'Digite o nome do produto',
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                fetchData(_searchController.text);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
              ),
              child: Text(
                'Consultar',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            if (isLoading)
              CircularProgressIndicator()
            else if (products.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(products[index]['nompro']),
                        subtitle: Text('Preço: ${products[index]['pvenda']}'),
                      ),
                    );
                  },
                ),
              )
            else
              Text(
                'Nenhum produto encontrado',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text?.toUpperCase() ?? '';
    
    return TextEditingValue(
      text: newText,
      selection: newValue.selection,
    );
  }
}

class ClienteSearch extends StatefulWidget {
    final String token;
  ClienteSearch({required this.token});

  @override
  _ClienteSearchState createState() => _ClienteSearchState();
}

class _ClienteSearchState extends State<ClienteSearch> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> clientes = [];
  bool isLoading = false;

  Future<void> fetchData(String clienteName) async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        Uri.parse('http://localhost/clientes?nomcli=$clienteName'),
        headers: {
          'Authorization': '${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData is List<dynamic>) {
          setState(() {
            clientes = responseData;
            isLoading = false;
          });
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
        clientes = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF33333),
        title: Text(
          'Consultar Cliente',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        color: Color(0xFF333333),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9 ]')),
                UpperCaseTextFormatter(),
              ],
              style: TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                labelText: 'Digite o nome do cliente',
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                fetchData(_searchController.text);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
              ),
              child: Text(
                'Consultar',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            if (isLoading)
              CircularProgressIndicator()
            else if (clientes.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: clientes.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text('Nome: ${clientes[index]['nomcli']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CPF / CNPJ: ${clientes[index]['cpf_cnpj']}'),
                            Text('Logradouro: ${clientes[index]['logradouro']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Text(
                'Nenhum cliente encontrado',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}