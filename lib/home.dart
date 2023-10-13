// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'model/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // Personaliza el diseño de la tarjeta del producto aquí
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0), // Agrega espaciado vertical
        child: Column(
          children: [
            Align(
              alignment: Alignment.center, // Centra verticalmente la imagen
              child: Image.network(
                product.thumbnail,
                height: 120, // Ajusta la altura de la imagen según tus necesidades
                fit: BoxFit.cover, // Ajusta cómo se ajusta la imagen dentro del contenedor
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}', // Formatea el precio según tus necesidades
                    style: TextStyle(
                      color: Color.fromARGB(255, 21, 0, 255), // Puedes ajustar el color según tus necesidades
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TwoProductCardColumn extends StatelessWidget {
  final Product bottom;
  final Product? top;

  const TwoProductCardColumn({Key? key, required this.bottom, this.top}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Muestra el producto inferior
        // Puedes personalizar el diseño para incluir la imagen, nombre y precio
        ProductCard(product: bottom),

        if (top != null)
          SizedBox(height: 16.0),

        if (top != null)
          // Muestra el producto superior si existe
          // Puedes personalizar el diseño para incluir la imagen, nombre y precio
          ProductCard(product: top!),
      ],
    );
  }
}

class OneProductCardColumn extends StatelessWidget {
  final Product product;

  const OneProductCardColumn({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Muestra el producto
        // Puedes personalizar el diseño para incluir la imagen, nombre y precio
        ProductCard(product: product),
      ],
    );
  }
}




class AsymmetricView extends StatelessWidget {
  final List<Product> products;

  const AsymmetricView({Key? key, required this.products}) : super(key: key);

  List<Widget> _buildColumns(BuildContext context) {
    if (products.isEmpty) {
      return <Container>[];
    }

    return List.generate(_listItemCount(products.length), (int index) {
      double width = .59 * MediaQuery.of(context).size.width;
      Widget column;
      if (index % 2 == 0) {
        /// Even cases
        int bottom = _evenCasesIndex(index);
        column = TwoProductCardColumn(
          bottom: products[bottom],
          top: products.length - 1 >= bottom + 1
              ? products[bottom + 1]
              : null,
        );
        width += 32.0;
      } else {
        /// Odd cases
        column = OneProductCardColumn(
          product: products[_oddCasesIndex(index)],
        );
      }
      return SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: column,
        ),
      );
    }).toList();
  }

  int _evenCasesIndex(int input) {
    return input ~/ 2 * 3;
  }

  int _oddCasesIndex(int input) {
    assert(input > 0);
    return (input / 2).ceil() * 3 - 1;
  }

  int _listItemCount(int totalItems) {
    if (totalItems % 3 == 0) {
      return totalItems ~/ 3 * 2;
    } else {
      return (totalItems / 3).ceil() * 2 - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(0.0, 34.0, 16.0, 44.0),
      children: _buildColumns(context),
    );
  }
}



class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> products = [];

  Future<void> _loadProducts() async {
  final response = await http.get(Uri.parse('https://dummyjson.com/products'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);

    if (jsonData.containsKey("products")) {
      final List<dynamic> productList = jsonData["products"];

      setState(() {
        products = productList.map((data) => Product.fromJson(data)).toList();
      });
    } else {
      throw Exception('La respuesta JSON no contiene la clave "products"');
    }
  } else {
    throw Exception('No se pudo cargar la lista de productos');
  }
}


  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            semanticLabel: 'menu',
          ),
          onPressed: () {},
        ),
        title: const Text('SHRINE'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.search,
              semanticLabel: 'search',
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.tune,
              semanticLabel: 'filter',
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: AsymmetricView(
        products: products,
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
