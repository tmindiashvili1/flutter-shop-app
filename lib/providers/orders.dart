import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    const url =
        'https://flutter-shop-6401f-default-rtdb.firebaseio.com/orders.json';

    final currentTime = DateTime.now();
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'amount': total,
          'dateTime': currentTime.toString(),
          'products': [
            ...cartProducts.map((cartItem) {
              return {
                'id': cartItem.id,
                'title': cartItem.title,
                'quantity': cartItem.quantity,
                'price': cartItem.price
              };
            })
          ]
        }),
      );

      _orders.insert(
          0,
          OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            dateTime: currentTime,
            products: cartProducts,
          ));
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> fetchAndSetOrders() async {
    const url =
        'https://flutter-shop-6401f-default-rtdb.firebaseio.com/orders.json';

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      List<OrderItem> loadedOrderItems = [];
      extractedData.forEach((prodItemId, prodData) {
        print(prodData);
        var products = loadedOrderItems.add(OrderItem(
          id: prodItemId.toString(),
          amount: prodData['amount'],
          dateTime: DateTime.parse(prodData['dateTime']),
          products: [
            ...prodData['products'].map((cartItem) {
              return CartItem(
                id: cartItem['id'],
                title: cartItem['title'],
                quantity: cartItem['quantity'],
                price: cartItem['price'],
              );
            })
          ],
        ));
      });
      _orders = loadedOrderItems;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
}
