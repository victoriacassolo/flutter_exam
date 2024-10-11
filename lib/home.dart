import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<dynamic> _data = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.14.6.119:5000/movies'));

      if (response.statusCode == 200) {
        List<dynamic> movies = json.decode(response.body);
        setState(() {
          _data = movies;
          _isLoading = false;
        });
      } else {
        _handleError('Erro ao carregar dados: ${response.statusCode}');
      }
    } catch (e) {
      _handleError('Erro: $e');
    } finally {
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleError(String message) {
    setState(() {
      _isLoading = false;
    });
    print(message);
  }

  void _addData(String nome, int nota) {
    setState(() {
      _data.add({'nome': nome, 'nota': nota});
    });
  }

  void _showAddDialog() {
    String nome = '';
    String nota = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Informação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Nome'),
                onChanged: (value) {
                  nome = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Nota'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  nota = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (nome.isNotEmpty && nota.isNotEmpty) {
                  _addData(nome, int.parse(nota));
                  Navigator.of(context).pop();
                }
              },
              child: Text('Adicionar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filmes'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_data[index]['nome']),
                  subtitle: Text(_data[index]['nota'].toString()),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.blue, // Cor do botão
        child: Icon(Icons.add), // Ícone do botão
      ),
    );
  }
}
